// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
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
  String _selectedCategory = 'عام'; 
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['عام', 'طعام ومطاعم', 'مشتريات', 'مواصلات', 'سكن وفواتير'];

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _titleController.text = widget.expenseToEdit!.title;
      // إزالة الفواصل إن وجدت عند التعديل لضمان قراءتها بشكل صحيح في الحقل
      _amountController.text = widget.expenseToEdit!.amount.toString().replaceAll(',', '');
      _selectedPerson = widget.expenseToEdit!.payer;
      _selectedCategory = widget.expenseToEdit!.category;
      _selectedDate = widget.expenseToEdit!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.expenseToEdit == null ? 'إضافة عملية'.tr() : 'تعديل عملية'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔹 كارت تجميع البيانات (Modern Card)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // حقل اسم العملية
                    _buildCustomTextField(
                      controller: _titleController,
                      label: 'اسم العملية'.tr(),
                      icon: Icons.edit_note_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    
                    // حقل المبلغ
                    _buildCustomTextField(
                      controller: _amountController,
                      label: '${'المبلغ'.tr()} (${provider.currency.tr()})',
                      icon: Icons.attach_money_rounded,
                      isDark: isDark,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20),
                    
                    // حقل من دفع
                    _buildCustomDropdown(
                      value: _selectedPerson,
                      label: 'من دفع؟'.tr(),
                      icon: Icons.person_rounded,
                      isDark: isDark,
                      items: provider.persons.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) => setState(() => _selectedPerson = val),
                    ),
                    const SizedBox(height: 20),
                    
                    // حقل التصنيف
                    _buildCustomDropdown(
                      value: _categories.contains(_selectedCategory) ? _selectedCategory : 'عام',
                      label: 'التصنيف'.tr(),
                      icon: Icons.category_rounded,
                      isDark: isDark,
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.tr()))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                    const SizedBox(height: 20),
                    
                    // حقل التاريخ
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context, 
                            initialDate: _selectedDate, 
                            firstDate: DateTime(2000), 
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: theme.copyWith(
                                  colorScheme: theme.colorScheme.copyWith(
                                    primary: isDark ? Colors.indigo.shade300 : Colors.indigo,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, color: Colors.indigo.shade400),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('التاريخ'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('yyyy-MM-dd', context.locale.languageCode).format(_selectedDate),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 🔹 زر الحفظ الاحترافي (Modern Gradient Button)
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: isDark ? [Colors.indigo.shade700, Colors.indigo.shade900] : [Colors.indigo.shade400, Colors.indigo.shade600],
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
                  ]
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (_titleController.text.isEmpty || _amountController.text.isEmpty || _selectedPerson == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('أكمل البيانات المطلوبة'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          )
                        );
                        return;
                      }

                      // 🔹 الحماية من الأخطاء (Safe Parsing): استبدال أي فاصلة بنص فارغ لتجنب خطأ التحويل
                      String cleanAmount = _amountController.text.replaceAll(',', '').replaceAll(' ', '');
                      double parsedAmount = double.tryParse(cleanAmount) ?? 0.0;
                      
                      if (parsedAmount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('الرجاء إدخال مبلغ صحيح'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.orange.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          )
                        );
                        return;
                      }

                      final newExp = ExpenseModel(
                        id: widget.expenseToEdit?.id ?? const Uuid().v4(),
                        title: _titleController.text,
                        amount: parsedAmount,
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
                    child: Center(
                      child: Text('حفظ'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 🔹 تصميم موحد لحقول النص (Text Fields)
  // ==========================================
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.indigo.shade400),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.indigo.shade300 : Colors.indigo, width: 2),
        ),
      ),
    );
  }

  // ==========================================
  // 🔹 تصميم موحد للقوائم المنسدلة (Dropdowns)
  // ==========================================
  Widget _buildCustomDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required bool isDark,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.indigo.shade400),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.indigo.shade300 : Colors.indigo, width: 2),
        ),
      ),
    );
  }
}