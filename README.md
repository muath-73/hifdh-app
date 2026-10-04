# حِفظ - مشروع Flutter الحقيقي

## وش جاهز الحين
- شاشة دخول حقيقية (رقم جوال → OTP فعلي عبر Supabase) + زر Apple Sign-In حقيقي
- نفس آلية موافقة شروط الخدمة (checkbox يمنع الاستمرار) من النموذج التجريبي
- إعداد بناء تلقائي (Codemagic) يبني تطبيق iOS ويرفعه لـ TestFlight بدون ما تحتاج Mac

## اللي لازم تعبيه قبل ما يشتغل

### 1. بيانات Supabase
افتح `lib/supabase_config.dart` وحط فيه:
- رابط مشروعك (Project URL)
- مفتاح anon public

تلقاهم في: لوحة Supabase → Project Settings → API

### 2. تفعيل الدخول برقم الجوال في Supabase
من لوحة Supabase: Authentication → Providers → Phone → فعّلها، واربط مزوّد SMS
(Supabase يدعم Twilio وغيره — تحتاج تفتح حساب Twilio مجاني للتجربة وتربطه هناك).

### 3. تفعيل Apple Sign-In في Supabase
Authentication → Providers → Apple → فعّلها، وتحتاج بيانات من حساب Apple Developer
(Service ID + Key) — خطوة نسويها مع بعض لما توصلها.

### 4. بيانات Apple Developer لـ Codemagic
من Codemagic → Teams → Environment variables، تضيف مجموعة اسمها `app_store_credentials` فيها:
- `APP_STORE_CONNECT_KEY_IDENTIFIER`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`

تطلعهم من App Store Connect → Users and Access → Keys → تنشئ مفتاح جديد.

## خطوات الرفع على GitHub
1. روح لحسابك على GitHub واضغط New repository، سمّه `hifdh-app`.
2. ارفع كل الملفات اللي بهذا المجلد (سحب وإفلات من صفحة الريبو مباشرة).
3. روح codemagic.io وسجّل بحساب GitHub، واختر الريبو `hifdh-app`.
4. أضف المتغيرات المذكورة فوق، واضغط Start new build.

## بعدين
بعد أول نسخة تشتغل على TestFlight، نكمل نقل باقي شاشات النموذج
(المواعيد، الضمانات، الإعدادات) من HTML إلى Flutter خطوة خطوة، كل شاشة وقت لحالها.
