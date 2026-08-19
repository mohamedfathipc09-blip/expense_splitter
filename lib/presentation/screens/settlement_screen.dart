import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../providers/expense_provider.dart';

class SettlementScreen extends StatelessWidget {
  const SettlementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسوية الحسابات'),
          centerTitle: true,
        ),
        body: Consumer<ExpenseProvider>(
          builder: (context, provider, child) {
            // استدعاء الخوارزمية الذكية الجديدة التي برمجناها
            final settlements = provider.settlementTransactions; 

            if (settlements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 16),
                    Text(
                      provider.expenses.isEmpty ? 'لا توجد عمليات لتسويتها' : 'جميع الحسابات تمت تسويتها! 🎉', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.teal.withValues(alpha: 0.1),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'هذه أقل عدد من التحويلات المطلوبة لتسوية جميع الحسابات بين الأفراد.',
                          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: settlements.length,
                    itemBuilder: (context, index) {
                      final s = settlements[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: const CircleAvatar(
                            backgroundColor: Colors.redAccent, 
                            child: Icon(Icons.arrow_upward, color: Colors.white)
                          ),
                          title: Row(
                            children: [
                              Text('${s['from']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Text(' يدفع إلى ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('${s['to']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: Text(
                            '${s['amount'].toStringAsFixed(2)} ${provider.currency}', 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.archive, color: Colors.white),
                    label: const Text('إنهاء الدورة وأرشفة العمليات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      // حل الخطأ الأخير: إرسال اسم الدورة كمتغير لدالة الأرشفة
                      String archiveTitle = 'دورة ${DateFormat('MMMM yyyy', 'ar').format(DateTime.now())}';
                      provider.settleAndArchive(archiveTitle);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تمت التسوية والأرشفة بنجاح!'), backgroundColor: Colors.green)
                      );
                      Navigator.pop(context); // العودة للرئيسية
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}