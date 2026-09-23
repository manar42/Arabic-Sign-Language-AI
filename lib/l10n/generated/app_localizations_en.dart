// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ishara';

  @override
  String get heroTitle => 'Communicate in sign, instantly.';

  @override
  String get heroSubtitle =>
      'Translation between Arabic sign language and text, running entirely on your device.';

  @override
  String get signToTextTitle => 'Sign → Text';

  @override
  String get signToTextSubtitle => 'Point your camera at your hand';

  @override
  String get textToSignTitle => 'Text → Sign';

  @override
  String get textToSignSubtitle => 'Type text and watch it signed';

  @override
  String get worksOffline => 'Works offline';

  @override
  String get backTooltip => 'Back';

  @override
  String get handDetected => 'Hand detected';

  @override
  String get pointHandAtFrame => 'Point your hand toward the frame';

  @override
  String get noLetterYet => 'No letter yet';

  @override
  String detectedLetterLabel(String letter) {
    return 'Detected letter: $letter';
  }

  @override
  String get initializingCameraAndModel => 'Preparing the camera and model…';

  @override
  String get initFailedTitle => 'Couldn\'t start the translator';

  @override
  String get initFailedDescription =>
      'Something went wrong while preparing the camera or the recognition model. You can try again.';

  @override
  String get cameraPermissionTitle => 'We need camera access to translate';

  @override
  String get cameraPermissionDescription =>
      'Allow the app to use the camera so it can read your signs.';

  @override
  String get retry => 'Retry';

  @override
  String get sentence => 'Sentence';

  @override
  String get sentencePlaceholder => 'Sentence letters will appear here…';

  @override
  String letterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count letters',
      one: '1 letter',
      zero: 'No letters',
    );
    return '$_temp0';
  }

  @override
  String get addLetter => 'Add letter';

  @override
  String get insertSpace => 'Space';

  @override
  String get deleteLastToken => 'Delete last character';

  @override
  String get clear => 'Clear';

  @override
  String get clearSentenceTitle => 'Clear the sentence?';

  @override
  String get clearSentenceDescription =>
      'All collected letters will be deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get inputHint => 'Type a word or a sentence…';

  @override
  String get showSign => 'Show sign';

  @override
  String get unsupportedShort => 'Not available yet';

  @override
  String imageMissing(String name) {
    return 'Image $name not found';
  }

  @override
  String currentLetterLabel(String letter) {
    return 'Current letter: $letter';
  }

  @override
  String letterProgress(int current, int total) {
    return 'Letter $current of $total';
  }

  @override
  String letterChipLabel(String letter) {
    return 'Letter $letter';
  }

  @override
  String letterChipUnavailableLabel(String letter) {
    return 'Letter $letter, not available yet';
  }

  @override
  String get startTypingTitle => 'Start typing to begin';

  @override
  String get emptyStateDescription =>
      'Letter signs will appear here during playback.';

  @override
  String get previousTooltip => 'Previous';

  @override
  String get playTooltip => 'Play';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get nextTooltip => 'Next';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get speakSentence => 'Speak sentence';

  @override
  String get speaking => 'Speaking…';

  @override
  String get copySentence => 'Copy sentence';

  @override
  String get sentenceCopied => 'Sentence copied to clipboard';

  @override
  String get familyAssistTitle => 'Family Quick Assist';

  @override
  String get familyAssistSubtitle =>
      'Instant communication with family via WhatsApp & SMS';

  @override
  String get contactCardTitle => 'Emergency Family Contact';

  @override
  String get noContactConfigured => 'Tap to configure family contact number';

  @override
  String get configureContact => 'Edit Contact';

  @override
  String get contactNameHint => 'Name (e.g. Dad, Mom, Brother)';

  @override
  String get contactPhoneHint => 'Phone (with country code e.g. +20...)';

  @override
  String get save => 'Save';

  @override
  String get sendViaWhatsApp => 'WhatsApp';

  @override
  String get sendViaSms => 'SMS';

  @override
  String get customMessageHint => 'Type a custom message here…';

  @override
  String get sendCustomMessage => 'Send Custom Message';

  @override
  String get contactRequiredToast => 'Please set up family phone number first';

  @override
  String get handsFreeMode => 'Auto-Flow';

  @override
  String get handsFreeModeTooltip =>
      'Automatically captures letter when held steadily for 1s without touching screen';

  @override
  String get autoSpaceAdded => 'Auto-space added';

  @override
  String get emergencySosTitle => 'Emergency SOS Alert';

  @override
  String get emergencySosSubtitle =>
      'Send instant SOS to family with your live GPS map link';

  @override
  String get emergencyCenterTitle => 'Emergency & Family SOS Center';

  @override
  String get emergencyCenterSubtitle =>
      'Instant distress alerts and direct assist for deaf users';

  @override
  String get primaryContact => 'Primary Contact';

  @override
  String get secondaryContact => 'Backup Contact';

  @override
  String get addSecondaryContact => 'Add Backup Contact';

  @override
  String get countryCode => 'Country Code';

  @override
  String get locatingGps => 'Acquiring GPS location...';

  @override
  String get gpsAttached => 'GPS location attached';

  @override
  String get sendToBoth => 'Send to Both Contacts';

  @override
  String get selectRecipient => 'Send to:';

  @override
  String get sosSentSuccess => 'Emergency alert dispatched successfully';

  @override
  String get phoneValidationHint =>
      'Enter phone number (country code & digits formatted automatically)';
}
