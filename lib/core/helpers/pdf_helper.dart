import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PdfHelper {
  static Future<void> generateAndShareReport({
    required BuildContext buildContext,
    required double totalExpenses,
    required double individualShare,
    required List<Map<String, dynamic>> accountStatuses,
    required String currency,
    List<Map<String, dynamic>>? settlements, // 🔹 أضفنا اقتراحات التسوية اختيارياً لو احتجتها
  }) async {
    final pdf = pw.Document();
    
    // تحميل خطوط كايرو العربية لضمان عدم ظهور حروف مربعة
    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    if (!buildContext.mounted) return;

    bool isArabic = buildContext.locale.languageCode == 'ar';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return [
            // العنوان الرئيسي
            pw.Center(
              child: pw.Text(
                'تقرير المصروفات الشامل'.tr(),
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800),
              ),
            ),
            pw.SizedBox(height: 16),
            
            // تاريخ التقرير
            pw.Text(
              '${'تاريخ التقرير:'.tr()} ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 16),

            // كارت الملخص (إجمالي المصروفات ونصيب الفرد)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColors.teal300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${'إجمالي المصروفات:'.tr()} ${totalExpenses.toStringAsFixed(2)} $currency',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '${'نصيب الفرد:'.tr()} ${individualShare.toStringAsFixed(2)} $currency',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // جدول تفاصيل الحسابات والأرصدة
            pw.Text(
              'تفاصيل الحسابات والأرصدة:'.tr(),
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800),
            ),
            pw.SizedBox(height: 8),
            
            pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(color: PdfColors.grey400),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
              headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.center,
              headers: ['الشخص'.tr(), 'ما دفعه'.tr(), 'الرصيد النهائي'.tr()],
              data: accountStatuses.map((s) {
                double balance = s['balance'];
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

            // قسم اقتراحات التسوية (إن وجدت)
            if (settlements != null && settlements.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text(
                'اقتراحات التسوية'.tr(),
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800),
              ),
              pw.SizedBox(height: 8),
              ...settlements.map((s) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 6),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green200),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(s['from'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                      child: pw.Text(
                        '${s['amount'].toStringAsFixed(2)} $currency (${'يدفع لـ'.tr()})',
                        style: pw.TextStyle(color: PdfColors.red800, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Text(s['to'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              )),
            ],

            pw.Spacer(),
            pw.Divider(),
            pw.Center(
              child: pw.Text(
                'تم إنشاء هذا التقرير آلياً بواسطة تطبيق "قسمة المصاريف"'.tr(),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ),
          ];
        },
      ),
    );

    // حفظ وحفظ/مشاركة الملف بطريقة تدعم أجهزة الموبايل والويب
    final bytes = await pdf.save();
    
    if (!buildContext.mounted) return;

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Expense_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}