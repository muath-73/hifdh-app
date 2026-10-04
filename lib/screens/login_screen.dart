import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _termsAgreed = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _requireTerms() {
    if (!_termsAgreed) {
      _showMsg('الرجاء الموافقة على شروط الخدمة وسياسة الخصوصية أولاً');
      return false;
    }
    return true;
  }

  Future<void> _sendOtp() async {
    if (!_requireTerms()) return;
    final raw = _phoneController.text.trim();
    if (raw.isEmpty) {
      _showMsg('الرجاء إدخال رقم الجوال');
      return;
    }
    final phone = raw.startsWith('0') ? '+966${raw.substring(1)}' : raw;

    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithOtp(phone: phone);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpScreen(phone: phone)),
      );
    } catch (e) {
      _showMsg('تعذّر إرسال الرمز: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithApple() async {
    if (!_requireTerms()) return;
    setState(() => _loading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final idToken = credential.identityToken;
      if (idToken == null) throw Exception('لم يتم استلام رمز الدخول من Apple');

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      _showMsg('تعذّر الدخول عبر Apple: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'حِفْظ',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brand,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'مرحباً بك في حفظ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'نظم مواعيدك وجدولك بكل دقة، واحفظ فواتيرك وضماناتك بطمأنينة تامة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.slateLight),
              ),
              const SizedBox(height: 32),
              const Text('رقم الجوال', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '05xxxxxxxx'),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _loading ? null : _sendOtp,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('إرسال رمز التحقق'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _termsAgreed = !_termsAgreed),
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _termsAgreed ? AppColors.brand : Colors.white,
                          border: Border.all(
                            color: _termsAgreed ? AppColors.brand : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: _termsAgreed
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 11, color: AppColors.slateLight, height: 1.8),
                          children: [
                            const TextSpan(text: 'بالمتابعة، أنت توافق على '),
                            TextSpan(
                              text: 'شروط الخدمة',
                              style: const TextStyle(
                                color: AppColors.brandDark,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' و'),
                            const TextSpan(
                              text: 'سياسة الخصوصية والأمان',
                              style: TextStyle(
                                color: AppColors.brandDark,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('أو', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loading ? null : _loginWithApple,
                icon: const Icon(CupertinoIcons.app_badge, color: Colors.white),
                label: const Text('الدخول باستخدام Apple'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
