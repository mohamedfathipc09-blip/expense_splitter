import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart'; // 🔹 استدعاء ضروري لقراءة سياق التطبيق
import 'package:easy_localization/easy_localization.dart'; // 🔹 استدعاء مكتبة الترجمة

class PdfHelper {
  static Future<void> generateAndShareReport({
    required BuildContext buildContext, // 🔹 أضفنا هذا السطر لمعرفة لغة التطبيق الحالية
    required double totalExpenses,
    required double individualShare,
    required List<Map<String, dynamic>> accountStatuses,
    required String currency,
  }) async {
    final pdf = pw.Document();
    
    final font = await PdfGoogleFonts.cairoRegular();
   final boldFont = await PdfGoogleFonts.cairoBold();

   if (!buildContext.mounted) return; // 👈 أضف هذا السطر هنا

   bool isArabic = buildContext.locale.languageCode == 'ar';
// ... باقي الكود

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        // 🔹 السحر هنا: قلب الاتجاه تلقائياً
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('تقرير المصروفات الشامل'.tr(), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
              ),
              pw.SizedBox(height: 20),
              // دمجنا الترجمة مع التاريخ
              pw.Text('${'تاريخ التقرير:'.tr()} ${DateFormat('yyyy-MM-dd').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100, 
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.teal300)
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${'إجمالي المصروفات:'.tr()} ${totalExpenses.toStringAsFixed(2)} $currency', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('${'نصيب الفرد:'.tr()} ${individualShare.toStringAsFixed(2)} $currency', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]
                )
              ),
              pw.SizedBox(height: 30),
              pw.Text('تفاصيل الحسابات والأرصدة:'.tr(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey400),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.center,
                // 🔹 ترجمة عناوين الجدول
                headers: ['الشخص'.tr(), 'ما دفعه'.tr(), 'الرصيد النهائي'.tr()],
                data: accountStatuses.map((s) {
                  double balance = s['balance'];
                  // 🔹 ترجمة حالة الحساب (له، عليه، خالص)
                  String status = balance > 0 
                      ? '${'له'.tr()} ${balance.toStringAsFixed(1)}' 
                      : (balance < 0 ? '${'عليه'.tr()} ${balance.abs().toStringAsFixed(1)}' : 'خالص'.tr());
                  return [
                    s['name'],
                    '${s['totalPaid'].toStringAsFixed(1)} $currency',
                    status,
                  ];
                }).toList(),
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text('تم إنشاء هذا التقرير آلياً بواسطة تطبيق "قسمة المصاريف"'.tr(), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Expense_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}