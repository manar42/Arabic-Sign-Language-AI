import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/app_spacing.dart';
import '../design/app_typography.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/family_alert_service.dart';
import '../services/tts_service.dart';

/// Screen empowering deaf users to quickly alert and communicate with family
/// via WhatsApp or offline SMS without typing or calling.
/// Features high-urgency SOS with live GPS location and dual-contact support.
class FamilyAssistScreen extends StatefulWidget {
  const FamilyAssistScreen({super.key});

  @override
  State<FamilyAssistScreen> createState() => _FamilyAssistScreenState();
}

class _FamilyAssistScreenState extends State<FamilyAssistScreen> {
  EmergencyContact _primary = const EmergencyContact(name: '', phone: '');
  EmergencyContact _secondary = const EmergencyContact(name: '', phone: '');
  bool _loading = true;
  bool _isLocatingGps = false;

  /// Recipient selection: 0 = Primary, 1 = Secondary, 2 = Both
  int _selectedRecipient = 0;

  final TextEditingController _customMessageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final (primary, secondary) =
        await FamilyAlertService.instance.getSavedContacts();
    if (mounted) {
      setState(() {
        _primary = primary;
        _secondary = secondary;
        _loading = false;
        if (_primary.isEmpty && _secondary.isNotEmpty) {
          _selectedRecipient = 1;
        } else {
          _selectedRecipient = 0;
        }
      });
    }
  }

  void _showEditContactDialog({
    required bool isPrimary,
    required AppLocalizations loc,
  }) {
    final current = isPrimary ? _primary : _secondary;
    final nameCtrl = TextEditingController(text: current.name);
    final phoneCtrl = TextEditingController(text: current.phone);
    String selectedCc = current.countryCode.isNotEmpty ? current.countryCode : '+20';

    showDialog(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final bool isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bool isArabic = Localizations.localeOf(ctx).languageCode == 'ar';

        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final String previewWa = FamilyAlertService.formatForWhatsApp(
              phoneCtrl.text,
              defaultCountryCode: selectedCc,
            );

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isPrimary
                              ? const Color(0xFF0D9488)
                              : const Color(0xFF3B82F6))
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPrimary
                          ? Icons.star_rounded
                          : Icons.person_add_alt_1_rounded,
                      color: isPrimary
                          ? const Color(0xFF0D9488)
                          : const Color(0xFF3B82F6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      isPrimary ? loc.primaryContact : loc.secondaryContact,
                      style: AppTextStyles.titleM.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country Code Picker
                    Text(
                      loc.countryCode,
                      style: AppTextStyles.labelM.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: FamilyAlertService.countryCodes
                                  .any((c) => c.code == selectedCc)
                              ? selectedCc
                              : '+20',
                          isExpanded: true,
                          dropdownColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          items: FamilyAlertService.countryCodes.map((item) {
                            return DropdownMenuItem<String>(
                              value: item.code,
                              child: Text(
                                item.displayName(isArabic),
                                style: AppTextStyles.bodyM,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedCc = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    // Name Field
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: loc.contactNameHint,
                        prefixIcon: const Icon(Icons.person_rounded),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    // Phone Field
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: loc.contactPhoneHint,
                        helperText: loc.phoneValidationHint,
                        helperMaxLines: 2,
                        prefixIcon: const Icon(Icons.phone_rounded),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    // Live WhatsApp format preview
                    if (previewWa.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded,
                                color: Color(0xFF10B981), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'WhatsApp: +$previewWa',
                                textDirection: TextDirection.ltr,
                                style: AppTextStyles.labelM.copyWith(
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                if (!isPrimary && current.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await FamilyAlertService.instance.deleteSecondaryContact();
                      await _loadContacts();
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                    style: TextButton.styleFrom(foregroundColor: scheme.error),
                    child: Text(loc.clear),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(loc.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updated = EmergencyContact(
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      countryCode: selectedCc,
                    );
                    if (isPrimary) {
                      await FamilyAlertService.instance.savePrimaryContact(updated);
                    } else {
                      await FamilyAlertService.instance.saveSecondaryContact(updated);
                    }
                    await _loadContacts();
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(loc.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Initiates the emergency SOS workflow: fetches GPS, then dispatches to selected contacts.
  Future<void> _handleSosPress(AppLocalizations loc) async {
    if (_primary.isEmpty && _secondary.isEmpty) {
      _showSetupRequiredSnackBar(loc);
      _showEditContactDialog(isPrimary: true, loc: loc);
      return;
    }

    HapticFeedback.heavyImpact();

    setState(() => _isLocatingGps = true);

    // Acquire GPS location link (with timeout guard)
    final String? locationUrl =
        await FamilyAlertService.instance.getCurrentLocationLink();

    if (!mounted) return;
    setState(() => _isLocatingGps = false);

    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String sosMessage = FamilyAlertService.instance.buildSosMessage(
      isArabic: isArabic,
      locationUrl: locationUrl,
    );

    _showSosDispatchDialog(sosMessage, locationUrl != null, loc);
  }

  void _showSosDispatchDialog(
    String sosMessage,
    bool hasGps,
    AppLocalizations loc,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SOS Header Badge
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.emergencySosTitle,
                          style: AppTextStyles.titleL.copyWith(
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasGps)
                          Row(
                            children: [
                              const Icon(Icons.fmd_good_rounded,
                                  size: 14, color: Color(0xFF10B981)),
                              const SizedBox(width: 4),
                              Text(
                                loc.gpsAttached,
                                style: AppTextStyles.caption.copyWith(
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              // Message preview card
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  sosMessage,
                  style: AppTextStyles.bodyM.copyWith(
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              // Actions: WhatsApp & SMS buttons
              Row(
                children: [
                  // WhatsApp
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _dispatchToSelectedRecipients(
                          isWhatsApp: true,
                          message: sosMessage,
                          loc: loc,
                        );
                      },
                      icon: const Icon(Icons.chat_rounded, size: 20),
                      label: Text(loc.sendViaWhatsApp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  // SMS
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _dispatchToSelectedRecipients(
                          isWhatsApp: false,
                          message: sosMessage,
                          loc: loc,
                        );
                      },
                      icon: const Icon(Icons.sms_rounded, size: 20),
                      label: Text(loc.sendViaSms),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
            ],
          ),
        );
      },
    );
  }

  void _dispatchToSelectedRecipients({
    required bool isWhatsApp,
    required String message,
    required AppLocalizations loc,
  }) async {
    final targets = <EmergencyContact>[];

    if (_selectedRecipient == 0 && _primary.isNotEmpty) {
      targets.add(_primary);
    } else if (_selectedRecipient == 1 && _secondary.isNotEmpty) {
      targets.add(_secondary);
    } else {
      if (_primary.isNotEmpty) targets.add(_primary);
      if (_secondary.isNotEmpty) targets.add(_secondary);
    }

    if (targets.isEmpty) {
      _showSetupRequiredSnackBar(loc);
      return;
    }

    for (final contact in targets) {
      if (isWhatsApp) {
        await FamilyAlertService.instance.sendWhatsApp(
          phone: contact.phone,
          countryCode: contact.countryCode,
          message: message,
        );
      } else {
        await FamilyAlertService.instance.sendSms(
          phone: contact.phone,
          countryCode: contact.countryCode,
          message: message,
        );
      }
    }
  }

  void _showSetupRequiredSnackBar(AppLocalizations loc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: AppSpacing.s),
            Expanded(child: Text(loc.contactRequiredToast)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.emergencyCenterTitle,
          style: AppTextStyles.titleL.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.m,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. High Urgency Hero SOS Banner
                  _buildHeroSosCard(isDark, loc),

                  const SizedBox(height: AppSpacing.l),

                  // 2. Dual Contact Management Section
                  _buildContactsSection(scheme, isDark, loc),

                  const SizedBox(height: AppSpacing.l),

                  // 3. Recipient Selector (if multiple contacts exist)
                  if (_primary.isNotEmpty && _secondary.isNotEmpty) ...[
                    _buildRecipientSelector(isDark, loc),
                    const SizedBox(height: AppSpacing.l),
                  ],

                  // 4. Quick Pre-Configured Assist Cards
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded,
                          color: Color(0xFFF59E0B), size: 22),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        loc.familyAssistSubtitle,
                        style: AppTextStyles.titleM.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),

                  for (final card in FamilyAlertService.defaultCards) ...[
                    _buildQuickCard(card, isDark, isArabic, loc),
                    const SizedBox(height: AppSpacing.m),
                  ],

                  const SizedBox(height: AppSpacing.l),

                  // 5. Custom Message Box
                  _buildCustomMessageBox(scheme, isDark, loc),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroSosCard(bool isDark, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.38),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLocatingGps ? null : () => _handleSosPress(loc),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                // Glowing SOS circular button
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: _isLocatingGps
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.sos_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.emergencySosTitle,
                        style: AppTextStyles.headlineM.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLocatingGps
                            ? loc.locatingGps
                            : loc.emergencySosSubtitle,
                        style: AppTextStyles.bodyM.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactsSection(
    ColorScheme scheme,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.contactCardTitle,
              style: AppTextStyles.titleM.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            // Contact 1 (Primary)
            Expanded(
              child: _buildContactTile(
                contact: _primary,
                isPrimary: true,
                isDark: isDark,
                loc: loc,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            // Contact 2 (Secondary)
            Expanded(
              child: _buildContactTile(
                contact: _secondary,
                isPrimary: false,
                isDark: isDark,
                loc: loc,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required EmergencyContact contact,
    required bool isPrimary,
    required bool isDark,
    required AppLocalizations loc,
  }) {
    final bool isEmpty = contact.isEmpty;
    final Color accent = isPrimary ? const Color(0xFF0D9488) : const Color(0xFF3B82F6);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEmpty
              ? (isPrimary ? const Color(0xFFEF4444) : Colors.grey.withValues(alpha: 0.3))
              : accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPrimary ? Icons.star_rounded : Icons.shield_rounded,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isPrimary ? loc.primaryContact : loc.secondaryContact,
                  style: AppTextStyles.labelM.copyWith(
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isEmpty)
            Text(
              isPrimary ? loc.noContactConfigured : loc.addSecondaryContact,
              style: AppTextStyles.caption.copyWith(
                color: isPrimary ? const Color(0xFFEF4444) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
            )
          else ...[
            Text(
              contact.name.isNotEmpty ? contact.name : loc.contactCardTitle,
              style: AppTextStyles.titleM.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${contact.countryCode} ${contact.phone}',
              textDirection: TextDirection.ltr,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showEditContactDialog(isPrimary: isPrimary, loc: loc),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                side: BorderSide(color: accent.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isEmpty ? loc.save : loc.configureContact,
                style: AppTextStyles.labelM.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientSelector(bool isDark, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRecipientChoice(
              index: 0,
              label: _primary.name.isNotEmpty ? _primary.name : loc.primaryContact,
              icon: Icons.person_rounded,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildRecipientChoice(
              index: 1,
              label: _secondary.name.isNotEmpty ? _secondary.name : loc.secondaryContact,
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildRecipientChoice(
              index: 2,
              label: loc.sendToBoth,
              icon: Icons.group_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientChoice({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRecipient == index;
    return InkWell(
      onTap: () => setState(() => _selectedRecipient = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

  Widget _buildQuickCard(
    FamilyAlertCard card,
    bool isDark,
    bool isArabic,
    AppLocalizations loc,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: card.accentColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: card.accentColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: card.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(card.icon, color: card.accentColor, size: 24),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title(isArabic),
                        style: AppTextStyles.titleM.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        card.subtitle(isArabic),
                        style: AppTextStyles.caption.copyWith(
                          color: card.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Voice preview button
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded),
                  color: card.accentColor,
                  tooltip: loc.speakSentence,
                  onPressed: () {
                    final lang = isArabic ? 'ar' : 'en';
                    TtsService.instance.speak(card.message(isArabic), languageCode: lang);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              card.message(isArabic),
              style: AppTextStyles.bodyM.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                // WhatsApp Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _dispatchToSelectedRecipients(
                      isWhatsApp: true,
                      message: card.message(isArabic),
                      loc: loc,
                    ),
                    icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                    label: Text(loc.sendViaWhatsApp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                // SMS Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _dispatchToSelectedRecipients(
                      isWhatsApp: false,
                      message: card.message(isArabic),
                      loc: loc,
                    ),
                    icon: const Icon(Icons.sms_rounded, size: 18),
                    label: Text(loc.sendViaSms),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0284C7),
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomMessageBox(
    ColorScheme scheme,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: Color(0xFF0D9488)),
              const SizedBox(width: AppSpacing.s),
              Text(
                loc.sendCustomMessage,
                style: AppTextStyles.titleM.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _customMessageController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: loc.customMessageHint,
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final text = _customMessageController.text.trim();
                    if (text.isNotEmpty) {
                      _dispatchToSelectedRecipients(
                        isWhatsApp: true,
                        message: text,
                        loc: loc,
                      );
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: Text(loc.sendViaWhatsApp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final text = _customMessageController.text.trim();
                    if (text.isNotEmpty) {
                      _dispatchToSelectedRecipients(
                        isWhatsApp: false,
                        message: text,
                        loc: loc,
                      );
                    }
                  },
                  icon: const Icon(Icons.sms_rounded, size: 18),
                  label: Text(loc.sendViaSms),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0284C7),
                    side: const BorderSide(color: Color(0xFF0284C7)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
