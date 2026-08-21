// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔹 مكتبة الترجمة
import '../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? expenseToEdit;
  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedPerson;
  String _selectedCategory = 'عام'; // التصنيف الافتراضي
  DateTime _selectedDate = DateTime.now();

  // أسماء التصنيفات (ستترجم عند العرض في الـ Dropdown)
  final List<String> _categories = ['عام', 'طعام ومطاعم', 'مشتريات', 'مواصلات', 'سكن وفواتير'.tr()];

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _titleController.text = widget.expenseToEdit!.title;
      _amountController.text = widget.expenseToEdit!.amount.toString();
      _selectedPerson = widget.expenseToEdit!.payer;
      _selectedCategory = widget.expenseToEdit!.category;
      _selectedDate = widget.expenseToEdit!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    // 🔹 تم إزالة Directionality تماماً لأن easy_localization تدير الاتجاه تلقائياً
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseToEdit == null ? 'إضافة عملية'.tr() : 'تعديل عملية'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'اسم العملية'.tr(), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                // 🔹 تم دمج الترجمة للمبلغ والعملة معاً
                labelText: '${'المبلغ'.tr()} (${provider.currency.tr()})', 
                border: const OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPerson,
              decoration: InputDecoration(labelText: 'من دفع؟'.tr(), border: const OutlineInputBorder()),
              items: provider.persons.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() => _selectedPerson = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: 'التصنيف'.tr(), border: const OutlineInputBorder()),
              // 🔹 ترجمة التصنيفات عند العرض فقط
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.tr()))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              title: Text('${'التاريخ:'.tr()} ${DateFormat('yyyy-MM-dd', context.locale.languageCode).format(_selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context, 
                  initialDate: _selectedDate, 
                  firstDate: DateTime(2000), 
                  lastDate: DateTime.now()
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              onPressed: () {
                if (_titleController.text.isEmpty || _amountController.text.isEmpty || _selectedPerson == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('أكمل البيانات المطلوبة'.tr()))
                  );
                  return;
                }
                final newExp = ExpenseModel(
                  id: widget.expenseToEdit?.id ?? const Uuid().v4(),
                  title: _titleController.text,
                  amount: double.parse(_amountController.text),
                  payer: _selectedPerson!,
                  date: _selectedDate,
                  category: _selectedCategory,
                );
                if (widget.expenseToEdit == null) {
                  provider.addExpense(newExp);
                } else {
                  provider.updateExpense(newExp);
                }
                Navigator.pop(context);
              },
              child: Text('حفظ'.tr(), style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}