// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EuroFest';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navMyArtists => 'My Artists';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSettings => 'Settings';

  @override
  String get onboardingWelcomeTitle => 'Never miss a show';

  @override
  String get onboardingWelcomeBody =>
      'Follow your favourite artists and get notified the moment they announce a concert near you in Europe.';

  @override
  String get onboardingChooseLanguage => 'Choose your language';

  @override
  String get onboardingChooseCity => 'Where are you based?';

  @override
  String get onboardingChooseArtists => 'Pick artists you love';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get discoverEmpty =>
      'No events yet. Follow some artists to see their shows here.';

  @override
  String discoverNearCity(String city) {
    return 'Events near $city';
  }

  @override
  String get discoverAllCities => 'All cities';

  @override
  String get eventUpcoming => 'Upcoming events';

  @override
  String get myArtistsTitle => 'My Artists';

  @override
  String get myArtistsEmpty => 'You are not following anyone yet.';

  @override
  String get myArtistsBrowseCta => 'Browse artists';

  @override
  String get catalogTitle => 'Browse artists';

  @override
  String get searchArtistsHint => 'Search artists or genres';

  @override
  String get searchNoResults => 'No artists match your search.';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet.';

  @override
  String get notificationNewEvent => 'New event';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsCity => 'City';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get notifPrefsTitle => 'Notification preferences';

  @override
  String get notifPrefsMaster => 'Push notifications';

  @override
  String get notifPrefsMasterSub =>
      'Alerts when artists you follow announce a show';

  @override
  String get notifPrefsQuietHours => 'Quiet hours';

  @override
  String get notifPrefsQuietHoursSub => 'Don\'t push between these hours';

  @override
  String get notifPrefsFrom => 'From';

  @override
  String get notifPrefsTo => 'To';

  @override
  String get notifPrefsMutedCities => 'Muted cities';

  @override
  String get notifPrefsMutedCitiesSub => 'Hide push for events in these cities';

  @override
  String get notifPrefsArtists =>
      'Per-artist alerts are managed from each artist\'s page.';

  @override
  String get eventBook => 'Book tickets';

  @override
  String get eventSoldOut => 'Sold out';

  @override
  String get eventCancelled => 'Cancelled';

  @override
  String get eventOnSale => 'On sale';

  @override
  String get eventAnnounced => 'Announced';

  @override
  String eventFrom(String price) {
    return 'From $price';
  }

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';
}
