import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/expense_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);
    
    double totalExpenses = provider.allExpenses.fold(0, (sum, item) => sum + item.amount);
    
    // حساب مدفوعات كل شخص
    Map<String, double> payments = {};
    for (var person in provider.persons) {
      payments[person] = provider.allExpenses.where((e) => e.payer == person).fold(0, (sum, item) => sum + item.amount);
    }

    // استخراج الأكثر والأقل دفعاً
    String maxPayer = "-";
    String minPayer = "-";
    if (payments.isNotEmpty && totalExpenses > 0) {
      var sortedEntries = payments.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      maxPayer = sortedEntries.first.key;
      minPayer = sortedEntries.last.key;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('إحصائيات المجموعة'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: provider.persons.isEmpty
        ? Center(child: Text('لا توجد بيانات لعرضها'.tr(), style: TextStyle(color: Colors.grey.shade600)))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('مؤشرات المجموعة'.tr(), theme),
                const SizedBox(height: 12),
                _buildGroupIndicators(provider, totalExpenses, maxPayer, minPayer, theme),
                
                const SizedBox(height: 32),
                _buildSectionTitle('مؤشر مشاركة المصروفات'.tr(), theme),
                const SizedBox(height: 16),
                _buildShareBars(payments, totalExpenses, theme, provider.currency),
                
                const SizedBox(height: 32),
                _buildSectionTitle('تفاصيل مساهمة الأشخاص'.tr(), theme),
                const SizedBox(height: 12),
                _buildPersonDetailsList(payments, totalExpenses, theme, provider.currency),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
    );
  }

  Widget _buildGroupIndicators(ExpenseProvider provider, double total, String maxPayer, String minPayer, ThemeData theme) {
    int operations = provider.allExpenses.length;
    double avg = operations > 0 ? total / operations : 0;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _IndicatorCard(title: 'العمليات'.tr(), value: '$operations', icon: Icons.receipt, color: Colors.orange, width: 160),
        _IndicatorCard(title: 'المتوسط'.tr(), value: '${avg.toStringAsFixed(0)} ${provider.currency.tr()}', icon: Icons.calculate, color: Colors.purple, width: 160),
        _IndicatorCard(title: 'الأكثر دفعاً'.tr(), value: maxPayer, icon: Icons.keyboard_double_arrow_up, color: Colors.green, width: 160),
        _IndicatorCard(title: 'الأقل دفعاً'.tr(), value: minPayer, icon: Icons.keyboard_double_arrow_down, color: Colors.red, width: 160),
      ],
    );
  }

  Widget _buildShareBars(Map<String, double> payments, double total, ThemeData theme, String currency) {
    if (total == 0) return const Center(child: Text('لا توجد مصروفات بعد'));
    
    return Column(
      children: payments.entries.map((entry) {
        double percentage = (entry.value / total);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${(percentage * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 12,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: _getColorForPercentage(percentage),
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPersonDetailsList(Map<String, double> payments, double total, ThemeData theme, String currency) {
    return Column(
      children: payments.entries.map((entry) {
        double percentage = total > 0 ? (entry.value / total) * 100 : 0;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorForPercentage(entry.value/total).withValues(alpha: 0.2),
              child: Text(entry.key.substring(0, 1), style: TextStyle(color: _getColorForPercentage(entry.value/total), fontWeight: FontWeight.bold)),
            ),
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('المساهمة: ${percentage.toStringAsFixed(1)}%'.tr()),
            trailing: Text('${entry.value.toStringAsFixed(0)} ${currency.tr()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForPercentage(double percent) {
    if (percent >= 0.5) return Colors.green;
    if (percent >= 0.2) return Colors.blue;
    if (percent > 0) return Colors.orange;
    return Colors.red;
  }
}

class _IndicatorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const _IndicatorCard({required this.title, required this.value, required this.icon, required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}