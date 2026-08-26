import 'package:intl/intl.dart';

class FormatHelper {
  /// دالة لتحويل الأرقام إلى صيغة مقروءة مع فواصل الآلاف
  static String formatNumber(double number) {
    // التنسيق '#,##0.##' يضع فاصلة كل 3 أرقام، ويترك رقمين عشريين فقط إذا لزم الأمر
    // استخدمنا 'en_US' لضمان أن الفاصلة للآلاف والنقطة للكسور (وهو الـ Standard المالي)
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return formatter.format(number);
  }
}