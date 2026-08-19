// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class PersonsManagementScreen extends StatelessWidget {
  const PersonsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text('إدارة الأشخاص', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Consumer<ExpenseProvider>(
          builder: (context, provider, child) {
            // ==========================================
            // الحسابات الذكية لصفحة الأشخاص
            // ==========================================
            double totalExpenses = provider.expenses.fold(0, (sum, item) => sum + item.amount);
            double sharePerPerson = provider.persons.isNotEmpty ? totalExpenses / provider.persons.length : 0;
            
            // تجميع بيانات كل شخص في قائمة واحدة لسهولة الترتيب
            List<Map<String, dynamic>> personsData = [];
            for (var p in provider.persons) {
              double paid = provider.expenses.where((e) => e.payer == p).fold(0, (sum, item) => sum + item.amount);
              double balance = paid - sharePerPerson;
              personsData.add({
                'name': p,
                'paid': paid,
                'share': sharePerPerson,
                'balance': balance,
              });
            }

            // ترتيب الأشخاص تلقائياً حسب الرصيد (الأعلى أولاً)
            personsData.sort((a, b) => b['balance'].compareTo(a['balance']));

            if (personsData.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_off_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text('لم تقم بإضافة أي أشخاص بعد', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: personsData.length,
              itemBuilder: (context, index) {
                final person = personsData[index];
                String name = person['name'];
                double paid = person['paid'];
                double share = person['share'];
                double balance = person['balance'];
                
                bool isCreditor = balance > 0.01;
                bool isSettled = balance.abs() <= 0.01;
                
                Color balanceColor = isSettled ? Colors.grey : (isCreditor ? Colors.green : Colors.red);
                String balanceStatus = isSettled ? 'خالص' : (isCreditor ? 'له' : 'عليه');

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // الجزء العلوي: الأفاتار، الاسم، وأزرار التعديل والحذف
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.teal.withValues(alpha: 0.1),
                              child: Text(
                                name.substring(0, 1).toUpperCase(), 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                              onPressed: () => _showEditPersonDialog(context, provider, name),
                              tooltip: 'تعديل الاسم',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _confirmDelete(context, provider, name, paid),
                              tooltip: 'حذف',
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(),
                        ),
                        // الجزء السفلي: الإحصائيات المالية للشخص
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem('ما دفعه', paid, provider.currency, Colors.black87),
                            _buildStatItem('نصيبه', share, provider.currency, Colors.blueGrey),
                            _buildStatItem('الرصيد ($balanceStatus)', balance, provider.currency, balanceColor),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        // زر إضافة شخص جديد
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddPersonDialog(context),
          backgroundColor: Colors.teal,
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text('إضافة شخص', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // بناء الأعمدة الصغيرة للإحصائيات داخل الكارت
  Widget _buildStatItem(String label, double amount, String currency, Color color) {
    // جعل الأرصدة السالبة تظهر كموجبة لأننا نكتب (له/عليه) بجوارها
    String amountStr = amount.abs().toStringAsFixed(2); 
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(amountStr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ==========================================
  // النوافذ المنبثقة (Dialogs)
  // ==========================================

  void _showAddPersonDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إضافة شخص جديد'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'اسم الشخص',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Provider.of<ExpenseProvider>(context, listen: false).addPerson(nameController.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: const Text('إضافة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPersonDialog(BuildContext context, ExpenseProvider provider, String oldName) {
    final nameController = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تعديل اسم الشخص'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'الاسم الجديد', border: OutlineInputBorder()),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != oldName) {
                  provider.editPersonName(oldName, newName);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ExpenseProvider provider, String name, double paidAmount) {
    if (paidAmount > 0) {
      // تحذير إذا كان الشخص قد دفع مبالغ بالفعل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن حذف "$name" لأنه قام بدفع مبالغ. قم بحذف عملياته أولاً.'),
          backgroundColor: Colors.redAccent,
        )
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف "$name" من المجموعة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                provider.removePerson(name);
                Navigator.pop(ctx);
              },
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}