import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('سياسة الخصوصية | Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 الكارت التعريفي المزدوج
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: Colors.teal, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نحن نأخذ خصوصيتك على محمل الجد، ونلتزم بحماية بياناتك.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, height: 1.5),
                        ),
                        SizedBox(height: 8),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            'We take your privacy seriously and are committed to protecting your data.',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // 🔹 الأقسام المزدوجة
            _buildBilingualSection(
              icon: Icons.data_usage,
              titleAr: 'جمع البيانات واستخدامها',
              titleEn: 'Data Collection and Use',
              textAr: 'تطبيق "قسمة المصاريف" يعمل بشكل كامل دون الحاجة للاتصال بالإنترنت. جميع البيانات التي تقوم بإدخالها يتم حفظها وتشفيرها محلياً على مساحة التخزين الخاصة بهاتفك فقط. نحن لا نجمع، ولا نخزن، ولا نرسل أي بيانات إلى خوادم خارجية.',
              textEn: 'The "Qesma Expenses" app works entirely offline. All data you enter is stored and encrypted locally on your device\'s storage only. We do not collect, store, or send any data to external servers.',
            ),
            const SizedBox(height: 24),

            _buildBilingualSection(
              icon: Icons.backup_outlined,
              titleAr: 'النسخ الاحتياطي',
              titleEn: 'Backup',
              textAr: 'إذا قمت باستخدام ميزة "النسخ الاحتياطي"، يتم إنشاء ملف محلي على جهازك. أنت وحدك المسؤول عن حفظ هذا الملف أو مشاركته.',
              textEn: 'If you use the "Backup" feature, a local file is created on your device. You are solely responsible for saving or sharing this file.',
            ),
            const SizedBox(height: 24),

            _buildBilingualSection(
              icon: Icons.lock_outline,
              titleAr: 'مشاركة الجهات الخارجية',
              titleEn: 'Third-Party Sharing',
              textAr: 'بما أننا لا نجمع بياناتك من الأساس، فإننا لا نشارك ولا نبيع أي معلومات لأي جهة خارجية.',
              textEn: 'Since we do not collect your data in the first place, we do not share or sell any information to third parties.',
            ),
            const SizedBox(height: 24),

            _buildBilingualSection(
              icon: Icons.check_circle_outline,
              titleAr: 'موافقتك',
              titleEn: 'Your Consent',
              textAr: 'باستخدامك للتطبيق، فإنك توافق على سياسة الخصوصية هذه.',
              textEn: 'By using the app, you consent to this privacy policy.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 🔹 دالة لبناء الأقسام باللغتين بتنسيق سليم
  Widget _buildBilingualSection({
    required IconData icon,
    required String titleAr,
    required String titleEn,
    required String textAr,
    required String textEn,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueGrey, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$titleAr / $titleEn',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // النص العربي (محاذاة لليمين)
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            textAr,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 8),
        // النص الإنجليزي (محاذاة لليسار)
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            textEn,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}