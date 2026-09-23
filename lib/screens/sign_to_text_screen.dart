import 'dart:math' show sqrt;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/arabic_sign_alphabet.dart';
import '../core/sign_detection_stabilizer.dart';
import '../services/classifier_service.dart';
import '../services/tts_service.dart';
import '../design/app_colors.dart';
import '../design/app_radius.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';
import '../design/components/app_components.dart';
import '../l10n/generated/app_localizations.dart';

/// Staged initialization lifecycle; each stage is failure-safe and any
/// failure lands in [failed] with a working retry.
enum _InitStage { idle, loadingModel, initializingDetector, initializingCamera, ready, failed }

/// Sign -> Text screen.
///
/// The camera setup, MediaPipe detection and classifier pipeline run through
/// a staged, retry-safe initialization; recognition is temporally
/// stabilized and confidence-gated before it can be added to the sentence.
class SignToTextScreen extends StatefulWidget {
  const SignToTextScreen({super.key});
  @override
  State<SignToTextScreen> createState() => _SignToTextScreenState();
}

class _SignToTextScreenState extends State<SignToTextScreen> {
  /// Minimum gap between inference passes (~15 fps). The hand detector and
  /// classifier are synchronous, so this keeps the UI thread responsive.
  static const Duration _minInferenceInterval = Duration(milliseconds: 66);

  /// Hands-free auto-capture: steady hold duration required before auto-capturing a letter.
  static const Duration _autoCaptureHoldDuration = Duration(milliseconds: 850);

  /// Hands-free auto-space: duration of hand absence required before inserting a space.
  static const Duration _autoSpaceSilenceDuration = Duration(milliseconds: 1400);

  /// Normalized-coordinate delta below which the landmark overlay is not
  /// considered changed, letting steady-hand frames skip rebuilds entirely.
  static const double _overlayEpsilon = 0.0025;

  /// MediaPipe hand topology.
  static const int _landmarkCount = 21;
  static const int _coordinatesPerLandmark = 3;

  /// hand_landmarker returns landmarks in the camera sensor's native
  /// coordinate space, which is rotated relative to the device portrait
  /// frame. For a back camera with sensorOrientation = 90 (most Android
  /// devices), the sensor x-axis points downward and the sensor y-axis
  /// points left. The classifier was trained on upright portrait landmarks
  /// (x = right, y = down), so before we feed landmarks into the classifier
  /// — and before we draw the overlay — we must rotate them back:
  ///   x_portrait = 1 − y_sensor
  ///   y_portrait = x_sensor
  ///
  /// This 90° rotation applies for sensorOrientation = 90. We store the
  /// sensor orientation at camera-init time and use it at inference time.
  int _sensorOrientation = 90;

  CameraController? _cameraController;
  HandLandmarkerPlugin? _handLandmarker;
  final ClassifierService _classifier = ClassifierService();
  final SignDetectionStabilizer _stabilizer = SignDetectionStabilizer();

  _InitStage _initStage = _InitStage.idle;
  bool _permissionDenied = false;
  bool _isProcessing = false;

  /// Canonical sentence as an ordered token list: Arabic vocabulary tokens
  /// (compound tokens stay atomic, e.g. 'لا') plus single ' ' entries for
  /// explicitly inserted word boundaries. The displayed sentence String is
  /// derived from this only when it changes; camera frames never touch it.
  final List<String> _sentenceTokens = <String>[];

  /// Stabilized, confidence-accepted letter; the only value the UI presents
  /// or adds to the sentence.
  String _stableDetectedSign = '';

  /// Real model confidence behind [_stableDetectedSign]; 0 when none.
  double _stableConfidence = 0;
  List<Offset> _landmarkPoints = const <Offset>[];

  /// Hands-Free auto-capture mode flag.
  bool _autoCaptureEnabled = true;

  /// Tracking state for Hands-Free hold-to-capture.
  DateTime? _signHoldStartTime;
  String? _holdingSign;
  double _holdProgress = 0.0;
  String? _lastAutoCapturedToken;
  bool _isCapturedFlash = false;

  /// Tracking state for Hands-Free auto-space insertion.
  DateTime? _noHandStartTime;
  bool _autoSpaceTriggered = false;

  DateTime _lastInferenceAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Guards against overlapping setup attempts (e.g. double-tapped retry);
  /// a superseded attempt exits without touching shared resources.
  int _setupGeneration = 0;

  /// Reused per-frame classifier input buffer (no reallocation in the hot
  /// path); filled with 21 landmarks × (x, y, z).
  final List<double> _classifyInput =
      List<double>.filled(_landmarkCount * _coordinatesPerLandmark, 0.0);

  // --- TEMPORARY F-08 diagnostics (remove after the mirror/normalization
  // --- experiment concludes; never feeds UI or acceptance state).
  static const Duration _diagnosticInterval = Duration(milliseconds: 450);
  DateTime _lastDiagnosticAt = DateTime.fromMillisecondsSinceEpoch(0);
  final List<double> _diagCurrentOut = List<double>.filled(
    ArabicSignAlphabet.classCount,
    0.0,
  );
  final List<double> _diagMirroredOut = List<double>.filled(
    ArabicSignAlphabet.classCount,
    0.0,
  );
  final List<double> _diagNormalizedOut = List<double>.filled(
    ArabicSignAlphabet.classCount,
    0.0,
  );

  @override
  void initState() {
    super.initState();
    _setupEverything();
  }

  Future<void> _setupEverything() async {
    final int generation = ++_setupGeneration;
    // اطلب إذن الكاميرا أولاً
    final status = await Permission.camera.request();
    if (generation != _setupGeneration || !mounted) return;
    if (!status.isGranted) {
      setState(() {
        _permissionDenied = true;
        _initStage = _InitStage.failed;
      });
      return;
    }
    setState(() => _permissionDenied = false);

    // Tear down anything left over from a previous attempt so retry can
    // never stack controllers, streams or detectors.
    await _teardownPipeline();
    if (generation != _setupGeneration) return;

    if (!await _runStage(
      _InitStage.loadingModel,
      () => _classifier.loadModel(),
      generation,
    )) {
      return;
    }
    if (!await _runStage(_InitStage.initializingDetector, () async {
      _handLandmarker = HandLandmarkerPlugin.create(
        numHands: 1,
        minHandDetectionConfidence: 0.5,
        delegate: HandLandmarkerDelegate.cpu,
      );
    }, generation)) {
      return;
    }
    if (!await _runStage(
      _InitStage.initializingCamera,
      _createAndStartCamera,
      generation,
    )) {
      return;
    }

    if (generation == _setupGeneration && mounted) {
      setState(() => _initStage = _InitStage.ready);
    }
  }

  /// Runs one init stage; on failure disposes partial work and surfaces
  /// [ErrorState] instead of hanging in loading. Returns false on failure or
  /// when superseded by a newer attempt (which then owns the UI).
  Future<bool> _runStage(
    _InitStage stage,
    Future<void> Function() action,
    int generation,
  ) async {
    if (mounted) setState(() => _initStage = stage);
    try {
      await action();
    } catch (e) {
      debugPrint('Initialization failed at $stage: $e');
      if (generation == _setupGeneration) {
        await _teardownPipeline();
        if (mounted) setState(() => _initStage = _InitStage.failed);
      }
      return false;
    }
    return generation == _setupGeneration;
  }

  Future<void> _createAndStartCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('No cameras available');
    }
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    // Capture sensor orientation so _processFrame can apply the correct
    // landmark coordinate rotation.
    _sensorOrientation = camera.sensorOrientation;

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // أضمن للتوافق
    );
    // Assign before awaiting so a failed initialize() can still be torn down.
    _cameraController = controller;
    try {
      await controller.initialize();
      await controller.startImageStream(_processFrame);
    } catch (_) {
      if (identical(_cameraController, controller)) {
        _cameraController = null;
      }
      try {
        await controller.dispose();
      } catch (_) {
        // Already disposed by a newer attempt; nothing to do.
      }
      rethrow;
    }
  }

  /// Idempotent cleanup of every owned pipeline resource.
  Future<void> _teardownPipeline() async {
    final controller = _cameraController;
    _cameraController = null;
    if (controller != null) {
      try {
        await controller.stopImageStream();
      } catch (_) {
        // Not streaming; nothing to do.
      }
      await controller.dispose();
    }
    _handLandmarker?.dispose();
    _handLandmarker = null;
    _stabilizer.reset();
    if (mounted) {
      setState(() {
        _stableDetectedSign = '';
        _stableConfidence = 0;
        _landmarkPoints = const <Offset>[];
      });
    } else {
      _stableDetectedSign = '';
      _stableConfidence = 0;
      _landmarkPoints = const <Offset>[];
    }
  }

  void _processFrame(CameraImage frame) {
    if (_isProcessing || _initStage != _InitStage.ready) return;
    final landmarker = _handLandmarker;
    final controller = _cameraController;
    if (landmarker == null || controller == null) return;

    final now = DateTime.now();
    if (now.difference(_lastInferenceAt) < _minInferenceInterval) return;
    _lastInferenceAt = now;
    _isProcessing = true;

    try {
      final hands = landmarker.detect(
        frame,
        controller.description.sensorOrientation,
      );

      FrameClassification? classification;
      List<Offset> points = const <Offset>[];
      if (hands.isNotEmpty) {
        final landmarks = hands.first.landmarks;
        final count =
            landmarks.length < _landmarkCount ? landmarks.length : _landmarkCount;
        for (var i = 0; i < count; i++) {
          final point = landmarks[i];
          // Apply coordinate rotation to convert from sensor space to upright
          // portrait space. For sensorOrientation = 90 (typical Android back
          // camera): x_portrait = 1 − y_sensor, y_portrait = x_sensor.
          // For sensorOrientation = 270 (some front cameras when remapped to
          // back logic): x_portrait = y_sensor, y_portrait = 1 − x_sensor.
          final double lx, ly;
          if (_sensorOrientation == 270) {
            lx = point.y;
            ly = 1.0 - point.x;
          } else {
            // Default: 90° (and 0°/180° fall back to raw for robustness).
            lx = 1.0 - point.y;
            ly = point.x;
          }
          _classifyInput[i * 3] = lx;
          _classifyInput[i * 3 + 1] = ly;
          _classifyInput[i * 3 + 2] = point.z;
        }
        // Build overlay points using the same rotated coordinates so the
        // landmark skeleton aligns with the visible hand in the preview.
        points = <Offset>[
          for (final point in landmarks)
            _sensorOrientation == 270
                ? Offset(point.y, 1.0 - point.x)
                : Offset(1.0 - point.y, point.x),
        ];
        classification = _classifier.classify(
          _classifyInput,
          debugOutputs: kDebugMode ? _diagCurrentOut : null,
        );
      }

      if (classification != null) {
        _logRecognitionDiagnostics();
      }
      _applyDetection(classification, points);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Stabilizes the raw frame result and rebuilds only when something
  /// meaningfully changed: the accepted letter, visible landmarks, or hold progress.
  void _applyDetection(
    FrameClassification? classification,
    List<Offset> points,
  ) {
    final String? stable = _stabilizer.update(
      classification?.token,
      classification?.confidence ?? 0,
    );

    final bool signChanged = stable != _stableDetectedSign;
    final bool overlayChanged = !_nearlySame(points, _landmarkPoints);
    bool stateNeedsRebuild = signChanged || overlayChanged;

    // Edge-triggered bring-up logging: fires only when the accepted letter
    // changes (including losing one), never per frame.
    if (kDebugMode && signChanged) {
      debugPrint(
        'Recognition: ${stable ?? "—"} '
        '(was: ${_stableDetectedSign.isEmpty ? "—" : _stableDetectedSign})',
      );
    }

    // Hands-Free Auto-Capture & Auto-Space tracking
    if (_autoCaptureEnabled) {
      final now = DateTime.now();

      if (stable != null && stable.isNotEmpty) {
        // Hand is producing a valid stable sign
        _noHandStartTime = null;
        _autoSpaceTriggered = false;

        if (stable != _holdingSign) {
          _holdingSign = stable;
          _signHoldStartTime = now;
          _holdProgress = 0.0;
          _isCapturedFlash = false;
          stateNeedsRebuild = true;
        } else {
          // Same sign is continuously being held
          if (_lastAutoCapturedToken == stable) {
            // Already captured this sign; maintain 1.0 progress without re-capturing
            if (_holdProgress != 1.0) {
              _holdProgress = 1.0;
              stateNeedsRebuild = true;
            }
          } else if (_signHoldStartTime != null) {
            final elapsed = now.difference(_signHoldStartTime!).inMilliseconds;
            final newProgress = (elapsed / _autoCaptureHoldDuration.inMilliseconds).clamp(0.0, 1.0);
            if ((newProgress - _holdProgress).abs() > 0.03 || newProgress >= 1.0) {
              _holdProgress = newProgress;
              stateNeedsRebuild = true;
            }

            if (newProgress >= 1.0) {
              // Auto-capture the letter!
              _sentenceTokens.add(stable);
              _lastAutoCapturedToken = stable;
              _isCapturedFlash = true;
              HapticFeedback.mediumImpact();
              stateNeedsRebuild = true;

              // Reset flash after brief celebratory glow
              Future.delayed(const Duration(milliseconds: 350), () {
                if (mounted && _isCapturedFlash) {
                  setState(() => _isCapturedFlash = false);
                }
              });
            }
          }
        }
      } else {
        // No stable sign detected
        if (_holdingSign != null || _holdProgress > 0) {
          _holdingSign = null;
          _signHoldStartTime = null;
          _holdProgress = 0.0;
          _isCapturedFlash = false;
          stateNeedsRebuild = true;
        }

        // Check for hand absence for Auto-Space
        if (points.isEmpty) {
          // Hand is away from camera
          _lastAutoCapturedToken = null;
          _noHandStartTime ??= now;

          if (!_autoSpaceTriggered && _canInsertSpace) {
            final noHandElapsed = now.difference(_noHandStartTime!).inMilliseconds;
            if (noHandElapsed >= _autoSpaceSilenceDuration.inMilliseconds) {
              _sentenceTokens.add(' ');
              _autoSpaceTriggered = true;
              HapticFeedback.lightImpact();
              stateNeedsRebuild = true;
            }
          }
        } else {
          // Hand is in view but moving / unsteady
          _noHandStartTime = null;
          _autoSpaceTriggered = false;
        }
      }
    }

    if (!stateNeedsRebuild || !mounted) return;

    setState(() {
      if (signChanged) {
        _stableDetectedSign = stable ?? '';
        _stableConfidence = stable == null ? 0 : classification!.confidence;
      }
      _landmarkPoints = points;
    });
  }

  bool _nearlySame(List<Offset> a, List<Offset> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if ((a[i].dx - b[i].dx).abs() > _overlayEpsilon ||
          (a[i].dy - b[i].dy).abs() > _overlayEpsilon) {
        return false;
      }
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // TEMPORARY F-08 recognition diagnostics — remove after the mirror /
  // normalization experiment concludes. Side computations only: the accepted
  // letter, stabilizer and UI always use the production representation.
  // ---------------------------------------------------------------------------

  /// Throttled to [_diagnosticInterval]: logs top-3 raw model outputs for
  /// (A) the production input, (B) an x-mirrored copy and (C) a
  /// wrist-centered + scale-normalized copy of the same frame.
  void _logRecognitionDiagnostics() {
    if (!kDebugMode) return;
    final now = DateTime.now();
    if (now.difference(_lastDiagnosticAt) < _diagnosticInterval) return;
    _lastDiagnosticAt = now;

    _classifier.classify(
      _mirroredLandmarks(_classifyInput),
      debugOutputs: _diagMirroredOut,
    );
    _classifier.classify(
      _normalizedLandmarks(_classifyInput),
      debugOutputs: _diagNormalizedOut,
    );

    debugPrint(
      'Diag Current    Top3: ${_top3(_diagCurrentOut)}\n'
      'Diag Mirrored   Top3: ${_top3(_diagMirroredOut)}\n'
      'Diag Normalized Top3: ${_top3(_diagNormalizedOut)}',
    );
  }

  String _top3(List<double> outputs) {
    final indices = List<int>.generate(outputs.length, (int i) => i)
      ..sort((int a, int b) => outputs[b].compareTo(outputs[a]));
    return indices
        .take(3)
        .map(
          (int i) =>
              '${ArabicSignAlphabet.tokenForClass(i).arabic}='
              '${outputs[i].toStringAsFixed(2)}',
        )
        .join(', ');
  }

  /// Mirror across the vertical axis: MediaPipe x lives in normalized image
  /// space, so x' = 1 - x. y/z untouched.
  List<double> _mirroredLandmarks(List<double> src) {
    final List<double> out = List<double>.of(src);
    for (var i = 0; i < out.length; i += _coordinatesPerLandmark) {
      out[i] = 1.0 - out[i];
    }
    return out;
  }

  /// Wrist-centered copy scaled by the largest planar wrist distance across
  /// landmarks; z is centered on the wrist and divided by the same scale.
  /// Degenerate frames are returned unchanged.
  List<double> _normalizedLandmarks(List<double> src) {
    final List<double> out = List<double>.of(src);
    const int stride = _coordinatesPerLandmark;
    final double wx = src[0], wy = src[1], wz = src[2];

    var scale = 0.0;
    for (var i = stride; i < src.length; i += stride) {
      final dx = src[i] - wx;
      final dy = src[i + 1] - wy;
      final d = sqrt(dx * dx + dy * dy);
      if (d > scale) scale = d;
    }
    if (scale <= 1e-6) return out;

    for (var j = 0; j < src.length; j += stride) {
      out[j] = (src[j] - wx) / scale;
      out[j + 1] = (src[j + 1] - wy) / scale;
      out[j + 2] = (src[j + 2] - wz) / scale;
    }
    return out;
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _teardownPipeline();
    _classifier.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Sentence state mutations — the ONLY writers of [_sentenceTokens].
  // Each fires setState only when an actual change occurs; camera frames
  // never reach this section.
  // ---------------------------------------------------------------------------

  /// Natural Arabic text; tokens join without separators so letters form
  /// words and explicit ' ' entries become real word boundaries.
  String get _sentence => _sentenceTokens.join();

  /// A word boundary is allowed only between content: never leading and
  /// never two spaces in a row.
  bool get _canInsertSpace =>
      _sentenceTokens.isNotEmpty && _sentenceTokens.last != ' ';

  /// Number of actual letters, excluding explicit word boundaries.
  int get _letterCount =>
      _sentenceTokens.where((String token) => token != ' ').length;

  void _acceptDetectedToken() {
    if (_stableDetectedSign.isEmpty) return;
    setState(() => _sentenceTokens.add(_stableDetectedSign));
  }

  void _insertWordBoundary() {
    if (!_canInsertSpace) return;
    setState(() => _sentenceTokens.add(' '));
  }

  /// Removes exactly one trailing token; because compound tokens are stored
  /// atomically this can never split e.g. 'لا', and a trailing space is
  /// simply the last element, so it goes first.
  void _deleteLastToken() {
    if (_sentenceTokens.isEmpty) return;
    setState(() => _sentenceTokens.removeLast());
  }

  void _speakSentence() {
    final String text = _sentence.trim();
    if (text.isEmpty) return;
    final String lang = Localizations.localeOf(context).languageCode;
    TtsService.instance.speak(text, languageCode: lang);
  }

  void _copySentence(AppLocalizations loc) {
    final String text = _sentence.trim();
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.sentenceCopied,
          style: AppTextStyles.bodyM.copyWith(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Presentation helpers (no business logic below this line)
  // ---------------------------------------------------------------------------

  Future<void> _confirmAndClear(AppLocalizations loc) async {
    final bool? confirmed = await ConfirmDialog.show(
      context,
      title: loc.clearSentenceTitle,
      description: loc.clearSentenceDescription,
      confirmLabel: loc.clear,
      cancelLabel: loc.cancel,
      destructive: true,
    );
    if (confirmed == true && mounted) {
      setState(_sentenceTokens.clear);
    }
  }

  Widget _header(ColorScheme scheme, AppLocalizations loc) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      children: [
        AppIconButton(
          icon: isRtl
              ? Icons.arrow_forward_ios_rounded
              : Icons.arrow_back_ios_new_rounded,
          tooltip: loc.backTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            loc.signToTextTitle,
            style:
                AppTextStyles.headlineM.copyWith(color: scheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _cameraLayer(ColorScheme scheme, AppLocalizations loc) {
    if (_permissionDenied) {
      return ErrorState(
        icon: Icons.photo_camera_outlined,
        title: loc.cameraPermissionTitle,
        description: loc.cameraPermissionDescription,
        retryLabel: loc.retry,
        onRetry: _setupEverything,
      );
    }
    switch (_initStage) {
      case _InitStage.failed:
        return ErrorState(
          icon: Icons.error_outline,
          title: loc.initFailedTitle,
          description: loc.initFailedDescription,
          retryLabel: loc.retry,
          onRetry: _setupEverything,
        );
      case _InitStage.ready:
        return CameraPreview(_cameraController!);
      default:
        return LoadingState(title: loc.initializingCameraAndModel);
    }
  }

  Widget _topOverlayBar(AppLocalizations loc, bool reducedMotion) {
    final (StatusPillState state, String message) =
        _stableDetectedSign.isNotEmpty
            ? (StatusPillState.detected, loc.handDetected)
            : (StatusPillState.searching, loc.pointHandAtFrame);

    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Detection Status Pill
            AnimatedSwitcher(
              duration: reducedMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              child: Semantics(
                // Announce detection-status changes automatically.
                liveRegion: true,
                child: StatusPill(
                  key: ValueKey<StatusPillState>(state),
                  state: state,
                  label: message,
                ),
              ),
            ),
            // Hands-Free Auto Flow Mode Toggle Pill
            Tooltip(
              message: loc.handsFreeModeTooltip,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _autoCaptureEnabled = !_autoCaptureEnabled;
                      _holdingSign = null;
                      _signHoldStartTime = null;
                      _holdProgress = 0.0;
                      _isCapturedFlash = false;
                    });
                  },
                  borderRadius: AppRadius.brStadium,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _autoCaptureEnabled
                          ? const Color(0xFF0D9488).withValues(alpha: 0.9)
                          : AppCameraColors.statusPillBackground,
                      borderRadius: AppRadius.brStadium,
                      border: Border.all(
                        color: _autoCaptureEnabled
                            ? const Color(0xFF2DD4BF)
                            : Colors.white24,
                        width: 1.2,
                      ),
                      boxShadow: _autoCaptureEnabled
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _autoCaptureEnabled
                              ? Icons.auto_awesome_rounded
                              : Icons.touch_app_rounded,
                          size: 16,
                          color: _autoCaptureEnabled
                              ? const Color(0xFF5EEAD4)
                              : Colors.white70,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          loc.handsFreeMode,
                          style: AppTextStyles.labelM.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultFocal(AppLocalizations loc, bool reducedMotion) {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: AnimatedSwitcher(
          duration: reducedMotion
              ? Duration.zero
              : const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: _stableDetectedSign.isEmpty
              ? Container(
                  key: const ValueKey<String>('empty'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: AppCameraColors.statusPillBackground,
                    borderRadius: AppRadius.brStadium,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.center_focus_weak,
                        size: 16,
                        color: AppColors.dark.primary,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        loc.noLetterYet,
                        style: AppTextStyles.labelL.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : ResultLetterTile(
                  key: ValueKey<String>(_stableDetectedSign),
                  letter: _stableDetectedSign,
                  // Real model confidence behind the accepted detection.
                  confidence:
                      _stableConfidence > 0 ? _stableConfidence : null,
                  holdProgress: _autoCaptureEnabled ? _holdProgress : 0.0,
                  isCaptured: _isCapturedFlash,
                  semanticLabel:
                      loc.detectedLetterLabel(_stableDetectedSign),
                ),
        ),
      ),
    );
  }

  Widget _cameraViewport(
    ColorScheme scheme,
    AppLocalizations loc,
    bool reducedMotion,
  ) {
    final bool live =
        _initStage == _InitStage.ready && !_permissionDenied;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Dark letterbox behind the preview, from the camera tokens.
        color: AppCameraColors.cameraScrim,
        borderRadius: AppRadius.brLarge,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _cameraLayer(scheme, loc),
          if (live) ...[
            HandGuideFrame(
              state: _stableDetectedSign.isNotEmpty
                  ? HandGuideState.detected
                  : HandGuideState.idle,
            ),
            LandmarkOverlay(points: _landmarkPoints),
            _topOverlayBar(loc, reducedMotion),
            _resultFocal(loc, reducedMotion),
          ],
        ],
      ),
    );
  }

  Widget _sentenceBar(ColorScheme scheme, AppLocalizations loc) {
    final List<String> tokens = _sentenceTokens;

    // Announce the sentence once as plain text instead of walking
    // every chip individually.
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: tokens.isEmpty ? loc.sentencePlaceholder : _sentence,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 64),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: AppRadius.brLarge,
          border: Border.all(color: scheme.outline),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.xs,
        ),
        child: tokens.isEmpty
            ? Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  loc.sentencePlaceholder,
                  style: AppTextStyles.caption
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < tokens.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.xs),
                      // Explicit word boundaries render as a small gap
                      // only; the canonical sentence string stays intact.
                      if (tokens[i] == ' ')
                        const SizedBox(width: AppSpacing.l)
                      else
                        LetterChip(
                          letter: tokens[i],
                          selected: i == tokens.length - 1,
                          semanticLabel: loc.letterChipLabel(tokens[i]),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _controls(ColorScheme scheme, AppLocalizations loc) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: AppButton.primary(
                label: loc.addLetter,
                icon: Icons.add_rounded,
                onPressed:
                    _stableDetectedSign.isEmpty ? null : _acceptDetectedToken,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              flex: 2,
              child: AppButton.tonal(
                label: loc.insertSpace,
                icon: Icons.space_bar_rounded,
                onPressed: _canInsertSpace ? _insertWordBoundary : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            // Voice Output (TTS) Button
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: TtsService.instance.isSpeaking,
                builder: (context, speaking, _) {
                  return ElevatedButton.icon(
                    onPressed: _sentenceTokens.isEmpty
                        ? null
                        : (speaking
                            ? TtsService.instance.stop
                            : _speakSentence),
                    icon: Icon(
                      speaking
                          ? Icons.stop_circle_rounded
                          : Icons.volume_up_rounded,
                      size: 20,
                      color: speaking
                          ? Colors.white
                          : (_sentenceTokens.isEmpty
                              ? scheme.onSurface.withValues(alpha: 0.38)
                              : Colors.white),
                    ),
                    label: Text(
                      speaking ? loc.speaking : loc.speakSentence,
                      style: AppTextStyles.labelL.copyWith(
                        color: speaking
                            ? Colors.white
                            : (_sentenceTokens.isEmpty
                                ? scheme.onSurface.withValues(alpha: 0.38)
                                : Colors.white),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: speaking
                          ? const Color(0xFFEF4444)
                          : (isDark
                              ? const Color(0xFF0D9488)
                              : const Color(0xFF0F766E)),
                      disabledBackgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.m,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: speaking ? 4 : 0,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            // Copy sentence button
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: isDark ? 0.3 : 0.6),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20),
                tooltip: loc.copySentence,
                color: scheme.onSurface,
                onPressed: _sentenceTokens.isEmpty ? null : () => _copySentence(loc),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // Backspace button
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: isDark ? 0.3 : 0.6),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.backspace_outlined, size: 20),
                tooltip: loc.deleteLastToken,
                color: scheme.onSurface,
                onPressed: _sentenceTokens.isEmpty ? null : _deleteLastToken,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // Clear sentence button
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: isDark ? 0.3 : 0.6),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: scheme.error,
                ),
                tooltip: loc.clear,
                onPressed:
                    _sentenceTokens.isEmpty ? null : () => _confirmAndClear(loc),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _controlPanel(
    ColorScheme scheme,
    AppLocalizations loc, {
    required bool scrollable,
  }) {
    final int letterCount = _letterCount;

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                loc.sentence,
                style: AppTextStyles.titleL
                    .copyWith(color: scheme.onSurface),
              ),
            ),
            Text(
              loc.letterCount(letterCount),
              style: AppTextStyles.caption
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        _sentenceBar(scheme, loc),
        const SizedBox(height: AppSpacing.l),
        _controls(scheme, loc),
      ],
    );

    if (scrollable) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: content,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations loc = AppLocalizations.of(context);
    final bool reducedMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 840;
            final double maxWidth = switch (constraints.maxWidth) {
              >= 840 => 1280,
              >= 600 => 680,
              _ => double.infinity,
            };

            final Widget content = wide
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.l),
                        child: _header(scheme, loc),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.l,
                            0,
                            AppSpacing.l,
                            AppSpacing.l,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _cameraViewport(
                                  scheme,
                                  loc,
                                  reducedMotion,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.l),
                              Expanded(
                                flex: 2,
                                child: _controlPanel(
                                  scheme,
                                  loc,
                                  scrollable: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.l,
                      AppSpacing.s,
                      AppSpacing.l,
                      AppSpacing.l,
                    ),
                    child: Column(
                      children: [
                        _header(scheme, loc),
                        const SizedBox(height: AppSpacing.m),
                        Expanded(
                          child: _cameraViewport(
                            scheme,
                            loc,
                            reducedMotion,
                          ),
                        ),
                        _controlPanel(
                          scheme,
                          loc,
                          scrollable: false,
                        ),
                      ],
                    ),
                  );

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }
}
