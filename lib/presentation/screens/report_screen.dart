import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../providers/expense_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

// المكتبات الخاصة بإنشاء ومشاركة الـ PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('تقرير المصروفات', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Consumer<ExpenseProvider>(
          builder: (context, provider, child) {
            // ==========================================
            // الحسابات والخوارزميات 
            // ==========================================
            final int totalPersons = provider.persons.length;
            final int totalTransactions = provider.expenses.length;
            final double totalExpenses = provider.expenses.fold(0, (sum, item) => sum + item.amount);
            final double sharePerPerson = totalPersons > 0 ? totalExpenses / totalPersons : 0;

            Map<String, double> paidAmounts = {for (var p in provider.persons) p: 0.0};
            for (var exp in provider.expenses) {
              if (paidAmounts.containsKey(exp.payer)) {
                paidAmounts[exp.payer] = (paidAmounts[exp.payer] ?? 0.0) + exp.amount;
              }
            }

            Map<String, double> balances = {};
            for (var p in provider.persons) {
              balances[p] = (paidAmounts[p] ?? 0.0) - sharePerPerson;
            }

            List<Map<String, dynamic>> settlements = _calculateSettlements(balances);

            // ==========================================
            // واجهة التقرير (UI) 
            // ==========================================
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context, provider),
                      const Divider(thickness: 2, color: Color(0xFF005C53)),
                      _buildResponsiveSummaryCards(totalExpenses, sharePerPerson, totalTransactions, totalPersons),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.bar_chart, color: Color(0xFF005C53)),
                            SizedBox(width: 8),
                            Text('تفاصيل الحسابات والأرصدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF005C53))),
                          ],
                        ),
                      ),
                      _buildAccountsTable(provider.persons, paidAmounts, sharePerPerson, balances),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSettlementsSection(settlements, provider.currency),
                      ),
                      const SizedBox(height: 24),
                      // الأزرار السفلية (زر الـ PDF)
                      _buildActionButtons(context, provider, totalExpenses, sharePerPerson, paidAmounts, balances, settlements, totalTransactions),
                      const SizedBox(height: 16),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateSettlements(Map<String, double> balances) {
    List<MapEntry<String, double>> debtors = balances.entries.where((e) => e.value < -0.01).toList();
    List<MapEntry<String, double>> creditors = balances.entries.where((e) => e.value > 0.01).toList();
    
    debtors.sort((a, b) => a.value.compareTo(b.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    List<Map<String, dynamic>> settlements = [];
    int i = 0, j = 0;

    while (i < debtors.length && j < creditors.length) {
      double debt = -debtors[i].value;
      double credit = creditors[j].value;
      double amount = debt < credit ? debt : credit;

      settlements.add({'from': debtors[i].key, 'to': creditors[j].key, 'amount': amount});

      debtors[i] = MapEntry(debtors[i].key, debtors[i].value + amount);
      creditors[j] = MapEntry(creditors[j].key, creditors[j].value - amount);

      if (debtors[i].value.abs() < 0.01) i++;
      if (creditors[j].value.abs() < 0.01) j++;
    }
    return settlements;
  }

  Widget _buildHeader(BuildContext context, ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet, color: Color(0xFF005C53), size: 36),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التقرير الشامل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    SizedBox(height: 4),
                    Text('تطبيق قسمة للمصروفات', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoItem(Icons.calendar_today, DateFormat('dd-MM-yyyy').format(DateTime.now())),
                _infoItem(Icons.groups, provider.groupName),
                _infoItem(Icons.payments, provider.currency),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF005C53)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildResponsiveSummaryCards(double total, double share, int transactions, int persons) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard('إجمالي المصروفات', total.toStringAsFixed(2), Icons.account_balance_wallet, Colors.teal)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('نصيب الفرد', share.toStringAsFixed(2), Icons.person, Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCard('عدد العمليات', '$transactions', Icons.receipt_long, Colors.purple)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('عدد الأشخاص', '$persons', Icons.groups, Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildAccountsTable(List<String> persons, Map<String, double> paid, double share, Map<String, double> balances) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF005C53)),
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('الشخص', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ما دفعه', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('نصيبه', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الرصيد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الحالة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
            rows: persons.map((person) {
              double bal = balances[person] ?? 0.0;
              bool isCreditor = bal > 0.01;
              bool isSettled = bal.abs() <= 0.01;

              return DataRow(
                cells: [
                  DataCell(Row(children: [const Icon(Icons.account_circle, color: Colors.teal, size: 18), const SizedBox(width: 4), Text(person, style: const TextStyle(fontWeight: FontWeight.bold))])),
                  DataCell(Text((paid[person] ?? 0.0).toStringAsFixed(2))),
                  DataCell(Text(share.toStringAsFixed(2))),
                  DataCell(Text(
                    isSettled ? '0.00' : '${bal > 0 ? '+' : ''}${bal.toStringAsFixed(2)}',
                    style: TextStyle(color: isSettled ? Colors.grey : (isCreditor ? Colors.green : Colors.red), fontWeight: FontWeight.bold),
                  )),
                  DataCell(Row(
                    children: [
                      Icon(isSettled ? Icons.check_circle : (isCreditor ? Icons.arrow_circle_up : Icons.arrow_circle_down),
                          color: isSettled ? Colors.grey : (isCreditor ? Colors.green : Colors.red), size: 16),
                      const SizedBox(width: 4),
                      Text(isSettled ? 'خالص' : (isCreditor ? 'له' : 'عليه'),
                          style: TextStyle(color: isSettled ? Colors.grey : (isCreditor ? Colors.green : Colors.red), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSettlementsSection(List<Map<String, dynamic>> settlements, String currency) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sync_alt, color: Color(0xFF005C53)),
              SizedBox(width: 8),
              Text('اقتراحات التسوية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF005C53))),
            ],
          ),
          const SizedBox(height: 12),
          if (settlements.isEmpty)
            const Text('لا توجد مبالغ مستحقة، جميع الحسابات خالصة!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
          else
            ...settlements.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [const Icon(Icons.person, color: Colors.teal, size: 16), const SizedBox(width: 4), Text(s['from'], style: const TextStyle(fontWeight: FontWeight.bold))]),
                      Column(
                        children: [
                          const Text('يدفع إلى', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text('${s['amount'].toStringAsFixed(2)} $currency', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          const Icon(Icons.arrow_forward, color: Colors.teal, size: 16),
                        ],
                      ),
                      Row(children: [Text(s['to'], style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 4), const Icon(Icons.person, color: Colors.purple, size: 16)]),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ExpenseProvider provider, double total, double share, Map<String, double> paid, Map<String, double> balances, List<Map<String, dynamic>> settlements, int transactions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _actionButton(Icons.share, 'مشاركة وحفظ PDF', Colors.blue, () async {
            await _generateAndSharePDF(context, provider, total, share, paid, balances, settlements, transactions);
          }),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // دالة إنشاء ومشاركة الـ PDF (بالخطوط المحلية)
  // ==========================================
  Future<void> _generateAndSharePDF(BuildContext context, ExpenseProvider provider, double totalExpenses, double share, Map<String, double> paidAmounts, Map<String, double> balances, List<Map<String, dynamic>> settlements, int totalTransactions) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري إنشاء التقرير الاحترافي...')));

    try {
      final pdf = pw.Document();
      
      // التعديل هنا: جلب الخطوط من ملفات التطبيق (بدون إنترنت)
      final regularData = await rootBundle.load('assets/fonts/cairo_regular.ttf');
      final arabicFont = pw.Font.ttf(regularData);

      final boldData = await rootBundle.load('assets/fonts/cairo_bold.ttf');
      final arabicFontBold = pw.Font.ttf(boldData);

      // محاولة جلب اللوجو 
      pw.MemoryImage? logoImage;
      try {
        final ByteData data = await rootBundle.load('assets/images/logo.jpg');
        logoImage = pw.MemoryImage(data.buffer.asUint8List());
      } catch (e) {
        debugPrint('Logo not found, proceeding without it.');
      }

      // تعريف الألوان المستخدمة في التصميم
      final tealColor = PdfColor.fromHex('#008080');
      final darkBlueColor = PdfColor.fromHex('#1E3A8A');
      final redColor = PdfColor.fromHex('#D32F2F');
      final greenColor = PdfColor.fromHex('#388E3C');
      final lightGrey = PdfColor.fromHex('#F8F9FA');
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          textDirection: pw.TextDirection.rtl, 
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
          // الفوتر السفلي المتطابق مع الصورة (شريط أزرق داكن)
          footer: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: pw.BoxDecoration(
                color: darkBlueColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('تطبيق قسمة - إدارة المصروفات المشتركة', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                  pw.Text('${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())} | صفحة ${context.pageNumber} من ${context.pagesCount}', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                ]
              )
            );
          },
          build: (pw.Context context) {
            return [
              // 1. الترويسة العلوية المتطابقة
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // صندوق المعلومات (يمين)
                  pw.Container(
                    width: 150,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      color: lightGrey,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('تاريخ التقرير: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Divider(color: PdfColors.grey300, height: 8),
                        pw.Text('المجموعة: ${provider.groupName}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Divider(color: PdfColors.grey300, height: 8),
                        pw.Text('العملة: ${provider.currency}', style: const pw.TextStyle(fontSize: 9)),
                      ]
                    )
                  ),
                  // العنوان (وسط)
                  pw.Column(
                    children: [
                      pw.Text('تقرير المصروفات الشامل', style: pw.TextStyle(font: arabicFontBold, fontSize: 22, color: darkBlueColor)),
                      pw.SizedBox(height: 4),
                      pw.Text('تطبيق قسمة - إدارة المصروفات المشتركة', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                    ]
                  ),
                  // اللوجو (يسار)
                  if (logoImage != null)
                    pw.Image(logoImage, width: 70, height: 70)
                  else
                    pw.SizedBox(width: 70), 
                ],
              ),
              
              pw.SizedBox(height: 24),

              // 2. كروت الإحصائيات 
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPdfStatCard('عدد الأشخاص', '${provider.persons.length}', 'أشخاص', arabicFontBold, tealColor),
                  _buildPdfStatCard('عدد العمليات', '$totalTransactions', 'عملية', arabicFontBold, PdfColor.fromHex('#6A1B9A')),
                  _buildPdfStatCard('نصيب الفرد', share.toStringAsFixed(2), provider.currency, arabicFontBold, PdfColor.fromHex('#1565C0')),
                  _buildPdfStatCard('إجمالي المصروفات', totalExpenses.toStringAsFixed(2), provider.currency, arabicFontBold, greenColor),
                ]
              ),
              
              pw.SizedBox(height: 24),
              pw.Text('تفاصيل الحسابات والأرصدة', style: pw.TextStyle(font: arabicFontBold, fontSize: 16, color: tealColor)),
              pw.SizedBox(height: 8),

              // 3. الجدول الاحترافي 
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                children: [
                  // صف العناوين 
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: tealColor),
                    children: [
                      'الشخص', 'ما دفعه', 'نصيبه المفترض', 'الرصيد النهائي', 'الحالة'
                    ].map((t) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4), 
                      child: pw.Text(t, style: pw.TextStyle(color: PdfColors.white, font: arabicFontBold, fontSize: 11), textAlign: pw.TextAlign.center)
                    )).toList(),
                  ),
                  // صفوف البيانات
                  ...provider.persons.map((person) {
                    double bal = balances[person] ?? 0.0;
                    bool isCreditor = bal > 0.01;
                    bool isSettled = bal.abs() <= 0.01;
                    
                    return pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.white),
                      children: [
                        _pdfTableCell(person, arabicFontBold),
                        _pdfTableCell((paidAmounts[person] ?? 0.0).toStringAsFixed(2), arabicFontBold),
                        _pdfTableCell(share.toStringAsFixed(2), arabicFontBold),
                        // الرصيد النهائي ملون
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Text(
                            isSettled ? '0.00' : '${bal > 0 ? '+' : ''}${bal.toStringAsFixed(2)}', 
                            style: pw.TextStyle(font: arabicFontBold, fontSize: 11, color: isSettled ? PdfColors.grey : (isCreditor ? greenColor : redColor)), 
                            textAlign: pw.TextAlign.center
                          )
                        ),
                        // الحالة مع الدوائر الملونة 
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(isSettled ? 'خالص' : (isCreditor ? 'له' : 'عليه'), style: pw.TextStyle(font: arabicFontBold, fontSize: 11, color: isSettled ? PdfColors.grey : (isCreditor ? greenColor : redColor))),
                              pw.SizedBox(width: 4),
                              pw.Container(width: 8, height: 8, decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: isSettled ? PdfColors.grey : (isCreditor ? greenColor : redColor))),
                            ]
                          )
                        ),
                      ]
                    );
                  }),
                ]
              ),

              pw.SizedBox(height: 24),

              // 4. قسم التسويات والملاحظات 
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // قسم التسويات (يمين الصفحة)
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F1F8E9'), 
                        border: pw.Border.all(color: greenColor, width: 0.5),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('اقتراحات التسوية', style: pw.TextStyle(font: arabicFontBold, fontSize: 14, color: greenColor)),
                          pw.SizedBox(height: 10),
                          if (settlements.isEmpty)
                            pw.Text('لا توجد تسويات مطلوبة.', style: const pw.TextStyle(color: PdfColors.grey))
                          else
                            ...settlements.map((s) => pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(s['from'], style: pw.TextStyle(font: arabicFontBold)),
                                  pw.Column(
                                    children: [
                                      pw.Text('يدفع إلى', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                                      pw.Text('${s['amount'].toStringAsFixed(2)}', style: pw.TextStyle(font: arabicFontBold, color: redColor, fontSize: 10)),
                                    ]
                                  ),
                                  pw.Text(s['to'], style: pw.TextStyle(font: arabicFontBold)),
                                ]
                              )
                            )),
                        ]
                      )
                    )
                  ),
                  pw.SizedBox(width: 16),
                  // قسم الملاحظات (يسار الصفحة)
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#E3F2FD'), 
                        border: pw.Border.all(color: darkBlueColor, width: 0.5),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('ملاحظات', style: pw.TextStyle(font: arabicFontBold, fontSize: 14, color: darkBlueColor)),
                          pw.SizedBox(height: 10),
                          _pdfNoteItem('جميع المبالغ محسوبة بناءً على إجمالي المصروفات.', darkBlueColor),
                          _pdfNoteItem('الأرصدة الموجبة (له) تعني أن الشخص يستحق مبلغاً.', darkBlueColor),
                          _pdfNoteItem('الأرصدة السالبة (عليه) تعني أن الشخص مدين بمبلغ.', darkBlueColor),
                          _pdfNoteItem('يمكنك مشاركة هذا التقرير كملف PDF مع الأعضاء.', darkBlueColor),
                        ]
                      )
                    )
                  ),
                ]
              )
            ];
          },
        ),
      );

      final bytes = await pdf.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'تقرير_قسمة_${provider.groupName}.pdf',
      );

    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء إعداد الـ PDF: $e')));
    }
  }

  // دوال مساعدة لرسم عناصر الـ PDF الداخلية
  pw.Widget _buildPdfStatCard(String title, String value, String subtitle, pw.Font fontBold, PdfColor color) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 10, color: color)),
          pw.SizedBox(height: 6),
          pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.black)),
          pw.SizedBox(height: 2),
          pw.Text(subtitle, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  pw.Widget _pdfTableCell(String text, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Text(text, style: pw.TextStyle(font: fontBold, fontSize: 11), textAlign: pw.TextAlign.center)
    );
  }

  pw.Widget _pdfNoteItem(String text, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 3, left: 6),
            width: 6, height: 6, 
            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: color)
          ),
          pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 9, color: PdfColors.black))),
        ]
      )
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تطبيق قسمة للمصروفات', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('Qisma Expenses v1.0', style: TextStyle(color: Colors.white70, fontSize: 9)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('تم الإنشاء', style: TextStyle(color: Colors.white, fontSize: 11)),
              Text(DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now()), style: const TextStyle(color: Colors.white70, fontSize: 9)),
            ],
          )
        ],
      ),
    );
  }
}