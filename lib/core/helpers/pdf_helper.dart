import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfHelper {
  static Future<void> generateAndShareReport({
    required double totalExpenses,
    required double individualShare,
    required List<Map<String, dynamic>> accountStatuses,
    required String currency,
  }) async {
    final pdf = pw.Document();
    
    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('تقرير المصروفات الشامل', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('تاريخ التقرير: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 14)),
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
                    pw.Text('إجمالي المصروفات: ${totalExpenses.toStringAsFixed(2)} $currency', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('نصيب الفرد: ${individualShare.toStringAsFixed(2)} $currency', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]
                )
              ),
              pw.SizedBox(height: 30),
              pw.Text('تفاصيل الحسابات والأرصدة:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              // التعديل السحري هنا: TableHelper بدلاً من Table
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey400),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.center,
                headers: ['الشخص', 'ما دفعه', 'الرصيد النهائي'],
                data: accountStatuses.map((s) {
                  double balance = s['balance'];
                  String status = balance > 0 
                      ? 'له ${balance.toStringAsFixed(1)}' 
                      : (balance < 0 ? 'عليه ${balance.abs().toStringAsFixed(1)}' : 'خالص');
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
                child: pw.Text('تم إنشاء هذا التقرير آلياً بواسطة تطبيق "قسمة المصاريف"', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
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