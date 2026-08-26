import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/archive_model.dart';
import '../../data/models/expense_model.dart';

class BackupHelper {
  /// إنشاء نسخة احتياطية ومشاركتها
  static Future<bool> createBackup() async {
    try {
      final expenseBox = Hive.box<ExpenseModel>('expensesBox');
      final settingsBox = Hive.box('settingsBox');
      final archiveBox = Hive.box<ArchiveModel>('archiveBox');

      final backupData = <String, dynamic>{
        'version': 1,
        'createdAt': DateTime.now().toIso8601String(),

        'expenses': expenseBox.values.map((expense) {
          return {
            'id': expense.id,
            'title': expense.title,
            'amount': expense.amount,
            'date': expense.date.toIso8601String(),
            'payer': expense.payer,
            'category': expense.category,
          };
        }).toList(),

        'settings': settingsBox.toMap(),

        'archives': archiveBox.values.map((archive) {
          return {
            'id': archive.id,
            'date': archive.date.toIso8601String(),
            'totalAmount': archive.totalAmount,
            'settlementSummary': archive.settlementSummary,
          };
        }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(
        backupData,
      );

      final Uint8List bytes = Uint8List.fromList(
        utf8.encode(jsonString),
      );

      final String fileName =
          'ExpenseBackup_${DateTime.now().millisecondsSinceEpoch}.json';

      final XFile xFile = XFile.fromData(
        bytes,
        name: fileName,
        mimeType: 'application/json',
      );

      // 🔹 تم حل التحذيرات: استخدام SharePlus.instance.share
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[xFile],
          text: 'نسخة احتياطية لتطبيق قسمة المصاريف',
          subject: 'نسخة احتياطية - قسمة المصاريف',
        ),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// استعادة نسخة احتياطية
  static Future<bool> restoreBackup() async {
    try {
      // 🔹 تم حل أخطاء FilePicker: استخدام طريقة الاستدعاء المتوافقة مع إصدارك
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json'],
      );

      if (files.isEmpty) {
        return false;
      }

      final PlatformFile file = files.first;

      // 🔹 قراءة الملفات في الذاكرة (RAM) لتعمل على الويب والموبايل بأمان
      final XFile xFile = file.xFile;
      final Uint8List fileBytes = await xFile.readAsBytes();

      if (fileBytes.isEmpty) {
        return false;
      }

      final String jsonString = utf8.decode(fileBytes);

      final dynamic decoded = jsonDecode(jsonString);

      if (decoded is! Map) {
        return false;
      }

      final Map<String, dynamic> backupData =
          Map<String, dynamic>.from(decoded);

      // التأكد من أن الملف نسخة احتياطية صحيحة
      final bool hasExpenses = backupData.containsKey('expenses');
      final bool hasSettings = backupData.containsKey('settings');
      final bool hasArchives = backupData.containsKey('archives');

      if (!hasExpenses && !hasSettings && !hasArchives) {
        return false;
      }

      // فتح صناديق Hive
      final Box<ExpenseModel> expenseBox =
          Hive.box<ExpenseModel>('expensesBox');

      final Box settingsBox = Hive.box('settingsBox');

      final Box<ArchiveModel> archiveBox =
          Hive.box<ArchiveModel>('archiveBox');

      /*
       * نحذف البيانات الحالية فقط بعد
       * التأكد أن ملف النسخة الاحتياطية صالح.
       */
      await expenseBox.clear();
      await settingsBox.clear();
      await archiveBox.clear();

      // ==========================================
      // استعادة الإعدادات
      // ==========================================

      final dynamic settingsData = backupData['settings'];

      if (settingsData is Map) {
        for (final MapEntry entry in settingsData.entries) {
          await settingsBox.put(
            entry.key,
            entry.value,
          );
        }
      }

      // ==========================================
      // استعادة المصروفات
      // ==========================================

      final dynamic expensesData = backupData['expenses'];

      if (expensesData is List) {
        for (final dynamic item in expensesData) {
          if (item is! Map) {
            continue;
          }

          final Map<String, dynamic> data =
              Map<String, dynamic>.from(item);

          final String? id = data['id']?.toString();

          if (id == null || id.isEmpty) {
            continue;
          }

          final ExpenseModel expense = ExpenseModel(
            id: id,
            title: data['title']?.toString() ?? '',
            amount: _toDouble(data['amount']),
            date: _toDateTime(data['date']),
            payer: data['payer']?.toString() ?? '',
            category: data['category']?.toString() ?? '',
          );

          await expenseBox.put(
            expense.id,
            expense,
          );
        }
      }

      // ==========================================
      // استعادة الأرشيف
      // ==========================================

      final dynamic archivesData = backupData['archives'];

      if (archivesData is List) {
        for (final dynamic item in archivesData) {
          if (item is! Map) {
            continue;
          }

          final Map<String, dynamic> data =
              Map<String, dynamic>.from(item);

          final String? id = data['id']?.toString();

          if (id == null || id.isEmpty) {
            continue;
          }

          final dynamic summaryData = data['settlementSummary'];

          final List<String> settlementSummary =
              summaryData is List
                  ? summaryData
                      .map(
                        (dynamic value) => value.toString(),
                      )
                      .toList()
                  : <String>[];

          final ArchiveModel archive = ArchiveModel(
            id: id,
            date: _toDateTime(data['date']),
            totalAmount: _toDouble(data['totalAmount']),
            settlementSummary: settlementSummary,
          );

          await archiveBox.put(
            archive.id,
            archive,
          );
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// تحويل قيمة إلى double
  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  /// تحويل قيمة إلى DateTime
  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
          value?.toString() ?? '',
        ) ??
        DateTime.now();
  }
}