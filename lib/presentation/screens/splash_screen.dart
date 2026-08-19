import 'package:flutter/material.dart';
import 'dart:async';
import 'dashboard_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // مؤقت زمني لمدة 3 ثواني ثم الانتقال للشاشة الرئيسية
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        // تم تصحيح اسم الكلاس هنا ليصبح QesmaDashboardScreen
        MaterialPageRoute(builder: (context) => const QesmaDashboardScreen()),
      );
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
            // مؤشر تحميل دائري أنيق بنفس لون التطبيق
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0052D4)),
            ),
          ],
        ),
      ),
    );
  }
}