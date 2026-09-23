import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Represents an emergency family contact.
class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.phone,
    this.countryCode = '+20',
  });

  final String name;
  final String phone;
  final String countryCode;

  bool get isEmpty => phone.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Returns fully formatted international phone number ready for WhatsApp.
  String toWhatsAppNumber() {
    return FamilyAlertService.formatForWhatsApp(phone, defaultCountryCode: countryCode);
  }

  /// Returns fully formatted phone number ready for SMS.
  String toSmsNumber() {
    return FamilyAlertService.formatForSms(phone, defaultCountryCode: countryCode);
  }
}

/// Country data for phone codes.
class CountryCodeItem {
  const CountryCodeItem({
    required this.flag,
    required this.nameAr,
    required this.nameEn,
    required this.code,
  });

  final String flag;
  final String nameAr;
  final String nameEn;
  final String code;

  String displayName(bool isArabic) => '$flag ${isArabic ? nameAr : nameEn} ($code)';
}

/// Pre-configured smart alert card tailored for deaf / hard-of-hearing communication.
class FamilyAlertCard {
  const FamilyAlertCard({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.messageAr,
    required this.messageEn,
    required this.icon,
    required this.accentColor,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final String messageAr;
  final String messageEn;
  final IconData icon;
  final Color accentColor;

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String subtitle(bool isArabic) => isArabic ? subtitleAr : subtitleEn;
  String message(bool isArabic) => isArabic ? messageAr : messageEn;
}

/// Professional service managing emergency contacts, GPS location, and alert dispatch.
class FamilyAlertService {
  FamilyAlertService._();
  static final FamilyAlertService instance = FamilyAlertService._();

  // Legacy keys for backward compatibility
  static const String _keyLegacyName = 'family_contact_name';
  static const String _keyLegacyPhone = 'family_contact_phone';

  // Multi-contact storage keys
  static const String _keyPrimaryName = 'family_contact_primary_name';
  static const String _keyPrimaryPhone = 'family_contact_primary_phone';
  static const String _keyPrimaryCc = 'family_contact_primary_cc';

  static const String _keySecondaryName = 'family_contact_secondary_name';
  static const String _keySecondaryPhone = 'family_contact_secondary_phone';
  static const String _keySecondaryCc = 'family_contact_secondary_cc';

  /// Supported country codes with high priority for Arab countries.
  static const List<CountryCodeItem> countryCodes = [
    CountryCodeItem(flag: '🇪🇬', nameAr: 'مصر', nameEn: 'Egypt', code: '+20'),
    CountryCodeItem(flag: '🇸🇦', nameAr: 'السعودية', nameEn: 'Saudi Arabia', code: '+966'),
    CountryCodeItem(flag: '🇦🇪', nameAr: 'الإمارات', nameEn: 'UAE', code: '+971'),
    CountryCodeItem(flag: '🇰🇼', nameAr: 'الكويت', nameEn: 'Kuwait', code: '+965'),
    CountryCodeItem(flag: '🇯🇴', nameAr: 'الأردن', nameEn: 'Jordan', code: '+962'),
    CountryCodeItem(flag: '🇶🇦', nameAr: 'قطر', nameEn: 'Qatar', code: '+974'),
    CountryCodeItem(flag: '🇧🇭', nameAr: 'البحرين', nameEn: 'Bahrain', code: '+973'),
    CountryCodeItem(flag: '🇴🇲', nameAr: 'عُمان', nameEn: 'Oman', code: '+968'),
    CountryCodeItem(flag: '🇮🇶', nameAr: 'العراق', nameEn: 'Iraq', code: '+964'),
    CountryCodeItem(flag: '🇱🇧', nameAr: 'لبنان', nameEn: 'Lebanon', code: '+961'),
    CountryCodeItem(flag: '🇵🇸', nameAr: 'فلسطين', nameEn: 'Palestine', code: '+970'),
    CountryCodeItem(flag: '🇲🇦', nameAr: 'المغرب', nameEn: 'Morocco', code: '+212'),
    CountryCodeItem(flag: '🇩🇿', nameAr: 'الجزائر', nameEn: 'Algeria', code: '+213'),
    CountryCodeItem(flag: '🇹🇳', nameAr: 'تونس', nameEn: 'Tunisia', code: '+216'),
    CountryCodeItem(flag: '🇱🇾', nameAr: 'ليبيا', nameEn: 'Libya', code: '+218'),
    CountryCodeItem(flag: '🇸🇩', nameAr: 'السودان', nameEn: 'Sudan', code: '+249'),
    CountryCodeItem(flag: '🇾🇪', nameAr: 'اليمن', nameEn: 'Yemen', code: '+967'),
    CountryCodeItem(flag: '🇸🇾', nameAr: 'سوريا', nameEn: 'Syria', code: '+963'),
  ];

  /// Default alert cards tailored for real-world deaf scenarios.
  static const List<FamilyAlertCard> defaultCards = [
    FamilyAlertCard(
      id: 'video_call',
      titleAr: 'طلب مكالمة فيديو بالإشارة',
      titleEn: 'Request Video Call (Sign)',
      subtitleAr: 'أحتاج لمترجم لغة إشارة فوراً',
      subtitleEn: 'Need sign language translation',
      messageAr:
          'أنا في موقف أحتاج فيه لمترجم، أرجو الاتصال بي فيديو بلغة الإشارة فوراً.',
      messageEn:
          'I need a sign language interpreter right now, please video call me immediately.',
      icon: Icons.video_camera_front_rounded,
      accentColor: Color(0xFF0D9488),
    ),
    FamilyAlertCard(
      id: 'health_emergency',
      titleAr: 'طوارئ صحية عاجلة',
      titleEn: 'Health Emergency',
      subtitleAr: 'أحتاج مساعدة طبية في المستشفى',
      subtitleEn: 'Urgent medical assistance',
      messageAr:
          'حالة طارئة: أنا في المستشفى أو أحتاج مساعدة طبية عاجلة، أرجو التواصل معي فوراً.',
      messageEn:
          'Emergency: I am at the hospital or need urgent medical assistance, please contact me immediately.',
      icon: Icons.local_hospital_rounded,
      accentColor: Color(0xFFEF4444),
    ),
    FamilyAlertCard(
      id: 'road_delay',
      titleAr: 'تأخر أو عطل في الطريق',
      titleEn: 'Road Delay / Breakdown',
      subtitleAr: 'أنا بخير وسأتأخر قليلاً',
      subtitleEn: 'I am safe, will be late',
      messageAr:
          'حدث عطل أو تأخر معي في الطريق، لا تقلقوا أنا بخير وسأتأخر قليلاً.',
      messageEn:
          'I experienced a breakdown or delay on the road, don\'t worry I am safe and will be slightly delayed.',
      icon: Icons.directions_car_rounded,
      accentColor: Color(0xFFF59E0B),
    ),
    FamilyAlertCard(
      id: 'urgent_location',
      titleAr: 'مساعدة في مكاني الحالي',
      titleEn: 'Need Help at My Location',
      subtitleAr: 'أواجه مشكلة وأحتاج لمساعدتكم',
      subtitleEn: 'Need assistance here',
      messageAr: 'أواجه مشكلة في مكاني الحالي وأحتاج لمساعدتكم فوراً.',
      messageEn:
          'I am facing an issue at my current location and need your help immediately.',
      icon: Icons.location_on_rounded,
      accentColor: Color(0xFF3B82F6),
    ),
  ];

  /// Converts Arabic-Indic (٠-٩) and Persian (۰-۹) digits to standard ASCII digits (0-9).
  static String convertArabicDigitsToAscii(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    const ascii = '0123456789';

    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(arabic[i], ascii[i]);
      result = result.replaceAll(persian[i], ascii[i]);
    }
    return result;
  }

  /// Cleans and formats phone number for WhatsApp wa.me link:
  /// - Converts Arabic digits to English digits
  /// - Strips spaces, dashes, brackets
  /// - If the number starts with local 0 (e.g. 010..., 05...), replaces leading 0 with countryCode
  /// - If number already has +, strips + for wa.me URL
  /// - Returns pure international digits (e.g. 201012345678)
  static String formatForWhatsApp(String rawPhone, {String defaultCountryCode = '+20'}) {
    String cleaned = convertArabicDigitsToAscii(rawPhone).trim();
    cleaned = cleaned.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');

    final bool hasPlus = cleaned.startsWith('+');
    cleaned = cleaned.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) return '';

    if (hasPlus) {
      return cleaned;
    }

    if (cleaned.startsWith('00')) {
      return cleaned.substring(2);
    }

    final codeDigits = defaultCountryCode.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.startsWith('0')) {
      return '$codeDigits${cleaned.substring(1)}';
    }

    if (!cleaned.startsWith(codeDigits)) {
      return '$codeDigits$cleaned';
    }

    return cleaned;
  }

  /// Formats phone number for native SMS app (+country_code... or local number).
  static String formatForSms(String rawPhone, {String defaultCountryCode = '+20'}) {
    final String intl = formatForWhatsApp(rawPhone, defaultCountryCode: defaultCountryCode);
    if (intl.isEmpty) return '';
    return '+$intl';
  }

  /// Loads both primary and secondary emergency contacts.
  Future<(EmergencyContact primary, EmergencyContact secondary)> getSavedContacts() async {
    final prefs = await SharedPreferences.getInstance();

    // Check primary contact with fallback to legacy keys
    String primaryName = prefs.getString(_keyPrimaryName) ?? '';
    String primaryPhone = prefs.getString(_keyPrimaryPhone) ?? '';
    String primaryCc = prefs.getString(_keyPrimaryCc) ?? '+20';

    if (primaryPhone.isEmpty) {
      primaryName = prefs.getString(_keyLegacyName) ?? '';
      primaryPhone = prefs.getString(_keyLegacyPhone) ?? '';
    }

    // Secondary contact
    final secondaryName = prefs.getString(_keySecondaryName) ?? '';
    final secondaryPhone = prefs.getString(_keySecondaryPhone) ?? '';
    final secondaryCc = prefs.getString(_keySecondaryCc) ?? '+20';

    return (
      EmergencyContact(name: primaryName, phone: primaryPhone, countryCode: primaryCc),
      EmergencyContact(name: secondaryName, phone: secondaryPhone, countryCode: secondaryCc),
    );
  }

  /// Saves or updates the primary family contact.
  Future<void> savePrimaryContact(EmergencyContact contact) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPrimaryName, contact.name.trim());
    await prefs.setString(_keyPrimaryPhone, contact.phone.trim());
    await prefs.setString(_keyPrimaryCc, contact.countryCode.trim());

    // Keep legacy keys in sync
    await prefs.setString(_keyLegacyName, contact.name.trim());
    await prefs.setString(_keyLegacyPhone, contact.phone.trim());
  }

  /// Saves or updates the secondary (backup) family contact.
  Future<void> saveSecondaryContact(EmergencyContact contact) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySecondaryName, contact.name.trim());
    await prefs.setString(_keySecondaryPhone, contact.phone.trim());
    await prefs.setString(_keySecondaryCc, contact.countryCode.trim());
  }

  /// Deletes the secondary contact.
  Future<void> deleteSecondaryContact() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySecondaryName);
    await prefs.remove(_keySecondaryPhone);
    await prefs.remove(_keySecondaryCc);
  }

  /// Legacy helper for backwards compatibility.
  Future<(String name, String phone)> getSavedContact() async {
    final (primary, _) = await getSavedContacts();
    return (primary.name, primary.phone);
  }

  /// Legacy helper for backwards compatibility.
  Future<void> saveContact(String name, String phone) async {
    await savePrimaryContact(EmergencyContact(name: name, phone: phone));
  }

  /// Cleans phone number to numeric international format.
  String cleanPhone(String raw) {
    return formatForWhatsApp(raw);
  }

  /// Acquires high-accuracy GPS coordinates and returns Google Maps URL.
  Future<String?> getCurrentLocationLink() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  /// Builds a high-urgency SOS distress message with optional GPS link.
  String buildSosMessage({
    required bool isArabic,
    String? locationUrl,
  }) {
    if (isArabic) {
      final locText = (locationUrl != null && locationUrl.isNotEmpty)
          ? '\n\n📍 موقعي الحالي على الخريطة (GPS):\n$locationUrl'
          : '';
      return '🚨 نداء استغاثة عاجل (SOS)!\nأنا أصم وأواجه موقفاً طارئاً وحرجاً جداً الآن، أرجو التواصل معي أو نجدتي فوراً!$locText';
    } else {
      final locText = (locationUrl != null && locationUrl.isNotEmpty)
          ? '\n\n📍 My current location on Map (GPS):\n$locationUrl'
          : '';
      return '🚨 EMERGENCY SOS ALERT!\nI am deaf and in an urgent emergency situation, please reach out or send help immediately!$locText';
    }
  }

  /// Opens WhatsApp directly with the pre-filled message and recipient.
  Future<bool> sendWhatsApp({
    required String phone,
    required String message,
    String countryCode = '+20',
  }) async {
    final String formatted = formatForWhatsApp(phone, defaultCountryCode: countryCode);
    if (formatted.isEmpty) return false;

    final String encodedMsg = Uri.encodeComponent(message);
    final Uri url = Uri.parse('https://wa.me/$formatted?text=$encodedMsg');

    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('WhatsApp Launch Error: $e');
      return false;
    }
  }

  /// Opens the native SMS app with the pre-filled message and recipient (offline capable).
  Future<bool> sendSms({
    required String phone,
    required String message,
    String countryCode = '+20',
  }) async {
    final String formatted = formatForSms(phone, defaultCountryCode: countryCode);
    if (formatted.isEmpty) return false;

    final String encodedMsg = Uri.encodeComponent(message);
    final Uri url = Uri.parse('sms:$formatted?body=$encodedMsg');

    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('SMS Launch Error: $e');
      return false;
    }
  }
}
