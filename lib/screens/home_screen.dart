import 'package:flutter/material.dart';

import '../design/app_radius.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';
import '../design/components/app_components.dart';
import '../l10n/generated/app_localizations.dart';
import 'sign_to_text_screen.dart';
import 'text_to_sign_screen.dart';

/// Home screen — "Calm Intelligence".
///
/// Presentation-only redesign: navigation targets are identical to the
/// previous implementation (SignToTextScreen / TextToSignScreen).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final bool twoColumns = width >= 840;
            final double maxWidth = switch (width) {
              >= 840 => 960,
              >= 600 => 520,
              _ => double.infinity,
            };

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: _HomeBody(twoColumns: twoColumns),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({required this.twoColumns});

  final bool twoColumns;

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody>
    with SingleTickerProviderStateMixin {
  static const int _sectionCount = 3;
  static const int _staggerMs = 80;
  static const int _entranceMs = 350;
  static const int _timelineMs =
      (_sectionCount - 1) * _staggerMs + _entranceMs;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _timelineMs),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _entrance(int index, Widget child, {required bool reducedMotion}) {
    final Animation<double> animation = reducedMotion
        ? kAlwaysCompleteAnimation
        : CurvedAnimation(
            parent: _controller,
            curve: Interval(
              (index * _staggerMs) / _timelineMs,
              (index * _staggerMs + _entranceMs) / _timelineMs,
              curve: Curves.easeOutCubic,
            ),
          );

    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? cachedChild) =>
            Transform.translate(
          offset: Offset(0, 24 * (1 - animation.value)),
          child: cachedChild,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations loc = AppLocalizations.of(context);
    final bool reducedMotion = MediaQuery.disableAnimationsOf(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _entrance(0, _brandHeader(scheme, loc),
                reducedMotion: reducedMotion),
            const SizedBox(height: AppSpacing.xxxl),
            _entrance(1, _modeCards(scheme, loc),
                reducedMotion: reducedMotion),
            const SizedBox(height: AppSpacing.sectionGap),
            _entrance(2, _trustArea(scheme, loc),
                reducedMotion: reducedMotion),
          ],
        ),
      ),
    );
  }

  Widget _brandHeader(ColorScheme scheme, AppLocalizations loc) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: AppRadius.brSmall,
          ),
          child: Icon(
            Icons.sign_language,
            size: 26,
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Text(
          loc.appName,
          style: AppTextStyles.titleL.copyWith(color: scheme.onSurface),
        ),
      ],
    );
  }

  Widget _modeCards(ColorScheme scheme, AppLocalizations loc) {
    final Widget signToText = ModeCard(
      icon: Icons.camera_alt,
      title: loc.signToTextTitle,
      subtitle: loc.signToTextSubtitle,
      accent: scheme.primary,
      // The screen's primary action: filled variant, higher elevation.
      emphasized: true,
      trailing: _directionalChevron(scheme, emphasized: true),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignToTextScreen()),
      ),
    );

    final Widget textToSign = ModeCard(
      icon: Icons.text_fields,
      title: loc.textToSignTitle,
      subtitle: loc.textToSignSubtitle,
      accent: scheme.secondary,
      trailing: _directionalChevron(scheme),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TextToSignScreen()),
      ),
    );

    if (widget.twoColumns) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: signToText),
          const SizedBox(width: AppSpacing.l),
          Expanded(child: textToSign),
        ],
      );
    }

    return Column(
      children: [
        signToText,
        const SizedBox(height: AppSpacing.l),
        textToSign,
      ],
    );
  }

  /// Forward-indicating chevron that respects the ambient direction
  /// instead of assuming an LTR arrow.
  Widget _directionalChevron(ColorScheme scheme, {bool emphasized = false}) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(
      isRtl
          ? Icons.arrow_back_ios_new_rounded
          : Icons.arrow_forward_ios_rounded,
      size: 16,
      color: emphasized ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
    );
  }

  Widget _trustArea(ColorScheme scheme, AppLocalizations loc) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        spacing: AppSpacing.s,
        runSpacing: AppSpacing.s,
        children: [
          TrustChip(label: loc.worksOffline, icon: Icons.wifi_off),
         
        ],
      ),
    );
  }
}
