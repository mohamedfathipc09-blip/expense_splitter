import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_splitter/main.dart'; 

void main() {
  // إعداد البيئة الوهمية لقاعدة البيانات قبل الاختبار
  setUpAll(() async {
    await Hive.initFlutter();
  });

  testWidgets('App should load properly', (WidgetTester tester) async {
    // بناء التطبيق الخاص بنا باستخدام الكلاس الحقيقي MyApp
    await tester.pumpWidget(const MyApp());

    // التحقق من أن التطبيق يعمل وتظهر كلمة قسمة المصاريف
    expect(find.text('قسمة المصاريف'), findsWidgets);
  });
}