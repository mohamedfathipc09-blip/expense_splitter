import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 

import 'data/models/expense_model.dart';
import 'data/models/archive_model.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/screens/splash_screen.dart'; 
import 'presentation/screens/language_selection_screen.dart'; // 🔹 1. استدعاء شاشة اختيار اللغة

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await EasyLocalization.ensureInitialized();
  
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);

  await Hive.initFlutter();
  
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(ArchiveModelAdapter());

  await Hive.openBox<ExpenseModel>('expenses'); 
  await Hive.openBox<String>('persons'); 
  await Hive.openBox('settingsBox');
  await Hive.openBox<ArchiveModel>('archiveBox'); 

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations', 
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'), 
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 2. التحقق مما إذا كانت هذه أول مرة يفتح فيها المستخدم التطبيق
    final settingsBox = Hive.box('settingsBox');
    final bool isFirstTime = settingsBox.get('isFirstTime', defaultValue: true);

    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            onGenerateTitle: (context) => 'قسمة المصاريف'.tr(),
            debugShowCheckedModeBanner: false,
            
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
            
            // 🔹 3. توجيه ذكي: لو أول مرة افتح شاشة اللغة، لو مش أول مرة افتح الـ Splash
            home: isFirstTime ? const LanguageSelectionScreen() : const SplashScreen(), 
          );
        },
      ),
    );
  }
}