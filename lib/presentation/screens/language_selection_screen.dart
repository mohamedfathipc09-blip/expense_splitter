import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// 🔹 أضفنا كلمة hide TextDirection هنا لحل التعارض
import 'package:easy_localization/easy_localization.dart' hide TextDirection; 
import 'dashboard_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  void _selectLanguage(BuildContext context, String langCode) async {
    // 1. تغيير لغة التطبيق بناءً على اختيار المستخدم
    await context.setLocale(Locale(langCode));

    // 2. حفظ قيمة في Hive تخبر التطبيق أن المرة الأولى قد انتهت
    var settingsBox = Hive.box('settingsBox');
    await settingsBox.put('isFirstTime', false);

    // 3. الانتقال فوراً إلى الشاشة الرئيسية
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const QesmaDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // نجعل الشاشة دائماً LTR هنا لكي يظهر النص الإنجليزي والعربي بشكل متناسق قبل اختيار اللغة
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.language, size: 80, color: Colors.indigo),
                const SizedBox(height: 24),
                const Text(
                  'اختر لغة التطبيق\nChoose App Language',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo, height: 1.5),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _selectLanguage(context, 'ar'),
                    child: const Text('العربية', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _selectLanguage(context, 'en'),
                    child: const Text('English', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}