import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔹 مكتبة الترجمة
import '../providers/expense_provider.dart';

class PersonsManagementScreen extends StatelessWidget {
  const PersonsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 تم إزالة Directionality الثابتة لكي تتجاوب الشاشة مع لغة التطبيق
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('إدارة الأشخاص'.tr(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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

          return Column(
            children: [
              // ==========================================
              // 🔹 الكارت الجديد المخصص لتعديل اسم المجموعة
              // ==========================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group_work, color: Colors.teal, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('اسم المجموعة'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(provider.groupName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.teal),
                      tooltip: 'تعديل اسم المجموعة'.tr(),
                      onPressed: () => _showEditGroupNameDialog(context, provider),
                    )
                  ],
                ),
              ),

              // ==========================================
              // قائمة الأشخاص
              // ==========================================
              Expanded(
                child: personsData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_off_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('لم تقم بإضافة أي أشخاص بعد'.tr(), style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          String balanceStatus = isSettled ? 'خالص'.tr() : (isCreditor ? 'له'.tr() : 'عليه'.tr());

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
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
                                        tooltip: 'تعديل الاسم'.tr(),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _confirmDelete(context, provider, name, paid),
                                        tooltip: 'حذف'.tr(),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Divider(),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildStatItem('ما دفعه'.tr(), paid, provider.currency, Colors.black87),
                                      _buildStatItem('نصيبه'.tr(), share, provider.currency, Colors.blueGrey),
                                      _buildStatItem('${'الرصيد'.tr()} ($balanceStatus)', balance, provider.currency, balanceColor),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPersonDialog(context),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text('إضافة شخص'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatItem(String label, double amount, String currency, Color color) {
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

  // 🔹 النافذة الجديدة لتعديل اسم المجموعة
  void _showEditGroupNameDialog(BuildContext context, ExpenseProvider provider) {
    final nameController = TextEditingController(text: provider.groupName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تعديل اسم المجموعة'.tr()),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'الاسم الجديد للمجموعة'.tr(),
            hintText: 'مثال: رحلة الإسكندرية...'.tr(),
            border: const OutlineInputBorder()
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'.tr(), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                provider.setGroupName(newName);
                Navigator.pop(ctx);
              }
            },
            child: Text('حفظ'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddPersonDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('إضافة شخص جديد'.tr()),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'اسم الشخص'.tr(),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'.tr(), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Provider.of<ExpenseProvider>(context, listen: false).addPerson(nameController.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text('إضافة'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditPersonDialog(BuildContext context, ExpenseProvider provider, String oldName) {
    final nameController = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تعديل اسم الشخص'.tr()),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'الاسم الجديد'.tr(), border: const OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'.tr(), style: const TextStyle(color: Colors.grey)),
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
            child: Text('حفظ'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ExpenseProvider provider, String name, double paidAmount) {
    if (paidAmount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن حذف هذا الشخص لوجود عمليات مالية مرتبطة به.'.tr()),
          backgroundColor: Colors.redAccent,
        )
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تأكيد الحذف'.tr()),
        content: Text('${'هل أنت متأكد من حذف'.tr()} "$name" ${'من المجموعة؟'.tr()}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.removePerson(name);
              Navigator.pop(ctx);
            },
            child: Text('حذف'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}