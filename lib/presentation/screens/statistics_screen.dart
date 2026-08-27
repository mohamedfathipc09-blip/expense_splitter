import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/expense_provider.dart';
import '../../core/helpers/format_helper.dart'; // 🔹 استدعاء ملف التنسيق الجديد

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

    // قائمة ألوان احترافية وعصرية للرسوم البيانية
    final List<Color> chartColors = [
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Emerald
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF43F5E), // Rose
      const Color(0xFF3B82F6), // Blue
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9), // متناسق مع باقي التطبيق
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'الإحصائيات والتحليلات'.tr(), 
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: totalExpenses == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.pie_chart_outline_rounded, size: 60, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  Text('لا توجد بيانات كافية للإحصائيات'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 1. بطاقة الملخص المالي (Gradient Card)
                  _buildSummaryHeader(context, totalExpenses, provider.allExpenses.length, provider.currency.tr(), isDark),
                  const SizedBox(height: 32),

                  // 🔹 2. مؤشر مساهمة الأشخاص
                  Text('مساهمة الأشخاص'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _buildChartSection(context, sortedPersons, totalExpenses, chartColors, provider.currency.tr(), isDark),

                  const SizedBox(height: 32),

                  // 🔹 3. مؤشر تصنيف العمليات
                  Text('تصنيف العمليات'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _buildChartSection(context, sortedCategories, totalExpenses, chartColors, provider.currency.tr(), isDark),

                  const SizedBox(height: 100), // مسافة للتمرير المريح
                ],
              ),
            ),
    );
  }

  // ==========================================
  // مكونات الواجهة (Widgets)
  // ==========================================

  Widget _buildSummaryHeader(BuildContext context, double total, int count, String currency, bool isDark) {
    String transactionWord = count == 1 ? 'عملية'.tr() : 'عمليات'.tr();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF312E81), const Color(0xFF4338CA)] // Darker Indigo
              : [const Color(0xFF4F46E5), const Color(0xFF6366F1)], // Vibrant Indigo
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('إجمالي الصرف'.tr(), style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              // 🔹 استخدام FormatHelper للإجمالي
              Text('${FormatHelper.formatNumber(total)} $currency', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Colors.white),
                const SizedBox(height: 4),
                Text('$count $transactionWord', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, List<MapEntry<String, double>> data, double total, List<Color> colors, String currency, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Column(
        children: [
          // 🔹 الرسم البياني الدائري (Modern Donut Chart)
          SizedBox(
            height: 220,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _DonutChartPainter(
                        data: data.map((e) => e.value).toList(),
                        total: total,
                        colors: colors,
                        animationValue: value,
                        isDark: isDark,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('الإجمالي'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        // 🔹 استخدام FormatHelper للرقم داخل الدائرة
                        Text(FormatHelper.formatNumber(total), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          
          // 🔹 تفاصيل النسب المئوية (Legend) بتصميم الكروت الصغيرة
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = data[index];
              final color = colors[index % colors.length];
              final percentage = (item.value / total) * 100;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    // المربع اللوني الدائري
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color, 
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))
                        ]
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(item.key.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 🔹 استخدام FormatHelper للقيم الفرعية
                        Text('${FormatHelper.formatNumber(item.value)} $currency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                        const SizedBox(height: 2),
                        Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTER (رسم عصري بحواف دائرية StrokeCap.round)
// ==========================================
class _DonutChartPainter extends CustomPainter {
  final List<double> data;
  final double total;
  final List<Color> colors;
  final double animationValue;
  final bool isDark;

  _DonutChartPainter({
    required this.data, 
    required this.total, 
    required this.colors, 
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const double strokeWidth = 22.0; 

    // 1. رسم خلفية مسار الدائرة (Track) لشكل 3D
    final bgPaint = Paint()
      ..color = isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    // 2. رسم البيانات
    double startAngle = -pi / 2; // يبدأ من الأعلى (الساعة 12)
    
    for (int i = 0; i < data.length; i++) {
      // إذا كانت القيمة 0 لا ترسم شيئاً
      if (data[i] == 0) continue;

      // إضافة فراغ بسيط بين الأقسام
      final sweepAngle = (data[i] / total) * 2 * pi * animationValue;
      
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round; 

      // يتم إنقاص زاوية الرسم قليلاً جداً لتفادي تداخل الحواف الدائرية بشكل مزعج
      final actualSweep = sweepAngle > 0.05 ? sweepAngle - 0.05 : sweepAngle;

      canvas.drawArc(rect, startAngle, actualSweep, false, paint);
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}