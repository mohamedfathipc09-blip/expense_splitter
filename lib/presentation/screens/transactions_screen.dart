import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  IconData _getCategoryIcon(String category) {
    if (category.contains('طعام') || category.contains('أكل')) return Icons.fastfood;
    if (category.contains('سكن') || category.contains('فندق')) return Icons.hotel;
    if (category.contains('مواصلات') || category.contains('سيارة')) return Icons.directions_car;
    if (category.contains('تسوق') || category.contains('شراء')) return Icons.shopping_bag;
    return Icons.receipt_long;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    // جلب جميع العمليات وترتيبها من الأحدث للأقدم
    final expenses = provider.allExpenses.toList()..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('سجل العمليات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: expenses.isEmpty
          ? const Center(child: Text('لا توجد عمليات مسجلة حتى الآن.', style: TextStyle(fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(_getCategoryIcon(expense.category), color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('${expense.category} • دفع: ${expense.payer}\n${DateFormat('d MMMM yyyy', 'ar').format(expense.date)}'),
                    ),
                    trailing: Text(
                      '${expense.amount.toStringAsFixed(0)} ${provider.currency}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                );
              },
            ),
    );
  }
}