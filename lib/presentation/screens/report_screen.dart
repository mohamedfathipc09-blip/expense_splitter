import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../providers/expense_provider.dart';
import '../../core/helpers/format_helper.dart'; // 🔹 استدعاء ملف تنسيق الأرقام
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'تقرير المصروفات'.tr(), 
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
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

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), 
                      blurRadius: 20, 
                      offset: const Offset(0, 10)
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, provider, isDark),
                    Divider(thickness: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, height: 1),
                    
                    _buildResponsiveSummaryCards(totalExpenses, sharePerPerson, totalTransactions, totalPersons, isDark),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.bar_chart_rounded, color: isDark ? Colors.teal.shade400 : const Color(0xFF005C53)),
                          const SizedBox(width: 8),
                          Text(
                            'تفاصيل الحسابات والأرصدة'.tr(), 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.teal.shade400 : const Color(0xFF005C53))
                          ),
                        ],
                      ),
                    ),
                    
                    _buildPerfectTable(provider.persons, paidAmounts, sharePerPerson, balances, isDark),
                    
                    const SizedBox(height: 24),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSettlementsSection(settlements, provider.currency.tr(), isDark),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    _buildActionButtons(context, provider, totalExpenses, sharePerPerson, paidAmounts, balances, settlements, totalTransactions, isDark),
                    
                    const SizedBox(height: 24),
                    
                    _buildFooter(context, isDark),
                  ],
                ),
              ),
            ),
          );
        },
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

  Widget _buildHeader(BuildContext context, ExpenseProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.teal.withValues(alpha: 0.15) : Colors.teal.shade50, 
                  shape: BoxShape.circle
                ),
                child: Icon(Icons.account_balance_wallet_rounded, color: isDark ? Colors.teal.shade400 : const Color(0xFF005C53), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التقرير الشامل'.tr(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade300 : const Color(0xFF1E3A8A))),
                    const SizedBox(height: 4),
                    Text('تطبيق قسمة للمصروفات'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoItem(Icons.calendar_today_rounded, DateFormat('dd-MM-yyyy', context.locale.languageCode).format(DateTime.now()), isDark),
                _infoItem(Icons.groups_rounded, provider.groupName.tr(), isDark),
                _infoItem(Icons.payments_rounded, provider.currency.tr(), isDark),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.teal.shade400 : const Color(0xFF005C53)),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }

  Widget _buildResponsiveSummaryCards(double total, double share, int transactions, int persons, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              // 🔹 استخدام FormatHelper للإجمالي والنصيب
              Expanded(child: _statCard('إجمالي المصروفات'.tr(), FormatHelper.formatNumber(total), Icons.account_balance_wallet_rounded, Colors.teal, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('نصيب الفرد'.tr(), FormatHelper.formatNumber(share), Icons.person_rounded, Colors.blue, isDark)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCard('عدد العمليات'.tr(), '$transactions', Icons.receipt_long_rounded, Colors.purple, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('عدد الأشخاص'.tr(), '$persons', Icons.groups_rounded, Colors.orange, isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, MaterialColor color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        border: Border.all(color: isDark ? color.shade700.withValues(alpha: 0.3) : color.shade200),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: isDark ? 0.05 : 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isDark ? color.shade400 : color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : color.shade800)),
        ],
      ),
    );
  }

  Widget _buildPerfectTable(List<String> persons, Map<String, double> paid, double share, Map<String, double> balances, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.teal.shade800 : const Color(0xFF005C53), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Table(
          border: TableBorder.symmetric(
            inside: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2.5), 
            1: FlexColumnWidth(2.0), 
            2: FlexColumnWidth(2.0), 
            3: FlexColumnWidth(2.2), 
            4: FlexColumnWidth(1.8), 
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(color: isDark ? Colors.teal.shade900 : const Color(0xFF005C53)),
              children: [
                _tableHeaderCell('الشخص'.tr()),
                _tableHeaderCell('ما دفعه'.tr()),
                _tableHeaderCell('نصيبه'.tr()),
                _tableHeaderCell('الرصيد'.tr()),
                _tableHeaderCell('الحالة'.tr()),
              ],
            ),
            ...persons.map((person) {
              double bal = balances[person] ?? 0.0;
              bool isCreditor = bal > 0.01;
              bool isSettled = bal.abs() <= 0.01;

              return TableRow(
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white),
                children: [
                  _tableDataCell(person, isDark, isBold: true),
                  // 🔹 استخدام FormatHelper
                  _tableDataCell(FormatHelper.formatNumber(paid[person] ?? 0.0), isDark),
                  _tableDataCell(FormatHelper.formatNumber(share), isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
                    child: Text(
                      isSettled ? '0' : '${bal > 0 ? '+' : ''}${FormatHelper.formatNumber(bal.abs())}',
                      style: TextStyle(
                        color: isSettled ? Colors.grey : (isCreditor ? Colors.green.shade500 : Colors.red.shade400),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isSettled ? Colors.grey : (isCreditor ? Colors.green : Colors.red)).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isSettled ? 'خالص'.tr() : (isCreditor ? 'له'.tr() : 'عليه'.tr()),
                          style: TextStyle(
                            color: isSettled ? Colors.grey : (isCreditor ? Colors.green.shade500 : Colors.red.shade400),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableDataCell(String text, bool isDark, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          fontSize: 13,
          color: isDark ? Colors.white : Colors.black87,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSettlementsSection(List<Map<String, dynamic>> settlements, String currency, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.teal.withValues(alpha: 0.1) : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.teal.shade800 : Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sync_alt_rounded, color: isDark ? Colors.teal.shade400 : const Color(0xFF005C53)),
              const SizedBox(width: 8),
              Text('اقتراحات التسوية'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.teal.shade400 : const Color(0xFF005C53))),
            ],
          ),
          const SizedBox(height: 16),
          if (settlements.isEmpty)
            Text('لا توجد مبالغ مستحقة، جميع الحسابات خالصة!'.tr(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
          else
            ...settlements.map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.withValues(alpha: isDark ? 0.3 : 0.2), width: 1),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_rounded, color: isDark ? Colors.teal.shade400 : Colors.teal, size: 18),
                          const SizedBox(width: 6),
                          Text(s['from'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🔹 استخدام FormatHelper هنا
                          Text('${FormatHelper.formatNumber(s['amount'])} $currency', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.red.shade400 : Colors.redAccent, fontSize: 14)),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('يدفع إلى'.tr(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, color: isDark ? Colors.teal.shade400 : Colors.teal, size: 14),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s['to'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(width: 6),
                          Icon(Icons.person_outline_rounded, color: isDark ? Colors.purple.shade300 : Colors.purple, size: 18),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ExpenseProvider provider, double total, double share, Map<String, double> paid, Map<String, double> balances, List<Map<String, dynamic>> settlements, int transactions, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark ? [Colors.blue.shade700, Colors.blue.shade900] : [Colors.blue.shade400, Colors.blue.shade700],
          ),
          boxShadow: [
            BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
          ]
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await _generateAndSharePDF(context, provider, total, share, paid, balances, settlements, transactions);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text('مشاركة وحفظ PDF'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateAndSharePDF(BuildContext context, ExpenseProvider provider, double totalExpenses, double share, Map<String, double> paidAmounts, Map<String, double> balances, List<Map<String, dynamic>> settlements, int totalTransactions) async {
    final String currentLang = context.locale.languageCode;
    final bool isArabic = currentLang == 'ar';
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('جاري إنشاء التقرير الاحترافي...'.tr())));

    try {
      final pdf = pw.Document();
      
      final regularData = await rootBundle.load('assets/fonts/cairo_regular.ttf');
      final arabicFont = pw.Font.ttf(regularData);

      final boldData = await rootBundle.load('assets/fonts/cairo_bold.ttf');
      final arabicFontBold = pw.Font.ttf(boldData);

      pw.MemoryImage? logoImage;
      try {
        final ByteData data = await rootBundle.load('assets/images/logo.jpg');
        logoImage = pw.MemoryImage(data.buffer.asUint8List());
      } catch (e) {
        debugPrint('Logo not found, proceeding without it.');
      }

      final tealColor = PdfColor.fromHex('#008080');
      final darkBlueColor = PdfColor.fromHex('#1E3A8A');
      final redColor = PdfColor.fromHex('#D32F2F');
      final greenColor = PdfColor.fromHex('#388E3C');
      final lightGrey = PdfColor.fromHex('#F8F9FA');
      
      final pdfTextDirection = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          textDirection: pdfTextDirection, 
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
          footer: (pw.Context pwContext) {
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: pw.BoxDecoration(
                color: darkBlueColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('تطبيق قسمة - إدارة المصروفات المشتركة'.tr(), style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                  pw.Text('${DateFormat('dd-MM-yyyy hh:mm a', currentLang).format(DateTime.now())} | ${'صفحة'.tr()} ${pwContext.pageNumber} ${'من'.tr()} ${pwContext.pagesCount}', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                ]
              )
            );
          },
          build: (pw.Context pwContext) {
            return [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
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
                        pw.Text('${'تاريخ التقرير:'.tr()} ${DateFormat('dd-MM-yyyy', currentLang).format(DateTime.now())}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Divider(color: PdfColors.grey300, height: 8),
                        pw.Text('${'المجموعة:'.tr()} ${provider.groupName.tr()}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Divider(color: PdfColors.grey300, height: 8),
                        pw.Text('${'العملة:'.tr()} ${provider.currency.tr()}', style: const pw.TextStyle(fontSize: 9)),
                      ]
                    )
                  ),
                  pw.Column(
                    children: [
                      pw.Text('التقرير الشامل'.tr(), style: pw.TextStyle(font: arabicFontBold, fontSize: 22, color: darkBlueColor)),
                      pw.SizedBox(height: 4),
                      pw.Text('تطبيق قسمة للمصروفات'.tr(), style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                    ]
                  ),
                  if (logoImage != null)
                    pw.Image(logoImage, width: 70, height: 70)
                  else
                    pw.SizedBox(width: 70), 
                ],
              ),
              
              pw.SizedBox(height: 24),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPdfStatCard('عدد الأشخاص'.tr(), '${provider.persons.length}', 'أشخاص'.tr(), arabicFontBold, tealColor),
                  _buildPdfStatCard('عدد العمليات'.tr(), '$totalTransactions', 'عملية'.tr(), arabicFontBold, PdfColor.fromHex('#6A1B9A')),
                  // 🔹 استخدام FormatHelper لـ PDF
                  _buildPdfStatCard('نصيب الفرد'.tr(), FormatHelper.formatNumber(share), provider.currency.tr(), arabicFontBold, PdfColor.fromHex('#1565C0')),
                  _buildPdfStatCard('إجمالي المصروفات'.tr(), FormatHelper.formatNumber(totalExpenses), provider.currency.tr(), arabicFontBold, greenColor),
                ]
              ),
              
              pw.SizedBox(height: 24),
              pw.Text('تفاصيل الحسابات والأرصدة'.tr(), style: pw.TextStyle(font: arabicFontBold, fontSize: 16, color: tealColor)),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: tealColor),
                    children: [
                      'الشخص'.tr(), 'ما دفعه'.tr(), 'نصيبه المفترض'.tr(), 'الرصيد النهائي'.tr(), 'الحالة'.tr()
                    ].map((t) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4), 
                      child: pw.Text(t, style: pw.TextStyle(color: PdfColors.white, font: arabicFontBold, fontSize: 11), textAlign: pw.TextAlign.center)
                    )).toList(),
                  ),
                  ...provider.persons.map((person) {
                    double bal = balances[person] ?? 0.0;
                    bool isCreditor = bal > 0.01;
                    bool isSettled = bal.abs() <= 0.01;
                    
                    return pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.white),
                      children: [
                        _pdfTableCell(person, arabicFontBold),
                        // 🔹 استخدام FormatHelper لـ PDF
                        _pdfTableCell(FormatHelper.formatNumber(paidAmounts[person] ?? 0.0), arabicFontBold),
                        _pdfTableCell(FormatHelper.formatNumber(share), arabicFontBold),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Text(
                            isSettled ? '0.00' : '${bal > 0 ? '+' : ''}${FormatHelper.formatNumber(bal.abs())}', 
                            style: pw.TextStyle(font: arabicFontBold, fontSize: 11, color: isSettled ? PdfColors.grey : (isCreditor ? greenColor : redColor)), 
                            textAlign: pw.TextAlign.center
                          )
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(isSettled ? 'خالص'.tr() : (isCreditor ? 'له'.tr() : 'عليه'.tr()), style: pw.TextStyle(font: arabicFontBold, fontSize: 11, color: isSettled ? PdfColors.grey : (isCreditor ? greenColor : redColor))),
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

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
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
                          pw.Text('اقتراحات التسوية'.tr(), style: pw.TextStyle(font: arabicFontBold, fontSize: 14, color: greenColor)),
                          pw.SizedBox(height: 10),
                          if (settlements.isEmpty)
                            pw.Text('لا توجد تسويات مطلوبة.'.tr(), style: const pw.TextStyle(color: PdfColors.grey))
                          else
                            ...settlements.map((s) => pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 8),
                              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(8),
                                border: pw.Border.all(color: greenColor, width: 0.5),
                              ),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(s['from'], style: pw.TextStyle(font: arabicFontBold, fontSize: 12)),
                                  pw.Column(
                                    children: [
                                      // 🔹 استخدام FormatHelper لـ PDF
                                      pw.Text('${FormatHelper.formatNumber(s['amount'])} ${provider.currency.tr()}', style: pw.TextStyle(font: arabicFontBold, color: redColor, fontSize: 11)),
                                      pw.SizedBox(height: 2),
                                      pw.Text('يدفع إلى'.tr(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                                    ]
                                  ),
                                  pw.Text(s['to'], style: pw.TextStyle(font: arabicFontBold, fontSize: 12)),
                                ]
                              )
                            )),
                        ]
                      )
                    )
                  ),
                  pw.SizedBox(width: 16),
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
                          pw.Text('ملاحظات'.tr(), style: pw.TextStyle(font: arabicFontBold, fontSize: 14, color: darkBlueColor)),
                          pw.SizedBox(height: 10),
                          _pdfNoteItem('جميع المبالغ محسوبة بناءً على إجمالي المصروفات.'.tr(), darkBlueColor),
                          _pdfNoteItem('الأرصدة الموجبة (له) تعني أن الشخص يستحق مبلغاً.'.tr(), darkBlueColor),
                          _pdfNoteItem('الأرصدة السالبة (عليه) تعني أن الشخص مدين بمبلغ.'.tr(), darkBlueColor),
                          _pdfNoteItem('يمكنك مشاركة هذا التقرير كملف PDF مع الأعضاء.'.tr(), darkBlueColor),
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
        filename: '${'تقرير_قسمة_'.tr()}${provider.groupName.tr()}.pdf',
      );

    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${'حدث خطأ أثناء إعداد الـ PDF: '.tr()}$e')));
    }
  }

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
            margin: const pw.EdgeInsets.only(top: 3, left: 6, right: 6),
            width: 6, height: 6, 
            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: color)
          ),
          pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 9, color: PdfColors.black))),
        ]
      )
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : const Color(0xFF1E3A8A),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تطبيق قسمة للمصروفات'.tr(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Qesma Expenses v1.0', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('تم الإنشاء'.tr(), style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 4),
              Text(DateFormat('dd-MM-yyyy hh:mm a', context.locale.languageCode).format(DateTime.now()), style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}