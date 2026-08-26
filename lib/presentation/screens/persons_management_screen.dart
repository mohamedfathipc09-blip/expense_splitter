import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../providers/expense_provider.dart';
import '../../core/helpers/format_helper.dart'; // 🔹 استدعاء ملف التنسيق الجديد

class PersonsManagementScreen extends StatelessWidget {
  const PersonsManagementScreen({super.key});

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
          'إدارة الأشخاص'.tr(), 
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
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

          // ترتيب الأشخاص تلقائياً حسب الرصيد
          personsData.sort((a, b) => b['balance'].compareTo(a['balance']));

          return Column(
            children: [
              // ==========================================
              // كارت تعديل اسم المجموعة (Modern UI)
              // ==========================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [Colors.teal.shade900, Colors.teal.shade800]
                        : [Colors.teal.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.groups_rounded, color: Colors.teal, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('اسم المجموعة'.tr(), style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                          const SizedBox(height: 2),
                          Text(provider.groupName.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.teal),
                      tooltip: 'تعديل اسم المجموعة'.tr(),
                      onPressed: () => _showEditGroupNameDialog(context, provider, isDark),
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
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.group_off_rounded, size: 60, color: Colors.grey.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(height: 24),
                            Text('لا يوجد أشخاص'.tr(), style: TextStyle(fontSize: 20, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('اضغط على الزر بالأسفل لإضافة أشخاص'.tr(), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // الجزء العلوي: الاسم والأزرار
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        child: Text(
                                          name.substring(0, 1).toUpperCase(), 
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary)
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit_rounded, color: Colors.blue.shade400, size: 22),
                                        onPressed: () => _showEditPersonDialog(context, provider, name, isDark),
                                        tooltip: 'تعديل الاسم'.tr(),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_rounded, color: Colors.red.shade400, size: 22),
                                        onPressed: () => _confirmDelete(context, provider, name, paid),
                                        tooltip: 'حذف'.tr(),
                                      ),
                                    ],
                                  ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, height: 1),
                                  ),
                                  
                                  // الجزء السفلي: الإحصائيات
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildStatItem('ما دفعه'.tr(), paid, provider.currency.tr(), isDark ? Colors.grey.shade300 : Colors.black87),
                                      _buildStatItem('نصيبه'.tr(), share, provider.currency.tr(), Colors.blueGrey),
                                      
                                      // تصميم الرصيد داخل (Chip) ملون ليبرز
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: balanceColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: balanceColor.withValues(alpha: 0.3)),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(balanceStatus, style: TextStyle(fontSize: 10, color: balanceColor, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 2),
                                            // 🔹 استخدام FormatHelper هنا للرصيد النهائي
                                            Text(
                                              '${FormatHelper.formatNumber(balance.abs())} ${provider.currency.tr()}', 
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: balanceColor)
                                            ),
                                          ],
                                        ),
                                      )
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
        onPressed: () => _showAddPersonDialog(context, isDark),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text('إضافة شخص'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ==========================================
  // مكون الإحصائيات الصغير
  // ==========================================
  Widget _buildStatItem(String label, double amount, String currency, Color color) {
    // 🔹 استخدام FormatHelper هنا لـ (ما دفعه / نصيبه)
    String amountStr = FormatHelper.formatNumber(amount.abs()); 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$amountStr $currency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ==========================================
  // النوافذ المنبثقة (Dialogs) بالتصميم الحديث
  // ==========================================

  Widget _buildDialogTextField(TextEditingController controller, String label, String? hint, bool isDark) {
    return TextField(
      controller: controller,
      autofocus: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
      ),
    );
  }

  void _showEditGroupNameDialog(BuildContext context, ExpenseProvider provider, bool isDark) {
    final nameController = TextEditingController(); 
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تعديل اسم المجموعة'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: _buildDialogTextField(nameController, 'الاسم الجديد للمجموعة'.tr(), 'مثال: رحلة الإسكندرية...'.tr(), isDark),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'.tr(), style: const TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                provider.setGroupName(newName);
                Navigator.pop(ctx);
              }
            },
            child: Text('حفظ'.tr()),
          ),
        ],
      ),
    );
  }

  void _showAddPersonDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('إضافة شخص جديد'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: _buildDialogTextField(nameController, 'اسم الشخص'.tr(), null, isDark),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'.tr(), style: const TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Provider.of<ExpenseProvider>(context, listen: false).addPerson(nameController.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text('إضافة'.tr()),
          ),
        ],
      ),
    );
  }

  void _showEditPersonDialog(BuildContext context, ExpenseProvider provider, String oldName, bool isDark) {
    final nameController = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تعديل اسم الشخص'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: _buildDialogTextField(nameController, 'الاسم الجديد'.tr(), null, isDark),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'.tr(), style: const TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                provider.editPersonName(oldName, newName);
                Navigator.pop(ctx);
              }
            },
            child: Text('حفظ'.tr()),
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text('تأكيد الحذف'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text('${'هل أنت متأكد من حذف'.tr()} "$name" ${'من المجموعة؟'.tr()}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء'.tr(), style: const TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: () {
              provider.removePerson(name);
              Navigator.pop(ctx);
            },
            child: Text('حذف'.tr()),
          ),
        ],
      ),
    );
  }
}