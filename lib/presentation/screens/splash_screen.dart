import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive/hive.dart'; // 🔹 استدعاء Hive
import 'dashboard_screen.dart';
import 'language_selection_screen.dart'; // 🔹 استدعاء شاشة اختيار اللغة الجديدة

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // مؤقت زمني لمدة 3 ثواني
    Timer(const Duration(seconds: 3), () {
      // 🔹 فحص هل هذه هي المرة الأولى لفتح التطبيق؟
      var settingsBox = Hive.box('settingsBox');
      bool isFirstTime = settingsBox.get('isFirstTime', defaultValue: true);

      if (isFirstTime) {
        // إذا كانت أول مرة -> اذهب لشاشة اختيار اللغة
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
        );
      } else {
        // إذا لم تكن أول مرة -> اذهب للشاشة الرئيسية مباشرة
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const QesmaDashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(98, 162, 178, 240), // لون خلفية الشاشة
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // عرض اللوجو
            ClipRRect(
              borderRadius: BorderRadius.circular(35), 
              child: Image.asset(
                'assets/images/logo.jpg',
                width: 300, 
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
            // مؤشر تحميل دائري
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0052D4)),
            ),
          ],
        ),
      ),
    );
  }
}