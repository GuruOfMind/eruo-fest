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
/// import 'l10n/app_localizations.dart';
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

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'EuroFest'**
  String get appName;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navMyArtists.
  ///
  /// In en, this message translates to:
  /// **'My Artists'**
  String get navMyArtists;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss a show'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Follow your favourite artists and get notified the moment they announce a concert near you in Europe.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingChooseLanguage;

  /// No description provided for @onboardingChooseCity.
  ///
  /// In en, this message translates to:
  /// **'Where are you based?'**
  String get onboardingChooseCity;

  /// No description provided for @onboardingChooseArtists.
  ///
  /// In en, this message translates to:
  /// **'Pick artists you love'**
  String get onboardingChooseArtists;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// No description provided for @discoverEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events yet. Follow some artists to see their shows here.'**
  String get discoverEmpty;

  /// No description provided for @discoverError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load events. Check your connection and try again.'**
  String get discoverError;

  /// No description provided for @discoverNearCity.
  ///
  /// In en, this message translates to:
  /// **'Events near {city}'**
  String discoverNearCity(String city);

  /// No description provided for @discoverAllCities.
  ///
  /// In en, this message translates to:
  /// **'All cities'**
  String get discoverAllCities;

  /// No description provided for @eventUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events'**
  String get eventUpcoming;

  /// No description provided for @myArtistsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Artists'**
  String get myArtistsTitle;

  /// No description provided for @myArtistsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You are not following anyone yet.'**
  String get myArtistsEmpty;

  /// No description provided for @myArtistsBrowseCta.
  ///
  /// In en, this message translates to:
  /// **'Browse artists'**
  String get myArtistsBrowseCta;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse artists'**
  String get catalogTitle;

  /// No description provided for @searchArtistsHint.
  ///
  /// In en, this message translates to:
  /// **'Search artists or genres'**
  String get searchArtistsHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No artists match your search.'**
  String get searchNoResults;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsEmpty;

  /// No description provided for @notificationNewEvent.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get notificationNewEvent;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get settingsCity;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @notifPrefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notifPrefsTitle;

  /// No description provided for @notifPrefsMaster.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get notifPrefsMaster;

  /// No description provided for @notifPrefsMasterSub.
  ///
  /// In en, this message translates to:
  /// **'Alerts when artists you follow announce a show'**
  String get notifPrefsMasterSub;

  /// No description provided for @notifPrefsQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get notifPrefsQuietHours;

  /// No description provided for @notifPrefsQuietHoursSub.
  ///
  /// In en, this message translates to:
  /// **'Don\'t push between these hours'**
  String get notifPrefsQuietHoursSub;

  /// No description provided for @notifPrefsFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get notifPrefsFrom;

  /// No description provided for @notifPrefsTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get notifPrefsTo;

  /// No description provided for @notifPrefsMutedCities.
  ///
  /// In en, this message translates to:
  /// **'Muted cities'**
  String get notifPrefsMutedCities;

  /// No description provided for @notifPrefsMutedCitiesSub.
  ///
  /// In en, this message translates to:
  /// **'Hide push for events in these cities'**
  String get notifPrefsMutedCitiesSub;

  /// No description provided for @notifPrefsArtists.
  ///
  /// In en, this message translates to:
  /// **'Per-artist alerts are managed from each artist\'s page.'**
  String get notifPrefsArtists;

  /// No description provided for @eventBook.
  ///
  /// In en, this message translates to:
  /// **'Book tickets'**
  String get eventBook;

  /// No description provided for @eventSoldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get eventSoldOut;

  /// No description provided for @eventCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get eventCancelled;

  /// No description provided for @eventOnSale.
  ///
  /// In en, this message translates to:
  /// **'On sale'**
  String get eventOnSale;

  /// No description provided for @eventAnnounced.
  ///
  /// In en, this message translates to:
  /// **'Announced'**
  String get eventAnnounced;

  /// No description provided for @eventFrom.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String eventFrom(String price);

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;
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
