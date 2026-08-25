import 'package:flutter/material.dart';

import '../app_spacing.dart';
import 'app_icon_button.dart';

/// Presentation-only playback controls: previous / play-pause / next /
/// stop.
///
/// All callbacks come from the parent; there are no timers and no
/// playback state machine here. Passing `null` disables a control.
/// Tooltips default to the app's Arabic wording and can be overridden
/// for localization later.
class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    super.key,
    this.isPlaying = false,
    this.onPrevious,
    this.onTogglePlay,
    this.onNext,
    this.onStop,
    this.previousTooltip = 'السابق',
    this.playTooltip = 'تشغيل',
    this.pauseTooltip = 'إيقاف مؤقت',
    this.nextTooltip = 'التالي',
    this.stopTooltip = 'إيقاف',
  });

  final bool isPlaying;
  final VoidCallback? onPrevious;
  final VoidCallback? onTogglePlay;
  final VoidCallback? onNext;
  final VoidCallback? onStop;

  final String previousTooltip;
  final String playTooltip;
  final String pauseTooltip;
  final String nextTooltip;
  final String stopTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(
          icon: Icons.skip_previous,
          tooltip: previousTooltip,
          onPressed: onPrevious,
        ),
        const SizedBox(width: AppSpacing.s),
        AppIconButton(
          icon: isPlaying ? Icons.pause : Icons.play_arrow,
          tooltip: isPlaying ? pauseTooltip : playTooltip,
          onPressed: onTogglePlay,
          variant: AppIconButtonVariant.filled,
          iconSize: 26,
        ),
        const SizedBox(width: AppSpacing.s),
        AppIconButton(
          icon: Icons.skip_next,
          tooltip: nextTooltip,
          onPressed: onNext,
        ),
        if (onStop != null) ...[
          const SizedBox(width: AppSpacing.l),
          AppIconButton(
            icon: Icons.stop,
            tooltip: stopTooltip,
            onPressed: onStop,
            variant: AppIconButtonVariant.tonal,
          ),
        ],
      ],
    );
  }
}
