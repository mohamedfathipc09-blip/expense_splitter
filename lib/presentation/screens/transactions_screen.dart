import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/expense_provider.dart';
// 🔹 تم مسح الاستيراد غير المستخدم هنا

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل'; 

  IconData _getCategoryIcon(String category) {
    if (category.contains('طعام') || category.contains('أكل')) return Icons.fastfood;
    if (category.contains('سكن') || category.contains('فندق')) return Icons.hotel;
    if (category.contains('مواصلات') || category.contains('سيارة')) return Icons.directions_car;
    if (category.contains('تسوق') || category.contains('شراء') || category.contains('مشتريات')) return Icons.shopping_bag;
    return Icons.receipt_long;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final allExpenses = provider.allExpenses;

    final Set<String> uniqueCategories = allExpenses.map((e) => e.category).toSet();
    final List<String> filterCategories = ['الكل', ...uniqueCategories];

    final filteredExpenses = allExpenses.where((expense) {
      final matchesSearch = _searchQuery.isEmpty ||
          expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expense.payer.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'الكل' || expense.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      // 🔹 تم تحديث الكود ليتوافق مع الإصدارات الجديدة (surfaceContainerHighest بدلاً من surfaceVariant)
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      appBar: AppBar(
        title: Text('سجل العمليات'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), 
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن عملية أو شخص...'.tr(),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        // 🔹 تم التحديث هنا أيضاً 
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                  FocusScope.of(context).unfocus(); 
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: filterCategories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            // 🔹 تم حل مشكلة الخطأ الأحمر باستخدام EdgeInsetsDirectional
                            padding: const EdgeInsetsDirectional.only(end: 8.0), 
                            child: FilterChip(
                              label: Text(category == 'الكل' ? 'الكل'.tr() : category.tr()),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() => _selectedCategory = category);
                              },
                              showCheckmark: false,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              selectedColor: Theme.of(context).colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: isSelected 
                                  ? Theme.of(context).colorScheme.onPrimaryContainer 
                                  : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: filteredExpenses.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Icon(
                                  _getCategoryIcon(expense.category), 
                                  color: Theme.of(context).colorScheme.onPrimaryContainer
                                ),
                              ),
                              title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${expense.category.tr()} • ${'دفع:'.tr()} ${expense.payer}\n${DateFormat('d MMMM yyyy', context.locale.languageCode).format(expense.date)}',
                                  style: TextStyle(color: Colors.grey[600], height: 1.4),
                                ),
                              ),
                              trailing: Text(
                                '${expense.amount.toStringAsFixed(0)} ${provider.currency.tr()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16, 
                                  color: Theme.of(context).colorScheme.primary
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty 
              ? 'لا توجد عمليات في هذا التصنيف.'.tr()
              : 'لا توجد عمليات مطابقة لبحثك.'.tr(),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'الكل') ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'الكل';
                });
              },
              icon: const Icon(Icons.clear_all),
              label: Text('مسح الفلاتر'.tr()),
            )
          ]
        ],
      ),
    );
  }
}