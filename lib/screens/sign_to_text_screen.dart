import 'dart:math' show sqrt;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/arabic_sign_alphabet.dart';
import '../core/sign_detection_stabilizer.dart';
import '../services/classifier_service.dart';
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

  /// Normalized-coordinate delta below which the landmark overlay is not
  /// considered changed, letting steady-hand frames skip rebuilds entirely.
  static const double _overlayEpsilon = 0.0025;

  /// MediaPipe hand topology.
  static const int _landmarkCount = 21;
  static const int _coordinatesPerLandmark = 3;

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
          _classifyInput[i * 3] = point.x;
          _classifyInput[i * 3 + 1] = point.y;
          _classifyInput[i * 3 + 2] = point.z;
        }
        points = <Offset>[
          for (final point in landmarks) Offset(point.x, point.y),
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
  /// meaningfully changed: the accepted letter or visible landmarks.
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

    // Edge-triggered bring-up logging: fires only when the accepted letter
    // changes (including losing one), never per frame.
    if (kDebugMode && signChanged) {
      debugPrint(
        'Recognition: ${stable ?? "—"} '
        '(was: ${_stableDetectedSign.isEmpty ? "—" : _stableDetectedSign})',
      );
    }

    if ((!signChanged && !overlayChanged) || !mounted) return;

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

  Widget _statusPill(AppLocalizations loc, bool reducedMotion) {
    final (StatusPillState state, String message) =
        _stableDetectedSign.isNotEmpty
            ? (StatusPillState.detected, loc.handDetected)
            : (StatusPillState.searching, loc.pointHandAtFrame);

    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: AnimatedSwitcher(
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
            _statusPill(loc, reducedMotion),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton.primary(
                label: loc.addLetter,
                icon: Icons.add,
                onPressed:
                    _stableDetectedSign.isEmpty ? null : _acceptDetectedToken,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: AppButton.outline(
                label: loc.clear,
                icon: Icons.delete_outline,
                onPressed:
                    _sentenceTokens.isEmpty ? null : () => _confirmAndClear(loc),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            Expanded(
              child: AppButton.tonal(
                label: loc.insertSpace,
                icon: Icons.space_bar,
                onPressed: _canInsertSpace ? _insertWordBoundary : null,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            AppIconButton(
              icon: Icons.backspace_outlined,
              tooltip: loc.deleteLastToken,
              onPressed:
                  _sentenceTokens.isEmpty ? null : _deleteLastToken,
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
