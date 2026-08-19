import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseCard({super.key, required this.expense, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<ExpenseProvider>(context, listen: false).currency;

    IconData catIcon = Icons.receipt;
    Color catColor = Colors.teal;
    if (expense.category == 'طعام ومطاعم') { catIcon = Icons.fastfood; catColor = Colors.orange; }
    else if (expense.category == 'مشتريات') { catIcon = Icons.shopping_cart; catColor = Colors.blue; }
    else if (expense.category == 'مواصلات') { catIcon = Icons.directions_car; catColor = Colors.redAccent; }
    else if (expense.category == 'سكن وفواتير') { catIcon = Icons.bolt; catColor = Colors.purple; }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: catColor.withValues(alpha: 0.1),
          child: Icon(catIcon, color: catColor),
        ),
        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('دفعها: ${expense.payer}'),
            Text(DateFormat('yyyy-MM-dd hh:mm a').format(expense.date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${expense.amount} $currency', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: onEdit, constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: onDelete, constraints: const BoxConstraints(), padding: EdgeInsets.zero),
              ],
            ),
          ],
        ),
      ),
    );
  }
}