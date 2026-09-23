import 'package:flutter/material.dart';

import '../core/arabic_sign_alphabet.dart';
import '../services/tts_service.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';
import '../design/components/app_components.dart';
import '../l10n/generated/app_localizations.dart';

/// Text -> Sign screen.
///
/// Input is tokenized against the unified sign vocabulary (longest match),
/// and playback runs on a generation counter so leaving the screen or
/// re-entering can never leave a stale async loop calling setState.
class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({super.key});
  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen> {
  /// Per-letter display duration, unchanged from the original behavior.
  static const Duration _letterDuration = Duration(seconds: 2);

  final TextEditingController _controller = TextEditingController();
  int _currentIndex = 0;
  List<String> _letters = [];
  bool _playing = false;

  /// Incremented on every playback start and on dispose; an in-flight loop
  /// whose generation no longer matches must exit without touching state.
  int _playbackGeneration = 0;

  Future<void> _play() async {
    final int generation = ++_playbackGeneration;
    final List<String> letters = ArabicSignAlphabet.tokenize(_controller.text);
    if (!mounted) return;
    setState(() {
      _letters = letters;
      _currentIndex = 0;
      _playing = true;
    });

    for (int i = 0; i < letters.length; i++) {
      if (!_playing || generation != _playbackGeneration) return;
      if (!mounted) return;
      setState(() => _currentIndex = i);
      await Future.delayed(_letterDuration);
      if (!mounted || generation != _playbackGeneration) return;
    }
    if (mounted && generation == _playbackGeneration) {
      setState(() => _playing = false);
    }
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    // Invalidate any in-flight playback loop before tearing down.
    _playbackGeneration++;
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Presentation helpers (no business logic below this line)
  // ---------------------------------------------------------------------------

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
            loc.textToSignTitle,
            style:
                AppTextStyles.headlineM.copyWith(color: scheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _inputSection(ColorScheme scheme, AppLocalizations loc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _controller,
          hintText: loc.inputHint,
          suffixIcon: IconButton(
            icon: Icon(Icons.volume_up_rounded, color: scheme.primary),
            tooltip: loc.speakSentence,
            onPressed: () {
              final String text = _controller.text.trim();
              if (text.isNotEmpty) {
                final String lang = Localizations.localeOf(context).languageCode;
                TtsService.instance.speak(text, languageCode: lang);
              }
            },
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        AppButton.primary(
          label: loc.showSign,
          icon: Icons.play_arrow_rounded,
          expand: true,
          onPressed: _playing ? null : _play,
        ),
      ],
    );
  }

  Widget _stageMedia(
    ColorScheme scheme,
    AppLocalizations loc, {
    required String fileName,
  }) {
    // These placeholders render inside the intentionally-light
    // playback stage, so they use the light palette in both themes.
    final Color stageText = AppColors.light.textSecondary;

    if (fileName.isNotEmpty) {
      return Image.asset(
        'assets/signs/$fileName.jpg',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 56,
              color: stageText,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              loc.imageMissing(fileName),
              style: AppTextStyles.bodyM.copyWith(color: stageText),
            ),
          ],
        ),
      );
    }

    // Existing unsupported-letter branch (lookup returned null).
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.help_outline,
          size: 56,
          color: stageText,
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          loc.unsupportedShort,
          style: AppTextStyles.bodyM.copyWith(color: stageText),
        ),
      ],
    );
  }

  Widget _playbackSection(
    ColorScheme scheme,
    AppLocalizations loc, {
    required String letter,
    required String? fileName,
    required bool reducedMotion,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: reducedMotion
              ? Duration.zero
              : const Duration(milliseconds: 200),
          child: PlaybackStage(
            key: ValueKey<String>('stage-$_currentIndex-$fileName'),
            child: _stageMedia(
              scheme,
              loc,
              fileName: fileName ?? '',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Center(
          child: AnimatedSwitcher(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: ResultLetterTile(
              key: ValueKey<int>(_currentIndex),
              letter: letter,
              accent: scheme.primary,
              semanticLabel: loc.currentLetterLabel(letter),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        // The progress bar right below announces the same position;
        // keep the visible caption out of the semantic tree to avoid
        // a duplicate announcement.
        ExcludeSemantics(
          child: Text(
            loc.letterProgress(_currentIndex + 1, _letters.length),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption
                .copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SegmentedProgressBar(
          segmentCount: _letters.length,
          currentIndex: _currentIndex,
          semanticLabel: loc.letterProgress(_currentIndex + 1, _letters.length),
        ),
      ],
    );
  }

  Widget _upcomingLetters(AppLocalizations loc) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _letters.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            Builder(
              builder: (BuildContext context) {
                final bool unsupported =
                    ArabicSignAlphabet.assetFileFor(_letters[i]) == null;
                final Widget chip = LetterChip(
                  letter: _letters[i],
                  selected: i == _currentIndex,

                  // Unsupported letters (existing lookup miss) are
                  // presented quieter; detection itself is untouched.
                  semanticLabel: unsupported
                      ? loc.letterChipUnavailableLabel(_letters[i])
                      : loc.letterChipLabel(_letters[i]),
                );
                return unsupported
                    ? Opacity(opacity: 0.5, child: chip)
                    : chip;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _controlsRow(AppLocalizations loc) {
    return Center(
      child: PlaybackControls(
        // Only play exists in the current logic; it stays disabled
        // while playing, exactly like the original button.
        onTogglePlay: _playing ? null : _play,
        previousTooltip: loc.previousTooltip,
        playTooltip: loc.playTooltip,
        pauseTooltip: loc.pauseTooltip,
        nextTooltip: loc.nextTooltip,
        stopTooltip: loc.stopTooltip,
      ),
    );
  }

  Widget _emptyState(AppLocalizations loc) {
    return EmptyState(
      icon: Icons.record_voice_over_outlined,
      title: loc.startTypingTitle,
      description: loc.emptyStateDescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations loc = AppLocalizations.of(context);
    final bool reducedMotion = MediaQuery.disableAnimationsOf(context);

    final String letter =
        _letters.isNotEmpty ? _letters[_currentIndex] : '';
    final String? fileName = letter.isNotEmpty
        ? ArabicSignAlphabet.assetFileFor(letter)
        : null;
    final bool hasSequence = _letters.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 840;
            final double maxWidth = switch (constraints.maxWidth) {
              >= 840 => 1200,
              >= 600 => 640,
              _ => double.infinity,
            };

            final Widget playbackArea = hasSequence
                ? _playbackSection(
                    scheme,
                    loc,
                    letter: letter,
                    fileName: fileName,
                    reducedMotion: reducedMotion,
                  )
                : _emptyState(loc);

            final Widget content = wide
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(scheme, loc),
                        const SizedBox(height: AppSpacing.l),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 400),
                                    child: playbackArea,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xl),
                              Expanded(
                                flex: 2,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _inputSection(scheme, loc),
                                      const SizedBox(
                                          height: AppSpacing.xxl),
                                      if (hasSequence) ...[
                                        _upcomingLetters(loc),
                                        const SizedBox(
                                            height: AppSpacing.xxl),
                                      ],
                                      _controlsRow(loc),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(scheme, loc),
                        const SizedBox(height: AppSpacing.xl),
                        _inputSection(scheme, loc),
                        const SizedBox(height: AppSpacing.xxl),
                        playbackArea,
                        if (hasSequence) ...[
                          const SizedBox(height: AppSpacing.xl),
                          _upcomingLetters(loc),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                        _controlsRow(loc),
                        const SizedBox(height: AppSpacing.l),
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
