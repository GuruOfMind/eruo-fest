// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'يورو فيست';

  @override
  String get navDiscover => 'اكتشف';

  @override
  String get navMyArtists => 'فنانيّ';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get onboardingWelcomeTitle => 'لا تفوّت أي حفلة';

  @override
  String get onboardingWelcomeBody =>
      'تابع فنانيك المفضّلين واحصل على إشعار فور إعلانهم عن حفلة قريبة منك في أوروبا.';

  @override
  String get onboardingChooseLanguage => 'اختر لغتك';

  @override
  String get onboardingChooseCity => 'أين تقيم؟';

  @override
  String get onboardingChooseArtists => 'اختر الفنانين الذين تحبّهم';

  @override
  String get onboardingContinue => 'متابعة';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingSkip => 'تخطّي';

  @override
  String get discoverTitle => 'اكتشف';

  @override
  String get discoverEmpty =>
      'لا توجد فعاليات بعد. تابع بعض الفنانين لتظهر حفلاتهم هنا.';

  @override
  String get discoverError =>
      'تعذّر تحميل الفعاليات. تحقّق من اتصالك وحاول مجددًا.';

  @override
  String discoverNearCity(String city) {
    return 'فعاليات قرب $city';
  }

  @override
  String get discoverAllCities => 'كل المدن';

  @override
  String get eventUpcoming => 'الفعاليات القادمة';

  @override
  String get myArtistsTitle => 'فنانيّ';

  @override
  String get myArtistsEmpty => 'أنت لا تتابع أحدًا بعد.';

  @override
  String get myArtistsBrowseCta => 'تصفّح الفنانين';

  @override
  String get catalogTitle => 'تصفّح الفنانين';

  @override
  String get searchArtistsHint => 'ابحث عن فنانين أو أنواع موسيقية';

  @override
  String get searchNoResults => 'لا يوجد فنانون مطابقون لبحثك.';

  @override
  String get follow => 'متابعة';

  @override
  String get following => 'تتابعه';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات بعد.';

  @override
  String get notificationNewEvent => 'حفلة جديدة';

  @override
  String get notificationsMarkAllRead => 'تعليم الكل كمقروء';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsCity => 'المدينة';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get notifPrefsTitle => 'إعدادات الإشعارات';

  @override
  String get notifPrefsMaster => 'الإشعارات الفورية';

  @override
  String get notifPrefsMasterSub =>
      'تنبيهات عند إعلان الفنانين الذين تتابعهم عن حفلة';

  @override
  String get notifPrefsQuietHours => 'ساعات الهدوء';

  @override
  String get notifPrefsQuietHoursSub => 'لا ترسل إشعارات بين هذه الساعات';

  @override
  String get notifPrefsFrom => 'من';

  @override
  String get notifPrefsTo => 'إلى';

  @override
  String get notifPrefsMutedCities => 'مدن مكتومة';

  @override
  String get notifPrefsMutedCitiesSub => 'إخفاء إشعارات الفعاليات في هذه المدن';

  @override
  String get notifPrefsArtists => 'تُدار تنبيهات كل فنان من صفحته.';

  @override
  String get eventBook => 'احجز التذاكر';

  @override
  String get eventSoldOut => 'نفدت التذاكر';

  @override
  String get eventCancelled => 'أُلغيت';

  @override
  String get eventOnSale => 'متاحة للبيع';

  @override
  String get eventAnnounced => 'مُعلَنة';

  @override
  String eventFrom(String price) {
    return 'ابتداءً من $price';
  }

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';
}
