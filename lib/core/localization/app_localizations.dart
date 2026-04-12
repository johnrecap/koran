import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const Map<String, Map<String, String>> _strings = {
    'ar': {
      'appTitle': 'القرآن الكريم',
      'splashTitle': 'القرآن الكريم',
      'splashSubtitle': 'النسخة الفاخرة',
      'enterFullscreen': 'وضع القراءة الكاملة',
      'restoreReaderChrome': 'إظهار الواجهة',
      'bookmarkUpdated': 'تم تحديث العلامة المرجعية',
      'verseActionAyah': 'الآية',
      'verseActionListen': 'استماع',
      'verseActionInsights': 'علوم',
      'verseActionBookmark': 'حفظ',
      'verseActionShare': 'مشاركة',
      'verseActionTranslations': 'ترجمات',
      'verseActionCopy': 'نسخ',
      'verseActionNote': 'ملاحظة',
      'verseMetadataUnavailable': 'تعذر تحميل بيانات السورة الآن.',
      'verseShareUnavailable': 'تعذرت مشاركة الآية الآن.',
      'verseCopyUnavailable': 'تعذر نسخ هذه الآية الآن.',
      'verseCopied': 'تم نسخ الآية.',
      'verseAudioUnavailable': 'تعذر تشغيل هذه الآية الآن.',
      'verseInsightsUnavailable': 'تعذر فتح التفسير وأحكام التجويد الآن.',
      'verseTranslationUnavailable': 'تعذر فتح ترجمة هذه الآية الآن.',
      'verseNoteHint': 'اكتب ملاحظتك على هذه الآية...',
      'verseNoteSave': 'حفظ',
      'verseNoteDelete': 'حذف',
      'verseNoteSaved': 'تم حفظ الملاحظة.',
      'verseNoteDeleted': 'تم حذف الملاحظة.',
      'verseNoteUnavailable': 'تعذر فتح ملاحظة هذه الآية الآن.',
      'verseNoteLoading': 'جارٍ تحميل الملاحظة...',
      'readerModeScroll': 'وضع التمرير',
      'readerModePage': 'وضع الصفحات',
      'readerModeTranslation': 'وضع الترجمة',
      'readerNightModeSheetTitle': 'القارئ الليلي',
      'readerNightModeNormal': 'عادي',
      'readerNightModeNight': 'ليلي',
      'readerNightModeAmoled': 'AMOLED',
      'readerNightModeNormalDescription': 'ألوان القارئ المعتادة',
      'readerNightModeNightDescription': 'ألوان ليلية مريحة',
      'readerNightModeAmoledDescription': 'سواد أعمق لشاشات OLED',
      'readerQuickJump': 'انتقال سريع',
      'readerSurahCountLabel': 'سورة',
      'readerSurahLoadError': 'تعذر تحميل السور الآن.',
      'readerSurahList': 'فهرس السور',
      'translationModeLoading': 'جارٍ تحميل الترجمة...',
      'translationModeRetry': 'إعادة المحاولة',
      'translationModeError': 'تعذر تحميل الترجمة الآن.',
      'translationModeEmpty': 'لا توجد ترجمة متاحة لهذه الآيات حالياً.',
      'translationVerseFallback': 'الترجمة غير متاحة لهذه الآية.',
      'verseAudioComingSoon': 'التلاوة الصوتية ستتوفر قريباً',
      'audioHubTitle': 'الصوت',
      'audioHubLoading': 'جارٍ تحميل مشغل الصوت...',
      'audioHubLoadError': 'تعذر تحميل مشغل الصوت الآن.',
      'audioHubRetry': 'إعادة المحاولة',
      'audioHubSelectReciter': 'اختيار القارئ',
      'audioHubCurrentReciter': 'القارئ الحالي',
      'audioHubReciterListUnavailable': 'تعذر تحميل قائمة القراء الآن.',
      'audioHubReciterChangeFailed': 'تعذر تبديل القارئ الآن.',
      'audioHubSelectSurah': 'اختيار السورة',
      'audioHubSurahListUnavailable': 'تعذر تحميل قائمة السور الآن.',
      'audioHubPlay': 'تشغيل',
      'audioHubPause': 'إيقاف',
      'audioHubPrevious': 'السورة السابقة',
      'audioHubNext': 'السورة التالية',
      'audioHubSurah': 'سورة',
      'audioHubAyahs': 'آيات',
      'mushafSetupTitle': 'تجهيز المصحف',
      'mushafSetupDescription':
          'حمّل المصحف والخطوط مرة واحدة لتكون القراءة والتمرير أكثر سلاسة من أول استخدام.',
      'mushafSetupStart': 'ابدأ التحميل',
      'mushafSetupInProgress': 'جارٍ تجهيز المصحف بالكامل...',
      'mushafSetupRetry': 'إعادة المحاولة',
      'mushafSetupError':
          'تعذر تجهيز المصحف الآن. تأكد من توفر مساحة كافية ثم حاول مرة أخرى.',
      'mushafSetupRequired': 'يلزم تجهيز المصحف قبل المتابعة.',
      'tafsirBrowserTitle': 'متصفح التفسير',
      'tafsirBrowserOpenFull': 'فتح متصفح التفسير',
      'tafsirBrowserLoading': 'جارٍ تحميل التفسير...',
      'tafsirBrowserLoadError': 'تعذر تحميل التفسير الآن.',
      'tafsirBrowserSourceUnavailable':
          'مصدر التفسير هذا غير متاح على هذا الجهاز.',
      'tafsirBrowserInvalidVerse': 'تعذر فتح التفسير لهذه الآية.',
      'tafsirBrowserSourceLabel': 'المصدر',
      'tafsirBrowserFootnotesTitle': 'الحواشي',
      'tafsirBrowserPrevious': 'الآية السابقة',
      'tafsirBrowserNext': 'الآية التالية',
      'insightSectionTafsir': 'التفسير',
      'insightSectionWordMeaning': 'معاني الكلمات',
      'insightSectionAsbaab': 'أسباب النزول',
      'insightSectionRelated': 'آيات ذات صلة',
      'insightSectionUnavailable': 'غير متاح حاليًا',
      'insightSectionCollapse': 'طي',
      'insightSectionExpand': 'توسيع',
      'insightWordRoot': 'الجذر',
      'insightAsbaabSource': 'المصدر',
      'insightRelatedOpen': 'فتح الآية',
      'insightRelatedTagThematic': 'موضوعي',
      'insightRelatedTagLinguistic': 'لغوي',
      'audioDownloadsOpen': 'إدارة التحميلات',
      'audioDownloadsTitle': 'إدارة التحميلات',
      'audioDownloadsEmptyTitle': 'ستظهر تحميلات الصوت هنا.',
      'audioDownloadsDownloadedSection': 'الشيوخ المحمّلون',
      'audioDownloadsAvailableSection': 'المتاح للتحميل',
      'audioDownloadsNoDownloadedReciters': 'لا توجد تحميلات صوتية بعد.',
      'audioDownloadsNoAvailableReciters': 'كل الشيوخ المتاحين ظاهرون هنا.',
      'audioDownloadsTotalStorage': 'إجمالي المساحة',
      'audioDownloadsDownloadedReciters': 'الشيوخ المحمّلون',
      'audioDownloadsActiveDownload': 'تحميل جارٍ للسورة',
      'audioDownloadsSurahCount': 'سورة',
      'audioDownloadsLocalSize': 'المساحة المحلية',
      'audioDownloadsStatusAvailable': 'غير محمّلة',
      'audioDownloadsStatusDownloaded': 'محمّلة',
      'audioDownloadsStatusDownloading': 'جارٍ التحميل',
      'audioDownloadsStatusFailed': 'فشل التحميل',
      'audioDownloadsDownload': 'تحميل',
      'audioDownloadsDelete': 'حذف',
      'audioDownloadsRetry': 'إعادة المحاولة',
      'audioDownloadsCancel': 'إلغاء',
      'audioDownloadsLoadError': 'تعذر تحميل إدارة التنزيلات الآن.',
      'audioDownloadsUnavailableMessage':
          'إدارة تنزيلات الصوت غير مدعومة على هذا الجهاز الآن.',
      'audioDownloadsActionFailed': 'تعذر تنفيذ هذا الإجراء الآن.',
      'errorLoadingData': 'تعذر تحميل البيانات الآن.',
      'errorRetry': 'إعادة المحاولة',
      'smartSearch': 'البحث الذكي',
      'searchByTopic': 'بحث بالموضوع',
      'searchingTopics': 'جارٍ البحث عن المواضيع...',
      'noSmartResults': 'لم يتم العثور على آيات مطابقة لهذا الموضوع.',
      'smartSearchHint': 'ابحث بمفهوم أو موضوع أو سؤال.',
      'fallbackToKeyword': 'البحث الذكي غير متاح بدون اتصال. عرض نتائج الكلمات المفتاحية بدلاً من ذلك.',
      'searchTopicPlaceholder': 'ابحث عن موضوع قرآني...',
      'verseContext': 'سياق الآية',
      'contextAndConnection': 'السياق والترابط',
      'loadingContext': 'جارٍ تحميل السياق...',
      'reflectionQuestions': 'أسئلة للتأمل',
      'tadabburQuestions': 'أسئلة للتدبر',
      'generatingQuestions': 'جارٍ توليد أسئلة التدبر...',
      'simplifyTafsir': 'تبسيط التفسير',
      'simplifying': 'جارٍ التبسيط...',
      'simplifiedSummary': 'ملخص مبسط',
      'tafsirAlreadyShort': 'هذا التفسير مختصر بالفعل.',
      'aiFeatures': 'ميزات الذكاء الاصطناعي',
      'aiPowered': 'مدعوم بالذكاء الاصطناعي',
      'aiDisclaimer': 'ملخص تقني',
      'aiDisclaimerFull': 'هذا ملخص تقني ولا يغني عن التفسير الكامل.',
      'aiOffline': 'هذه الميزة تتطلب اتصالاً بالإنترنت.',
      'aiTimeout': 'تعذر الحصول على استجابة في الوقت المناسب.',
      'aiRetry': 'حاول مرة أخرى',
      'aiUnavailable': 'الذكاء الاصطناعي غير متاح حالياً.',
      'aiQuotaExhausted': 'لقد وصلت إلى حد الاستخدام المجاني اليوم. حاول غداً.',
      'aiQuotaRemaining': 'المتبقي اليوم',
      'aiQuotaFormat': '{remaining}/{total} متبقي اليوم',
      'aiProviderError': 'حدث خطأ تقني. حاول مرة أخرى.',
      'aiSafetyBlocked': 'تعذرت معالجة هذا الطلب بأمان.',
      'aiQuotaRemainingFormat': '{remaining}/{total} متبقي اليوم',
      'aiPremiumFeature': 'الذكاء الاصطناعي غير المحدود ميزة مميزة.',
      'refusesFatwa': 'هذه الميزة لا تقدم فتاوى أو أحكام شرعية.',
      'technicalSummary': 'ملخص تقني',
      'referToScholar': 'يرجى الرجوع إلى عالم مؤهل للأحكام.',
      'upgradeForUnlimitedAi': 'ترقية للحصول على طلبات ذكاء اصطناعي غير محدودة',
      'storiesAddToFavorites': 'أضف إلى المفضلة',
      'storiesRemoveFromFavorites': 'أزل من المفضلة',
      'storiesNoFavorites': 'لا توجد قصص مفضلة بعد.',
      'storiesNoStoriesFound': 'لم يتم العثور على قصص.',
      'storiesReadingProgress': 'تقدم القراءة',
      'storiesCompleted': 'مكتملة',
      'storiesFavorites': 'المفضلة',
      'storiesContinueReading': 'واصل القراءة',
      'storiesReadNow': 'اقرأ الآن',
      'storiesStartReading': 'ابدأ القراءة',
      'storiesOpenInReader': 'افتح في القارئ',
      'storiesShareUnavailable': 'تعذرت مشاركة هذا الفصل الآن.',
    },
    'en': {
      'appTitle': 'Quran Kareem',
      'splashTitle': 'Quran Kareem',
      'splashSubtitle': 'Premium Edition',
      'enterFullscreen': 'Enter full reading mode',
      'restoreReaderChrome': 'Show reader controls',
      'bookmarkUpdated': 'Bookmark updated',
      'verseActionAyah': 'Ayah',
      'verseActionListen': 'Listen',
      'verseActionInsights': 'Insights',
      'verseActionBookmark': 'Bookmark',
      'verseActionShare': 'Share',
      'verseActionTranslations': 'Translations',
      'verseActionCopy': 'Copy',
      'verseActionNote': 'Note',
      'verseActionTadabbur': 'Tadabbur',
      'verseMetadataUnavailable': 'Unable to load surah details right now.',
      'verseShareUnavailable': 'Unable to share this verse right now.',
      'verseCopyUnavailable': 'Unable to copy this verse right now.',
      'verseCopied': 'Verse copied.',
      'verseAudioUnavailable': 'Unable to play this verse right now.',
      'verseInsightsUnavailable':
          'Unable to open tafsir and tajweed right now.',
      'verseTranslationUnavailable':
          'Unable to open this verse translation right now.',
      'verseNoteHint': 'Write your note for this verse...',
      'verseNoteSave': 'Save',
      'verseNoteDelete': 'Delete',
      'verseNoteSaved': 'Note saved.',
      'verseNoteDeleted': 'Note deleted.',
      'verseNoteUnavailable': 'Unable to open this verse note right now.',
      'verseNoteLoading': 'Loading note...',
      'readerModeScroll': 'Scroll mode',
      'readerModePage': 'Page mode',
      'readerModeTranslation': 'Translation mode',
      'readerNightModeSheetTitle': 'Night Reader',
      'readerNightModeNormal': 'Normal',
      'readerNightModeNight': 'Night',
      'readerNightModeAmoled': 'AMOLED',
      'readerNightModeNormalDescription': 'Standard reader colors',
      'readerNightModeNightDescription': 'Comfortable low-light palette',
      'readerNightModeAmoledDescription': 'Pure black palette for OLED screens',
      'readerToggleToScroll': 'Switch to scroll mode',
      'readerToggleToPage': 'Switch to page mode',
      'readerQuickJump': 'Quick jump',
      'readerSurahCountLabel': 'surahs',
      'readerSurahLoadError': 'Unable to load surahs right now.',
      'errorLoadingData': 'Unable to load this data right now.',
      'errorRetry': 'Retry',
      'mushafFontsTitle': 'Mushaf fonts',
      'mushafFontsNotes':
          'Download the mushaf fonts to match the Madinah Mushaf appearance.',
      'mushafFontsDownloading': 'Downloading...',
      'surahPrefix': 'Surah',
      'readerSurahList': 'Surah list',
      'translationModeLoading': 'Loading translation...',
      'translationModeRetry': 'Retry',
      'translationModeError': 'Unable to load translation right now.',
      'translationModeEmpty':
          'No translation is available for these verses yet.',
      'translationVerseFallback': 'Translation is unavailable for this verse.',
      'ayahShareCardTitle': 'Ayah share card',
      'ayahShareCardSubtitle':
          'Choose a template and preview the card before sharing.',
      'ayahShareCardShareAction': 'Share image',
      'ayahShareCardTranslationToggle': 'Include translation',
      'ayahShareCardPreparing': 'Preparing card...',
      'ayahShareCardRetry': 'Retry',
      'ayahShareCardMissingTemplate': 'Unable to load this template right now.',
      'ayahShareCardExportUnavailable':
          'Unable to prepare this card right now.',
      'ayahShareCardShareUnavailable': 'Unable to share this card right now.',
      'premiumAyahShareCardsTitle': 'Ayah Share Cards Pro',
      'premiumAyahShareCardsSubtitle': 'Unlock premium templates',
      'premiumAyahShareCardsLockedTemplateBody':
          'Unlock photo 4 through photo 10 and use them in your share cards.',
      'premiumPaywallPurchaseAction': 'Unlock premium',
      'premiumPaywallRestoreAction': 'Restore purchase',
      'premiumPaywallWorking': 'Checking purchase...',
      'premiumBillingUnavailable':
          'Billing is unavailable on this device right now.',
      'ayahShareCardTemplateWhiteStop': 'Light template',
      'ayahShareCardTemplateBrownStop': 'Brown template',
      'tafsirBrowserTitle': 'Tafsir Browser',
      'tafsirBrowserOpenFull': 'Open full tafsir browser',
      'tafsirBrowserLoading': 'Loading tafsir...',
      'tafsirBrowserLoadError': 'Unable to load tafsir right now.',
      'tafsirBrowserSourceUnavailable':
          'This tafsir source is not available on this device.',
      'tafsirBrowserInvalidVerse': 'Unable to open tafsir for this verse.',
      'tafsirBrowserSourceLabel': 'Source',
      'tafsirBrowserFootnotesTitle': 'Footnotes',
      'tafsirBrowserPrevious': 'Previous',
      'tafsirBrowserNext': 'Next',
      'insightSectionTafsir': 'Tafsir',
      'insightSectionWordMeaning': 'Word Meanings',
      'insightSectionAsbaab': 'Reasons for Revelation',
      'insightSectionRelated': 'Related Verses',
      'insightSectionUnavailable': 'Currently unavailable',
      'insightSectionCollapse': 'Collapse',
      'insightSectionExpand': 'Expand',
      'insightWordRoot': 'Root',
      'insightAsbaabSource': 'Source',
      'insightRelatedOpen': 'Open Verse',
      'insightRelatedTagThematic': 'Thematic',
      'insightRelatedTagLinguistic': 'Linguistic',
      'verseAudioComingSoon': 'Audio recitation is coming soon',
      'audioHubTitle': 'Audio',
      'audioHubLoading': 'Loading audio player...',
      'audioHubLoadError': 'Unable to load the audio player right now.',
      'audioHubRetry': 'Retry',
      'audioHubSelectReciter': 'Select reciter',
      'audioHubCurrentReciter': 'Current reciter',
      'audioHubReciterListUnavailable':
          'Unable to load reciter list right now.',
      'audioHubReciterChangeFailed': 'Unable to switch reciter right now.',
      'audioHubSelectSurah': 'Select surah',
      'audioHubSurahListUnavailable': 'Unable to load surah list right now.',
      'audioHubPlay': 'Play',
      'audioHubStop': 'Stop and close',
      'audioHubPause': 'Pause',
      'audioHubPrevious': 'Previous surah',
      'audioHubNext': 'Next surah',
      'audioHubSurah': 'Surah',
      'audioHubAyahs': 'Ayahs',
      'audioDownloadsOpen': 'Open downloads manager',
      'audioDownloadsTitle': 'Downloads',
      'audioDownloadsEmptyTitle': 'Audio downloads will appear here.',
      'audioDownloadsDownloadedSection': 'Downloaded reciters',
      'audioDownloadsAvailableSection': 'Available to download',
      'audioDownloadsNoDownloadedReciters': 'No audio downloads yet.',
      'audioDownloadsNoAvailableReciters':
          'All supported reciters are already listed here.',
      'audioDownloadsTotalStorage': 'Total storage',
      'audioDownloadsDownloadedReciters': 'Downloaded reciters',
      'audioDownloadsActiveDownload': 'Downloading surah',
      'audioDownloadsSurahCount': 'surahs',
      'audioDownloadsLocalSize': 'Local size',
      'audioDownloadsStatusAvailable': 'Not downloaded',
      'audioDownloadsStatusDownloaded': 'Downloaded',
      'audioDownloadsStatusDownloading': 'Downloading',
      'audioDownloadsStatusFailed': 'Download failed',
      'audioDownloadsDownload': 'Download',
      'audioDownloadsDelete': 'Delete',
      'audioDownloadsRetry': 'Retry',
      'audioDownloadsCancel': 'Cancel',
      'audioDownloadsLoadError':
          'Unable to load the downloads manager right now.',
      'audioDownloadsUnavailableMessage':
          'Audio downloads are not supported on this device right now.',
      'audioDownloadsActionFailed': 'Unable to complete this action right now.',
      'libraryTitle': 'Library',
      'libraryTabSurahs': 'Surahs',
      'libraryTabKhatmas': 'Khatmas',
      'libraryTabManualSaves': 'Manual saves',
      'libraryTabAutoSave': 'Auto save',
      'librarySearchHint': 'Search the Quran...',
      'libraryRecentSearches': 'Recent searches',
      'librarySearchClearHistory': 'Clear',
      'librarySearchResultsLoading': 'Searching ayahs...',
      'librarySearchResultsEmpty': 'No matching ayahs',
      'librarySearchLoadError': 'Unable to load search results right now.',
      'librarySearchKindAyahs': 'Ayahs',
      'librarySearchKindTranslations': 'Translations',
      'librarySearchKindTopics': 'Topics',
      'librarySearchScopeFullQuran': 'Full Quran',
      'librarySearchScopeCurrentSurah': 'Current surah',
      'libraryTranslationSearchResultsLoading': 'Searching translations...',
      'libraryTranslationSearchResultsEmpty': 'No matching translations',
      'libraryTranslationSearchLoadError':
          'Unable to load translation results right now.',
      'libraryTopicsLoading': 'Loading topics...',
      'libraryTopicsLoadError': 'Unable to load topics right now.',
      'libraryTopicsEmpty': 'No matching topics',
      'libraryTopicsCategoryAll': 'All',
      'libraryTopicsCategoryStories': 'Stories',
      'libraryTopicsCategoryLaws': 'Laws',
      'libraryTopicsCategoryAfterlife': 'Afterlife',
      'libraryTopicsDetailsLoading': 'Loading topic references...',
      'libraryTopicsDetailsLoadError':
          'Unable to load topic references right now.',
      'libraryTopicsDetailsEmpty':
          'No verses are available for this topic yet.',
      'libraryNoResults': 'No results',
      'librarySurahsLoading': 'Loading surahs...',
      'librarySurahsLoadError': 'Unable to load surahs right now.',
      'libraryKhatmasCreate': 'New khatma',
      'libraryKhatmasEmptyTitle': 'No khatmas yet',
      'libraryKhatmasEmptySubtitle':
          'Create a new khatma to start tracking your completion.',
      'libraryManualSavesEmptyTitle': 'No manual saves yet',
      'libraryManualSavesEmptySubtitle':
          'Save verses manually from the reader to find them here.',
      'libraryAutoSaveEmptyTitle': 'No auto-saved position yet',
      'libraryAutoSaveEmptySubtitle':
          'Start reading and the latest saved position will appear here.',
      'libraryAutoSaveLoading': 'Loading the latest saved position...',
      'libraryAutoSaveLoadError':
          'Unable to load the auto-saved position right now.',
      'libraryAutoSaveCardTitle': 'Latest auto save',
      'libraryAyahLabel': 'Ayah',
      'libraryPageLabel': 'Page',
      'librarySavedAtLabel': 'Saved',
      'mushafSetupTitle': 'Prepare Mushaf',
      'mushafSetupDescription':
          'Download the mushaf and fonts once so reading and scrolling stay smooth from the first use.',
      'mushafSetupStart': 'Start download',
      'mushafSetupInProgress': 'Preparing the full mushaf...',
      'mushafSetupRetry': 'Retry',
      'mushafSetupError':
          'Unable to prepare the mushaf right now. Make sure enough storage is available, then try again.',
      'mushafSetupRequired':
          'Mushaf preparation is required before continuing.',
      'mushafSetupBridgeTitle': 'Finishing your first setup',
      'mushafSetupBridgeDescription':
          'The mushaf is still being prepared in the background so the first reading experience stays smooth.',
      'onboardingEyebrow': 'A guided opening',
      'onboardingSkip': 'Skip',
      'onboardingNext': 'Next',
      'onboardingStart': 'Start now',
      'onboardingReadTitle': 'Read as you like',
      'onboardingReadDescription':
          'Scroll mode, page mode, and translation stay together in one calm reader.',
      'onboardingListenTitle': 'Listen with focus',
      'onboardingListenDescription':
          'Move with the recitation through a dedicated audio experience built into the app.',
      'onboardingSaveTitle': 'Save and return with ease',
      'onboardingSaveDescription':
          'Search, topics, notes, and memorization tools keep every important verse close.',
      'onboardingDailyTitle': 'With you through the day',
      'onboardingDailyDescription':
          'Prayer times and Qibla sit inside your daily tools without leaving the app.',
      'onboardingBeginTitle': 'Begin your journey',
      'onboardingBeginDescription':
          'Everything you need for reading, listening, and daily follow-up lives in one place.',
      'onboardingBackgroundLoading': 'Preparing the mushaf in the background',
      'onboardingBackgroundReady': 'The mushaf is ready for your first session',
      'navReader': 'Reader',
      'navAudio': 'Audio',
      'navLibrary': 'Library',
      'navMemorization': 'Memorization',
      'navMore': 'Home Tools',
      'memorizationTitle': 'Memorization',
      'memorizationTabSessions': 'Sessions',
      'memorizationTabKhatmas': 'Khatmas',
      'memorizationTabBookmarks': 'Manual Saves',
      'memorizationSessionsEmptyTitle': 'No sessions yet',
      'memorizationSessionsEmptySubtitle':
          'Start reading in the mushaf and your sessions will be saved here.',
      'memorizationKhatmasNew': 'New Khatma',
      'memorizationKhatmasActive': 'Active Khatmas',
      'memorizationKhatmasCompleted': 'Completed Khatmas',
      'memorizationKhatmasEmptyTitle': 'No khatmas yet',
      'memorizationKhatmasEmptySubtitle':
          'Create a new khatma and start your journey.',
      'memorizationBookmarksEmptyTitle': 'No saved verses',
      'memorizationBookmarksEmptySubtitle':
          'Tap on a verse number in the mushaf to save it here.',
      'memorizationHubHeroEyebrow': 'Current plan',
      'memorizationHubNoActiveTitle': 'No active khatma',
      'memorizationHubNoActiveSubtitle':
          'Create a new khatma to make resume and progress available here.',
      'memorizationHubResumeSubtitle':
          'Resume your active khatma from its latest saved position when available.',
      'memorizationHubStartSubtitle':
          'This khatma is ready to start from the beginning.',
      'memorizationHubResume': 'Resume',
      'memorizationHubAllSessions': 'All sessions',
      'memorizationHubRecentSessions': 'Recent sessions',
      'memorizationHubRecentSessionsSubtitle': 'Automatic reading saves',
      'memorizationHubKhatmasTitle': 'Khatmas',
      'memorizationHubKhatmasSubtitle': 'Your active and completed plans',
      'memorizationHubBookmarksTitle': 'Manual saves',
      'memorizationHubBookmarksSubtitle':
          'Verses you saved manually from the reader',
      'memorizationHubUpcomingReviewsTitle': 'Upcoming reviews',
      'memorizationHubUpcomingReviewsSubtitle':
          'Automatic reviews for the ranges you have already completed.',
      'memorizationReviewsStart': 'Start reviews',
      'memorizationReviewsDueCount': '{count} due now',
      'memorizationReviewsNextReview': 'Next review',
      'memorizationReviewsToday': 'Today',
      'memorizationReviewsTomorrow': 'Tomorrow',
      'memorizationReviewsInDays': 'In {days} days',
      'memorizationReviewsOverdueDays': '{days} days late',
      'memorizationReviewsQueueTitle': 'Review queue',
      'memorizationReviewsDueSectionTitle': 'Due now',
      'memorizationReviewsUpcomingSectionTitle': 'Later',
      'memorizationReviewsQueueEmptyTitle': 'No reviews yet',
      'memorizationReviewsQueueEmptySubtitle':
          'Finish a khatma range to unlock automatic reviews here.',
      'memorizationReviewsPageRange': 'Pages {start} - {end}',
      'memorizationReviewsSessionTitle': 'Review session',
      'memorizationReviewsOpenReader': 'Open in reader',
      'memorizationReviewsOpenReaderFirst':
          'Open the saved range in the reader, then choose how it felt.',
      'memorizationReviewsChooseResult': 'How was this review?',
      'memorizationReviewsEasy': 'Easy',
      'memorizationReviewsMedium': 'Medium',
      'memorizationReviewsHard': 'Hard',
      'memorizationReviewsUnableToOpenReader':
          'Unable to open this review in the reader right now.',
      'memorizationHubStatActiveKhatmas': 'Active khatmas',
      'memorizationHubStatRecentSessions': 'Recent sessions',
      'memorizationHubStatBookmarks': 'Bookmarks',
      'memorizationHubProgressLabel': 'Progress',
      'memorizationKhatmaCompletedBadge': 'Completed',
      'memorizationSessionDurationMinutes': '{minutes} min',
      'memorizationNewKhatmaDialogTitle': 'New khatma',
      'memorizationNewKhatmaNameLabel': 'Khatma name',
      'memorizationNewKhatmaDurationLabel': 'Khatma duration',
      'memorizationNewKhatmaOptionWeek': '1 week',
      'memorizationNewKhatmaOptionTenDays': '10 days',
      'memorizationNewKhatmaOptionFifteenDays': '15 days',
      'memorizationNewKhatmaOptionMonth': '1 month',
      'memorizationNewKhatmaOptionTwoMonths': '2 months',
      'memorizationNewKhatmaStart': 'Start khatma',
      'memorizationPlannerEyebrow': 'Khatma planner',
      'memorizationPlannerDailyAssignment': 'Daily assignment',
      'memorizationPlannerReadingStreak': 'Reading streak',
      'memorizationPlannerTrackedTime': 'Tracked time',
      'memorizationPlannerPagesRemaining': 'Pages left',
      'memorizationPlannerNextPage': 'Next page',
      'memorizationPlannerExpectedToday': 'Expected today',
      'memorizationPlannerResume': 'Resume reading',
      'memorizationPlannerOnTrack': 'On track',
      'memorizationPlannerBehind': 'Behind schedule',
      'achievementsTitle': 'Achievements',
      'achievementsNextLevelLabel': 'Next level progress',
      'achievementsBadgesTitle': 'Badges',
      'achievementsBadgesSubtitle':
          'Unlocked and upcoming milestones from your memorization activity.',
      'achievementsRecordsTitle': 'Personal records',
      'achievementsRecordsSubtitle':
          'Your best local milestones without social ranking.',
      'achievementsMomentumTitle': 'Your momentum',
      'achievementsMomentumSubtitle':
          'See what you earned and the next milestone waiting for you.',
      'achievementsMomentumBadgesEarned': 'Badges earned',
      'achievementsMomentumNextMilestone': 'Next milestone',
      'achievementsMomentumAllUnlockedTitle': 'All badges earned',
      'achievementsMomentumAllUnlockedSubtitle':
          'You unlocked the full achievements catalog for this release.',
      'achievementsUnlocksTitle': 'New unlocks',
      'achievementsUnlocksDismiss': 'Got it',
      'achievementsZeroTitle': 'No achievements yet',
      'achievementsZeroSubtitle':
          'Read, review, or start a khatma and your progress will appear here.',
      'achievementsStatVisits': 'Visits',
      'achievementsStatMinutes': 'Minutes',
      'achievementsStatKhatmas': 'Khatmas',
      'achievementsStatReviews': 'Reviews',
      'achievementsProgressValue': '{current} / {target} to next level',
      'achievementsBadgeProgress': '{current} / {target}',
      'achievementsRecordBestStreakDays': 'Best streak',
      'achievementsRecordTrackedMinutes': 'Tracked minutes',
      'achievementsRecordCompletedKhatmas': 'Completed khatmas',
      'achievementsRecordReviewedReviews': 'Reviewed ranges',
      'achievementsRecordTotalVisits': 'Total visits',
      'achievementsBadgeStatusUnlocked': 'Unlocked',
      'achievementsBadgeStatusInProgress': 'In progress',
      'achievementsBadgeFirstStepsTitle': 'First steps',
      'achievementsBadgeFirstStepsDescription':
          'Finish your first reading visit.',
      'achievementsBadgeSteadyReaderTitle': 'Steady reader',
      'achievementsBadgeSteadyReaderDescription': 'Reach five reading visits.',
      'achievementsBadgeStreakGuardianTitle': 'Streak guardian',
      'achievementsBadgeStreakGuardianDescription':
          'Hold a five-day reading streak.',
      'achievementsBadgeFocusMinutesTitle': 'Focus minutes',
      'achievementsBadgeFocusMinutesDescription':
          'Track thirty minutes of reading.',
      'achievementsBadgeDeepFocusTitle': 'Deep focus',
      'achievementsBadgeDeepFocusDescription':
          'Track one hundred and twenty minutes of reading.',
      'achievementsBadgeFirstKhatmaTitle': 'First khatma',
      'achievementsBadgeFirstKhatmaDescription': 'Complete one khatma.',
      'achievementsBadgeKhatmaFinisherTitle': 'Khatma finisher',
      'achievementsBadgeKhatmaFinisherDescription': 'Complete three khatmas.',
      'achievementsBadgeReviewStarterTitle': 'Review starter',
      'achievementsBadgeReviewStarterDescription':
          'Finish your first spaced review.',
      'achievementsBadgeReviewKeeperTitle': 'Review keeper',
      'achievementsBadgeReviewKeeperDescription':
          'Record five review repetitions.',
      'achievementsBadgeReviewArchivistTitle': 'Review archivist',
      'achievementsBadgeReviewArchivistDescription':
          'Review three spaced ranges.',
      'achievementsBadgeKhatmaBuilderTitle': 'Khatma builder',
      'achievementsBadgeKhatmaBuilderDescription':
          'Keep two khatmas in your history.',
      'achievementsBadgeStreakLighthouseTitle': 'Streak lighthouse',
      'achievementsBadgeStreakLighthouseDescription':
          'Reach a ten-day reading streak.',
      'homeToolsTitle': 'Home Tools',
      'homeToolsPrayerTimes': 'Prayer Times',
      'homeToolsLoadingPrayerTimes': 'Loading prayer times...',
      'homeToolsPrayerError': 'Unable to load prayer times right now.',
      'homeToolsPrayerCached': 'Using saved data',
      'homeToolsPrayerCachedAt': 'Saved at {time}',
      'homeToolsRetry': 'Retry',
      'homeToolsOpenTracker': 'Open tracker',
      'homeToolsQibla': 'Qibla',
      'homeToolsAzkar': 'Azkar',
      'analyticsTitle': 'Analytics',
      'analyticsLoading': 'Loading analytics...',
      'analyticsError': 'Unable to load analytics right now.',
      'analyticsEmptyTitle': 'Your analytics will appear here',
      'analyticsEmptySubtitle':
          'Read, review, and track prayers to unlock your weekly and monthly insights.',
      'analyticsPeriodThisWeek': 'This week',
      'analyticsPeriodThisMonth': 'This month',
      'analyticsReadingHeroEyebrow': 'Reading overview',
      'analyticsReadingHeroTitle': 'Your reading time for this period',
      'analyticsReadingVisitsLabel': 'Visits',
      'analyticsReadingStreakLabel': 'Current streak',
      'analyticsDeltaNew': 'New this period',
      'analyticsDeltaNoChange': 'No change from previous period',
      'analyticsDeltaComparedToPrevious': '{value} from previous period',
      'analyticsReadingAverageDailyLabel': 'Daily average',
      'analyticsReadingPagesLabel': 'Pages visited',
      'analyticsReadingDaysLabel': 'Reading days',
      'analyticsReadingSectionTitle': 'Reading details',
      'analyticsReadingSectionSubtitle':
          'Average pace, page coverage, and reading-day consistency',
      'analyticsTopSurahsTitle': 'Top surahs',
      'analyticsTopSurahsSubtitle':
          'The surahs you returned to most in this period',
      'analyticsTopSurahsEmptyTitle': 'No surahs yet',
      'analyticsTopSurahsEmptySubtitle':
          'Your most-read surahs will appear after a few visits.',
      'analyticsVisitCount': '{count} visits',
      'analyticsMemorizationSectionTitle': 'Memorization',
      'analyticsMemorizationSectionSubtitle':
          'Khatma momentum and review follow-through for this period',
      'analyticsMemorizationEmptyTitle': 'No memorization activity yet',
      'analyticsMemorizationEmptySubtitle':
          'Khatma progress and review consistency will appear here once you start.',
      'analyticsMemorizationActiveKhatmasLabel': 'Active khatmas',
      'analyticsMemorizationDueReviewsLabel': 'Due reviews',
      'analyticsMemorizationAdherenceLabel': 'Adherence',
      'analyticsReviewAdherenceEmptyValue': 'No review data',
      'analyticsReviewEmptySubtitle':
          'No review items landed in this period yet.',
      'analyticsPrayerSectionTitle': 'Prayer consistency',
      'analyticsPrayerSectionSubtitle':
          'How steadily you tracked prayers in this period',
      'analyticsPrayerEmptyTitle': 'No prayer tracking yet',
      'analyticsPrayerEmptySubtitle':
          'Prayer consistency will appear here once you start checking prayers.',
      'analyticsPrayerPerfectDaysLabel': 'Perfect days',
      'analyticsPrayerPerfectState': 'Perfect consistency in this period',
      'analyticsPrayerTrackedDaysLabel': 'Tracked days',
      'homeToolsSettings': 'Settings',
      'adhkarLoading': 'Loading adhkar...',
      'adhkarError': 'Unable to load adhkar right now.',
      'adhkarCounterTitle': 'Digital tasbeeh',
      'adhkarCounterIncrement': 'Increase counter',
      'adhkarCounterReset': 'Reset',
      'adhkarCounterTargetLabel': 'Target',
      'adhkarCounterFreeTarget': 'Open target',
      'adhkarItemsLabel': 'entries',
      'adhkarRepetitionLabel': 'Repeat',
      'adhkarSourceLabel': 'Source',
      'adhkarSourceDetailLabel': 'Detailed source',
      'adhkarAuthenticityLabel': 'Authenticity',
      'adhkarTimingLabel': 'When to say it',
      'adhkarVirtueLabel': 'Virtue',
      'adhkarNoteLabel': 'Note',
      'adhkarTrustedSourceLabel': 'Trusted source',
      'adhkarCategoryNotFound': 'This adhkar category is unavailable.',
      'adhkarEmptyCategory':
          'No adhkar entries are available in this category yet.',
      'adhkarGroupDailyCore': 'Daily core',
      'adhkarGroupHeartWork': 'Heart and repentance',
      'adhkarGroupLifeNeeds': 'Needs and occasions',
      'adhkarGroupSourceLed': 'From Quran and Sunnah',
      'adhkarCategoryMorning': 'Morning adhkar',
      'adhkarCategoryEvening': 'Evening adhkar',
      'adhkarCategoryAfterPrayer': 'After prayer',
      'adhkarCategorySleep': 'Sleep',
      'adhkarCategoryWaking': 'Waking up',
      'adhkarCategoryIstighfar': 'Istighfar',
      'adhkarCategoryRizq': 'Rizq',
      'adhkarCategoryDistress': 'Distress',
      'adhkarCategoryTravel': 'Travel',
      'adhkarCategoryQuranDuas': 'Quran duas',
      'adhkarCategorySunnahDuas': 'Sunnah duas',
      'quranStories': 'Quran Stories',
      'storiesAll': 'All',
      'storiesProphets': 'Prophets',
      'storiesQuranic': 'Quranic',
      'storiesSearchHint': 'Search stories',
      'storiesNoResults': 'No stories found.',
      'storiesPreviousChapter': 'Previous',
      'storiesNextChapter': 'Next',
      'storiesLesson': 'Lesson',
      'storiesChapterOf': 'Chapter {current} of {total}',
      'storiesVerseCount': '{count} verses',
      'storiesMarkAsRead': 'Mark as read',
      'storiesBackToHub': 'Back to stories',
      'storiesCompletedTitle': 'Story completed',
      'storiesCompletedMessage': 'You finished all chapters of this story.',
      'storiesShareChapter': 'Share chapter',
      'quizHubTitle': 'Quiz hub',
      'quizHubDescription':
          'Choose a quiz type and tune the session before you begin.',
      'quizHistoryTitle': 'History',
      'quizHistoryEmpty':
          'Complete your first quiz to start tracking progress.',
      'quizHistoryChartMinimum': 'Complete more quizzes to see your progress',
      'storiesChapterCount': '{count} chapters',
      'storiesMinutesCount': '{count} min',
      'storiesReadSummary': '{readCount} of {totalCount} stories read',
      'quizTypeVerseCompletion': 'Verse completion',
      'quizTypeVerseCompletionDesc':
          'Complete the missing continuation of an ayah.',
      'quizTypeWordMeaning': 'Word meaning',
      'quizTypeWordMeaningDesc':
          'Choose the correct meaning for a Quranic word.',
      'quizTypeVerseTopic': 'Verse topic',
      'quizTypeVerseTopicDesc': 'Match a verse snippet to its topic.',
      'quizUnavailable': 'Unavailable',
      'quizStart': 'Start',
      'quizConfigTitle': 'Quiz setup',
      'quizQuestionCount': 'Question count',
      'quizSurahFilter': 'Surah',
      'quizAllQuran': 'All Quran',
      'quizDifficultyLabel': 'Difficulty',
      'quizDifficultyEasy': 'Easy',
      'quizDifficultyMedium': 'Medium',
      'quizDifficultyHard': 'Hard',
      'quizBegin': 'Begin',
      'quizProgress': '{current} / {total}',
      'quizCompleteThe': 'Complete the verse',
      'quizWhatMeans': 'What does this word mean?',
      'quizWhichTopic': 'Which topic matches this verse?',
      'quizCorrect': 'Correct',
      'quizIncorrect': 'Incorrect',
      'quizNext': 'Next',
      'quizShowFullVerse': 'Show full verse',
      'quizExitConfirmTitle': 'Exit quiz?',
      'quizExitConfirmMessage': 'This session will be discarded.',
      'quizExitConfirm': 'Exit',
      'quizExitCancel': 'Stay',
      'quizMistakesReviewCount': '{count} to review',
      'quizResultTitle': 'Quiz results',
      'quizResultScore': 'Score',
      'quizResultReviewTitle': 'Review',
      'quizResultTryAgain': 'Try again',
      'quizResultBackToHub': 'Back to hub',
      'quizResultYourAnswer': 'Your answer',
      'quizResultCorrectAnswer': 'Correct answer',
      'quizResultExcellent': 'Excellent',
      'quizResultGreat': 'Very good',
      'quizResultGood': 'Good start',
      'quizResultPractice': 'Keep practicing',
      'quizResultVeryGood': 'Very good',
      'quizResultGoodStart': 'Good start',
      'quizResultKeepPracticing': 'Keep practicing',
      'quizTryAgain': 'Try again',
      'quizBackToHub': 'Back to hub',
      'quizReviewCorrectAnswer': 'Correct answer',
      'quizReviewYourAnswer': 'Your answer',
      'quizHistoryDate': 'Date',
      'quizHistoryScore': 'Score',
      'quizHistoryDifficulty': 'Difficulty',
      'quizMistakesBadge': 'Mistakes',
      'quizResultCardSaveAction': 'Save as image',
      'quizResultCardShareAction': 'Share',
      'quizResultCardSaved': 'Image saved to your photos.',
      'quizResultCardSaveUnavailable': 'Unable to save this card right now.',
      'quizResultCardShareUnavailable': 'Unable to share this card right now.',
      'quizResultCardExportUnavailable':
          'Unable to prepare this card right now.',
      'quizResultCardSavePermissionDenied':
          'Photo permission was denied. Opening the share sheet instead.',
      'memorizationQuizAction': 'Quizzes',
      'settingsTitle': 'Settings',
      'settingsPreviewEyebrow': 'Live preview',
      'settingsPreviewHelp':
          'Changes here apply immediately during the current session.',
      'settingsPreviewVerse': 'In the name of Allah, the Most Merciful',
      'settingsPreviewTranslation':
          'Reading and interface styling update immediately with your choices.',
      'settingsSectionAppearance': 'Appearance',
      'settingsSectionReading': 'Reading',
      'settingsThemeLabel': 'Theme',
      'settingsThemeSystem': 'System',
      'settingsThemeLight': 'Light',
      'settingsThemeDark': 'Dark',
      'settingsLanguageLabel': 'Language',
      'settingsLanguageArabic': 'Arabic',
      'settingsLanguageEnglish': 'English',
      'settingsFontSizeLabel': 'Arabic font size',
      'settingsFontSizeHelp':
          'Applies to the preview and app-owned Arabic surfaces while keeping authentic mushaf pages unchanged.',
      'settingsReaderModeLabel': 'Default reader mode',
      'settingsTajweedLabel': 'Tajweed',
      'settingsTajweedHelp':
          'Updates Tajweed coloring in the mushaf reader immediately when available.',
      'settingsSectionNightReader': 'Night Reader',
      'settingsNightReaderAutoEnableLabel': 'Auto-enable',
      'settingsNightReaderAutoEnableHelp':
          'Automatically apply your saved night style during the configured local hours.',
      'settingsNightReaderStartLabel': 'Start time',
      'settingsNightReaderEndLabel': 'End time',
      'settingsNightReaderPreferredStyleLabel': 'Preferred night style',
      'settingsNightReaderAutoEnableOn': 'Auto-enable on',
      'settingsNightReaderAutoEnableOff': 'Auto-enable off',
      'settingsNightReaderStyleNight': 'Night',
      'settingsNightReaderStyleAmoled': 'AMOLED',
      'settingsNightReaderInvalidSchedule':
          'Start and end times must be different.',
      'settingsNotificationsEntryTitle': 'Notifications',
      'settingsNotificationsEntrySubtitle':
          'Manage reminder families, times, and notification access.',
      'notificationsSettingsTitle': 'Notifications',
      'notificationsSettingsFamiliesTitle': 'Reminder families',
      'notificationsTimeLabel': 'Reminder time',
      'notificationsPermissionRequestAction': 'Allow notifications',
      'notificationsPermissionUnknownTitle': 'Notification access',
      'notificationsPermissionUnknownBody':
          'Choose which reminders you want, then allow notifications from inside the app.',
      'notificationsPermissionGrantedTitle': 'Notifications are ready',
      'notificationsPermissionGrantedBody':
          'Reminder families can schedule and update from inside the app.',
      'notificationsPermissionDeniedTitle': 'Notifications are off',
      'notificationsPermissionDeniedBody':
          'Your reminder choices are saved, but the app cannot deliver them until notification access is allowed.',
      'notificationsPermissionBlockedTitle': 'Notifications are blocked',
      'notificationsPermissionBlockedBody':
          'Notification delivery is blocked at the system level right now.',
      'notificationsPermissionUnavailableTitle': 'Notifications unavailable',
      'notificationsPermissionUnavailableBody':
          'This device does not currently expose local-notification access through the app.',
      'notificationsFamilyDailyWirdTitle': 'Daily wird',
      'notificationsFamilyDailyWirdSubtitle':
          'A daily reminder back into your reading continuity.',
      'notificationsFamilyPrayerTitle': 'Prayer reminder',
      'notificationsFamilyPrayerSubtitle':
          'One reminder for the next upcoming prayer from the current prayer data.',
      'notificationsFamilyFridayKahfTitle': 'Friday Kahf',
      'notificationsFamilyFridayKahfSubtitle':
          'A weekly reminder that opens Surah Al-Kahf on Friday.',
      'notificationsFamilyReviewTitle': 'Spaced review',
      'notificationsFamilyReviewSubtitle':
          'A queue-level reminder for the nearest upcoming review.',
      'notificationsFamilyAdhkarTitle': 'Adhkar',
      'notificationsFamilyAdhkarSubtitle':
          'A daily reminder that opens the adhkar categories.',
      'notificationsFamilyStatusPermissionRequired':
          'Notification permission is still required before this family can be delivered.',
      'notificationsFamilyStatusPrayerUnavailable':
          'Prayer reminders wait until fresh prayer data is available.',
      'notificationsFamilyStatusReviewWaiting':
          'Review reminders stay idle until review items exist or become due.',
      'notificationsReminderDailyWirdTitle': 'Daily wird',
      'notificationsReminderDailyWirdBody':
          'Return to your reading flow and continue where you left off.',
      'notificationsReminderAdhkarTitle': 'Adhkar time',
      'notificationsReminderAdhkarBody':
          'Open the adhkar library and continue your daily remembrance.',
      'notificationsReminderFridayKahfTitle': 'Friday Kahf',
      'notificationsReminderFridayKahfBody':
          'Open Surah Al-Kahf and begin your Friday reading.',
      'notificationsReminderPrayerTitle': 'Prayer reminder',
      'notificationsReminderPrayerBodyPrefix': 'Prepare for',
      'notificationsReminderPrayerBodyGeneric':
          'Open the prayer details view for the next upcoming prayer.',
      'notificationsReminderReviewTitle': 'Review queue',
      'notificationsReminderReviewBody':
          'Your next spaced review is ready in the memorization queue.',
      'prayerDetailsTitle': 'Prayer Details',
      'prayerDetailsLoadingMonth': 'Loading Hijri month...',
      'prayerDetailsError': 'Unable to load this Hijri month right now.',
      'prayerDetailsTrackPrayers': 'Tracked prayers for day',
      'prayerTodayTitle': "Today's Prayer Times",
      'prayerAdherenceToday': "Today's Prayers",
      'prayerAdherenceStreak': '{count} day streak',
      'prayerStatusPast': 'Past',
      'prayerStatusCurrent': 'Current',
      'prayerStatusUpcoming': 'Upcoming',
      'prayerWeeklyTitle': 'This Week',
      'prayerReminderOffsetLabel': 'Remind me',
      'prayerReminderAtAdhan': 'At Adhan time',
      'prayerReminderMinsBefore': '{mins} min before',
      'prayerLabelFajr': 'Fajr',
      'prayerLabelDhuhr': 'Dhuhr',
      'prayerLabelAsr': 'Asr',
      'prayerLabelMaghrib': 'Maghrib',
      'prayerLabelIsha': 'Isha',
      'qiblaCompassTitle': 'Qibla Compass',
      'qiblaCompassLoading': 'Loading Qibla compass...',
      'qiblaCompassError': 'Unable to load the Qibla compass right now.',
      'qiblaCompassDistance': 'Distance',
      'qiblaCompassBearing': 'Qibla bearing',
      'qiblaCompassHeading': 'Current heading',
      'qiblaCompassFacing': 'Facing Qibla',
      'qiblaCompassNotFacing': 'Not facing Qibla yet',
      'qiblaCompassTurnLeft': 'Turn left',
      'qiblaCompassTurnRight': 'Turn right',
      'qiblaCompassCalibrate':
          'Move the phone in a figure-eight to improve compass accuracy.',
      'qiblaCompassSensorUnavailable':
          'Compass data is unavailable on this device right now.',
      'qiblaCompassNeedleHint':
          'Rotate the phone until the Qibla needle points up.',
      'aiFeatures': 'AI Features',
      'aiPowered': 'AI-powered',
      'aiDisclaimer': 'Technical summary',
      'aiDisclaimerFull':
          'This is a technical summary and does not replace the full tafsir.',
      'aiOffline': 'This feature requires an internet connection.',
      'aiTimeout': 'We could not get a response in time.',
      'aiRetry': 'Try again',
      'aiUnavailable': 'AI is currently unavailable.',
      'aiQuotaExhausted':
          'You have reached today\'s free AI limit. Try again tomorrow.',
      'aiQuotaRemaining': 'Remaining today',
      'aiQuotaFormat': '{remaining}/{total} remaining today',
      'aiProviderError': 'A technical error occurred. Please try again.',
      'aiSafetyBlocked': 'We could not process this request safely.',
      'aiQuotaRemainingFormat': '{remaining}/{total} remaining today',
      'simplifyTafsir': 'Simplify tafsir',
      'simplifying': 'Simplifying...',
      'simplifiedSummary': 'Simplified summary',
      'noTafsirToSimplify': 'No tafsir is available to simplify.',
      'tafsirAlreadyShort': 'This tafsir is already brief.',
      'simplifyError': 'We could not simplify this tafsir right now.',
      'smartSearch': 'Smart Search',
      'searchByTopic': 'Search by topic',
      'searchingTopics': 'Searching related topics...',
      'noSmartResults': 'No relevant verses were found for this topic.',
      'smartSearchHint': 'Search by concept, theme, or question.',
      'fallbackToKeyword':
          'Smart search is unavailable offline. Showing keyword matches instead.',
      'searchTopicPlaceholder': 'Search for a Quranic topic...',
      'verseContext': 'Verse Context',
      'contextAndConnection': 'Context and Connection',
      'loadingContext': 'Loading context...',
      'reflectionQuestions': 'Reflection Questions',
      'tadabburQuestions': 'Tadabbur Questions',
      'generatingQuestions': 'Generating reflection questions...',
      'aiPremiumFeature': 'Unlimited AI is a premium feature.',
      'refusesFatwa': 'This feature does not provide fatwas or legal rulings.',
      'technicalSummary': 'Technical summary',
      'referToScholar': 'Please refer to a qualified scholar for rulings.',
      'juzSummary': 'Juz Summary',
      'summarizeJuz': 'Summarize the juz',
      'loadingSummary': 'Loading summary...',
      'upgradeForUnlimitedAi': 'Upgrade for unlimited AI requests',
      'storiesAddToFavorites': 'Add to favorites',
      'storiesRemoveFromFavorites': 'Remove from favorites',
      'storiesNoFavorites': 'No favorite stories yet.',
      'storiesNoStoriesFound': 'No stories found.',
      'storiesReadingProgress': 'Reading progress',
      'storiesCompleted': 'Completed',
      'storiesFavorites': 'Favorites',
      'storiesContinueReading': 'Continue reading',
      'storiesReadNow': 'Read now',
      'storiesStartReading': 'Start reading',
      'storiesOpenInReader': 'Open in reader',
      'storiesShareUnavailable': 'Unable to share this chapter right now.',
    },
  };

  static const Map<String, String> _arabicOverrides = {
    'quizProgress': '{current} / {total}',
    'quizCompleteThe': 'أكمل الآية',
    'quizWhatMeans': 'ما معنى هذه الكلمة؟',
    'quizWhichTopic': 'ما الموضوع المطابق لهذه الآية؟',
    'quizCorrect': 'إجابة صحيحة',
    'quizIncorrect': 'إجابة خاطئة',
    'quizNext': 'التالي',
    'quizShowFullVerse': 'إظهار الآية كاملة',
    'quizExitConfirmTitle': 'إنهاء الاختبار؟',
    'quizExitConfirmMessage': 'سيتم تجاهل هذه الجلسة.',
    'quizExitConfirm': 'خروج',
    'quizExitCancel': 'بقاء',
    'quranStories': 'القصص القرآنية',
    'storiesAll': 'الكل',
    'storiesProphets': 'الأنبياء',
    'storiesQuranic': 'القرآنية',
    'storiesSearchHint': 'ابحث في القصص',
    'storiesNoResults': 'لم يتم العثور على قصص.',
    'storiesPreviousChapter': 'السابق',
    'storiesNextChapter': 'التالي',
    'storiesLesson': 'الدرس',
    'storiesChapterOf': 'الفصل {current} من {total}',
    'storiesVerseCount': '{count} آيات',
    'storiesMarkAsRead': 'تحديد كمقروءة',
    'storiesBackToHub': 'العودة إلى القصص',
    'storiesCompletedTitle': 'اكتملت القصة',
    'storiesCompletedMessage': 'أنهيت جميع فصول هذه القصة.',
    'storiesShareChapter': 'مشاركة الفصل',
    'quizHubTitle': 'المسابقات',
    'quizHistoryTitle': 'السجل',
    'quizHistoryEmpty': 'أكمل أول اختبار لك ليبدأ سجل التقدم.',
    'quizHistoryChartMinimum': 'أكمل اختبارات أكثر لرؤية تقدمك',
    'storiesChapterCount': '{count} فصول',
    'storiesMinutesCount': '{count} د',
    'storiesReadSummary': 'قرأت {readCount} من {totalCount} قصة',
    'quizTypeVerseCompletion': 'إكمال الآية',
    'quizTypeVerseCompletionDesc': 'اختر تتمة الآية الصحيحة من بين الخيارات.',
    'quizTypeWordMeaning': 'معاني الكلمات',
    'quizTypeWordMeaningDesc': 'اختر المعنى الصحيح لكلمة قرآنية.',
    'quizTypeVerseTopic': 'موضوع الآية',
    'quizTypeVerseTopicDesc': 'طابق مقطع الآية مع موضوعه الصحيح.',
    'quizUnavailable': 'غير متاح',
    'quizConfigTitle': 'إعداد الجلسة',
    'quizQuestionCount': 'عدد الأسئلة',
    'quizSurahFilter': 'السورة',
    'quizAllQuran': 'كل القرآن',
    'quizDifficultyLabel': 'الصعوبة',
    'quizDifficultyEasy': 'سهل',
    'quizDifficultyMedium': 'متوسط',
    'quizDifficultyHard': 'صعب',
    'quizBegin': 'ابدأ',
    'quizMistakesReviewCount': '{count} للمراجعة',
    'quizResultTitle': 'نتيجة المسابقة',
    'quizResultReviewTitle': 'مراجعة الأسئلة',
    'quizResultTryAgain': 'أعد المحاولة',
    'quizResultBackToHub': 'العودة للمسابقات',
    'quizResultYourAnswer': 'إجابتك',
    'quizResultCorrectAnswer': 'الإجابة الصحيحة',
    'quizResultExcellent': 'ممتاز',
    'quizResultVeryGood': 'جيد جدًا',
    'quizResultGoodStart': 'بداية جيدة',
    'quizResultKeepPracticing': 'واصل التدريب',
    'quizResultCardSaveAction': 'حفظ كصورة',
    'quizResultCardShareAction': 'مشاركة',
    'quizResultCardSaved': 'تم حفظ الصورة في الصور.',
    'quizResultCardSaveUnavailable': 'تعذر حفظ هذه البطاقة الآن.',
    'quizResultCardShareUnavailable': 'تعذرت مشاركة هذه البطاقة الآن.',
    'quizResultCardExportUnavailable': 'تعذر تجهيز هذه البطاقة الآن.',
    'quizResultCardSavePermissionDenied':
        'تم رفض إذن الصور. سيتم فتح ورقة المشاركة بدلًا من ذلك.',
    'memorizationQuizAction': 'ط§ظ„ظ…ط³ط§ط¨ظ‚ط§طھ',
    'quizHubDescription': 'اختر نوع المسابقة واضبط الجلسة قبل أن تبدأ.',
    'quizStart': 'ابدأ',
    'quizResultScore': 'النتيجة',
    'quizResultGreat': 'جيد جدًا',
    'quizResultGood': 'بداية جيدة',
    'quizResultPractice': 'واصل التدريب',
    'quizTryAgain': 'أعد المحاولة',
    'quizBackToHub': 'العودة للمسابقات',
    'quizReviewCorrectAnswer': 'الإجابة الصحيحة',
    'quizReviewYourAnswer': 'إجابتك',
    'quizHistoryDate': 'التاريخ',
    'quizHistoryScore': 'النتيجة',
    'quizHistoryDifficulty': 'الصعوبة',
    'quizMistakesBadge': 'الأخطاء',
    'verseActionTadabbur': '????',
    'ayahShareCardTitle': 'بطاقة مشاركة الآية',
    'ayahShareCardSubtitle': 'اختر قالبًا وراجع البطاقة قبل المشاركة.',
    'ayahShareCardShareAction': 'مشاركة الصورة',
    'ayahShareCardTranslationToggle': 'إضافة الترجمة',
    'ayahShareCardPreparing': 'جارٍ تجهيز البطاقة...',
    'ayahShareCardRetry': 'إعادة المحاولة',
    'ayahShareCardMissingTemplate': 'تعذر تحميل هذا القالب الآن.',
    'ayahShareCardExportUnavailable': 'تعذر تجهيز البطاقة الآن.',
    'ayahShareCardShareUnavailable': 'تعذرت مشاركة البطاقة الآن.',
    'premiumAyahShareCardsTitle': 'بطاقات مشاركة الآيات برو',
    'premiumAyahShareCardsSubtitle': 'افتح القوالب المميزة',
    'premiumAyahShareCardsLockedTemplateBody':
        'افتح القوالب من الصورة 4 إلى الصورة 10 لاستخدامها في بطاقات المشاركة.',
    'premiumPaywallPurchaseAction': 'فتح الميزة',
    'premiumPaywallRestoreAction': 'استعادة الشراء',
    'premiumPaywallWorking': 'جارٍ التحقق من الشراء...',
    'premiumBillingUnavailable': 'الفوترة غير متاحة على هذا الجهاز حاليًا.',
    'ayahShareCardTemplateWhiteStop': 'قالب فاتح',
    'ayahShareCardTemplateBrownStop': 'قالب بني',
    'readerToggleToScroll': 'تبديل إلى وضع التمرير',
    'readerToggleToPage': 'تبديل إلى وضع الصفحات',
    'mushafFontsTitle': 'خطوط المصحف',
    'mushafFontsNotes':
        'حمّل خطوط المصحف ليصبح مظهر القراءة أقرب إلى مصحف المدينة.',
    'mushafFontsDownloading': 'جارٍ التحميل...',
    'surahPrefix': 'سورة',
    'librarySearchKindAyahs': 'الآيات',
    'librarySearchKindTranslations': 'الترجمات',
    'librarySearchKindTopics': 'المواضيع',
    'libraryTranslationSearchResultsLoading': 'جارٍ البحث في الترجمات...',
    'libraryTranslationSearchResultsEmpty': 'لا توجد ترجمات مطابقة',
    'libraryTranslationSearchLoadError': 'تعذر تحميل نتائج بحث الترجمات الآن.',
    'libraryTopicsLoading': 'جارٍ تحميل الموضوعات...',
    'libraryTopicsLoadError': 'تعذر تحميل الموضوعات الآن.',
    'libraryTopicsEmpty': 'لا توجد موضوعات مطابقة',
    'libraryTopicsCategoryAll': 'الكل',
    'libraryTopicsCategoryStories': 'القصص',
    'libraryTopicsCategoryLaws': 'الأحكام',
    'libraryTopicsCategoryAfterlife': 'الآخرة',
    'libraryTopicsDetailsLoading': 'جارٍ تحميل الآيات المرتبطة...',
    'libraryTopicsDetailsLoadError': 'تعذر تحميل آيات هذا الموضوع الآن.',
    'libraryTopicsDetailsEmpty': 'لا توجد آيات متاحة لهذا الموضوع حالياً.',
    'libraryTitle': 'المكتبة',
    'libraryTabSurahs': 'السور',
    'libraryTabKhatmas': 'الختمات',
    'libraryTabManualSaves': 'الحفظ اليدوي',
    'libraryTabAutoSave': 'الحفظ التلقائي',
    'librarySearchHint': 'ابحث في القرآن...',
    'libraryRecentSearches': 'عمليات البحث الأخيرة',
    'librarySearchClearHistory': 'مسح',
    'librarySearchResultsLoading': 'جارٍ البحث في الآيات...',
    'librarySearchResultsEmpty': 'لا توجد آيات مطابقة',
    'librarySearchLoadError': 'تعذر تحميل نتائج البحث الآن.',
    'librarySearchScopeFullQuran': 'القرآن كامل',
    'librarySearchScopeCurrentSurah': 'السورة الحالية',
    'libraryNoResults': 'لا توجد نتائج',
    'librarySurahsLoading': 'جارٍ تحميل السور...',
    'librarySurahsLoadError': 'تعذر تحميل السور الآن.',
    'libraryKhatmasCreate': 'ختمة جديدة',
    'libraryKhatmasEmptyTitle': 'لا توجد ختمات بعد',
    'libraryKhatmasEmptySubtitle': 'أنشئ ختمة جديدة لتبدأ متابعة التقدم.',
    'libraryManualSavesEmptyTitle': 'لا يوجد حفظ يدوي بعد',
    'libraryManualSavesEmptySubtitle':
        'احفظ الآيات يدويًا من القارئ لتظهر هنا.',
    'libraryAutoSaveEmptyTitle': 'لا يوجد حفظ تلقائي بعد',
    'libraryAutoSaveEmptySubtitle': 'ابدأ القراءة وسيظهر هنا آخر موضع محفوظ.',
    'libraryAutoSaveLoading': 'جارٍ تحميل آخر موضع محفوظ...',
    'libraryAutoSaveLoadError': 'تعذر تحميل موضع الحفظ التلقائي الآن.',
    'libraryAutoSaveCardTitle': 'آخر حفظ تلقائي',
    'libraryAyahLabel': 'آية',
    'libraryPageLabel': 'صفحة',
    'librarySavedAtLabel': 'وقت الحفظ',
    'navReader': 'القارئ',
    'navAudio': 'الصوت',
    'navLibrary': 'المكتبة',
    'navMemorization': 'الحفظ',
    'navMore': 'الأدوات',
    'memorizationTitle': 'حفظ القراءة',
    'memorizationTabSessions': 'جلساتي',
    'memorizationTabKhatmas': 'ختماتي',
    'memorizationTabBookmarks': 'الحفظ اليدوي',
    'memorizationSessionsEmptyTitle': 'لا توجد جلسات بعد',
    'memorizationSessionsEmptySubtitle':
        'ابدأ القراءة في المصحف وستُحفظ جلساتك هنا',
    'memorizationKhatmasNew': 'ختمة جديدة',
    'memorizationKhatmasActive': 'الختمات الجارية',
    'memorizationKhatmasCompleted': 'ختمات مكتملة',
    'memorizationKhatmasEmptyTitle': 'لا توجد ختمات بعد',
    'memorizationKhatmasEmptySubtitle': 'أنشئ ختمة جديدة وابدأ رحلتك',
    'memorizationBookmarksEmptyTitle': 'لا توجد آيات محفوظة',
    'memorizationBookmarksEmptySubtitle':
        'اضغط على رقم الآية في المصحف لحفظها هنا',
    'memorizationHubHeroEyebrow': 'الختمة الحالية',
    'memorizationHubNoActiveTitle': 'لا توجد ختمة نشطة',
    'memorizationHubNoActiveSubtitle':
        'أنشئ ختمة جديدة لتظهر هنا نقطة الاستكمال والتقدم.',
    'memorizationHubResumeSubtitle':
        'استكمل الختمة النشطة من آخر موضع محفوظ عند توفره.',
    'memorizationHubStartSubtitle': 'هذه الختمة جاهزة للبدء من البداية.',
    'memorizationHubResume': 'استكمال',
    'memorizationHubAllSessions': 'كل الجلسات',
    'memorizationHubRecentSessions': 'آخر الجلسات',
    'memorizationHubRecentSessionsSubtitle': 'حفظ تلقائي لآخر مواضع القراءة',
    'memorizationHubKhatmasTitle': 'الختمات',
    'memorizationHubKhatmasSubtitle': 'الختمات الجارية والمكتملة',
    'memorizationHubBookmarksTitle': 'الحفظ اليدوي',
    'memorizationHubBookmarksSubtitle': 'آيات حفظتها يدويًا من القارئ',
    'memorizationHubUpcomingReviewsTitle': 'المراجعات القادمة',
    'memorizationHubUpcomingReviewsSubtitle':
        'مراجعات تلقائية للنطاقات التي أنهيتها بالفعل.',
    'memorizationReviewsStart': 'ابدأ المراجعة',
    'memorizationReviewsDueCount': '{count} مستحقة الآن',
    'memorizationReviewsNextReview': 'المراجعة التالية',
    'memorizationReviewsToday': 'اليوم',
    'memorizationReviewsTomorrow': 'غدًا',
    'memorizationReviewsInDays': 'بعد {days} أيام',
    'memorizationReviewsOverdueDays': 'متأخرة {days} أيام',
    'memorizationReviewsQueueTitle': 'قائمة المراجعة',
    'memorizationReviewsDueSectionTitle': 'مستحقة الآن',
    'memorizationReviewsUpcomingSectionTitle': 'لاحقًا',
    'memorizationReviewsQueueEmptyTitle': 'لا توجد مراجعات بعد',
    'memorizationReviewsQueueEmptySubtitle':
        'أكمل نطاقًا من الختمة لتظهر هنا المراجعات التلقائية.',
    'memorizationReviewsPageRange': 'الصفحات {start} - {end}',
    'memorizationReviewsSessionTitle': 'جلسة مراجعة',
    'memorizationReviewsOpenReader': 'افتح في القارئ',
    'memorizationReviewsOpenReaderFirst':
        'افتح النطاق المحفوظ في القارئ ثم اختر مستوى الصعوبة.',
    'memorizationReviewsChooseResult': 'كيف كانت هذه المراجعة؟',
    'memorizationReviewsEasy': 'سهل',
    'memorizationReviewsMedium': 'متوسط',
    'memorizationReviewsHard': 'صعب',
    'memorizationReviewsUnableToOpenReader':
        'تعذر فتح هذه المراجعة في القارئ الآن.',
    'memorizationHubStatActiveKhatmas': 'الختمات الجارية',
    'memorizationHubStatRecentSessions': 'الجلسات الأخيرة',
    'memorizationHubStatBookmarks': 'العلامات اليدوية',
    'memorizationHubProgressLabel': 'التقدم',
    'memorizationKhatmaCompletedBadge': 'مكتملة',
    'memorizationSessionDurationMinutes': '{minutes} د',
    'memorizationNewKhatmaDialogTitle': 'ختمة جديدة',
    'memorizationNewKhatmaNameLabel': 'اسم الختمة',
    'memorizationNewKhatmaDurationLabel': 'مدة الختمة',
    'memorizationNewKhatmaOptionWeek': 'أسبوع',
    'memorizationNewKhatmaOptionTenDays': '10 أيام',
    'memorizationNewKhatmaOptionFifteenDays': '15 يوم',
    'memorizationNewKhatmaOptionMonth': 'شهر',
    'memorizationNewKhatmaOptionTwoMonths': 'شهرين',
    'memorizationNewKhatmaStart': 'ابدأ الختمة',
    'memorizationPlannerEyebrow': 'مخطط الختمة',
    'memorizationPlannerDailyAssignment': 'مهمة اليوم',
    'memorizationPlannerReadingStreak': 'سلسلة القراءة',
    'memorizationPlannerTrackedTime': 'الوقت المتتبع',
    'memorizationPlannerPagesRemaining': 'الصفحات المتبقية',
    'memorizationPlannerNextPage': 'الصفحة التالية',
    'memorizationPlannerExpectedToday': 'المتوقع اليوم',
    'memorizationPlannerResume': 'استكمال القراءة',
    'memorizationPlannerOnTrack': 'ضمن الخطة',
    'memorizationPlannerBehind': 'متأخر عن الخطة',
    'achievementsTitle': 'الإنجازات',
    'achievementsNextLevelLabel': 'التقدم للمستوى التالي',
    'achievementsBadgesTitle': 'الأوسمة',
    'achievementsBadgesSubtitle':
        'ما أنجزته من أوسمة، وما ينتظرك من محطات قادمة.',
    'achievementsRecordsTitle': 'أفضل أرقامك',
    'achievementsRecordsSubtitle':
        'أبرز أرقامك الشخصية دون أي مقارنة مع الآخرين.',
    'achievementsMomentumTitle': 'زخم رحلتك',
    'achievementsMomentumSubtitle':
        'راقب ما أنجزته، وتعرّف إلى المحطة الأقرب لك.',
    'achievementsMomentumBadgesEarned': 'الأوسمة التي حققتها',
    'achievementsMomentumNextMilestone': 'المحطة الأقرب',
    'achievementsMomentumAllUnlockedTitle': 'حصدت كل الأوسمة',
    'achievementsMomentumAllUnlockedSubtitle':
        'فتحت جميع أوسمة هذه النسخة. استمر على هذا النسق.',
    'achievementsUnlocksTitle': 'إنجازاتك الجديدة',
    'achievementsUnlocksDismiss': 'رائع',
    'achievementsZeroTitle': 'لم تُسجَّل إنجازات بعد',
    'achievementsZeroSubtitle':
        'ابدأ بقراءة أو مراجعة أو بختمة جديدة، وستظهر إنجازاتك هنا.',
    'achievementsStatVisits': 'الزيارات',
    'achievementsStatMinutes': 'الدقائق',
    'achievementsStatKhatmas': 'الختمات',
    'achievementsStatReviews': 'المراجعات',
    'achievementsProgressValue': '{current} من {target} للمستوى التالي',
    'achievementsBadgeProgress': '{current} من {target}',
    'achievementsRecordBestStreakDays': 'أفضل سلسلة أيام',
    'achievementsRecordTrackedMinutes': 'إجمالي الدقائق المتتبعة',
    'achievementsRecordCompletedKhatmas': 'الختمات المكتملة',
    'achievementsRecordReviewedReviews': 'المقاطع المُراجَعة',
    'achievementsRecordTotalVisits': 'إجمالي الزيارات',
    'achievementsBadgeStatusUnlocked': 'مكتمل',
    'achievementsBadgeStatusInProgress': 'قيد الإنجاز',
    'achievementsBadgeFirstStepsTitle': 'خطوات البداية',
    'achievementsBadgeFirstStepsDescription': 'أكمل أول جلسة قراءة في رحلتك.',
    'achievementsBadgeSteadyReaderTitle': 'القارئ المواظب',
    'achievementsBadgeSteadyReaderDescription': 'أكمل خمس جلسات قراءة.',
    'achievementsBadgeStreakGuardianTitle': 'حارس السلسلة',
    'achievementsBadgeStreakGuardianDescription':
        'حافظ على سلسلة قراءة لخمسة أيام.',
    'achievementsBadgeFocusMinutesTitle': 'دقائق التركيز',
    'achievementsBadgeFocusMinutesDescription': 'سجّل ثلاثين دقيقة من القراءة.',
    'achievementsBadgeDeepFocusTitle': 'تركيز عميق',
    'achievementsBadgeDeepFocusDescription':
        'سجّل مئةً وعشرين دقيقة من القراءة.',
    'achievementsBadgeFirstKhatmaTitle': 'الختمة الأولى',
    'achievementsBadgeFirstKhatmaDescription': 'أتمم ختمة واحدة.',
    'achievementsBadgeKhatmaFinisherTitle': 'متمّ الختمات',
    'achievementsBadgeKhatmaFinisherDescription': 'أتمم ثلاث ختمات.',
    'achievementsBadgeReviewStarterTitle': 'بداية المراجعة',
    'achievementsBadgeReviewStarterDescription': 'أنهِ أول مراجعة متباعدة لك.',
    'achievementsBadgeReviewKeeperTitle': 'مواظب المراجعة',
    'achievementsBadgeReviewKeeperDescription':
        'أكمل خمس مرات تكرار في المراجعات.',
    'achievementsBadgeReviewArchivistTitle': 'مراجع متقدّم',
    'achievementsBadgeReviewArchivistDescription': 'راجع ثلاثة مقاطع متباعدة.',
    'achievementsBadgeKhatmaBuilderTitle': 'باني الختمات',
    'achievementsBadgeKhatmaBuilderDescription': 'احتفظ بختمتين في سجلّك.',
    'achievementsBadgeStreakLighthouseTitle': 'سلسلة راسخة',
    'achievementsBadgeStreakLighthouseDescription':
        'بلغ سلسلة قراءة لعشرة أيام.',
    'homeToolsTitle': 'الأدوات',
    'homeToolsPrayerTimes': 'مواقيت الصلاة',
    'homeToolsLoadingPrayerTimes': 'جارٍ تحميل مواقيت الصلاة...',
    'homeToolsPrayerError': 'تعذر تحميل مواقيت الصلاة الآن.',
    'homeToolsPrayerCached': 'بيانات محفوظة',
    'homeToolsPrayerCachedAt': 'محفوظة الساعة {time}',
    'homeToolsRetry': 'إعادة المحاولة',
    'homeToolsOpenTracker': 'فتح المتابعة',
    'homeToolsQibla': 'القبلة',
    'homeToolsAzkar': 'الأذكار',
    'analyticsTitle': 'التحليلات',
    'analyticsLoading': 'جارٍ تحميل التحليلات...',
    'analyticsError': 'تعذر تحميل التحليلات الآن.',
    'analyticsEmptyTitle': 'ستظهر تحليلاتك هنا',
    'analyticsEmptySubtitle':
        'استمر في القراءة والمراجعة ومتابعة الصلوات لتظهر لك نظرة أسبوعية وشهرية واضحة.',
    'analyticsPeriodThisWeek': 'هذا الأسبوع',
    'analyticsPeriodThisMonth': 'هذا الشهر',
    'analyticsReadingHeroEyebrow': 'ملخص القراءة',
    'analyticsReadingHeroTitle': 'وقت قراءتك في هذه الفترة',
    'analyticsReadingVisitsLabel': 'الزيارات',
    'analyticsReadingStreakLabel': 'السلسلة الحالية',
    'analyticsDeltaNew': 'جديد في هذه الفترة',
    'analyticsDeltaNoChange': 'لا تغيير عن الفترة السابقة',
    'analyticsDeltaComparedToPrevious': '{value} عن الفترة السابقة',
    'analyticsReadingAverageDailyLabel': 'المتوسط اليومي',
    'analyticsReadingPagesLabel': 'الصفحات المزارة',
    'analyticsReadingDaysLabel': 'أيام القراءة',
    'analyticsReadingSectionTitle': 'تفاصيل القراءة',
    'analyticsReadingSectionSubtitle':
        'متوسط الوتيرة، وتغطية الصفحات، وانتظام أيام القراءة',
    'analyticsTopSurahsTitle': 'السور الأكثر زيارة',
    'analyticsTopSurahsSubtitle': 'السور التي رجعت إليها أكثر خلال هذه الفترة',
    'analyticsTopSurahsEmptyTitle': 'لا توجد سور بعد',
    'analyticsTopSurahsEmptySubtitle':
        'ستظهر هنا السور الأكثر زيارة بعد عدة جلسات قراءة.',
    'analyticsVisitCount': '{count} زيارة',
    'analyticsMemorizationSectionTitle': 'الحفظ',
    'analyticsMemorizationSectionSubtitle':
        'زخم الختمة والالتزام بالمراجعة خلال هذه الفترة',
    'analyticsMemorizationEmptyTitle': 'لا يوجد نشاط حفظ بعد',
    'analyticsMemorizationEmptySubtitle':
        'سيظهر هنا تقدم الختمة وانتظام المراجعة بمجرد بدء الحفظ.',
    'analyticsMemorizationActiveKhatmasLabel': 'الختمات الجارية',
    'analyticsMemorizationDueReviewsLabel': 'المراجعات المستحقة',
    'analyticsMemorizationAdherenceLabel': 'الالتزام',
    'analyticsReviewAdherenceEmptyValue': 'لا توجد بيانات مراجعة',
    'analyticsReviewEmptySubtitle':
        'لم تدخل أي عناصر مراجعة في هذه الفترة بعد.',
    'analyticsPrayerSectionTitle': 'انتظام الصلاة',
    'analyticsPrayerSectionSubtitle':
        'مدى ثباتك في متابعة الصلوات خلال هذه الفترة',
    'analyticsPrayerEmptyTitle': 'لا توجد متابعة صلاة بعد',
    'analyticsPrayerEmptySubtitle':
        'سيظهر هنا انتظامك في الصلوات عندما تبدأ بالتتبع.',
    'analyticsPrayerPerfectDaysLabel': 'أيام مكتملة',
    'analyticsPrayerPerfectState': 'انتظام كامل في هذه الفترة',
    'analyticsPrayerTrackedDaysLabel': 'أيام متتبعة',
    'homeToolsSettings': 'الإعدادات',
    'adhkarLoading': 'جارٍ تحميل الأذكار...',
    'adhkarError': 'تعذر تحميل الأذكار الآن.',
    'adhkarCounterTitle': 'السبحة الرقمية',
    'adhkarCounterIncrement': 'زيادة العدّاد',
    'adhkarCounterReset': 'إعادة التصفير',
    'adhkarCounterTargetLabel': 'الهدف',
    'adhkarCounterFreeTarget': 'مفتوح',
    'adhkarItemsLabel': 'أذكار',
    'adhkarRepetitionLabel': 'التكرار',
    'adhkarSourceLabel': 'المصدر',
    'adhkarSourceDetailLabel': 'التخريج والتفصيل',
    'adhkarAuthenticityLabel': 'درجة التوثيق',
    'adhkarTimingLabel': 'وقت الذكر',
    'adhkarVirtueLabel': 'الفضل والأثر',
    'adhkarNoteLabel': 'ملاحظة',
    'adhkarTrustedSourceLabel': 'المصدر الموثوق',
    'adhkarCategoryNotFound': 'هذا القسم غير متاح الآن.',
    'adhkarEmptyCategory': 'لا توجد أذكار متاحة في هذا القسم بعد.',
    'adhkarGroupDailyCore': 'اليومي',
    'adhkarGroupHeartWork': 'الاستغفار وصلاح القلب',
    'adhkarGroupLifeNeeds': 'الحاجات والمواقف',
    'adhkarGroupSourceLed': 'من القرآن والسنة',
    'adhkarCategoryMorning': 'أذكار الصباح',
    'adhkarCategoryEvening': 'أذكار المساء',
    'adhkarCategoryAfterPrayer': 'أذكار بعد الصلاة',
    'adhkarCategorySleep': 'أذكار النوم',
    'adhkarCategoryWaking': 'أذكار الاستيقاظ',
    'adhkarCategoryIstighfar': 'الاستغفار والتوبة',
    'adhkarCategoryRizq': 'الرزق وتيسير الأمر',
    'adhkarCategoryDistress': 'الكرب والهم',
    'adhkarCategoryTravel': 'السفر',
    'adhkarCategoryQuranDuas': 'أدعية القرآن',
    'adhkarCategorySunnahDuas': 'أدعية السنة',
    'settingsTitle': 'الإعدادات',
    'settingsPreviewEyebrow': 'معاينة مباشرة',
    'settingsPreviewHelp': 'أي تغيير هنا يطبَّق فورًا داخل نفس الجلسة.',
    'settingsPreviewVerse': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    'settingsPreviewTranslation':
        'شكل القراءة والواجهة يتحدثان فورًا حسب اختياراتك.',
    'settingsSectionAppearance': 'المظهر',
    'settingsSectionReading': 'القراءة',
    'settingsThemeLabel': 'الثيم',
    'settingsThemeSystem': 'النظام',
    'settingsThemeLight': 'فاتح',
    'settingsThemeDark': 'داكن',
    'settingsLanguageLabel': 'اللغة',
    'settingsLanguageArabic': 'العربية',
    'settingsLanguageEnglish': 'الإنجليزية',
    'settingsFontSizeLabel': 'حجم الخط',
    'settingsFontSizeHelp':
        'يُطبَّق على المعاينة والأسطح العربية المملوكة للتطبيق مع إبقاء صفحات المصحف الأصيلة كما هي.',
    'settingsReaderModeLabel': 'وضع القراءة الافتراضي',
    'settingsTajweedLabel': 'التجويد',
    'settingsTajweedHelp':
        'يحدّث تلوين التجويد في قارئ المصحف فورًا عند توفره.',
    'settingsSectionNightReader': 'القارئ الليلي',
    'settingsNightReaderAutoEnableLabel': 'التفعيل التلقائي',
    'settingsNightReaderAutoEnableHelp':
        'يطبق وضعك الليلي المحفوظ تلقائيًا خلال الساعات المحلية التي تحددها.',
    'settingsNightReaderStartLabel': 'وقت البداية',
    'settingsNightReaderEndLabel': 'وقت النهاية',
    'settingsNightReaderPreferredStyleLabel': 'الوضع الليلي المفضل',
    'settingsNightReaderAutoEnableOn': 'التفعيل التلقائي مفعّل',
    'settingsNightReaderAutoEnableOff': 'التفعيل التلقائي متوقف',
    'settingsNightReaderStyleNight': 'ليلي',
    'settingsNightReaderStyleAmoled': 'AMOLED',
    'settingsNightReaderInvalidSchedule':
        'يجب أن يكون وقت البداية مختلفًا عن وقت النهاية.',
    'settingsNotificationsEntryTitle': 'الإشعارات',
    'settingsNotificationsEntrySubtitle':
        'تحكم في أنواع التذكير والأوقات وصلاحية الإشعارات من داخل التطبيق.',
    'notificationsSettingsTitle': 'الإشعارات',
    'notificationsSettingsFamiliesTitle': 'أنواع التذكير',
    'notificationsTimeLabel': 'وقت التذكير',
    'notificationsPermissionRequestAction': 'تفعيل الإشعارات',
    'notificationsPermissionUnknownTitle': 'وصول الإشعارات',
    'notificationsPermissionUnknownBody':
        'اختر التذكيرات التي تريدها ثم فعّل الإشعارات من داخل التطبيق.',
    'notificationsPermissionGrantedTitle': 'الإشعارات جاهزة',
    'notificationsPermissionGrantedBody':
        'يمكن الآن جدولة التذكيرات وتحديثها من داخل التطبيق.',
    'notificationsPermissionDeniedTitle': 'الإشعارات متوقفة',
    'notificationsPermissionDeniedBody':
        'تم حفظ اختياراتك، لكن التطبيق لن يرسل التذكيرات حتى تُمنح صلاحية الإشعارات.',
    'notificationsPermissionBlockedTitle': 'الإشعارات محجوبة',
    'notificationsPermissionBlockedBody':
        'النظام يمنع إرسال الإشعارات لهذا التطبيق حاليًا.',
    'notificationsPermissionUnavailableTitle': 'الإشعارات غير متاحة',
    'notificationsPermissionUnavailableBody':
        'هذا الجهاز لا يوفّر حاليًا وصول الإشعارات المحلية من داخل التطبيق.',
    'notificationsFamilyDailyWirdTitle': 'الورد اليومي',
    'notificationsFamilyDailyWirdSubtitle':
        'تذكير يومي يعيدك إلى موضع قراءتك واستمرارك الحالي.',
    'notificationsFamilyPrayerTitle': 'تذكير الصلاة',
    'notificationsFamilyPrayerSubtitle':
        'تذكير واحد للصلاة القادمة اعتمادًا على بيانات الصلاة الحالية.',
    'notificationsFamilyFridayKahfTitle': 'تذكير الكهف',
    'notificationsFamilyFridayKahfSubtitle':
        'تذكير أسبوعي يوم الجمعة يفتح سورة الكهف مباشرة.',
    'notificationsFamilyReviewTitle': 'المراجعة المتباعدة',
    'notificationsFamilyReviewSubtitle':
        'تذكير واحد يوجّهك إلى أقرب مراجعة مستحقة في الطابور.',
    'notificationsFamilyAdhkarTitle': 'الأذكار',
    'notificationsFamilyAdhkarSubtitle':
        'تذكير يومي يفتح فئات الأذكار داخل التطبيق.',
    'notificationsFamilyStatusPermissionRequired':
        'ما زالت صلاحية الإشعارات مطلوبة قبل إرسال هذا النوع من التذكير.',
    'notificationsFamilyStatusPrayerUnavailable':
        'تذكيرات الصلاة تنتظر حتى تتوفر بيانات صلاة حديثة.',
    'notificationsFamilyStatusReviewWaiting':
        'تذكيرات المراجعة تبقى متوقفة حتى توجد عناصر مراجعة أو يحين موعدها.',
    'notificationsReminderDailyWirdTitle': 'الورد اليومي',
    'notificationsReminderDailyWirdBody':
        'ارجع إلى قراءتك وأكمل من الموضع الذي توقفت عنده.',
    'notificationsReminderAdhkarTitle': 'وقت الأذكار',
    'notificationsReminderAdhkarBody': 'افتح مكتبة الأذكار وأكمل وردك اليومي.',
    'notificationsReminderFridayKahfTitle': 'تذكير الكهف',
    'notificationsReminderFridayKahfBody':
        'افتح سورة الكهف وابدأ قراءتك ليوم الجمعة.',
    'notificationsReminderPrayerTitle': 'تذكير الصلاة',
    'notificationsReminderPrayerBodyPrefix': 'استعد لـ',
    'notificationsReminderPrayerBodyGeneric':
        'افتح شاشة الصلاة لعرض تفاصيل الصلاة القادمة.',
    'notificationsReminderReviewTitle': 'طابور المراجعة',
    'notificationsReminderReviewBody':
        'مراجعتك المتباعدة التالية جاهزة داخل طابور الحفظ.',
    'prayerDetailsTitle': 'تفاصيل الصلاة',
    'prayerDetailsLoadingMonth': 'جارٍ تحميل الشهر الهجري...',
    'prayerDetailsError': 'تعذر تحميل هذا الشهر الهجري الآن.',
    'prayerDetailsTrackPrayers': 'صلوات اليوم',
    'prayerTodayTitle': 'مواقيت صلاة اليوم',
    'prayerAdherenceToday': 'صلوات اليوم',
    'prayerAdherenceStreak': '{count} أيام متتالية',
    'prayerStatusPast': 'انتهت',
    'prayerStatusCurrent': 'الحالية',
    'prayerStatusUpcoming': 'قادمة',
    'prayerWeeklyTitle': 'هذا الأسبوع',
    'prayerReminderOffsetLabel': 'ذكّرني',
    'prayerReminderAtAdhan': 'وقت الأذان',
    'prayerReminderMinsBefore': 'قبل {mins} دقيقة',
    'prayerLabelFajr': 'الفجر',
    'prayerLabelDhuhr': 'الظهر',
    'prayerLabelAsr': 'العصر',
    'prayerLabelMaghrib': 'المغرب',
    'prayerLabelIsha': 'العشاء',
    'qiblaCompassTitle': 'بوصلة القبلة',
    'qiblaCompassLoading': 'جارٍ تحميل بوصلة القبلة...',
    'qiblaCompassError': 'تعذر تحميل بوصلة القبلة الآن.',
    'qiblaCompassDistance': 'المسافة',
    'qiblaCompassBearing': 'اتجاه القبلة',
    'qiblaCompassHeading': 'اتجاه الهاتف',
    'qiblaCompassFacing': 'أنت مواجه للقبلة',
    'qiblaCompassNotFacing': 'لست مواجهًا للقبلة بعد',
    'qiblaCompassTurnLeft': 'لف يسارًا',
    'qiblaCompassTurnRight': 'لف يمينًا',
    'qiblaCompassCalibrate': 'حرك الهاتف على شكل 8 لتحسين دقة البوصلة.',
    'qiblaCompassSensorUnavailable':
        'بيانات البوصلة غير متاحة على هذا الجهاز الآن.',
    'qiblaCompassNeedleHint': 'لف الهاتف حتى تشير إبرة القبلة لأعلى.',
    'mushafSetupBridgeTitle': 'نُنهي تجهيزك الأول',
    'mushafSetupBridgeDescription':
        'ما زال المصحف يُجهز في الخلفية حتى تبدأ القراءة الأولى بسلاسة وثبات.',
    'onboardingEyebrow': 'جولة سريعة',
    'onboardingSkip': 'تخطي',
    'onboardingNext': 'التالي',
    'onboardingStart': 'ابدأ الآن',
    'onboardingReadTitle': 'اقرأ كما تحب',
    'onboardingReadDescription':
        'التمرير والصفحات والترجمة داخل قارئ واحد هادئ وواضح.',
    'onboardingListenTitle': 'استمع بتركيز',
    'onboardingListenDescription':
        'تابع التلاوة من خلال تجربة صوتية مدمجة وسلسة داخل التطبيق.',
    'onboardingSaveTitle': 'احفظ وارجع بسهولة',
    'onboardingSaveDescription':
        'البحث والمواضيع والملاحظات وأدوات الحفظ تبقي كل ما يهمك قريبًا.',
    'onboardingDailyTitle': 'معك طوال اليوم',
    'onboardingDailyDescription':
        'مواقيت الصلاة والقبلة داخل أدواتك اليومية من غير ما تخرج من التطبيق.',
    'onboardingBeginTitle': 'ابدأ رحلتك',
    'onboardingBeginDescription':
        'القراءة والاستماع والمتابعة اليومية كلها مجتمعة في مكان واحد.',
    'onboardingBackgroundLoading': 'يتم تجهيز المصحف في الخلفية',
    'onboardingBackgroundReady': 'المصحف أصبح جاهزًا لجلستك الأولى',
  };

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context.');
    return localizations!;
  }

  String _value(String key) {
    final languageCode =
        _strings.containsKey(locale.languageCode) ? locale.languageCode : 'en';
    if (languageCode == 'ar') {
      return _strings['ar']![key] ??
          _arabicOverrides[key] ??
          _strings['en']![key]!;
    }

    return _strings[languageCode]![key] ?? _strings['en']![key]!;
  }

  String value(String key) => _value(key);

  String get appTitle => _value('appTitle');
  String get splashTitle => _value('splashTitle');
  String get splashSubtitle => _value('splashSubtitle');
  String get enterFullscreen => _value('enterFullscreen');
  String get restoreReaderChrome => _value('restoreReaderChrome');
  String get bookmarkUpdated => _value('bookmarkUpdated');
  String get verseActionAyah => _value('verseActionAyah');
  String get verseActionListen => _value('verseActionListen');
  String get verseActionInsights => _value('verseActionInsights');
  String get verseActionBookmark => _value('verseActionBookmark');
  String get verseActionShare => _value('verseActionShare');
  String get verseActionTranslations => _value('verseActionTranslations');
  String get verseActionCopy => _value('verseActionCopy');
  String get verseActionNote => _value('verseActionNote');
  String get verseActionTadabbur => _value('verseActionTadabbur');
  String get verseMetadataUnavailable => _value('verseMetadataUnavailable');
  String get verseShareUnavailable => _value('verseShareUnavailable');
  String get verseCopyUnavailable => _value('verseCopyUnavailable');
  String get verseCopied => _value('verseCopied');
  String get verseAudioUnavailable => _value('verseAudioUnavailable');
  String get verseInsightsUnavailable => _value('verseInsightsUnavailable');
  String get verseTranslationUnavailable =>
      _value('verseTranslationUnavailable');
  String get verseNoteHint => _value('verseNoteHint');
  String get verseNoteSave => _value('verseNoteSave');
  String get verseNoteDelete => _value('verseNoteDelete');
  String get verseNoteSaved => _value('verseNoteSaved');
  String get verseNoteDeleted => _value('verseNoteDeleted');
  String get verseNoteUnavailable => _value('verseNoteUnavailable');
  String get verseNoteLoading => _value('verseNoteLoading');
  String get readerModeScroll => _value('readerModeScroll');
  String get readerModePage => _value('readerModePage');
  String get readerModeTranslation => _value('readerModeTranslation');
  String get readerNightModeSheetTitle => _value('readerNightModeSheetTitle');
  String get readerNightModeNormal => _value('readerNightModeNormal');
  String get readerNightModeNight => _value('readerNightModeNight');
  String get readerNightModeAmoled => _value('readerNightModeAmoled');
  String get readerNightModeNormalDescription =>
      _value('readerNightModeNormalDescription');
  String get readerNightModeNightDescription =>
      _value('readerNightModeNightDescription');
  String get readerNightModeAmoledDescription =>
      _value('readerNightModeAmoledDescription');
  String get readerToggleToScroll => _value('readerToggleToScroll');
  String get readerToggleToPage => _value('readerToggleToPage');
  String get readerQuickJump => _value('readerQuickJump');
  String get readerSurahCountLabel => _value('readerSurahCountLabel');
  String get readerSurahLoadError => _value('readerSurahLoadError');
  String get errorLoadingData => _value('errorLoadingData');
  String get errorRetry => _value('errorRetry');
  String get mushafFontsTitle => _value('mushafFontsTitle');
  String get mushafFontsNotes => _value('mushafFontsNotes');
  String get mushafFontsDownloading => _value('mushafFontsDownloading');
  String get surahPrefix => _value('surahPrefix');
  String get readerSurahList => _value('readerSurahList');
  String get translationModeLoading => _value('translationModeLoading');
  String get translationModeRetry => _value('translationModeRetry');
  String get translationModeError => _value('translationModeError');
  String get translationModeEmpty => _value('translationModeEmpty');
  String get translationVerseFallback => _value('translationVerseFallback');
  String get ayahShareCardTitle => _value('ayahShareCardTitle');
  String get ayahShareCardSubtitle => _value('ayahShareCardSubtitle');
  String get ayahShareCardShareAction => _value('ayahShareCardShareAction');
  String get ayahShareCardTranslationToggle =>
      _value('ayahShareCardTranslationToggle');
  String get ayahShareCardPreparing => _value('ayahShareCardPreparing');
  String get ayahShareCardRetry => _value('ayahShareCardRetry');
  String get ayahShareCardMissingTemplate =>
      _value('ayahShareCardMissingTemplate');
  String get ayahShareCardExportUnavailable =>
      _value('ayahShareCardExportUnavailable');
  String get ayahShareCardShareUnavailable =>
      _value('ayahShareCardShareUnavailable');
  String get premiumAyahShareCardsTitle => _value('premiumAyahShareCardsTitle');
  String get premiumAyahShareCardsSubtitle =>
      _value('premiumAyahShareCardsSubtitle');
  String get premiumAyahShareCardsLockedTemplateBody =>
      _value('premiumAyahShareCardsLockedTemplateBody');
  String get premiumPaywallPurchaseAction =>
      _value('premiumPaywallPurchaseAction');
  String get premiumPaywallRestoreAction =>
      _value('premiumPaywallRestoreAction');
  String get premiumPaywallWorking => _value('premiumPaywallWorking');
  String get premiumBillingUnavailable => _value('premiumBillingUnavailable');
  String ayahShareCardTemplateName(String templateId) {
    if (templateId.startsWith('photo-')) {
      final number = templateId.substring('photo-'.length);
      if (locale.languageCode == 'ar') {
        return 'الصورة $number';
      }

      return 'Photo $number';
    }

    switch (templateId) {
      case 'white-stop':
        return _value('ayahShareCardTemplateWhiteStop');
      case 'brown-stop':
        return _value('ayahShareCardTemplateBrownStop');
      default:
        return templateId;
    }
  }

  String get tafsirBrowserTitle => _value('tafsirBrowserTitle');
  String get tafsirBrowserOpenFull => _value('tafsirBrowserOpenFull');
  String get tafsirBrowserLoading => _value('tafsirBrowserLoading');
  String get tafsirBrowserLoadError => _value('tafsirBrowserLoadError');
  String get tafsirBrowserSourceUnavailable =>
      _value('tafsirBrowserSourceUnavailable');
  String get tafsirBrowserInvalidVerse => _value('tafsirBrowserInvalidVerse');
  String get tafsirBrowserSourceLabel => _value('tafsirBrowserSourceLabel');
  String get tafsirBrowserFootnotesTitle =>
      _value('tafsirBrowserFootnotesTitle');
  String get tafsirBrowserPrevious => _value('tafsirBrowserPrevious');
  String get tafsirBrowserNext => _value('tafsirBrowserNext');
  String get insightSectionTafsir => _value('insightSectionTafsir');
  String get insightSectionWordMeaning => _value('insightSectionWordMeaning');
  String get insightSectionAsbaab => _value('insightSectionAsbaab');
  String get insightSectionRelated => _value('insightSectionRelated');
  String get insightSectionUnavailable => _value('insightSectionUnavailable');
  String get insightSectionCollapse => _value('insightSectionCollapse');
  String get insightSectionExpand => _value('insightSectionExpand');
  String get insightWordRoot => _value('insightWordRoot');
  String get insightAsbaabSource => _value('insightAsbaabSource');
  String get insightRelatedOpen => _value('insightRelatedOpen');
  String get insightRelatedTagThematic => _value('insightRelatedTagThematic');
  String get insightRelatedTagLinguistic =>
      _value('insightRelatedTagLinguistic');
  String insightRelatedTagLabel(String tag) {
    switch (tag.trim().toLowerCase()) {
      case 'thematic':
        return insightRelatedTagThematic;
      case 'linguistic':
        return insightRelatedTagLinguistic;
      default:
        return tag;
    }
  }

  String get verseAudioComingSoon => _value('verseAudioComingSoon');
  String get audioHubTitle => _value('audioHubTitle');
  String get audioHubLoading => _value('audioHubLoading');
  String get audioHubLoadError => _value('audioHubLoadError');
  String get audioHubRetry => _value('audioHubRetry');
  String get audioHubSelectReciter => _value('audioHubSelectReciter');
  String get audioHubCurrentReciter => _value('audioHubCurrentReciter');
  String get audioHubReciterListUnavailable =>
      _value('audioHubReciterListUnavailable');
  String get audioHubReciterChangeFailed =>
      _value('audioHubReciterChangeFailed');
  String get audioHubSelectSurah => _value('audioHubSelectSurah');
  String get audioHubSurahListUnavailable =>
      _value('audioHubSurahListUnavailable');
  String get audioHubPlay => _value('audioHubPlay');
  String get audioHubStop => _value('audioHubStop');
  String get audioHubPause => _value('audioHubPause');
  String get audioHubPrevious => _value('audioHubPrevious');
  String get audioHubNext => _value('audioHubNext');
  String get audioHubSurah => _value('audioHubSurah');
  String get audioHubAyahs => _value('audioHubAyahs');
  String get audioDownloadsOpen => _value('audioDownloadsOpen');
  String get audioDownloadsTitle => _value('audioDownloadsTitle');
  String get audioDownloadsEmptyTitle => _value('audioDownloadsEmptyTitle');
  String get audioDownloadsDownloadedSection =>
      _value('audioDownloadsDownloadedSection');
  String get audioDownloadsAvailableSection =>
      _value('audioDownloadsAvailableSection');
  String get audioDownloadsNoDownloadedReciters =>
      _value('audioDownloadsNoDownloadedReciters');
  String get audioDownloadsNoAvailableReciters =>
      _value('audioDownloadsNoAvailableReciters');
  String get audioDownloadsTotalStorage => _value('audioDownloadsTotalStorage');
  String get audioDownloadsDownloadedReciters =>
      _value('audioDownloadsDownloadedReciters');
  String get audioDownloadsActiveDownload =>
      _value('audioDownloadsActiveDownload');
  String get audioDownloadsSurahCount => _value('audioDownloadsSurahCount');
  String get audioDownloadsLocalSize => _value('audioDownloadsLocalSize');
  String get audioDownloadsStatusAvailable =>
      _value('audioDownloadsStatusAvailable');
  String get audioDownloadsStatusDownloaded =>
      _value('audioDownloadsStatusDownloaded');
  String get audioDownloadsStatusDownloading =>
      _value('audioDownloadsStatusDownloading');
  String get audioDownloadsStatusFailed => _value('audioDownloadsStatusFailed');
  String get audioDownloadsDownload => _value('audioDownloadsDownload');
  String get audioDownloadsDelete => _value('audioDownloadsDelete');
  String get audioDownloadsRetry => _value('audioDownloadsRetry');
  String get audioDownloadsCancel => _value('audioDownloadsCancel');
  String get audioDownloadsLoadError => _value('audioDownloadsLoadError');
  String get audioDownloadsUnavailableMessage =>
      _value('audioDownloadsUnavailableMessage');
  String get audioDownloadsActionFailed => _value('audioDownloadsActionFailed');
  String get libraryTitle => _value('libraryTitle');
  String get libraryTabSurahs => _value('libraryTabSurahs');
  String get libraryTabKhatmas => _value('libraryTabKhatmas');
  String get libraryTabManualSaves => _value('libraryTabManualSaves');
  String get libraryTabAutoSave => _value('libraryTabAutoSave');
  String get librarySearchHint => _value('librarySearchHint');
  String get libraryRecentSearches => _value('libraryRecentSearches');
  String get librarySearchClearHistory => _value('librarySearchClearHistory');
  String get librarySearchResultsLoading =>
      _value('librarySearchResultsLoading');
  String get librarySearchResultsEmpty => _value('librarySearchResultsEmpty');
  String get librarySearchLoadError => _value('librarySearchLoadError');
  String get librarySearchKindAyahs => _value('librarySearchKindAyahs');
  String get librarySearchKindTranslations =>
      _value('librarySearchKindTranslations');
  String get librarySearchKindTopics => _value('librarySearchKindTopics');
  String get librarySearchScopeFullQuran =>
      _value('librarySearchScopeFullQuran');
  String get librarySearchScopeCurrentSurah =>
      _value('librarySearchScopeCurrentSurah');
  String get libraryTranslationSearchResultsLoading =>
      _value('libraryTranslationSearchResultsLoading');
  String get libraryTranslationSearchResultsEmpty =>
      _value('libraryTranslationSearchResultsEmpty');
  String get libraryTranslationSearchLoadError =>
      _value('libraryTranslationSearchLoadError');
  String get libraryTopicsLoading => _value('libraryTopicsLoading');
  String get libraryTopicsLoadError => _value('libraryTopicsLoadError');
  String get libraryTopicsEmpty => _value('libraryTopicsEmpty');
  String get libraryTopicsCategoryAll => _value('libraryTopicsCategoryAll');
  String get libraryTopicsCategoryStories =>
      _value('libraryTopicsCategoryStories');
  String get libraryTopicsCategoryLaws => _value('libraryTopicsCategoryLaws');
  String get libraryTopicsCategoryAfterlife =>
      _value('libraryTopicsCategoryAfterlife');
  String get libraryTopicsDetailsLoading =>
      _value('libraryTopicsDetailsLoading');
  String get libraryTopicsDetailsLoadError =>
      _value('libraryTopicsDetailsLoadError');
  String get libraryTopicsDetailsEmpty => _value('libraryTopicsDetailsEmpty');
  String get libraryNoResults => _value('libraryNoResults');
  String get librarySurahsLoading => _value('librarySurahsLoading');
  String get librarySurahsLoadError => _value('librarySurahsLoadError');
  String get libraryKhatmasCreate => _value('libraryKhatmasCreate');
  String get libraryKhatmasEmptyTitle => _value('libraryKhatmasEmptyTitle');
  String get libraryKhatmasEmptySubtitle =>
      _value('libraryKhatmasEmptySubtitle');
  String get libraryManualSavesEmptyTitle =>
      _value('libraryManualSavesEmptyTitle');
  String get libraryManualSavesEmptySubtitle =>
      _value('libraryManualSavesEmptySubtitle');
  String get libraryAutoSaveEmptyTitle => _value('libraryAutoSaveEmptyTitle');
  String get libraryAutoSaveEmptySubtitle =>
      _value('libraryAutoSaveEmptySubtitle');
  String get libraryAutoSaveLoading => _value('libraryAutoSaveLoading');
  String get libraryAutoSaveLoadError => _value('libraryAutoSaveLoadError');
  String get libraryAutoSaveCardTitle => _value('libraryAutoSaveCardTitle');
  String get libraryAyahLabel => _value('libraryAyahLabel');
  String get libraryPageLabel => _value('libraryPageLabel');
  String get librarySavedAtLabel => _value('librarySavedAtLabel');
  String get mushafSetupTitle => _value('mushafSetupTitle');
  String get mushafSetupDescription => _value('mushafSetupDescription');
  String get mushafSetupStart => _value('mushafSetupStart');
  String get mushafSetupInProgress => _value('mushafSetupInProgress');
  String get mushafSetupRetry => _value('mushafSetupRetry');
  String get mushafSetupError => _value('mushafSetupError');
  String get mushafSetupRequired => _value('mushafSetupRequired');
  String get mushafSetupBridgeTitle => _value('mushafSetupBridgeTitle');
  String get mushafSetupBridgeDescription =>
      _value('mushafSetupBridgeDescription');
  String get onboardingEyebrow => _value('onboardingEyebrow');
  String get onboardingSkip => _value('onboardingSkip');
  String get onboardingNext => _value('onboardingNext');
  String get onboardingStart => _value('onboardingStart');
  String get onboardingReadTitle => _value('onboardingReadTitle');
  String get onboardingReadDescription => _value('onboardingReadDescription');
  String get onboardingListenTitle => _value('onboardingListenTitle');
  String get onboardingListenDescription =>
      _value('onboardingListenDescription');
  String get onboardingSaveTitle => _value('onboardingSaveTitle');
  String get onboardingSaveDescription => _value('onboardingSaveDescription');
  String get onboardingDailyTitle => _value('onboardingDailyTitle');
  String get onboardingDailyDescription => _value('onboardingDailyDescription');
  String get onboardingBeginTitle => _value('onboardingBeginTitle');
  String get onboardingBeginDescription => _value('onboardingBeginDescription');
  String get onboardingBackgroundLoading =>
      _value('onboardingBackgroundLoading');
  String get onboardingBackgroundReady => _value('onboardingBackgroundReady');
  String get navReader => _value('navReader');
  String get navAudio => _value('navAudio');
  String get navLibrary => _value('navLibrary');
  String get navMemorization => _value('navMemorization');
  String get navMore => _value('navMore');
  String get memorizationTitle => _value('memorizationTitle');
  String get memorizationTabSessions => _value('memorizationTabSessions');
  String get memorizationTabKhatmas => _value('memorizationTabKhatmas');
  String get memorizationTabBookmarks => _value('memorizationTabBookmarks');
  String get memorizationSessionsEmptyTitle =>
      _value('memorizationSessionsEmptyTitle');
  String get memorizationSessionsEmptySubtitle =>
      _value('memorizationSessionsEmptySubtitle');
  String get memorizationKhatmasNew => _value('memorizationKhatmasNew');
  String get memorizationKhatmasActive => _value('memorizationKhatmasActive');
  String get memorizationKhatmasCompleted =>
      _value('memorizationKhatmasCompleted');
  String get memorizationKhatmasEmptyTitle =>
      _value('memorizationKhatmasEmptyTitle');
  String get memorizationKhatmasEmptySubtitle =>
      _value('memorizationKhatmasEmptySubtitle');
  String get memorizationBookmarksEmptyTitle =>
      _value('memorizationBookmarksEmptyTitle');
  String get memorizationBookmarksEmptySubtitle =>
      _value('memorizationBookmarksEmptySubtitle');
  String get memorizationHubHeroEyebrow => _value('memorizationHubHeroEyebrow');
  String get memorizationHubNoActiveTitle =>
      _value('memorizationHubNoActiveTitle');
  String get memorizationHubNoActiveSubtitle =>
      _value('memorizationHubNoActiveSubtitle');
  String get memorizationHubResumeSubtitle =>
      _value('memorizationHubResumeSubtitle');
  String get memorizationHubStartSubtitle =>
      _value('memorizationHubStartSubtitle');
  String get memorizationHubResume => _value('memorizationHubResume');
  String get memorizationHubAllSessions => _value('memorizationHubAllSessions');
  String get memorizationQuizAction => _value('memorizationQuizAction');
  String get memorizationHubRecentSessions =>
      _value('memorizationHubRecentSessions');
  String get memorizationHubRecentSessionsSubtitle =>
      _value('memorizationHubRecentSessionsSubtitle');
  String get memorizationHubKhatmasTitle =>
      _value('memorizationHubKhatmasTitle');
  String get memorizationHubKhatmasSubtitle =>
      _value('memorizationHubKhatmasSubtitle');
  String get memorizationHubBookmarksTitle =>
      _value('memorizationHubBookmarksTitle');
  String get memorizationHubBookmarksSubtitle =>
      _value('memorizationHubBookmarksSubtitle');
  String get memorizationHubUpcomingReviewsTitle =>
      _value('memorizationHubUpcomingReviewsTitle');
  String get memorizationHubUpcomingReviewsSubtitle =>
      _value('memorizationHubUpcomingReviewsSubtitle');
  String get memorizationReviewsStart => _value('memorizationReviewsStart');
  String memorizationReviewsDueCount(String count) {
    return _value('memorizationReviewsDueCount').replaceAll('{count}', count);
  }

  String get memorizationReviewsNextReview =>
      _value('memorizationReviewsNextReview');
  String get memorizationReviewsToday => _value('memorizationReviewsToday');
  String get memorizationReviewsTomorrow =>
      _value('memorizationReviewsTomorrow');
  String memorizationReviewsInDays(String days) {
    return _value('memorizationReviewsInDays').replaceAll('{days}', days);
  }

  String memorizationReviewsOverdueDays(String days) {
    return _value('memorizationReviewsOverdueDays').replaceAll('{days}', days);
  }

  String get memorizationReviewsQueueTitle =>
      _value('memorizationReviewsQueueTitle');
  String get memorizationReviewsDueSectionTitle =>
      _value('memorizationReviewsDueSectionTitle');
  String get memorizationReviewsUpcomingSectionTitle =>
      _value('memorizationReviewsUpcomingSectionTitle');
  String get memorizationReviewsQueueEmptyTitle =>
      _value('memorizationReviewsQueueEmptyTitle');
  String get memorizationReviewsQueueEmptySubtitle =>
      _value('memorizationReviewsQueueEmptySubtitle');
  String memorizationReviewsPageRange(String start, String end) {
    return _value(
      'memorizationReviewsPageRange',
    ).replaceAll('{start}', start).replaceAll('{end}', end);
  }

  String get memorizationReviewsSessionTitle =>
      _value('memorizationReviewsSessionTitle');
  String get memorizationReviewsOpenReader =>
      _value('memorizationReviewsOpenReader');
  String get memorizationReviewsOpenReaderFirst =>
      _value('memorizationReviewsOpenReaderFirst');
  String get memorizationReviewsChooseResult =>
      _value('memorizationReviewsChooseResult');
  String get memorizationReviewsEasy => _value('memorizationReviewsEasy');
  String get memorizationReviewsMedium => _value('memorizationReviewsMedium');
  String get memorizationReviewsHard => _value('memorizationReviewsHard');
  String get memorizationReviewsUnableToOpenReader =>
      _value('memorizationReviewsUnableToOpenReader');
  String get memorizationHubStatActiveKhatmas =>
      _value('memorizationHubStatActiveKhatmas');
  String get memorizationHubStatRecentSessions =>
      _value('memorizationHubStatRecentSessions');
  String get memorizationHubStatBookmarks =>
      _value('memorizationHubStatBookmarks');
  String get memorizationHubProgressLabel =>
      _value('memorizationHubProgressLabel');
  String get memorizationKhatmaCompletedBadge =>
      _value('memorizationKhatmaCompletedBadge');
  String memorizationSessionDurationMinutes(String minutes) {
    return _value(
      'memorizationSessionDurationMinutes',
    ).replaceAll('{minutes}', minutes);
  }

  String get memorizationNewKhatmaDialogTitle =>
      _value('memorizationNewKhatmaDialogTitle');
  String get memorizationNewKhatmaNameLabel =>
      _value('memorizationNewKhatmaNameLabel');
  String get memorizationNewKhatmaDurationLabel =>
      _value('memorizationNewKhatmaDurationLabel');
  String get memorizationNewKhatmaOptionWeek =>
      _value('memorizationNewKhatmaOptionWeek');
  String get memorizationNewKhatmaOptionTenDays =>
      _value('memorizationNewKhatmaOptionTenDays');
  String get memorizationNewKhatmaOptionFifteenDays =>
      _value('memorizationNewKhatmaOptionFifteenDays');
  String get memorizationNewKhatmaOptionMonth =>
      _value('memorizationNewKhatmaOptionMonth');
  String get memorizationNewKhatmaOptionTwoMonths =>
      _value('memorizationNewKhatmaOptionTwoMonths');
  String get memorizationNewKhatmaStart => _value('memorizationNewKhatmaStart');
  String get memorizationPlannerEyebrow => _value('memorizationPlannerEyebrow');
  String get memorizationPlannerDailyAssignment =>
      _value('memorizationPlannerDailyAssignment');
  String get memorizationPlannerReadingStreak =>
      _value('memorizationPlannerReadingStreak');
  String get memorizationPlannerTrackedTime =>
      _value('memorizationPlannerTrackedTime');
  String get memorizationPlannerPagesRemaining =>
      _value('memorizationPlannerPagesRemaining');
  String get memorizationPlannerNextPage =>
      _value('memorizationPlannerNextPage');
  String get memorizationPlannerExpectedToday =>
      _value('memorizationPlannerExpectedToday');
  String get memorizationPlannerResume => _value('memorizationPlannerResume');
  String get memorizationPlannerOnTrack => _value('memorizationPlannerOnTrack');
  String get memorizationPlannerBehind => _value('memorizationPlannerBehind');
  String get achievementsTitle => _value('achievementsTitle');
  String get achievementsNextLevelLabel => _value('achievementsNextLevelLabel');
  String get achievementsBadgesTitle => _value('achievementsBadgesTitle');
  String get achievementsBadgesSubtitle => _value('achievementsBadgesSubtitle');
  String get achievementsRecordsTitle => _value('achievementsRecordsTitle');
  String get achievementsRecordsSubtitle =>
      _value('achievementsRecordsSubtitle');
  String get achievementsMomentumTitle => _value('achievementsMomentumTitle');
  String get achievementsMomentumSubtitle =>
      _value('achievementsMomentumSubtitle');
  String get achievementsMomentumBadgesEarned =>
      _value('achievementsMomentumBadgesEarned');
  String get achievementsMomentumNextMilestone =>
      _value('achievementsMomentumNextMilestone');
  String get achievementsMomentumAllUnlockedTitle =>
      _value('achievementsMomentumAllUnlockedTitle');
  String get achievementsMomentumAllUnlockedSubtitle =>
      _value('achievementsMomentumAllUnlockedSubtitle');
  String get achievementsUnlocksTitle => _value('achievementsUnlocksTitle');
  String get achievementsUnlocksDismiss => _value('achievementsUnlocksDismiss');
  String get achievementsZeroTitle => _value('achievementsZeroTitle');
  String get achievementsZeroSubtitle => _value('achievementsZeroSubtitle');
  String get achievementsStatVisits => _value('achievementsStatVisits');
  String get achievementsStatMinutes => _value('achievementsStatMinutes');
  String get achievementsStatKhatmas => _value('achievementsStatKhatmas');
  String get achievementsStatReviews => _value('achievementsStatReviews');
  String get achievementsRecordBestStreakDays =>
      _value('achievementsRecordBestStreakDays');
  String get achievementsRecordTrackedMinutes =>
      _value('achievementsRecordTrackedMinutes');
  String get achievementsRecordCompletedKhatmas =>
      _value('achievementsRecordCompletedKhatmas');
  String get achievementsRecordReviewedReviews =>
      _value('achievementsRecordReviewedReviews');
  String get achievementsRecordTotalVisits =>
      _value('achievementsRecordTotalVisits');
  String get achievementsBadgeStatusUnlocked =>
      _value('achievementsBadgeStatusUnlocked');
  String get achievementsBadgeStatusInProgress =>
      _value('achievementsBadgeStatusInProgress');
  String get achievementsBadgeFirstStepsTitle =>
      _value('achievementsBadgeFirstStepsTitle');
  String get achievementsBadgeFirstStepsDescription =>
      _value('achievementsBadgeFirstStepsDescription');
  String get achievementsBadgeSteadyReaderTitle =>
      _value('achievementsBadgeSteadyReaderTitle');
  String get achievementsBadgeSteadyReaderDescription =>
      _value('achievementsBadgeSteadyReaderDescription');
  String get achievementsBadgeStreakGuardianTitle =>
      _value('achievementsBadgeStreakGuardianTitle');
  String get achievementsBadgeStreakGuardianDescription =>
      _value('achievementsBadgeStreakGuardianDescription');
  String get achievementsBadgeFocusMinutesTitle =>
      _value('achievementsBadgeFocusMinutesTitle');
  String get achievementsBadgeFocusMinutesDescription =>
      _value('achievementsBadgeFocusMinutesDescription');
  String get achievementsBadgeDeepFocusTitle =>
      _value('achievementsBadgeDeepFocusTitle');
  String get achievementsBadgeDeepFocusDescription =>
      _value('achievementsBadgeDeepFocusDescription');
  String get achievementsBadgeFirstKhatmaTitle =>
      _value('achievementsBadgeFirstKhatmaTitle');
  String get achievementsBadgeFirstKhatmaDescription =>
      _value('achievementsBadgeFirstKhatmaDescription');
  String get achievementsBadgeKhatmaFinisherTitle =>
      _value('achievementsBadgeKhatmaFinisherTitle');
  String get achievementsBadgeKhatmaFinisherDescription =>
      _value('achievementsBadgeKhatmaFinisherDescription');
  String get achievementsBadgeReviewStarterTitle =>
      _value('achievementsBadgeReviewStarterTitle');
  String get achievementsBadgeReviewStarterDescription =>
      _value('achievementsBadgeReviewStarterDescription');
  String get achievementsBadgeReviewKeeperTitle =>
      _value('achievementsBadgeReviewKeeperTitle');
  String get achievementsBadgeReviewKeeperDescription =>
      _value('achievementsBadgeReviewKeeperDescription');
  String get achievementsBadgeReviewArchivistTitle =>
      _value('achievementsBadgeReviewArchivistTitle');
  String get achievementsBadgeReviewArchivistDescription =>
      _value('achievementsBadgeReviewArchivistDescription');
  String get achievementsBadgeKhatmaBuilderTitle =>
      _value('achievementsBadgeKhatmaBuilderTitle');
  String get achievementsBadgeKhatmaBuilderDescription =>
      _value('achievementsBadgeKhatmaBuilderDescription');
  String get achievementsBadgeStreakLighthouseTitle =>
      _value('achievementsBadgeStreakLighthouseTitle');
  String get achievementsBadgeStreakLighthouseDescription =>
      _value('achievementsBadgeStreakLighthouseDescription');
  String achievementsLevelValue(String level) {
    if (locale.languageCode == 'ar') {
      return 'المستوى $level';
    }

    return 'Level $level';
  }

  String achievementsXpValue(String xp) {
    if (locale.languageCode == 'ar') {
      return '$xp XP';
    }

    return '$xp XP';
  }

  String achievementsProgressValue(String current, String target) {
    return _value(
      'achievementsProgressValue',
    ).replaceAll('{current}', current).replaceAll('{target}', target);
  }

  String achievementsBadgeProgress(String current, String target) {
    return _value(
      'achievementsBadgeProgress',
    ).replaceAll('{current}', current).replaceAll('{target}', target);
  }

  String memorizationAyahValue(String ayahNumber) {
    if (locale.languageCode == 'ar') {
      return 'الآية $ayahNumber';
    }

    return 'Ayah $ayahNumber';
  }

  String memorizationSurahProgress(String completed, String total) {
    if (locale.languageCode == 'ar') {
      return '$completed / $total سورة';
    }

    return '$completed / $total surahs';
  }

  String memorizationDaysRemaining(String days) {
    if (locale.languageCode == 'ar') {
      return 'باقي $days يوم';
    }

    return '$days days left';
  }

  String memorizationMinutesAgo(String minutes) {
    if (locale.languageCode == 'ar') {
      return 'منذ $minutes دقيقة';
    }

    return '$minutes min ago';
  }

  String memorizationPlannerTrackedTimeValue(String hours, String minutes) {
    if (locale.languageCode == 'ar') {
      if (hours == '0') {
        return '$minutes د';
      }
      if (minutes == '0') {
        return '$hours س';
      }

      return '$hours س $minutes د';
    }

    if (hours == '0') {
      return '${minutes}m';
    }
    if (minutes == '0') {
      return '${hours}h';
    }

    return '${hours}h ${minutes}m';
  }

  String memorizationHoursAgo(String hours) {
    if (locale.languageCode == 'ar') {
      return 'منذ $hours ساعة';
    }

    return '$hours hr ago';
  }

  String memorizationDaysAgo(String days) {
    if (locale.languageCode == 'ar') {
      return 'منذ $days يوم';
    }

    return '$days days ago';
  }

  String get homeToolsTitle => _value('homeToolsTitle');
  String get homeToolsPrayerTimes => _value('homeToolsPrayerTimes');
  String get homeToolsLoadingPrayerTimes =>
      _value('homeToolsLoadingPrayerTimes');
  String get homeToolsPrayerError => _value('homeToolsPrayerError');
  String get homeToolsPrayerCached => _value('homeToolsPrayerCached');
  String homeToolsPrayerCachedAt(String time) {
    return _value('homeToolsPrayerCachedAt').replaceAll('{time}', time);
  }

  String get homeToolsRetry => _value('homeToolsRetry');
  String get homeToolsOpenTracker => _value('homeToolsOpenTracker');
  String get homeToolsQibla => _value('homeToolsQibla');
  String get homeToolsAzkar => _value('homeToolsAzkar');
  String get analyticsTitle => _value('analyticsTitle');
  String get analyticsLoading => _value('analyticsLoading');
  String get analyticsError => _value('analyticsError');
  String get analyticsEmptyTitle => _value('analyticsEmptyTitle');
  String get analyticsEmptySubtitle => _value('analyticsEmptySubtitle');
  String get analyticsPeriodThisWeek => _value('analyticsPeriodThisWeek');
  String get analyticsPeriodThisMonth => _value('analyticsPeriodThisMonth');
  String get analyticsReadingHeroEyebrow =>
      _value('analyticsReadingHeroEyebrow');
  String get analyticsReadingHeroTitle => _value('analyticsReadingHeroTitle');
  String get analyticsReadingVisitsLabel =>
      _value('analyticsReadingVisitsLabel');
  String get analyticsReadingStreakLabel =>
      _value('analyticsReadingStreakLabel');
  String get analyticsDeltaNew => _value('analyticsDeltaNew');
  String get analyticsDeltaNoChange => _value('analyticsDeltaNoChange');
  String analyticsDeltaComparedToPrevious(String value) {
    return _value('analyticsDeltaComparedToPrevious').replaceAll(
      '{value}',
      value,
    );
  }

  String get analyticsReadingAverageDailyLabel =>
      _value('analyticsReadingAverageDailyLabel');
  String get analyticsReadingPagesLabel => _value('analyticsReadingPagesLabel');
  String get analyticsReadingDaysLabel => _value('analyticsReadingDaysLabel');
  String get analyticsReadingSectionTitle =>
      _value('analyticsReadingSectionTitle');
  String get analyticsReadingSectionSubtitle =>
      _value('analyticsReadingSectionSubtitle');
  String get analyticsTopSurahsTitle => _value('analyticsTopSurahsTitle');
  String get analyticsTopSurahsSubtitle => _value('analyticsTopSurahsSubtitle');
  String get analyticsTopSurahsEmptyTitle =>
      _value('analyticsTopSurahsEmptyTitle');
  String get analyticsTopSurahsEmptySubtitle =>
      _value('analyticsTopSurahsEmptySubtitle');
  String analyticsVisitCount(String count) {
    return _value('analyticsVisitCount').replaceAll('{count}', count);
  }

  String get analyticsMemorizationSectionTitle =>
      _value('analyticsMemorizationSectionTitle');
  String get analyticsMemorizationSectionSubtitle =>
      _value('analyticsMemorizationSectionSubtitle');
  String get analyticsMemorizationEmptyTitle =>
      _value('analyticsMemorizationEmptyTitle');
  String get analyticsMemorizationEmptySubtitle =>
      _value('analyticsMemorizationEmptySubtitle');
  String get analyticsMemorizationActiveKhatmasLabel =>
      _value('analyticsMemorizationActiveKhatmasLabel');
  String get analyticsMemorizationDueReviewsLabel =>
      _value('analyticsMemorizationDueReviewsLabel');
  String get analyticsMemorizationAdherenceLabel =>
      _value('analyticsMemorizationAdherenceLabel');
  String get analyticsReviewAdherenceEmptyValue =>
      _value('analyticsReviewAdherenceEmptyValue');
  String get analyticsReviewEmptySubtitle =>
      _value('analyticsReviewEmptySubtitle');
  String get analyticsPrayerSectionTitle =>
      _value('analyticsPrayerSectionTitle');
  String get analyticsPrayerSectionSubtitle =>
      _value('analyticsPrayerSectionSubtitle');
  String get analyticsPrayerEmptyTitle => _value('analyticsPrayerEmptyTitle');
  String get analyticsPrayerEmptySubtitle =>
      _value('analyticsPrayerEmptySubtitle');
  String get analyticsPrayerPerfectDaysLabel =>
      _value('analyticsPrayerPerfectDaysLabel');
  String get analyticsPrayerPerfectState =>
      _value('analyticsPrayerPerfectState');
  String get analyticsPrayerTrackedDaysLabel =>
      _value('analyticsPrayerTrackedDaysLabel');
  String get homeToolsSettings => _value('homeToolsSettings');
  String get adhkarLoading => _value('adhkarLoading');
  String get adhkarError => _value('adhkarError');
  String get adhkarCounterTitle => _value('adhkarCounterTitle');
  String get adhkarCounterIncrement => _value('adhkarCounterIncrement');
  String get adhkarCounterReset => _value('adhkarCounterReset');
  String get adhkarCounterTargetLabel => _value('adhkarCounterTargetLabel');
  String get adhkarCounterFreeTarget => _value('adhkarCounterFreeTarget');
  String get adhkarItemsLabel => _value('adhkarItemsLabel');
  String get adhkarRepetitionLabel => _value('adhkarRepetitionLabel');
  String get adhkarSourceLabel => _value('adhkarSourceLabel');
  String get adhkarSourceDetailLabel => _value('adhkarSourceDetailLabel');
  String get adhkarAuthenticityLabel => _value('adhkarAuthenticityLabel');
  String get adhkarTimingLabel => _value('adhkarTimingLabel');
  String get adhkarVirtueLabel => _value('adhkarVirtueLabel');
  String get adhkarNoteLabel => _value('adhkarNoteLabel');
  String get adhkarTrustedSourceLabel => _value('adhkarTrustedSourceLabel');
  String get adhkarCategoryNotFound => _value('adhkarCategoryNotFound');
  String get adhkarEmptyCategory => _value('adhkarEmptyCategory');
  String get adhkarGroupDailyCore => _value('adhkarGroupDailyCore');
  String get adhkarGroupHeartWork => _value('adhkarGroupHeartWork');
  String get adhkarGroupLifeNeeds => _value('adhkarGroupLifeNeeds');
  String get adhkarGroupSourceLed => _value('adhkarGroupSourceLed');
  String get adhkarCategoryMorning => _value('adhkarCategoryMorning');
  String get adhkarCategoryEvening => _value('adhkarCategoryEvening');
  String get adhkarCategoryAfterPrayer => _value('adhkarCategoryAfterPrayer');
  String get adhkarCategorySleep => _value('adhkarCategorySleep');
  String get adhkarCategoryWaking => _value('adhkarCategoryWaking');
  String get adhkarCategoryIstighfar => _value('adhkarCategoryIstighfar');
  String get adhkarCategoryRizq => _value('adhkarCategoryRizq');
  String get adhkarCategoryDistress => _value('adhkarCategoryDistress');
  String get adhkarCategoryTravel => _value('adhkarCategoryTravel');
  String get adhkarCategoryQuranDuas => _value('adhkarCategoryQuranDuas');
  String get adhkarCategorySunnahDuas => _value('adhkarCategorySunnahDuas');
  String get quranStories => _value('quranStories');
  String get storiesAll => _value('storiesAll');
  String get storiesProphets => _value('storiesProphets');
  String get storiesQuranic => _value('storiesQuranic');
  String get storiesSearchHint => _value('storiesSearchHint');
  String get storiesNoResults => _value('storiesNoResults');
  String get storiesPreviousChapter => _value('storiesPreviousChapter');
  String get storiesNextChapter => _value('storiesNextChapter');
  String get storiesLesson => _value('storiesLesson');
  String get storiesMarkAsRead => _value('storiesMarkAsRead');
  String get storiesBackToHub => _value('storiesBackToHub');
  String get storiesCompletedTitle => _value('storiesCompletedTitle');
  String get storiesCompletedMessage => _value('storiesCompletedMessage');
  String get storiesShareChapter => _value('storiesShareChapter');
  String storiesChapterCount(String count) {
    return _value('storiesChapterCount').replaceAll('{count}', count);
  }

  String storiesMinutesCount(String count) {
    return _value('storiesMinutesCount').replaceAll('{count}', count);
  }

  String storiesChapterOf(String current, String total) {
    return _value(
      'storiesChapterOf',
    ).replaceAll('{current}', current).replaceAll('{total}', total);
  }

  String storiesVerseCount(String count) {
    return _value('storiesVerseCount').replaceAll('{count}', count);
  }

  String storiesReadSummary(String readCount, String totalCount) {
    return _value(
      'storiesReadSummary',
    )
        .replaceAll('{readCount}', readCount)
        .replaceAll('{totalCount}', totalCount);
  }

  String get quizHubTitle => _value('quizHubTitle');
  String get quizHubDescription => _value('quizHubDescription');
  String get quizHistoryTitle => _value('quizHistoryTitle');
  String get quizHistoryEmpty => _value('quizHistoryEmpty');
  String get quizHistoryChartMinimum => _value('quizHistoryChartMinimum');
  String get quizTypeVerseCompletion => _value('quizTypeVerseCompletion');
  String get quizTypeVerseCompletionDesc =>
      _value('quizTypeVerseCompletionDesc');
  String get quizTypeWordMeaning => _value('quizTypeWordMeaning');
  String get quizTypeWordMeaningDesc => _value('quizTypeWordMeaningDesc');
  String get quizTypeVerseTopic => _value('quizTypeVerseTopic');
  String get quizTypeVerseTopicDesc => _value('quizTypeVerseTopicDesc');
  String get quizUnavailable => _value('quizUnavailable');
  String get quizStart => _value('quizStart');
  String get quizConfigTitle => _value('quizConfigTitle');
  String get quizQuestionCount => _value('quizQuestionCount');
  String get quizSurahFilter => _value('quizSurahFilter');
  String get quizAllQuran => _value('quizAllQuran');
  String get quizDifficultyLabel => _value('quizDifficultyLabel');
  String get quizDifficultyEasy => _value('quizDifficultyEasy');
  String get quizDifficultyMedium => _value('quizDifficultyMedium');
  String get quizDifficultyHard => _value('quizDifficultyHard');
  String get quizBegin => _value('quizBegin');
  String quizProgress(String current, String total) {
    return _value(
      'quizProgress',
    ).replaceAll('{current}', current).replaceAll('{total}', total);
  }

  String get quizCompleteThe => _value('quizCompleteThe');
  String get quizWhatMeans => _value('quizWhatMeans');
  String get quizWhichTopic => _value('quizWhichTopic');
  String get quizCorrect => _value('quizCorrect');
  String get quizIncorrect => _value('quizIncorrect');
  String get quizNext => _value('quizNext');
  String get quizShowFullVerse => _value('quizShowFullVerse');
  String get quizExitConfirmTitle => _value('quizExitConfirmTitle');
  String get quizExitConfirmMessage => _value('quizExitConfirmMessage');
  String get quizExitConfirm => _value('quizExitConfirm');
  String get quizExitCancel => _value('quizExitCancel');
  String quizMistakesReviewCount(String count) {
    return _value('quizMistakesReviewCount').replaceAll('{count}', count);
  }

  String get quizResultTitle => _value('quizResultTitle');
  String get quizResultScore => _value('quizResultScore');
  String get quizResultReviewTitle => _value('quizResultReviewTitle');
  String get quizTryAgain => _value('quizTryAgain');
  String get quizBackToHub => _value('quizBackToHub');
  String get quizReviewYourAnswer => _value('quizReviewYourAnswer');
  String get quizReviewCorrectAnswer => _value('quizReviewCorrectAnswer');
  String get quizResultTryAgain => _value('quizResultTryAgain');
  String get quizResultBackToHub => _value('quizResultBackToHub');
  String get quizResultYourAnswer => _value('quizResultYourAnswer');
  String get quizResultCorrectAnswer => _value('quizResultCorrectAnswer');
  String get quizResultExcellent => _value('quizResultExcellent');
  String get quizResultGreat => _value('quizResultGreat');
  String get quizResultGood => _value('quizResultGood');
  String get quizResultPractice => _value('quizResultPractice');
  String get quizResultVeryGood => _value('quizResultVeryGood');
  String get quizResultGoodStart => _value('quizResultGoodStart');
  String get quizResultKeepPracticing => _value('quizResultKeepPracticing');
  String get quizHistoryDate => _value('quizHistoryDate');
  String get quizHistoryScore => _value('quizHistoryScore');
  String get quizHistoryDifficulty => _value('quizHistoryDifficulty');
  String get quizMistakesBadge => _value('quizMistakesBadge');
  String get quizResultCardSaveAction => _value('quizResultCardSaveAction');
  String get quizResultCardShareAction => _value('quizResultCardShareAction');
  String get quizResultCardSaved => _value('quizResultCardSaved');
  String get quizResultCardSaveUnavailable =>
      _value('quizResultCardSaveUnavailable');
  String get quizResultCardShareUnavailable =>
      _value('quizResultCardShareUnavailable');
  String get quizResultCardExportUnavailable =>
      _value('quizResultCardExportUnavailable');
  String get quizResultCardSavePermissionDenied =>
      _value('quizResultCardSavePermissionDenied');

  String get settingsTitle => _value('settingsTitle');
  String get settingsPreviewEyebrow => _value('settingsPreviewEyebrow');
  String get settingsPreviewHelp => _value('settingsPreviewHelp');
  String get settingsPreviewVerse => _value('settingsPreviewVerse');
  String get settingsPreviewTranslation => _value('settingsPreviewTranslation');
  String get settingsSectionAppearance => _value('settingsSectionAppearance');
  String get settingsSectionReading => _value('settingsSectionReading');
  String get settingsThemeLabel => _value('settingsThemeLabel');
  String get settingsThemeSystem => _value('settingsThemeSystem');
  String get settingsThemeLight => _value('settingsThemeLight');
  String get settingsThemeDark => _value('settingsThemeDark');
  String get settingsLanguageLabel => _value('settingsLanguageLabel');
  String get settingsLanguageArabic => _value('settingsLanguageArabic');
  String get settingsLanguageEnglish => _value('settingsLanguageEnglish');
  String get settingsFontSizeLabel => _value('settingsFontSizeLabel');
  String get settingsFontSizeHelp => _value('settingsFontSizeHelp');
  String get settingsReaderModeLabel => _value('settingsReaderModeLabel');
  String get settingsTajweedLabel => _value('settingsTajweedLabel');
  String get settingsTajweedHelp => _value('settingsTajweedHelp');
  String get settingsSectionNightReader => _value('settingsSectionNightReader');
  String get settingsNightReaderAutoEnableLabel =>
      _value('settingsNightReaderAutoEnableLabel');
  String get settingsNightReaderAutoEnableHelp =>
      _value('settingsNightReaderAutoEnableHelp');
  String get settingsNightReaderStartLabel =>
      _value('settingsNightReaderStartLabel');
  String get settingsNightReaderEndLabel =>
      _value('settingsNightReaderEndLabel');
  String get settingsNightReaderPreferredStyleLabel =>
      _value('settingsNightReaderPreferredStyleLabel');
  String get settingsNightReaderAutoEnableOn =>
      _value('settingsNightReaderAutoEnableOn');
  String get settingsNightReaderAutoEnableOff =>
      _value('settingsNightReaderAutoEnableOff');
  String get settingsNightReaderStyleNight =>
      _value('settingsNightReaderStyleNight');
  String get settingsNightReaderStyleAmoled =>
      _value('settingsNightReaderStyleAmoled');
  String get settingsNightReaderInvalidSchedule =>
      _value('settingsNightReaderInvalidSchedule');
  String get settingsNotificationsEntryTitle =>
      _value('settingsNotificationsEntryTitle');
  String get settingsNotificationsEntrySubtitle =>
      _value('settingsNotificationsEntrySubtitle');
  String get notificationsSettingsTitle => _value('notificationsSettingsTitle');
  String get notificationsSettingsFamiliesTitle =>
      _value('notificationsSettingsFamiliesTitle');
  String get notificationsTimeLabel => _value('notificationsTimeLabel');
  String get notificationsPermissionRequestAction =>
      _value('notificationsPermissionRequestAction');
  String get notificationsPermissionUnknownTitle =>
      _value('notificationsPermissionUnknownTitle');
  String get notificationsPermissionUnknownBody =>
      _value('notificationsPermissionUnknownBody');
  String get notificationsPermissionGrantedTitle =>
      _value('notificationsPermissionGrantedTitle');
  String get notificationsPermissionGrantedBody =>
      _value('notificationsPermissionGrantedBody');
  String get notificationsPermissionDeniedTitle =>
      _value('notificationsPermissionDeniedTitle');
  String get notificationsPermissionDeniedBody =>
      _value('notificationsPermissionDeniedBody');
  String get notificationsPermissionBlockedTitle =>
      _value('notificationsPermissionBlockedTitle');
  String get notificationsPermissionBlockedBody =>
      _value('notificationsPermissionBlockedBody');
  String get notificationsPermissionUnavailableTitle =>
      _value('notificationsPermissionUnavailableTitle');
  String get notificationsPermissionUnavailableBody =>
      _value('notificationsPermissionUnavailableBody');
  String get notificationsFamilyDailyWirdTitle =>
      _value('notificationsFamilyDailyWirdTitle');
  String get notificationsFamilyDailyWirdSubtitle =>
      _value('notificationsFamilyDailyWirdSubtitle');
  String get notificationsFamilyPrayerTitle =>
      _value('notificationsFamilyPrayerTitle');
  String get notificationsFamilyPrayerSubtitle =>
      _value('notificationsFamilyPrayerSubtitle');
  String get notificationsFamilyFridayKahfTitle =>
      _value('notificationsFamilyFridayKahfTitle');
  String get notificationsFamilyFridayKahfSubtitle =>
      _value('notificationsFamilyFridayKahfSubtitle');
  String get notificationsFamilyReviewTitle =>
      _value('notificationsFamilyReviewTitle');
  String get notificationsFamilyReviewSubtitle =>
      _value('notificationsFamilyReviewSubtitle');
  String get notificationsFamilyAdhkarTitle =>
      _value('notificationsFamilyAdhkarTitle');
  String get notificationsFamilyAdhkarSubtitle =>
      _value('notificationsFamilyAdhkarSubtitle');
  String get notificationsFamilyStatusPermissionRequired =>
      _value('notificationsFamilyStatusPermissionRequired');
  String get notificationsFamilyStatusPrayerUnavailable =>
      _value('notificationsFamilyStatusPrayerUnavailable');
  String get notificationsFamilyStatusReviewWaiting =>
      _value('notificationsFamilyStatusReviewWaiting');
  String get notificationsReminderDailyWirdTitle =>
      _value('notificationsReminderDailyWirdTitle');
  String get notificationsReminderDailyWirdBody =>
      _value('notificationsReminderDailyWirdBody');
  String get notificationsReminderAdhkarTitle =>
      _value('notificationsReminderAdhkarTitle');
  String get notificationsReminderAdhkarBody =>
      _value('notificationsReminderAdhkarBody');
  String get notificationsReminderFridayKahfTitle =>
      _value('notificationsReminderFridayKahfTitle');
  String get notificationsReminderFridayKahfBody =>
      _value('notificationsReminderFridayKahfBody');
  String get notificationsReminderPrayerTitle =>
      _value('notificationsReminderPrayerTitle');
  String get notificationsReminderPrayerBodyGeneric =>
      _value('notificationsReminderPrayerBodyGeneric');
  String notificationsReminderPrayerBody(String prayerName) {
    return '${_value('notificationsReminderPrayerBodyPrefix')} $prayerName';
  }

  String get notificationsReminderReviewTitle =>
      _value('notificationsReminderReviewTitle');
  String get notificationsReminderReviewBody =>
      _value('notificationsReminderReviewBody');
  String get prayerDetailsTitle => _value('prayerDetailsTitle');
  String get prayerDetailsLoadingMonth => _value('prayerDetailsLoadingMonth');
  String get prayerDetailsError => _value('prayerDetailsError');
  String get prayerDetailsTrackPrayers => _value('prayerDetailsTrackPrayers');
  String get prayerTodayTitle => _value('prayerTodayTitle');
  String get prayerAdherenceToday => _value('prayerAdherenceToday');
  String prayerAdherenceStreak(String count) {
    return _value('prayerAdherenceStreak').replaceAll('{count}', count);
  }

  String get prayerStatusPast => _value('prayerStatusPast');
  String get prayerStatusCurrent => _value('prayerStatusCurrent');
  String get prayerStatusUpcoming => _value('prayerStatusUpcoming');
  String get prayerWeeklyTitle => _value('prayerWeeklyTitle');
  String get prayerReminderOffsetLabel => _value('prayerReminderOffsetLabel');
  String get prayerReminderAtAdhan => _value('prayerReminderAtAdhan');
  String prayerReminderMinsBefore(String mins) {
    return _value('prayerReminderMinsBefore').replaceAll('{mins}', mins);
  }

  String get prayerLabelFajr => _value('prayerLabelFajr');
  String get prayerLabelDhuhr => _value('prayerLabelDhuhr');
  String get prayerLabelAsr => _value('prayerLabelAsr');
  String get prayerLabelMaghrib => _value('prayerLabelMaghrib');
  String get prayerLabelIsha => _value('prayerLabelIsha');
  String get qiblaCompassTitle => _value('qiblaCompassTitle');
  String get qiblaCompassLoading => _value('qiblaCompassLoading');
  String get qiblaCompassError => _value('qiblaCompassError');
  String get qiblaCompassDistance => _value('qiblaCompassDistance');
  String get qiblaCompassBearing => _value('qiblaCompassBearing');
  String get qiblaCompassHeading => _value('qiblaCompassHeading');
  String get qiblaCompassFacing => _value('qiblaCompassFacing');
  String get qiblaCompassNotFacing => _value('qiblaCompassNotFacing');
  String get qiblaCompassTurnLeft => _value('qiblaCompassTurnLeft');
  String get qiblaCompassTurnRight => _value('qiblaCompassTurnRight');
  String get qiblaCompassCalibrate => _value('qiblaCompassCalibrate');
  String get qiblaCompassSensorUnavailable =>
      _value('qiblaCompassSensorUnavailable');
  String get qiblaCompassNeedleHint => _value('qiblaCompassNeedleHint');

  // ─── AI Features ───
  String get aiFeatures => _value('aiFeatures');
  String get aiPowered => _value('aiPowered');
  String get aiDisclaimer => _value('aiDisclaimer');
  String get aiDisclaimerFull => _value('aiDisclaimerFull');
  String get aiOffline => _value('aiOffline');
  String get aiTimeout => _value('aiTimeout');
  String get aiRetry => _value('aiRetry');
  String get aiUnavailable => _value('aiUnavailable');
  String get aiQuotaExhausted => _value('aiQuotaExhausted');
  String get aiQuotaRemaining => _value('aiQuotaRemaining');
  String get aiProviderError => _value('aiProviderError');
  String get aiSafetyBlocked => _value('aiSafetyBlocked');
  String get aiPremiumFeature => _value('aiPremiumFeature');
  String get refusesFatwa => _value('refusesFatwa');
  String get technicalSummary => _value('technicalSummary');
  String get referToScholar => _value('referToScholar');
  String get upgradeForUnlimitedAi => _value('upgradeForUnlimitedAi');
  String aiQuotaFormat(String remaining, String total) {
    return _value('aiQuotaFormat')
        .replaceAll('{remaining}', remaining)
        .replaceAll('{total}', total);
  }
  String aiQuotaRemainingFormat(String remaining, String total) {
    return _value('aiQuotaRemainingFormat')
        .replaceAll('{remaining}', remaining)
        .replaceAll('{total}', total);
  }

  // ─── AI: Simplify ───
  String get simplifyTafsir => _value('simplifyTafsir');
  String get simplifying => _value('simplifying');
  String get simplifiedSummary => _value('simplifiedSummary');
  String get noTafsirToSimplify => _value('noTafsirToSimplify');
  String get tafsirAlreadyShort => _value('tafsirAlreadyShort');
  String get simplifyError => _value('simplifyError');

  // ─── AI: Smart Search ───
  String get smartSearch => _value('smartSearch');
  String get searchByTopic => _value('searchByTopic');
  String get searchingTopics => _value('searchingTopics');
  String get noSmartResults => _value('noSmartResults');
  String get smartSearchHint => _value('smartSearchHint');
  String get fallbackToKeyword => _value('fallbackToKeyword');
  String get searchTopicPlaceholder => _value('searchTopicPlaceholder');

  // ─── AI: Context ───
  String get verseContext => _value('verseContext');
  String get contextAndConnection => _value('contextAndConnection');
  String get loadingContext => _value('loadingContext');

  // ─── AI: Tadabbur ───
  String get reflectionQuestions => _value('reflectionQuestions');
  String get tadabburQuestions => _value('tadabburQuestions');
  String get generatingQuestions => _value('generatingQuestions');

  // ─── AI: Juz Summary ───
  String get juzSummary => _value('juzSummary');
  String get summarizeJuz => _value('summarizeJuz');
  String get loadingSummary => _value('loadingSummary');

  // ─── Stories extras ───
  String get storiesAddToFavorites => _value('storiesAddToFavorites');
  String get storiesRemoveFromFavorites => _value('storiesRemoveFromFavorites');
  String get storiesNoFavorites => _value('storiesNoFavorites');
  String get storiesNoStoriesFound => _value('storiesNoStoriesFound');
  String get storiesReadingProgress => _value('storiesReadingProgress');
  String get storiesCompleted => _value('storiesCompleted');
  String get storiesFavorites => _value('storiesFavorites');
  String get storiesContinueReading => _value('storiesContinueReading');
  String get storiesReadNow => _value('storiesReadNow');
  String get storiesStartReading => _value('storiesStartReading');
  String get storiesOpenInReader => _value('storiesOpenInReader');
  String get storiesShareUnavailable => _value('storiesShareUnavailable');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
        (supportedLocale) =>
            supportedLocale.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
