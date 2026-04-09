# مرجع المرحلة الثالثة

هذا الملف هو المرجع التنفيذي للمرحلة الثالثة بعد اكتمال الأساس الكبير في
المرحلة الأولى، وبناء طبقة التمييز الأساسية في المرحلة الثانية.

الهدف هنا ليس مجرد إضافة شاشات جديدة، بل اختيار التوسعات التي تعمّق قيمة
التطبيق فعلًا، وتستفيد من الموجود، وتفصل بين ما يمكن شحنه بسرعة، وبين ما
يحتاج subproject مستقل أو قرار تقني قبل البدء.

---

## 1. هدف المرحلة الثالثة

المرحلة الثالثة هي مرحلة:

- تعميق تجربة القراءة والفهم، لا مجرد توسيع عدد الشاشات.
- تحويل التطبيق من "قارئ + صوت + حفظ + أدوات يومية" إلى منتج أعمق في:
  التفسير، التدبر، القياس، التفاعل، والمحتوى القرآني الغني.
- الاستفادة من البنية الحالية بدل هدمها أو تجاوزها.
- فرز البنود الكبيرة جدًا مبكرًا حتى لا تختلط مع البنود التي يمكن شحنها من
  الأساس الموجود فعليًا.

بمعنى عملي:

- المرحلة الأولى بنت core قوي.
- المرحلة الثانية بنت differentiation واضح.
- المرحلة الثالثة يجب أن تبني depth وintelligence وrich experiences فوق هذا
  الأساس.

---

## 2. خط الأساس الحالي قبل بدء المرحلة الثالثة

### 2.1 ما هو موجود بالفعل ويمكن البناء عليه

الريبو الحالي ليس فارغًا. بالعكس، فيه foundations قوية جدًا يمكن الاعتماد
عليها:

- قارئ ناضج في `reader` مع أوضاع `scroll / page / translation`.
- fullscreen mode، حفظ موضع القراءة، quick jump، drawer، ومشاركة الآيات.
- bottom sheets للآية: ترجمة، تفسير، علوم، ملاحظات، نسخ، مشاركة، واستماع.
- `tafsir browser` مستقل داخل `lib/features/tafsir`.
- `audio hub` كامل نسبيًا: تشغيل، mini player، reciters، download manager،
  offline audio، وخدمة تشغيل مشتركة.
- `library` فيها surahs + khatmas + manual saves + ayah search +
  translation search + topics browser.
- `memorization` فيها hub، khatma planner، spaced review، review queue،
  review session، achievements dashboard.
- `more` فيها prayer times، qibla، adhkar، وتتبع محلي لبعض بيانات الصلاة.
- `notifications` فيها إعدادات محلية وجدولة وإطلاق داخلي وروابط تنقل.
- `premium` فيها paywall وfeature matrix وحدود مدفوعة داخل التطبيق.
- localization موجودة فعليًا عبر `AppLocalizations`.
- الاعتماد المحلي واضح: `SharedPreferences`, `sqflite`, أصول محلية، وخدمات
  app-owned حول الحزم الخارجية.

### 2.2 ما هو غير موجود أو غير ناضج للمرحلة الثالثة

هذه الأنظمة غير موجودة أو ليست ناضجة بما يكفي بعد:

- لا يوجد word-by-word layer متكامل.
- لا يوجد i'rab / asbab al-nuzul / related-ayah graph كطبقات app-owned.
- لا يوجد night-reader مستقل بخصائص بصرية مخصصة لليل.
- لا يوجد tadabbur mode كامل فوق القارئ الحالي، رغم وجود notes يمكن البناء
  عليها.
- لا يوجد analytics dashboard مشتق يعرض trends وتقارير واضحة للمستخدم.
- لا يوجد quizzes engine أو exam engine.
- لا يوجد recording pipeline ولا mic permissions flow داخل التطبيق.
- لا يوجد map provider ولا datasets مكانية لبناء Quran Maps.
- لا يوجد authored content pipeline للقصص القرآنية.
- لا يوجد AI provider abstraction أو safety/prompt boundaries في الكود.
- لا يوجد 3D/AR support layer للقبلة.

### 2.3 خلاصة مهمة

أي phase 3 reference مبني على فكرة أن "المشروع ما زال empty" سيكون مضللًا.

المرجع الصحيح هنا يجب أن يتعامل مع:

- الريبو الحالي باعتباره source of truth للحالة التنفيذية.
- `project_features.md` باعتباره source of truth لنية المنتج.
- `project_features_review.md.resolved` باعتباره مفيدًا للترقيم والاتجاهات
  العامة، لا لوصف الحالة الحالية للريبو.

---

## 3. بوابة الدخول قبل بدء المرحلة الثالثة

### 3.1 المطلوب قبل التنفيذ الفعلي

قبل أي feature من phase 3، نحتاج التأكد من الآتي:

- أي بنود متبقية أو placeholders من phase 2 تكون إما:
  shipped فعلًا، أو مؤجلة صراحة، أو موثقة كديون/fast-follow.
- تشغيل تحقق أساسي على البيئة الحالية عندما تسمح البيئة:
  `flutter analyze`
  `flutter test`
  `flutter build apk --debug`
- حسم القرارات التقنية للبنود المعتمدة على مزودات خارجية:
  AI, maps, recording/speech evaluation, AR.
- حسم سياسات الخصوصية والصلاحيات لأي ميزة ستستخدم:
  microphone, camera, location-heavy usage, external APIs.

### 3.2 لماذا هذا مهم

لأن المرحلة الثالثة تحتوي نوعين مختلفين جدًا من العمل:

- features يمكن بناؤها فوق الأساس الموجود بسرعة مع توسعات منطقية.
- features تحتاج بنية جديدة بالكامل أو vendor decisions أو data pipeline
  خاص.

خلط النوعين معًا يجعل الخطة تبدو كبيرة جدًا ومبهمة، ويؤدي غالبًا إلى:

- تأخير.
- scope creep.
- بداية خاطئة في ميزة تعتمد على decisions غير محسومة.

### 3.3 القرار العملي

لا نبدأ phase 3 كباك لوج واحد.

نبدأها على شكل waves مرتبة، ونفصل مبكرًا بين:

- البنود القابلة للشحن من foundations موجودة.
- البنود التي تحتاج subproject تقني مستقل.

---

## 4. مبادئ التنفيذ العامة للمرحلة الثالثة

### 4.1 تعميق الموجود قبل التوسع الأفقي

الأولوية هنا ليست لعدد أكبر من features، بل لfeatures تجعل:

- القارئ أعمق.
- الحفظ أذكى.
- الصلاة والالتزام أوضح.
- المحتوى القرآني أغنى وأكثر تماسكًا.

لذلك البنود الأقرب للبنية الحالية يجب أن تسبق البنود التي تحتاج stack جديدًا.

### 4.2 إعادة الاستخدام قبل البناء من الصفر

كل بند في phase 3 يجب أن يبدأ بسؤالين:

- ما الذي أملكه بالفعل في `reader / tafsir / memorization / more / audio`؟
- ما أقل توسيع لازم لكي أطلق أول slice مفيد؟

مثال:

- `night reader` يجب أن يبنى فوق reader الحالي، لا كقارئ جديد مستقل.
- `tadabbur` يجب أن يعيد استخدام notes + verse surfaces + fullscreen +
  reader navigation.
- `analytics` يجب أن يستنتج أولًا من البيانات المحلية الموجودة قبل التفكير
  في telemetry أو backend.

### 4.3 local-first بحدود واضحة مع أي مزود خارجي

عندما ندخل AI أو maps أو speech analysis، لا يجب أن تتسرب الحزمة أو الـ SDK
مباشرة إلى كل مكان.

المطلوب:

- app-owned abstraction layer.
- provider/service boundaries واضحة.
- fallback behavior واضح عند غياب الشبكة أو فشل المزود.
- قابلية تشغيل أول slice بدون ربط كل التطبيق بالمزود.

### 4.4 الخصوصية والصلاحيات مبكرًا

أي ميزة تستخدم:

- microphone
- camera
- location-rich experience
- API request يحمل user-generated content

يجب أن تُصمم من البداية وفيها:

- permission flow واضح.
- شرح للمستخدم لماذا نطلب الصلاحية.
- minimal-data approach.
- fallback محترم إذا رفض المستخدم الصلاحية.

### 4.5 فصل "الميزة الكبيرة جدًا"

هذه البنود لا يجب أن تعامل كبنود UI بسيطة:

- `3.4` AI Features
- `3.8` Recitation Practice
- `3.9` Quran Maps
- `3.11` Enhanced Qibla (3D + AR)

كل بند من هؤلاء قد يحتاج:

- spec منفصل.
- spike تقني.
- provider decision.
- dataset/content strategy.
- verification مختلف عن features المحلية البحتة.

### 4.6 الترجمة والتعريب

حتى لو العمل هنا documentation-only، أي تنفيذ لاحق لبنود المرحلة الثالثة يجب
أن يلتزم بما هو قائم في المشروع:

- كل النصوص user-facing عبر `AppLocalizations`.
- لا hardcoded strings جديدة في الواجهات.
- العربية هي اللغة الأساسية، مع اتساق كامل مع النسخة الإنجليزية.

---

## 5. ترتيب التنفيذ المقترح

## 5.1 Wave 1: تعميق القارئ والاستفادة من البيانات المحلية

هذه أول wave موصى بها لأنها تبني فوق foundations موجودة بقوة:

1. `3.2` قارئ ليلي محسّن
2. `3.3` وضع التدبر المتقدم
3. `3.5` التقارير والإحصائيات
4. `3.12` مواقيت الصلاة المحسّنة

سبب هذه wave:

- تعتمد بدرجة كبيرة على reader / memorization / more الموجودة.
- لا تحتاج vendor decision كبير قبل أول slice.
- تعطي قيمة يومية واضحة بسرعة.

## 5.2 Wave 2: طبقة الفهم والتقييم المنظم

بعد تثبيت Wave 1:

1. `3.1` التفسير التفاعلي المتقدم
2. `3.6` المسابقات والاختبارات
3. `3.7` وضع الامتحان

سبب هذه wave:

- ما زالت قريبة من الأساس الحالي.
- لكنها تحتاج structuring أكبر للمحتوى والبيانات والمنطق التفاعلي.
- تستفيد من استقرار reader + tafsir + memorization surfaces.

## 5.3 Wave 3: التوسع بالمحتوى القرآني الغني

بعد ما يكون التطبيق ثابت في عمق القراءة والتفاعل:

1. `3.10` القصص القرآنية
2. `3.9` الخرائط القرآنية

سبب هذه wave:

- هذه features محتواها/dataset أهم من مجرد UI.
- الأفضل بناؤها بعدما يكون عندنا clarity في أسلوب العرض والربط بالآيات.

## 5.4 Wave 4: الرهانات الثقيلة تقنيًا

هذه تؤجل لآخر wave أو تُدار كsubprojects مستقلة:

1. `3.4` ميزات الذكاء الاصطناعي
2. `3.8` ممارسة التلاوة
3. `3.11` بوصلة القبلة المحسّنة

سبب هذه wave:

- تعتمد على vendors أو قدرات platform إضافية.
- فيها مخاطر خصوصية/صلاحيات/دقة تقنية أعلى.
- لا يجب أن تعطل البنود الأسهل والأسرع قيمة.

---

## 6. خريطة التبعيات بين بنود المرحلة الثالثة

### تبعيات مباشرة

- `3.2` يعتمد على:
  reader theme system + fullscreen + settings/runtime theme sync.
- `3.3` يعتمد على:
  reader surfaces + ayah notes + verse-level navigation + possibly timers.
- `3.5` يعتمد على:
  sessions + khatmas + spaced review + achievements + prayer tracking data.
- `3.12` يعتمد على:
  prayer snapshot cache + prayer tracking + notifications + calendar UI.
- `3.1` يعتمد على:
  existing tafsir browser + reader insights surface + local/remote Quran text
  repositories + structured metadata.
- `3.6` يعتمد على:
  Quran data access + topics/search + scoring model + lightweight persistence.
- `3.7` يعتمد على:
  reader rendering + memorization state + evaluation rules، ويستفيد من `3.6`.
- `3.10` يعتمد على:
  authored content model + verse-linking + story assets/content strategy.
- `3.9` يعتمد على:
  location/place dataset + map/list presentation + verse/location links.
- `3.4` يعتمد على:
  AI provider abstraction + safety rules + structured prompt inputs + fallback UX.
- `3.8` يعتمد على:
  recording pipeline + mic permissions + audio sync + evaluation strategy.
- `3.11` يعتمد على:
  current qibla foundation + animation strategy + optional map/AR support.

### تبعيات غير مباشرة

- نجاح `3.3` يجعل `3.5` أغنى لأن analytics وقتها يمكن أن تقيس reflection
  sessions أو use of notes لاحقًا.
- نجاح `3.1` يساعد `3.6` و`3.7` لأن بعض أنواع الأسئلة أو feedback يمكن أن
  تعتمد على structured tafsir / meaning data.
- `3.10` و`3.9` يستفيدان من أي asset/content pipeline يُبنى باكرًا.
- `3.12` و`3.11` يجب أن يحافظا على نفس data ownership في `more` حتى لا يحدث
  تكرار أو split في منطق الصلاة والقبلة.

---

## 7. البنود التفصيلية للمرحلة الثالثة

## 7.1 `3.1` التفسير التفاعلي المتقدم

### الهدف

تحويل التفسير من شاشة قراءة تفسير فقط إلى طبقة تفاعلية متعددة الأبعاد تساعد
المستخدم على فهم الآية من أكثر من مدخل: معنى، سياق، روابط، ومراجع إضافية.

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود حاليًا قوي كبداية:

- `tafsir browser` قائم بالفعل.
- `reader_ayah_insights_sheet` موجود كمدخل سريع من القارئ.
- translation + tafsir repositories والبنية العامة لعرض نصوص الشرح موجودة.
- navigation بين السور والآيات موجودة بالفعل.

غير الموجود:

- word-by-word dataset/app-owned layer.
- i'rab layer.
- asbab al-nuzul layer.
- related-ayah graph أو cross-reference explorer.

### نطاق المرحلة الثالثة

الـ scope الموصى به لأول slice من هذا البند:

- توسيع `ayah insights` و`tafsir browser` إلى sections واضحة قابلة للإضافة.
- البدء بطبقات موثوقة ومهيكلة أولًا، مثل:
  vocabulary/word meaning
  سبب النزول إن توفر مصدر منضبط
  روابط آيات مشابهة أو موضوعيًا قريبة
- جعل كل section تعتمد على source availability واضح، لا على افتراض وجود كل
  البيانات.

### خارج النطاق

- chatbot تفسيري حر.
- توليد linguistic analysis بالذكاء الاصطناعي بدون source موثق.
- بناء محرك لغوي عربي كامل من الصفر داخل هذا الـ slice.

### التبعيات

- structured metadata sources.
- contracts موحدة لكل insight section.
- توافق العرض مع `reader` و`tafsir browser`.

### الشاشات والتدفقات

- من long press على الآية -> `Sciences` -> `Advanced Insights`.
- من `tafsir browser` -> tabs/sections جديدة داخل نفس التجربة.
- من `library topics` أو نتائج البحث -> فتح الآية ثم الوصول لنفس الطبقات.

### خطوات التنفيذ المقترحة

1. تعريف model موحد لطبقات الـ insights.
2. فصل كل section في provider/data source مستقل.
3. بناء first-party UI sections قابلة للإخفاء حسب توافر البيانات.
4. توسيع `reader_ayah_insights_sheet` و`tafsir browser` بدل بناء سطح جديد.
5. إطلاق أول slice بطبقتين أو ثلاث موثوقات فقط، ثم التوسع لاحقًا.

### معايير القبول

- المستخدم يستطيع فتح الآية ورؤية أكثر من نوع insight داخل surface موحدة.
- كل طبقة تعرض loading/error/unavailable state محترمة.
- التنقل بين الآيات لا يكسر state ولا يخرج المستخدم من السياق.
- غياب dataset معين لا يؤدي إلى كسر الشاشة بالكامل.

### الاختبارات

- widget tests لحالات section available/unavailable.
- provider tests لكل source adapter.
- smoke tests للتنقل بين الآيات داخل `tafsir browser`.

### المخاطر والملاحظات

- أكبر خطر هنا هو جودة البيانات لا الـ UI.
- لا يجب أن نعد بطبقات مثل i'rab أو asbab إلا بعد توثيق المصدر وصياغة model
  ثابتة.

## 7.2 `3.2` قارئ ليلي محسّن (Night Reading Mode)

### الهدف

تقديم تجربة قراءة ليلية مريحة للعين ومندمجة في القارئ الحالي، لا قارئًا منفصلًا.

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود حاليًا:

- theme system على مستوى التطبيق.
- reader fullscreen.
- settings runtime sync.
- page/scroll/translation modes.

غير الموجود:

- preset ليلي app-owned خاص بالقارئ.
- AMOLED mode خاص بالقراءة.
- سلوك ليلي مضبوط للسطوع/التلوين داخل surfaces القارئ.

### نطاق المرحلة الثالثة

الـ scope الموصى به:

- `Night Reader` toggle أو preset داخل القارئ.
- لوحات ألوان ليلية مريحة، مع contrast مضبوط.
- `AMOLED black` variant.
- optional time-aware suggestion أو auto-enable اختياري من settings.
- تطبيق نفس النمط على `scroll / page / translation` بدون تفاوت مزعج.

### خارج النطاق

- التحكم المباشر في system brightness بشكل إجباري.
- blue-light filter على مستوى النظام.
- إنشاء شاشة قارئ منفصلة خاصة بالليل.

### التبعيات

- `AppTheme` وreader chrome.
- settings persistence.
- page وscroll rendering compatibility.

### الشاشات والتدفقات

- toggle من reader toolbar أو reader settings sheet.
- إعداد دائم من settings.
- entry suggestion ليلية optional عند فتح القارئ ليلًا.

### خطوات التنفيذ المقترحة

1. تعريف `ReaderNightPresentationPolicy` أو equivalent theme layer.
2. إضافة preference واضحة للمستخدم داخل الإعدادات.
3. توحيد الخلفيات والألوان والoverlays لكل reader mode.
4. اختبار readability في page/scroll/translation.
5. إضافة AMOLED variant كخيار فرعي لا كdefault إجباري.

### معايير القبول

- يمكن تشغيل الوضع الليلي وإيقافه بدون فقدان موضع القراءة.
- كل reader modes تدعم الوضع الليلي بشكل متناسق.
- النص والmarkers وأزرار chrome تبقى واضحة ومقروءة.
- تفضيل المستخدم يُحفظ ويُستعاد في الجلسات اللاحقة.

### الاختبارات

- widget tests لتغير الألوان والحالة.
- state tests لحفظ واستعادة preference.
- manual verification على page وscroll وtranslation modes.

### المخاطر والملاحظات

- خطر هذه الميزة ليس تقنيًا كبيرًا، بل بصريًا وتجريبيًا.
- لذلك هي أفضل بداية للمرحلة الثالثة.

## 7.3 `3.3` وضع التدبر المتقدم (Tadabbur Mode)

### الهدف

إتاحة تجربة تأمل أبطأ وأهدأ تركّز على آية أو مقطع صغير، مع كتابة reflections
شخصية داخل التطبيق.

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود الآن:

- reader navigation والانتقال بين الآيات.
- fullscreen experience.
- `ayah notes` موجودة بالفعل.
- translation وtafsir surfaces يمكن استدعاؤها عند الحاجة.

غير الموجود:

- mode مخصص للتدبر.
- timer/pace controls.
- presentation layer تركز على آية واحدة أو مجموعة صغيرة.
- reflection session framing كمفهوم مستقل.

### نطاق المرحلة الثالثة

الـ scope الموصى به:

- دخول `Tadabbur Mode` من القارئ أو من verse actions.
- عرض آية واحدة أو card واحدة كبيرة مع مساحة هادئة.
- timer اختياري للتأمل.
- كتابة reflection وربطها بالآية.
- العودة السلسة إلى القارئ العادي دون كسر السياق.

### خارج النطاق

- شبكة اجتماعية أو feed لتأملات المستخدمين.
- moderation/content pipeline لمشاركة عامة.
- جلسات صوتية guided meditation.

### التبعيات

- `ayah_notes_provider`.
- reader navigation target/state.
- localization copy واضحة جدًا لهذا الوضع.

### الشاشات والتدفقات

- من الآية -> `Enter Tadabbur Mode`.
- داخل الوضع: قراءة -> تأمل -> كتابة note -> next/previous ayah.
- خروج سلس إلى القارئ أو حفظ الجلسة محليًا.

### خطوات التنفيذ المقترحة

1. تعريف session model خفيف لوضع التدبر.
2. إعادة استخدام notes الحالية بدل بناء storage جديد.
3. بناء surface مخصص بواجهة أبسط من القارئ الكامل.
4. إضافة timer optional وminimal controls.
5. ربط مخرجات الجلسة بالملاحظات والتحليلات لاحقًا.

### معايير القبول

- يمكن بدء جلسة تدبر من آية محددة بسهولة.
- يمكن كتابة reflection وحفظها محليًا وربطها بالآية.
- يمكن التنقل داخل الجلسة بدون فقدان النص أو note.
- الخروج من الوضع يعيد المستخدم بسلاسة إلى السياق السابق.

### الاختبارات

- provider tests لحفظ/استرجاع notes في هذا المسار.
- widget tests لحالات timer وempty note وsaved note.
- manual verification للتنقل بين reader وtadabbur mode.

### المخاطر والملاحظات

- يجب أن يبقى هذا الوضع هادئًا ومحدودًا، لا يتحول إلى نسخة ثانية معقدة من
  القارئ.
- reuse للملاحظات الحالية أفضل من خلق storage parallel.

## 7.4 `3.4` ميزات الذكاء الاصطناعي (AI Features)

### الهدف

إضافة قدرات ذكية تضيف قيمة حقيقية للفهم والوصول إلى المعرفة، من غير أن تتحول
الميزة إلى "روبوت يجيب عن كل شيء" بلا حدود.

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود حاليًا:

- search foundations.
- tafsir/translation content surfaces.
- app-owned architecture patterns حول الخدمات الخارجية.
- premium layer يمكن أن تستوعب gating إذا لزم.

غير الموجود:

- AI provider abstraction.
- prompt/safety policy.
- network boundary خاصة بميزات AI.
- semantic retrieval layer.

### نطاق المرحلة الثالثة

هذا البند يجب أن يبدأ كsubproject مستقل، وأول slice موصى به هو واحد فقط من:

- semantic search تجريبي محدود.
- تبسيط/تلخيص تفسير قائم من source معروف.

ولا يُنصح بإطلاق أكثر من use case واحد في البداية.

### خارج النطاق

- مساعد ديني عام مفتوح.
- إجابات فقهية أو فتوى تلقائية.
- استخدام AI كبديل عن التفسير المعتمد.
- ربط الميزة بكل أسطح التطبيق منذ أول release.

### التبعيات

- provider decision.
- safety/prompt rules.
- cost controls.
- connectivity + timeout + fallback UX.
- privacy policy واضحة.

### الشاشات والتدفقات

- entry محدود من search أو tafsir، وليس global floating assistant.
- user asks -> guarded request -> structured result -> clear disclaimer/fallback.

### خطوات التنفيذ المقترحة

1. اختيار provider وتجريد service boundary app-owned.
2. كتابة policy واضحة: allowed inputs, disallowed outputs, disclaimers.
3. تنفيذ use case واحد narrow.
4. إضافة analytics داخلية لاستخدام الميزة وتكلفتها.
5. توسيع النطاق فقط بعد مراجعة الجودة والثقة.

### معايير القبول

- كل استدعاء AI يمر عبر service boundary واحدة.
- توجد حالات timeout/error/fallback واضحة.
- الـ UX لا يدعي authority أعلى من المصادر الأصلية.
- يمكن تعطيل الميزة أو تبديل المزود دون إعادة هيكلة التطبيق كله.

### الاختبارات

- unit tests على prompt/result mapping.
- mocked integration tests لحالات success/failure/timeout.
- manual verification للنصوص التحذيرية والfallback behavior.

### المخاطر والملاحظات

- هذا البند عالي المخاطر من ناحية الثقة والتكلفة.
- لذلك يجب أن يبقى في wave متأخرة، وبنطاق ضيق جدًا في البداية.

## 7.5 `3.5` التقارير والإحصائيات (Analytics Dashboard)

### الهدف

تحويل البيانات المحلية الحالية إلى تقارير مفهومة تساعد المستخدم على رؤية
تقدمه الفعلي في القراءة والحفظ والالتزام.

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود حاليًا:

- `ReadingSession` وسجل القراءة.
- khatma planner summaries.
- spaced review state.
- achievements snapshot data.
- prayer tracking local data.

غير الموجود:

- dashboard موحد.
- visual summaries/charts.
- derived analytics policy موحدة.

### نطاق المرحلة الثالثة

الـ scope الموصى به لأول slice:

- dashboard محلي بالكامل.
- weekly/monthly summaries.
- عدد الصفحات/الآيات/الدقائق المقروءة.
- streaks أو continuity signals.
- أكثر السور قراءة.
- progress snapshots للحفظ والمراجعة.

وإذا كان التنفيذ يريد charts:

- يبدأ برسوم بسيطة جدًا أو mini charts.
- لا يشترط charting stack ضخم من البداية.

### خارج النطاق

- cloud analytics.
- مقارنة المستخدمين ببعض.
- export/report sharing المعقد.
- machine-learning insights.

### التبعيات

- data aggregation policy موحدة.
- تنظيف legacy session edge cases.
- optional charting presentation layer.

### الشاشات والتدفقات

- entry من memorization أو more أو profile-level analytics surface.
- overview -> reading -> memorization -> prayer insights.

### خطوات التنفيذ المقترحة

1. تعريف `AnalyticsSnapshotPolicy` app-owned.
2. اشتقاق المؤشرات من البيانات الحالية بدل تخزين analytics جديدة.
3. بناء dashboard cards أولًا.
4. إضافة mini trends/charts فقط عند الحاجة.
5. توثيق أي قيود في جودة البيانات التاريخية.

### معايير القبول

- المستخدم يرى تقريرًا أسبوعيًا/شهريًا واضحًا من البيانات المحلية.
- لا يوجد duplication لمصدر الحقيقة؛ كل الأرقام مشتقة من sources الحالية.
- dashboard يعرض empty states محترمة للمستخدم الجديد.
- الحسابات لا تتضارب مع sessions أو khatma progress المعروضة في بقية التطبيق.

### الاختبارات

- unit tests لسياسات الاشتقاق والتجميع.
- widget tests لحالات empty/new/power-user.
- manual validation بعينات بيانات فعلية من التخزين المحلي.

### المخاطر والملاحظات

- دقة الـ dashboard تعتمد على نظافة session ownership الحالية.
- من الأفضل البدء بمؤشرات قليلة موثوقة بدل dashboard ضخم متذبذب.

## 7.6 `3.6` المسابقات والاختبارات (Quizzes)

### الهدف

إضافة طبقة تفاعل وتعليم خفيفة تساعد المستخدم على التثبيت والمراجعة عبر أسئلة
مهيكلة، لا عبر gamification فارغة.

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود حاليًا:

- Quran text access.
- topic browser.
- tafsir foundations.
- memorization data.
- achievements/premium patterns يمكن الاستفادة منها لاحقًا.

غير الموجود:

- question engine.
- question bank أو generation rules.
- quiz session/result flow.

### نطاق المرحلة الثالثة

الـ scope الموصى به لأول slice:

- أنواع أسئلة محدودة وواضحة فقط، مثل:
  إكمال آية قصيرة
  معنى كلمة
  ربط آية بموضوع
- scoring محلي بسيط.
- session قصيرة وسريعة.
- نتيجة نهائية مع correct/incorrect review.

### خارج النطاق

- مسابقات جماعية.
- leaderboards.
- live PvP.
- توليد أسئلة حر بالذكاء الاصطناعي من أول نسخة.

### التبعيات

- question model.
- content source strategy.
- local persistence for scores/history if needed.

### الشاشات والتدفقات

- `Quiz Hub` بأنواع الاختبارات.
- `Quiz Session` بسؤال واحد في كل خطوة.
- `Quiz Result` مع ملخص وتصحيحات.

### خطوات التنفيذ المقترحة

1. تعريف question/answer/result models.
2. اختيار 2 إلى 3 quiz types فقط لأول إصدار.
3. بناء deterministic generators أو authored bank بسيط.
4. ربط النتائج بنقطة rewards خفيفة إن لزم.
5. إضافة history لاحقًا فقط إذا ظهر احتياج واضح.

### معايير القبول

- المستخدم يستطيع بدء quiz قصيرة وإنهاءها ورؤية النتيجة.
- الأسئلة تعمل محليًا دون اعتماد إجباري على الشبكة.
- كل quiz type له rules واضحة ويمكن اختباره مستقلًا.
- الأخطاء في توليد سؤال أو تحميل محتوى لا تكسر التجربة كلها.

### الاختبارات

- unit tests لتوليد الأسئلة والتحقق من الإجابات.
- widget tests لتدفق session/result.
- manual verification على العربية والـ layout للإجابات.

### المخاطر والملاحظات

- الجودة التعليمية للأسئلة أهم من عددها.
- لذلك البداية المحدودة أفضل من "20 نوع سؤال" بجودة ضعيفة.

## 7.7 `3.7` وضع الامتحان (Exam Mode)

### الهدف

تقديم وضع أكثر جدية من quizzes لقياس الحفظ والاسترجاع، مع تقرير أخطاء وتوصيات
للمراجعة.

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود حاليًا:

- memorization foundations.
- khatma and review flows.
- reader rendering and verse navigation.
- Quran text access.

غير الموجود:

- exam templates.
- blank/fill/hide interactions.
- exam scoring/report layer.

### نطاق المرحلة الثالثة

الـ scope الموصى به:

- exam على آيات أو ranges محددة.
- أنماط محدودة مثل:
  إخفاء كلمات وإكمالها
  إخفاء آية وطلب الاستدعاء النصي
  reveal/hint stepwise
- تقرير نتيجة مع أخطاء وتوصيات مراجعة.

### خارج النطاق

- voice-based grading.
- teacher dashboard أو مشاركة النتائج خارجيًا.
- handwriting recognition.

### التبعيات

- Arabic text segmentation.
- range selection من memorization context.
- result persistence خفيفة إذا لزم.

### الشاشات والتدفقات

- entry من memorization/review context.
- select scope -> exam session -> result summary -> open review target.

### خطوات التنفيذ المقترحة

1. تعريف exam modes قليلة وواضحة.
2. إعادة استخدام reader text data بدل duplication.
3. بناء result report مع links للمراجعة.
4. توصيله لاحقًا بـ spaced review أو memorization insights عند الحاجة.

### معايير القبول

- يمكن للمستخدم بدء exam على نطاق محدد وإنهاؤه.
- التقرير النهائي يوضح الأخطاء أو النقاط الضعيفة بوضوح.
- النتائج تقود المستخدم إلى المراجعة بدل أن تكون dead end.
- إدخال النص أو الاختيار لا يفسد التجربة العربية.

### الاختبارات

- unit tests على masking/reveal rules.
- widget tests لتدفق الامتحان والتقرير.
- manual verification لحالات Arabic input والترقيم.

### المخاطر والملاحظات

- التحدي الأكبر هنا UX للإدخال العربي، لا توليد الشاشات.
- من الأفضل البدء بأنماط answer أبسط قبل إدخال كتابة حرة طويلة.

## 7.8 `3.8` ممارسة التلاوة (Recitation Practice)

### الهدف

تمكين المستخدم من تسجيل تلاوته ومقارنتها والاستفادة من feedback تدريجي، مع
فصل واضح بين "التسجيل والمقارنة" و"التقييم الآلي المتقدم".

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود الآن:

- audio playback وreciters.
- reader navigation.
- offline audio assets لبعض المسارات.

غير الموجود:

- mic permission flow.
- recording package/service.
- waveform أو timeline UI.
- recitation evaluation layer.

### نطاق المرحلة الثالثة

هذا البند يجب أن يبدأ كsubproject، والـ first slice الموصى به هو:

- تسجيل صوت المستخدم.
- إعادة التشغيل والاستماع الذاتي.
- مقارنة بسيطة مع تلاوة القارئ.
- marker لحفظ محاولة أو إعادة المحاولة.

أما التقييم الآلي للتجويد أو اكتشاف الأخطاء:

- يكون fast-follow لاحق داخل نفس البند، وليس جزءًا إلزاميًا من أول إصدار.

### خارج النطاق

- حكم آلي موثوق على التجويد من أول release.
- تصنيف شامل للأخطاء الصوتية الدقيقة.
- اجتماعات/تقييمات مباشرة بين مستخدمين.

### التبعيات

- recorder service boundary.
- microphone permissions.
- storage strategy للملفات الصوتية.
- sync مع reader/audio timing إذا أردنا comparison أدق.

### الشاشات والتدفقات

- من الآية أو المقطع -> `Start Recitation Practice`.
- record -> playback -> compare -> save/delete attempt.

### خطوات التنفيذ المقترحة

1. اختيار package وتغليفها داخل app-owned recording service.
2. بناء permission UX واضح ومحترم.
3. تنفيذ local recording + playback فقط أولًا.
4. إضافة comparison flow مبسط مع reciter audio.
5. تأجيل automated evaluation إلى slice لاحق بعد spike واضح.

### معايير القبول

- المستخدم يستطيع التسجيل والاستماع لتسجيله داخل التطبيق.
- الصلاحيات مفسرة بوضوح ولها fallback محترم عند الرفض.
- الملفات الصوتية تدار محليًا دون فوضى أو تسريب غير لازم.
- المقارنة الأساسية تعمل بدون ادعاء تقييم علمي غير موجود.

### الاختبارات

- provider/service tests للـ recording lifecycle.
- manual verification فعلي على أجهزة حقيقية للصلاحيات والتسجيل.
- regression tests لحفظ/حذف المحاولات metadata إن وجدت.

### المخاطر والملاحظات

- هذا البند عالي المخاطر على Android/iOS بسبب permissions والملفات.
- لا يجب ربطه مبكرًا بأي claim عن "تصحيح تجويد آلي" قبل إثبات تقني واضح.

## 7.9 `3.9` الخرائط القرآنية (Quran Maps)

### الهدف

ربط الأماكن المذكورة في القرآن بتجربة استكشاف بصرية ومعرفية تجعل النص مرتبطًا
بالجغرافيا والتاريخ بشكل أوضح.

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود حاليًا:

- location services داخل `more`.
- qibla/location foundations.
- topic/detail navigation patterns.
- reader linking إلى السور والآيات.

غير الموجود:

- map provider.
- place dataset مرتبط بالآيات.
- map presentation layer خاصة بهذا المحتوى.

### نطاق المرحلة الثالثة

الـ scope الموصى به لهذا البند يجب أن يبدأ هكذا:

- dataset app-owned للأماكن المذكورة في القرآن.
- place explorer مع list/filter/details.
- ربط المكان بالآيات ذات الصلة.
- map surface بسيطة أو provider-backed card بعد حسم المزود.

إذا لم يُحسم map provider سريعًا:

- يبدأ البند كـ `Quran Places Explorer` أولًا.
- ثم تضاف الخريطة التفاعلية لاحقًا داخل نفس المسار.

### خارج النطاق

- خرائط ثلاثية الأبعاد.
- GIS features معقدة.
- crowded travel/tourism functionality.

### التبعيات

- dataset strategy.
- map provider decision.
- content linking بين المكان والآيات/القصص.

### الشاشات والتدفقات

- places list -> place details -> related ayahs -> open reader.
- optional map view -> select place -> details.

### خطوات التنفيذ المقترحة

1. بناء dataset موحدة للأماكن.
2. تنفيذ list/details أولًا قبل التورط في خريطة كاملة.
3. إضافة verse linking واضح وموثوق.
4. إدخال map provider بعد ثبات نموذج البيانات.

### معايير القبول

- يستطيع المستخدم استعراض الأماكن والانتقال إلى الآيات المرتبطة بها.
- البيانات منظمة بشكل موحد وقابلة للتوسع.
- غياب الخريطة الكاملة لا يمنع إطلاق أول slice مفيد.

### الاختبارات

- unit tests على parsing/linking للدataset.
- widget tests لشاشات list/details.
- manual verification لروابط الانتقال إلى القارئ.

### المخاطر والملاحظات

- هذا البند dataset-heavy أكثر من كونه UI-heavy.
- إذا بدأنا بالخريطة قبل المحتوى، سنبني واجهة بلا قيمة معرفية كافية.

## 7.10 `3.10` القصص القرآنية (Quran Stories)

### الهدف

تحويل القصص القرآنية إلى مسار محتوى منظم، مرتبط بالآيات، وسهل القراءة
للكبار، ويمكن لاحقًا توجيهه لأسطح مختلفة مثل الأطفال أو التعليم.

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود حاليًا:

- topic browser.
- tafsir foundations.
- reader linking.
- share/presentation patterns.

غير الموجود:

- story content model.
- authored story pipeline.
- story screens/datasets/assets.

### نطاق المرحلة الثالثة

الـ scope الموصى به:

- catalog للقصص القرآنية.
- story details منظمة على شكل sections.
- روابط مباشرة إلى الآيات المرتبطة بكل قصة.
- supporting illustrations/assets اختيارية إذا توفرت، لكن ليست شرطًا لأول slice.

### خارج النطاق

- نسخة أطفال كاملة gamified.
- فيديوهات أو motion story engine.
- crowdsourced story content.

### التبعيات

- editorial/content strategy.
- verse-linking model.
- optional asset pipeline للصور.

### الشاشات والتدفقات

- stories index -> story detail -> related verses -> open reader/tafsir.

### خطوات التنفيذ المقترحة

1. تعريف story/domain model واضح.
2. تجهيز authored content محلي أو قابل للتحديث لاحقًا.
3. بناء catalog + detail surfaces.
4. ربط كل section بآيات واضحة يمكن فتحها مباشرة.

### معايير القبول

- يستطيع المستخدم تصفح القصص وقراءة القصة وفتح آياتها المرتبطة.
- القصة ليست مجرد نص واحد طويل غير منظم.
- links إلى القارئ تعمل بسلاسة من داخل صفحات القصص.

### الاختبارات

- parsing tests لبيانات القصص.
- widget tests للفهرس والتفاصيل.
- manual verification للروابط والـ layout العربي الطويل.

### المخاطر والملاحظات

- هذا البند محتواه أهم من الشاشات نفسها.
- quality editorial ضعيفة هنا ستؤذي الميزة أكثر من غياب animation أو images.

## 7.11 `3.11` بوصلة القبلة المحسّنة

### الهدف

تطوير تجربة القبلة من بوصلة جيدة وظيفيًا إلى تجربة أوضح بصريًا وأكثر ثقة،
مع فصل التحسينات الواقعية عن طموح 3D/AR.

### الوضع الحالي وما يمكن إعادة استخدامه

الموجود حاليًا:

- qibla compass screen.
- bearing/location services.
- heading snapshots وسياسات qibla الحالية.

غير الموجود:

- 3D visualization layer.
- AR camera flow.
- map line to Kaaba presentation.

### نطاق المرحلة الثالثة

الـ scope الموصى به لأول slice:

- تحسين visual clarity ومعايرة الاتجاه.
- حالات أوضح لـ unavailable/calibration.
- animated guidance أفضل.
- optional map line/basic map context إذا توفر provider مناسب.

أما `3D + AR`:

- تعامل كfast-follow أو subproject داخل نفس البند.
- لا تُجعل شرطًا لأول إصدار.

### خارج النطاق

- إلزام إطلاق AR من أول نسخة.
- complex 3D engine.
- camera-heavy experience بدون privacy/performance spike.

### التبعيات

- qibla foundations الحالية.
- optional map/AR provider decisions.
- sensor behavior verification على أجهزة حقيقية.

### الشاشات والتدفقات

- qibla screen الحالية مع تحسينات presentation.
- optional secondary AR/map entry إذا نضجت البنية.

### خطوات التنفيذ المقترحة

1. تحسين surface الحالية أولًا.
2. تقوية حالات calibration/unavailable/retry.
3. اختبار animated guidance على أجهزة حقيقية.
4. فتح spike منفصل لـ AR قبل أي commitment.

### معايير القبول

- تجربة القبلة الأساسية تصبح أوضح وأكثر ثباتًا بصريًا.
- رسائل المعايرة والفشل تصبح مفهومة ومباشرة.
- أي تجربة إضافية مثل AR تكون اختيارية وغير معيقة للمسار الأساسي.

### الاختبارات

- widget tests للحالات المختلفة.
- manual verification على أجهزة حقيقية لاتجاهات متعددة.
- device testing خاص بالمستشعرات قبل ادعاء الجودة.

### المخاطر والملاحظات

- مشكلة هذا البند ليست نقص UI فقط؛ بل حساسية sensor accuracy عبر الأجهزة.
- لذلك AR يجب ألا يسبق تحسين المسار الأساسي.

## 7.12 `3.12` مواقيت الصلاة المحسّنة

### الهدف

تطوير مسار الصلاة من "مواقيت + تتبع أساسي" إلى تجربة أوضح في التخطيط
اليومي/الأسبوعي والالتزام.

### الوضع الحالي وما يمكن إعادة استخدامه

هذا البند مميز لأن جزءًا منه موجود فعلًا الآن:

- prayer times details screen.
- prayer calendar widget.
- month/hijri cache.
- local prayer tracking.
- notifications foundations.

إذًا هذا ليس net-new بالكامل، بل enhancement قوي فوق الموجود.

### نطاق المرحلة الثالثة

الـ scope الموصى به:

- تحسين التقويم الأسبوعي/الشهري وتجربته.
- pre-adhan reminder presets مثل `15 min` و`5 min`.
- daily adherence summary أو report بسيط.
- وضوح أعلى في حالة اليوم الحالي والصلاة التالية.
- ربط أذكى بين tracking وnotifications والcalendar.

### خارج النطاق

- backend sync.
- social prayer accountability.
- provider switching متعدد ومعقد في أول slice.

### التبعيات

- `more_providers` وبيانات الصلاة الحالية.
- notifications scheduling policies.
- local tracking consistency.

### الشاشات والتدفقات

- home prayer hero -> prayer details -> calendar/tracking/reminders.
- settings/reminder adjustments -> reflected snapshot داخل نفس المسار.

### خطوات التنفيذ المقترحة

1. مراجعة ما شُحن بالفعل لتجنب duplication.
2. تحديد gap الحقيقي بين الموجود ووصف roadmap.
3. تحسين calendar + reminders presets + adherence summary.
4. التأكد أن التتبع والتنبيهات يعكسان بعضهما بشكل مفهوم.

### معايير القبول

- التحسينات ترفع قيمة المسار الحالي بدل إنشاء مسار موازٍ.
- reminders presets تعمل بوضوح ويمكن تعديلها بسهولة.
- calendar/tracking/report surfaces تقدم صورة أوضح من الحالة الحالية.
- لا يحدث تضارب بين بيانات today snapshot وبيانات التتبع والتقويم.

### الاختبارات

- provider tests للتتبع والتنبيهات والاشتقاق.
- widget tests للcalendar والحالات اليومية.
- manual verification للتنبيهات الزمنية والحالات الانتقالية بين الأيام.

### المخاطر والملاحظات

- أخطر شيء هنا هو إعادة بناء شيء موجود جزئيًا بدل تحسينه.
- لذا يجب أن يبدأ البند بمراجعة gap دقيقة بين ما هو shipped وما هو مطلوب.

---

## 8. ترتيب الـ specs المقترحة بعد هذا المرجع

بعد اعتماد هذا المرجع، هذا هو ترتيب الـ specs المقترح:

1. `night-reader-enhanced`
2. `tadabbur-mode`
3. `analytics-dashboard`
4. `prayer-times-plus`
5. `interactive-tafsir-advanced`
6. `quizzes`
7. `exam-mode`
8. `quran-stories`
9. `quran-maps`
10. `ai-features-foundation`
11. `recitation-practice`
12. `qibla-3d-ar`

---

## 9. ما الذي نبدأ به أولًا

### الخيار الموصى به

أول slice موصى به في phase 3 هو:

- `3.2` قارئ ليلي محسّن

### لماذا؟

- أعلى reuse.
- أقل مخاطرة.
- قيمة يومية واضحة جدًا.
- يختبر discipline المرحلة الثالثة بدون إدخال vendor complexity.

### ثاني slice بعدها مباشرة

- `3.3` وضع التدبر المتقدم

لأنه يبني فوق:

- reader
- notes
- fullscreen
- verse navigation

### ثالث slice

- `3.5` التقارير والإحصائيات

ثم بعده:

- `3.12` مواقيت الصلاة المحسّنة

لأن هذين البندين يعتمدان على data موجودة فعلًا، ويعطيان retention value
واضحة.

---

## 10. Definition of Done للمرحلة الثالثة

لكل بند phase 3 لاحقًا، لا نعتبره جاهزًا إلا إذا تحقق الآتي:

- له spec / plan / tasks مستقلة.
- تم تحديد reusable foundations بوضوح.
- تم تحديد ما هو خارج النطاق.
- تم توثيق dependencies والـ risks.
- أي نصوص user-facing تمر عبر `AppLocalizations`.
- تم تنفيذ verification مناسب لنوع الميزة.
- إذا كان البند يعتمد على AI أو recording أو AR أو maps provider:
  فلا توجد ادعاءات نجاح بدون verification فعلي على البيئة المناسبة.

---

## 11. القرار التنفيذي النهائي

المرحلة الثالثة لا تُنفذ كباك لوج واحد.

القرار الصحيح هو:

- البدء بـ reader-centric improvements أولًا.
- ثم reflection + analytics + prayer enhancement.
- ثم نقل التطبيق إلى learning/assessment surfaces.
- ثم الدخول في content-heavy features.
- وتأجيل provider-heavy bets إلى آخر الخطة أو إلى subprojects مستقلة.

وبشكل أوضح:

- `3.2`, `3.3`, `3.5`, `3.12` هي أفضل نقطة دخول.
- `3.1`, `3.6`, `3.7` تأتي بعدها عندما يثبت المسار الأول.
- `3.10`, `3.9` تُنفذ بعد وضوح content strategy.
- `3.4`, `3.8`, `3.11` لا تبدأ قبل حسم decisions التقنية المرتبطة بها.

---

## 12. الخطوات المختصرة بالترتيب

1. تأكيد أن أي بقايا من phase 2 موثقة كمؤجلة أو مكتملة، ولا توجد منطقة رمادية.
2. بدء spec أول بند: `3.2 night-reader-enhanced`.
3. بعده مباشرة: `3.3 tadabbur-mode`.
4. ثم: `3.5 analytics-dashboard`.
5. ثم: `3.12 prayer-times-plus`.
6. بعد تثبيت wave الأولى: `3.1 interactive-tafsir-advanced`.
7. ثم: `3.6 quizzes`.
8. ثم: `3.7 exam-mode`.
9. بعد وضوح content pipeline: `3.10 quran-stories`.
10. ثم: `3.9 quran-maps`.
11. تأجيل `3.4 ai-features-foundation` إلى subproject متأخر بحدود صارمة.
12. تأجيل `3.8 recitation-practice` إلى subproject recording-first.
13. تأجيل `3.11 qibla-3d-ar` إلى ما بعد تحسين مسار القبلة الحالي وحسم spike الـ AR.
