import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application name shown in the OS task switcher and home header.
  ///
  /// In en, this message translates to:
  /// **'Ishara'**
  String get appName;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Communicate in sign, instantly.'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Translation between Arabic sign language and text, running entirely on your device.'**
  String get heroSubtitle;

  /// No description provided for @signToTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign → Text'**
  String get signToTextTitle;

  /// No description provided for @signToTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at your hand'**
  String get signToTextSubtitle;

  /// No description provided for @textToSignTitle.
  ///
  /// In en, this message translates to:
  /// **'Text → Sign'**
  String get textToSignTitle;

  /// No description provided for @textToSignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type text and watch it signed'**
  String get textToSignSubtitle;

  /// No description provided for @worksOffline.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get worksOffline;

  /// No description provided for @backTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backTooltip;

  /// No description provided for @handDetected.
  ///
  /// In en, this message translates to:
  /// **'Hand detected'**
  String get handDetected;

  /// No description provided for @pointHandAtFrame.
  ///
  /// In en, this message translates to:
  /// **'Point your hand toward the frame'**
  String get pointHandAtFrame;

  /// No description provided for @noLetterYet.
  ///
  /// In en, this message translates to:
  /// **'No letter yet'**
  String get noLetterYet;

  /// No description provided for @detectedLetterLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected letter: {letter}'**
  String detectedLetterLabel(String letter);

  /// No description provided for @initializingCameraAndModel.
  ///
  /// In en, this message translates to:
  /// **'Preparing the camera and model…'**
  String get initializingCameraAndModel;

  /// No description provided for @initFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the translator'**
  String get initFailedTitle;

  /// No description provided for @initFailedDescription.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while preparing the camera or the recognition model. You can try again.'**
  String get initFailedDescription;

  /// No description provided for @cameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'We need camera access to translate'**
  String get cameraPermissionTitle;

  /// No description provided for @cameraPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow the app to use the camera so it can read your signs.'**
  String get cameraPermissionDescription;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @sentence.
  ///
  /// In en, this message translates to:
  /// **'Sentence'**
  String get sentence;

  /// No description provided for @sentencePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Sentence letters will appear here…'**
  String get sentencePlaceholder;

  /// No description provided for @letterCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No letters} =1{1 letter} other{{count} letters}}'**
  String letterCount(int count);

  /// No description provided for @addLetter.
  ///
  /// In en, this message translates to:
  /// **'Add letter'**
  String get addLetter;

  /// No description provided for @insertSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get insertSpace;

  /// No description provided for @deleteLastToken.
  ///
  /// In en, this message translates to:
  /// **'Delete last character'**
  String get deleteLastToken;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearSentenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the sentence?'**
  String get clearSentenceTitle;

  /// No description provided for @clearSentenceDescription.
  ///
  /// In en, this message translates to:
  /// **'All collected letters will be deleted.'**
  String get clearSentenceDescription;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @inputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a word or a sentence…'**
  String get inputHint;

  /// No description provided for @showSign.
  ///
  /// In en, this message translates to:
  /// **'Show sign'**
  String get showSign;

  /// No description provided for @unsupportedShort.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get unsupportedShort;

  /// No description provided for @imageMissing.
  ///
  /// In en, this message translates to:
  /// **'Image {name} not found'**
  String imageMissing(String name);

  /// No description provided for @currentLetterLabel.
  ///
  /// In en, this message translates to:
  /// **'Current letter: {letter}'**
  String currentLetterLabel(String letter);

  /// No description provided for @letterProgress.
  ///
  /// In en, this message translates to:
  /// **'Letter {current} of {total}'**
  String letterProgress(int current, int total);

  /// No description provided for @letterChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Letter {letter}'**
  String letterChipLabel(String letter);

  /// No description provided for @letterChipUnavailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Letter {letter}, not available yet'**
  String letterChipUnavailableLabel(String letter);

  /// No description provided for @startTypingTitle.
  ///
  /// In en, this message translates to:
  /// **'Start typing to begin'**
  String get startTypingTitle;

  /// No description provided for @emptyStateDescription.
  ///
  /// In en, this message translates to:
  /// **'Letter signs will appear here during playback.'**
  String get emptyStateDescription;

  /// No description provided for @previousTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousTooltip;

  /// No description provided for @playTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playTooltip;

  /// No description provided for @pauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTooltip;

  /// No description provided for @nextTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextTooltip;

  /// No description provided for @stopTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
