import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../providers/expense_provider.dart';
import '../../core/helpers/format_helper.dart'; // 🔹 استدعاء ملف تنسيق الأرقام

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

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
          'أرشيف المخالصات'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.archives.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.archive_outlined, size: 60, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد أرشيف للمخالصات السابقة.'.tr(), 
                    style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: provider.archives.length,
            // 🔹 عكس الترتيب ليظهر الأحدث في الأعلى
            itemBuilder: (context, reversedIndex) {
              final index = provider.archives.length - 1 - reversedIndex;
              final archive = provider.archives[index] as Map<dynamic, dynamic>;
              
              final String title = archive['title'] ?? 'دورة سابقة'.tr();
              final DateTime date = archive['date'] != null ? DateTime.parse(archive['date']) : DateTime.now();
              final double totalAmount = (archive['totalAmount'] as num?)?.toDouble() ?? 0.0;
              final List<dynamic> expensesList = archive['expensesList'] ?? [];
              
              final List<dynamic> settlementSummary = archive['settlementSummary'] ?? [];
              final List<dynamic> settlementRawData = archive['settlementRawData'] ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.inventory_2_rounded, color: theme.colorScheme.primary),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        // 🔹 استخدام FormatHelper للإجمالي
                        '${DateFormat('yyyy-MM-dd', context.locale.languageCode).format(date)} • ${'إجمالي:'.tr()} ${FormatHelper.formatNumber(totalAmount)} ${provider.currency.tr()}',
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, height: 1),
                      ),
                      
                      // ==============================
                      // 1. قسم التسويات النهائية
                      // ==============================
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.handshake_rounded, color: Colors.teal, size: 20),
                                const SizedBox(width: 8),
                                Text('التسويات (من يدفع إلى من):'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            if (settlementRawData.isNotEmpty)
                              ...settlementRawData.map((s) => _buildModernSettlementRow(s, provider.currency.tr(), isDark))
                            else if (settlementSummary.isNotEmpty)
                              ...settlementSummary.map((line) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(line.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
                                  ],
                                ),
                              ))
                            else
                              Text('الكل خالص، لا توجد ديون مسجلة.'.tr(), style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, height: 1),
                      ),

                      // ==============================
                      // 2. قسم تفاصيل العمليات
                      // ==============================
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.receipt_long_rounded, color: Colors.blue.shade400, size: 20),
                                const SizedBox(width: 8),
                                Text('تفاصيل المصروفات:'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue.shade400)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            if (expensesList.isEmpty)
                              Text('لا توجد عمليات مسجلة في هذه الدورة.'.tr(), style: const TextStyle(color: Colors.grey))
                            else
                              ...expensesList.map((expenseItem) {
                                final exp = expenseItem as Map<dynamic, dynamic>;
                                final expDate = exp['date'] != null ? DateTime.parse(exp['date']) : DateTime.now();
                                final double expAmount = (exp['amount'] as num?)?.toDouble() ?? 0.0;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.black26 : Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.receipt_rounded, size: 16, color: Colors.grey),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(exp['title'] ?? 'بدون عنوان'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${'الدفع:'.tr()} ${exp['payer']} • ${DateFormat('yyyy-MM-dd', context.locale.languageCode).format(expDate)}',
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 🔹 استخدام FormatHelper لمبلغ العملية
                                      Text(
                                        '${FormatHelper.formatNumber(expAmount)} ${provider.currency.tr()}', 
                                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent, fontSize: 14)
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🔹 ودجت لعرض التسوية بطريقة عصرية
  Widget _buildModernSettlementRow(Map<dynamic, dynamic> s, String currency, bool isDark) {
    final double amount = (s['amount'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.teal.withValues(alpha: 0.1) : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.person_rounded, color: Colors.teal, size: 16),
              const SizedBox(width: 4),
              Text('${s['from']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            children: [
              Text('يدفع إلى'.tr(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const Icon(Icons.arrow_forward_rounded, color: Colors.teal, size: 14),
            ],
          ),
          Row(
            children: [
              Text('${s['to']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              const Icon(Icons.person_outline_rounded, color: Colors.purple, size: 16),
            ],
          ),
          // 🔹 استخدام FormatHelper للديون
          Text(
            '${FormatHelper.formatNumber(amount)} $currency', 
            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent)
          ),
        ],
      ),
    );
  }
}