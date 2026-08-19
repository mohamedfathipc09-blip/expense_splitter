import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أرشيف المخالصات'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.archives.isEmpty) {
            return const Center(
              child: Text('لا يوجد أرشيف للمخالصات السابقة.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.archives.length,
            itemBuilder: (context, index) {
              final archive = provider.archives[index] as Map<dynamic, dynamic>;
              
              final String title = archive['title'] ?? 'دورة سابقة';
              final DateTime date = archive['date'] != null ? DateTime.parse(archive['date']) : DateTime.now();
              final double totalAmount = archive['totalAmount'] ?? 0.0;
              final List<dynamic> expensesList = archive['expensesList'] ?? [];
              
              // 🔹 جلب ملخص التسويات (الديون)
              final List<dynamic> settlementSummary = archive['settlementSummary'] ?? [];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ExpansionTile(
                  shape: const Border(), // لمنع الخطوط المزعجة عند الفتح
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.archive, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(
                    '${DateFormat('yyyy-MM-dd').format(date)} • إجمالي: ${totalAmount.toStringAsFixed(2)} ${provider.currency}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  children: [
                    const Divider(),
                    
                    // ==============================
                    // 1. قسم التسويات النهائية
                    // ==============================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('💰 التسويات (من يدفع لمن):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                      ),
                    ),
                    if (settlementSummary.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('الكل خالص، لا توجد ديون مسجلة.', style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...settlementSummary.map((line) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        title: Text(line.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      )),

                    const Divider(),

                    // ==============================
                    // 2. قسم تفاصيل العمليات
                    // ==============================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('🧾 تفاصيل المصروفات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
                      ),
                    ),
                    
                    if (expensesList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('لا توجد عمليات مسجلة في هذه الدورة.', style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...expensesList.map((expenseItem) {
                        final exp = expenseItem as Map<dynamic, dynamic>;
                        final expDate = exp['date'] != null ? DateTime.parse(exp['date']) : DateTime.now();
                        
                        return ListTile(
                          dense: true,
                          leading: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.black12,
                            child: Icon(Icons.receipt_long, size: 18, color: Colors.black54),
                          ),
                          title: Text(exp['title'] ?? 'بدون عنوان', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('الدفع: ${exp['payer']} • ${DateFormat('yyyy-MM-dd').format(expDate)}'),
                          trailing: Text(
                            '${exp['amount']} ${provider.currency}', 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)
                          ),
                        );
                      }),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}