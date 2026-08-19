import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String payer;

  // الحقول الجديدة لدعم التحديثات
  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String category;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.payer,
    required this.date,
    required this.category,
  });
}