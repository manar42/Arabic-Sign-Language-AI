// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'إشارة';

  @override
  String get heroTitle => 'تواصل بالإشارة، فورًا.';

  @override
  String get heroSubtitle =>
      'ترجمة بين لغة الإشارة العربية والنص، تعمل كاملةً على جهازك.';

  @override
  String get signToTextTitle => 'إشارة ← نص';

  @override
  String get signToTextSubtitle => 'وجّه الكاميرا نحو يدك';

  @override
  String get textToSignTitle => 'نص ← إشارة';

  @override
  String get textToSignSubtitle => 'اكتب نصًا وشاهده بإشارات';

  @override
  String get worksOffline => 'يعمل بدون إنترنت';

  @override
  String get backTooltip => 'رجوع';

  @override
  String get handDetected => 'تم اكتشاف اليد';

  @override
  String get pointHandAtFrame => 'وجّه يدك نحو الإطار';

  @override
  String get noLetterYet => 'لا يوجد حرف بعد';

  @override
  String detectedLetterLabel(String letter) {
    return 'الحرف المكتشف: $letter';
  }

  @override
  String get initializingCameraAndModel => 'جارٍ تجهيز الكاميرا والنموذج…';

  @override
  String get initFailedTitle => 'تعذّر تشغيل المترجم';

  @override
  String get initFailedDescription =>
      'حدث خطأ أثناء تجهيز الكاميرا أو نموذج التعرّف. يمكنك المحاولة مرة أخرى.';

  @override
  String get cameraPermissionTitle => 'نحتاج إذن الكاميرا للترجمة';

  @override
  String get cameraPermissionDescription =>
      'اسمح للتطبيق باستخدام الكاميرا حتى نتمكن من قراءة الإشارة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get sentence => 'الجملة';

  @override
  String get sentencePlaceholder => 'ستظهر حروف الجملة هنا…';

  @override
  String letterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حروف',
      many: '$count حرفًا',
      few: '$count حروف',
      two: 'حرفان',
      one: 'حرف واحد',
      zero: 'لا حروف',
    );
    return '$_temp0';
  }

  @override
  String get addLetter => 'أضف الحرف';

  @override
  String get insertSpace => 'مسافة';

  @override
  String get deleteLastToken => 'حذف آخر حرف';

  @override
  String get clear => 'مسح';

  @override
  String get clearSentenceTitle => 'مسح الجملة؟';

  @override
  String get clearSentenceDescription => 'سيتم حذف جميع الحروف المكتسبة.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get inputHint => 'اكتب كلمة أو جملة…';

  @override
  String get showSign => 'عرض الإشارة';

  @override
  String get unsupportedShort => 'غير متوفر بعد';

  @override
  String imageMissing(String name) {
    return 'صورة $name غير موجودة';
  }

  @override
  String currentLetterLabel(String letter) {
    return 'الحرف الحالي: $letter';
  }

  @override
  String letterProgress(int current, int total) {
    return 'الحرف $current من $total';
  }

  @override
  String letterChipLabel(String letter) {
    return 'حرف $letter';
  }

  @override
  String letterChipUnavailableLabel(String letter) {
    return 'حرف $letter غير متوفر بعد';
  }

  @override
  String get startTypingTitle => 'اكتب نصًا للبدء';

  @override
  String get emptyStateDescription => 'ستظهر إشارات الحروف هنا أثناء التشغيل.';

  @override
  String get previousTooltip => 'السابق';

  @override
  String get playTooltip => 'تشغيل';

  @override
  String get pauseTooltip => 'إيقاف مؤقت';

  @override
  String get nextTooltip => 'التالي';

  @override
  String get stopTooltip => 'إيقاف';
}
