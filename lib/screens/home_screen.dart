import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('حِفْظ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.brand, size: 48),
            const SizedBox(height: 12),
            Text('تم تسجيل الدخول بنجاح ✅\n${user?.phone ?? user?.email ?? ''}',
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
              'من هنا نكمل: ربط المواعيد والضمانات بقاعدة البيانات الحقيقية',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
