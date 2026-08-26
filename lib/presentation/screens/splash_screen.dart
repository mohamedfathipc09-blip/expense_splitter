import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart'; // 🔹 استدعاء Hive
import 'dart:async';
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
    
    // 🔹 مؤقت زمني لمدة 2.5 ثانية (يكفي لعرض الأنيميشن)
    Timer(const Duration(milliseconds: 2500), () {
      // فحص هل هذه هي المرة الأولى لفتح التطبيق؟
      var settingsBox = Hive.box('settingsBox');
      bool isFirstTime = settingsBox.get('isFirstTime', defaultValue: true);

      // تحديد الشاشة التالية بناءً على الفحص
      Widget nextScreen = isFirstTime ? const LanguageSelectionScreen() : const QesmaDashboardScreen();

      if (mounted) {
        // 🔹 الانتقال بتأثير سينمائي ناعم (Fade)
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // 🔹 خلفية متدرجة عصرية متناسقة 
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // 🔹 حركة انسيابية (Scale Animation) للوجو الخاص بك
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.asset(
                    'assets/images/logo.jpg', // 👈 اللوجو الخاص بك
                    width: 220, // صغرت الحجم قليلاً ليتناسق مع النصوص أسفله
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 🔹 حركة ظهور تدريجي (Fade-in) للنصوص
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeIn,
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: Column(
                children: [
                  Text(
                    'قسمة المصاريف'.tr(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Qesma Expenses',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 3.0,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // 🔹 رقم الإصدار في الأسفل كبديل احترافي لعلامة التحميل (Loading Indicator)
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Text(
                'V 1.0.0',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}