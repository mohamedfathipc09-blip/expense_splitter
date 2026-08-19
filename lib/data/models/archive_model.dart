import 'package:hive/hive.dart';

part 'archive_model.g.dart';

@HiveType(typeId: 1)
class ArchiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  List<String> settlementSummary;

  ArchiveModel({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.settlementSummary,
  });
}