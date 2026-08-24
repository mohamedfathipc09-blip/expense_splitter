import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/expense_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double totalExpenses = provider.allExpenses.fold(0, (sum, item) => sum + item.amount);

    // 1. حساب مساهمات الأشخاص
    Map<String, double> personContributions = {};
    for (var expense in provider.allExpenses) {
      personContributions[expense.payer] = (personContributions[expense.payer] ?? 0) + expense.amount;
    }
    // ترتيب تنازلي للأشخاص
    var sortedPersons = personContributions.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // 2. حساب تصنيفات العمليات
    Map<String, double> categoryBreakdown = {};
    for (var expense in provider.allExpenses) {
      categoryBreakdown[expense.category] = (categoryBreakdown[expense.category] ?? 0) + expense.amount;
    }
    // ترتيب تنازلي للتصنيفات
    var sortedCategories = categoryBreakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // قائمة ألوان احترافية للرسوم البيانية
    final List<Color> chartColors = [
      Colors.blue.shade500,
      Colors.orange.shade500,
      Colors.purple.shade500,
      Colors.teal.shade500,
      Colors.red.shade500,
      Colors.green.shade500,
      Colors.indigo.shade500,
      Colors.pink.shade500,
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9), // خلفيات هادئة جداً
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('الإحصائيات والتحليلات'.tr(), style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
        centerTitle: true,
      ),
      body: totalExpenses == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('لا توجد بيانات كافية للإحصائيات'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 1. بطاقة الملخص المالي
                  _buildSummaryHeader(context, totalExpenses, provider.allExpenses.length, provider.currency),
                  const SizedBox(height: 32),

                  // 🔹 2. مؤشر مساهمة الأشخاص
                  Text('مساهمة الأشخاص'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  _buildChartSection(context, sortedPersons, totalExpenses, chartColors, provider.currency, isDark),

                  const SizedBox(height: 32),

                  // 🔹 3. مؤشر تصنيف العمليات
                  Text('تصنيف العمليات'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  _buildChartSection(context, sortedCategories, totalExpenses, chartColors, provider.currency, isDark),

                  const SizedBox(height: 100), // مسافة للتمرير المريح
                ],
              ),
            ),
    );
  }

  // ==========================================
  // مكونات الواجهة (Widgets)
  // ==========================================

  Widget _buildSummaryHeader(BuildContext context, double total, int count, String currency) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 🔹 تحديد ما إذا كانت كلمة "عملية" مفرد أم جمع (حسب لغة واجهة المستخدم)
    String transactionWord = count == 1 ? 'عملية'.tr() : 'عمليات'.tr();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('إجمالي الصرف'.tr(), style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // 🔹 إضافة الترجمة للعملة
              Text('${total.toStringAsFixed(0)} ${currency.tr()}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.receipt_long, color: Colors.blue),
                const SizedBox(height: 4),
                // 🔹 استخدام كلمة المعاملة الصحيحة المترجمة
                Text('$count $transactionWord', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, List<MapEntry<String, double>> data, double total, List<Color> colors, String currency, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          // 🔹 الرسم البياني الدائري (Donut Chart)
          SizedBox(
            height: 200,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(160, 160),
                      painter: _DonutChartPainter(
                        data: data.map((e) => e.value).toList(),
                        total: total,
                        colors: colors,
                        animationValue: value,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('الإجمالي'.tr(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text(total.toStringAsFixed(0), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // 🔹 تفاصيل النسب المئوية (Legend)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey.withValues(alpha: 0.1), height: 16),
            itemBuilder: (context, index) {
              final item = data[index];
              final color = colors[index % colors.length];
              final percentage = (item.value / total) * 100;

              return Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.key.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 🔹 إضافة الترجمة للعملة هنا أيضاً
                      Text('${item.value.toStringAsFixed(0)} ${currency.tr()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                      Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTER (لرسم الـ Donut Chart باحترافية وبدون مكتبات خارجية)
// ==========================================
class _DonutChartPainter extends CustomPainter {
  final List<double> data;
  final double total;
  final List<Color> colors;
  final double animationValue;

  _DonutChartPainter({required this.data, required this.total, required this.colors, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -pi / 2; // يبدأ الرسم من الأعلى (الساعة 12)
    const double strokeWidth = 24.0; // سمك الدائرة

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i] / total) * 2 * pi * animationValue;
      
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt; // لضمان عدم وجود فراغات

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      
      // مسافة بيضاء صغيرة جداً بين كل قسم (للشكل الاحترافي)
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}