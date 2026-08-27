import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../providers/expense_provider.dart';
import '../../core/helpers/format_helper.dart'; // 🔹 استدعاء ملف التنسيق الجديد

class SettlementScreen extends StatelessWidget {
  const SettlementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'تسوية الحسابات'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final settlements = provider.settlementTransactions; 

          if (settlements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.green.withValues(alpha: 0.1) : Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade400, size: 80),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    provider.expenses.isEmpty ? 'لا توجد عمليات لتسويتها'.tr() : 'جميع الحسابات تمت تسويتها! 🎉'.tr(), 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.green.shade300 : Colors.green.shade700)
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.teal.withValues(alpha: 0.1) : Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: isDark ? Colors.teal.shade300 : Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'هذه أقل عدد من التحويلات المطلوبة لتسوية جميع الحسابات بين الأفراد.'.tr(),
                        style: TextStyle(color: isDark ? Colors.teal.shade300 : Colors.teal.shade800, fontWeight: FontWeight.bold, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: settlements.length,
                  itemBuilder: (context, index) {
                    final s = settlements[index];
                    final double amount = (s['amount'] as num?)?.toDouble() ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), 
                            blurRadius: 10, 
                            offset: const Offset(0, 4)
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_rounded, color: isDark ? Colors.teal.shade400 : Colors.teal, size: 20),
                              const SizedBox(width: 6),
                              Text('${s['from']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 🔹 استخدام FormatHelper لتنسيق مبلغ التسوية
                              Text(
                                '${FormatHelper.formatNumber(amount)} ${provider.currency.tr()}', 
                                style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.red.shade400 : Colors.redAccent, fontSize: 15)
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('يدفع إلى'.tr(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, color: isDark ? Colors.teal.shade400 : Colors.teal, size: 14),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${s['to']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                              const SizedBox(width: 6),
                              Icon(Icons.person_outline_rounded, color: isDark ? Colors.purple.shade300 : Colors.purple, size: 20),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // 🔹 زر إنهاء الدورة (Modern Button)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isDark ? [Colors.teal.shade700, Colors.teal.shade900] : [Colors.teal.shade400, Colors.teal.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.teal.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        String archiveTitle = '${'دورة'.tr()} ${DateFormat('MMMM yyyy', context.locale.languageCode).format(DateTime.now())}';
                        provider.settleAndArchive(archiveTitle);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تمت التسوية والأرشفة بنجاح!'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)), 
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          )
                        );
                        Navigator.pop(context); 
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Text('إنهاء الدورة وأرشفة العمليات'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}