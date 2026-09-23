import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../design/app_typography.dart';
import '../design/components/app_components.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart';
import 'family_assist_screen.dart';
import 'sign_to_text_screen.dart';
import 'text_to_sign_screen.dart';

/// Luxury Modern Home Screen with interactive language switch,
/// glowing hero section, stats row, and tactile high-end cards.
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
              >= 600 => 560,
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
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animateSection(int index, Widget child, {required bool reducedMotion}) {
    if (reducedMotion) return child;

    final double start = (index * 0.15).clamp(0.0, 1.0);
    final double end = (start + 0.45).clamp(0.0, 1.0);

    final Animation<double> fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations loc = AppLocalizations.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool reducedMotion = MediaQuery.disableAnimationsOf(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Brand + Live Language Selector
            _animateSection(
              0,
              _topBar(context, scheme, loc, isDark),
              reducedMotion: reducedMotion,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Hero Section: Glowing Badge, Inspiring Headline & Tagline
            _animateSection(
              1,
              _heroBanner(scheme, loc, isDark),
              reducedMotion: reducedMotion,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Capability & Tech Stats Row
            _animateSection(
              2,
              _statsPills(scheme, loc, isDark),
              reducedMotion: reducedMotion,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Translation Mode Cards
            _animateSection(
              3,
              _modeCards(scheme, loc),
              reducedMotion: reducedMotion,
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Trust & Offline indicator footer
            _animateSection(
              4,
              _footerTrust(scheme, loc, isDark),
              reducedMotion: reducedMotion,
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations loc,
    bool isDark,
  ) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary,
                    scheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.sign_language,
                size: 26,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.appName,
                  style: AppTextStyles.titleL.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  isArabic ? 'لغة الإشارة العربية' : 'Arabic Sign Language AI',
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Live Language Toggle Button (Ar / En)
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scheme.outline.withValues(alpha: isDark ? 0.3 : 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                final Locale nextLocale = isArabic
                    ? const Locale('en')
                    : const Locale('ar');
                appLocaleNotifier.value = nextLocale;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 16,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isArabic ? 'English' : 'العربية',
                      style: AppTextStyles.labelM.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroBanner(ColorScheme scheme, AppLocalizations loc, bool isDark) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [
                  const Color(0xFF134E4A),
                  const Color(0xFF0F172A),
                ]
              : [
                  scheme.primary.withValues(alpha: 0.12),
                  scheme.primary.withValues(alpha: 0.04),
                ],
        ),
        border: Border.all(
          color: scheme.primary.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'ذكاء اصطناعي محلي 100%' : '100% On-Device AI',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? const Color(0xFF5EEAD4) : scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            loc.heroTitle,
            style: AppTextStyles.headlineL.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            loc.heroSubtitle,
            style: AppTextStyles.bodyL.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsPills(ColorScheme scheme, AppLocalizations loc, bool isDark) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: '31',
            subtitle: isArabic ? 'إشارة وحرف مدعوم' : 'Supported Signs',
            icon: Icons.gesture_rounded,
            scheme: scheme,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _statCard(
            title: '0 ms',
            subtitle: isArabic ? 'معالجة بدون إنترنت' : 'Offline Latency',
            icon: Icons.bolt_rounded,
            scheme: scheme,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151C28) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: isDark ? 0.25 : 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleL.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeCards(ColorScheme scheme, AppLocalizations loc) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final Widget signToText = ModeCard(
      icon: Icons.camera_alt_rounded,
      title: loc.signToTextTitle,
      subtitle: loc.signToTextSubtitle,
      badgeText: isArabic ? 'كاميرا حية' : 'Live Camera',
      accent: scheme.primary,
      emphasized: true,
      trailing: _directionalChevron(scheme, emphasized: true),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignToTextScreen()),
      ),
    );

    final Widget textToSign = ModeCard(
      icon: Icons.translate_rounded,
      title: loc.textToSignTitle,
      subtitle: loc.textToSignSubtitle,
      badgeText: isArabic ? 'توليد بصري' : 'Visual Signs',
      accent: scheme.secondary,
      trailing: _directionalChevron(scheme),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TextToSignScreen()),
      ),
    );

    final Widget familyAssist = ModeCard(
      icon: Icons.family_restroom_rounded,
      title: loc.familyAssistTitle,
      subtitle: loc.familyAssistSubtitle,
      badgeText: isArabic ? 'طوارئ الأهل' : 'SOS & Family',
      accent: const Color(0xFFEF4444),
      trailing: _directionalChevron(scheme),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FamilyAssistScreen()),
      ),
    );

    if (widget.twoColumns) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: signToText),
              const SizedBox(width: AppSpacing.l),
              Expanded(child: textToSign),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          familyAssist,
        ],
      );
    }

    return Column(
      children: [
        signToText,
        const SizedBox(height: AppSpacing.l),
        textToSign,
        const SizedBox(height: AppSpacing.l),
        familyAssist,
      ],
    );
  }

  Widget _directionalChevron(ColorScheme scheme, {bool emphasized = false}) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (emphasized ? scheme.primary : scheme.outline)
            .withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isRtl
            ? Icons.arrow_back_ios_new_rounded
            : Icons.arrow_forward_ios_rounded,
        size: 14,
        color: emphasized ? scheme.primary : scheme.onSurfaceVariant,
      ),
    );
  }

  Widget _footerTrust(ColorScheme scheme, AppLocalizations loc, bool isDark) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151C28) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: scheme.outline.withValues(alpha: isDark ? 0.2 : 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 15,
              color: scheme.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isArabic
                    ? 'خصوصية كاملة • لا تُرسل أي بيانات إلى السحابة'
                    : 'Complete Privacy • No data leaves your phone',
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
