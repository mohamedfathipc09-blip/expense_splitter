import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔹 1. إضافة مكتبة الترجمة

import 'data/models/expense_model.dart';
import 'data/models/archive_model.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/screens/splash_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await EasyLocalization.ensureInitialized(); // 🔹 2. تهيئة مكتبة الترجمة قبل التشغيل
  
  await initializeDateFormatting('ar', null);

  await Hive.initFlutter();
  
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(ArchiveModelAdapter());

  await Hive.openBox<ExpenseModel>('expenses'); 
  await Hive.openBox<String>('persons'); 
  await Hive.openBox('settingsBox');
  await Hive.openBox<ArchiveModel>('archiveBox'); 

  // 🔹 3. تغليف التطبيق بمحرك الترجمة
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations', // مسار المجلد الذي أنشأناه
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'), // اللغة الافتراضية
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'قسمة المصاريف',
            debugShowCheckedModeBanner: false,
            
            // 🔹 4. ربط إعدادات اللغة بالتطبيق (هذا ما سيقلب الاتجاهات RTL/LTR)
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale, 

            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.indigo,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                elevation: 0,
              )
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.indigo,
            ),
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            
            home: const SplashScreen(), 
          );
        },
      ),
    );
  }
}