import 'package:easy_localization/easy_localization.dart';
import 'report_screen.dart';
import 'archive_screen.dart';
import 'settings_screen.dart';
import 'settlement_screen.dart';
import 'add_expense_screen.dart';
import 'persons_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import 'transactions_screen.dart';

// ==========================================
// 1. MAIN DASHBOARD SCREEN
// ==========================================
class QesmaDashboardScreen extends StatefulWidget {
  const QesmaDashboardScreen({super.key});

  @override
  State<QesmaDashboardScreen> createState() => _QesmaDashboardScreenState();
}

class _QesmaDashboardScreenState extends State<QesmaDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // الاستماع للبيانات الحقيقية باستخدام context.watch الخاص بمكتبة Provider
    final provider = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      
      // 🔹 إضافة القائمة الجانبية (الثلاث شرط) هنا
      // 🔹 التعديل هنا: تغيير drawer إلى endDrawer
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // تصميم رأس القائمة 
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text('قسمة المصاريف', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // ... (هنا يكمل باقي كود القائمة الخاص بك)
            
            // زر الإعدادات
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.black87),
              title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context); // إغلاق القائمة الجانبية أولاً
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            
            // يمكنك إضافة المزيد من الأزرار هنا لاحقاً بنفس طريقة ListTile
          ],
        ),
      ),

      // Bottom Navigation Bar
     bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 0) return; // البقاء في الرئيسية

          // الانتقال لشاشة العمليات 
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen()));
          }
          // الانتقال لشاشة التقارير
          else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportScreen()));
          }
          
          // تأكيد عودة المؤشر للرئيسية
          setState(() => _currentIndex = 0);
        },
        elevation: 0,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        indicatorColor: theme.colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'العمليات'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'الإحصائيات'),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            const SliverToBoxAdapter(child: _HeaderSection()),
            
            // Main Content
            SliverPadding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _MainCardsSection(provider: provider),
                  const SizedBox(height: 24),
                  _StatisticsGridSection(provider: provider),
                  const SizedBox(height: 24),
                  const _QuickActionsSection(),
                  const SizedBox(height: 24),
                  _SmartAlertsSection(provider: provider),
                  const SizedBox(height: 24),
                  _SettlementSuggestionSection(provider: provider),
                  const SizedBox(height: 24),
                  _RecentTransactionsSection(provider: provider),
                  const SizedBox(height: 24),
                  _PeopleBalancesSection(provider: provider),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. HEADER SECTION
// ==========================================
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return FadeInSlide(
      delay: 0,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
        child: Row(
          children: [
            Hero(
              tag: 'user_avatar',
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.group, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المجموعة الحالية', // يمكن ربطها لاحقاً باسم الرحلة
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'دورة: ${DateFormat('MMMM yyyy', 'ar').format(DateTime.now())}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Badge(child: Icon(Icons.notifications_outlined)),
              onPressed: () {},
            ),
            // زر الثلاث شرط (القائمة)
            IconButton(
              icon: const Icon(Icons.menu), 
              onPressed: () {
                // فتح القائمة الجانبية (Drawer) بدلاً من الانتقال المباشر
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }
}
// 3. MAIN CARDS (With Dynamic Target Budget)
// ==========================================
// ==========================================
// 3. MAIN CARDS (With Dynamic Target Budget)
// ==========================================
class _MainCardsSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _MainCardsSection({required this.provider});

  // نافذة تغيير الميزانية
  void _showBudgetDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: provider.targetBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تحديد الميزانية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'المبلغ',
              suffixText: provider.currency,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  double? newBudget = double.tryParse(controller.text);
                  if (newBudget != null && newBudget > 0) {
                    provider.setTargetBudget(newBudget);
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses = provider.allExpenses.fold(0, (sum, item) => sum + item.amount);
    
    // جلب الميزانية الديناميكية من الـ Provider
    double targetBudget = provider.targetBudget;
    double progressValue = totalExpenses > 0 ? (totalExpenses / targetBudget).clamp(0.0, 1.0) : 0.0;
    int percentage = (progressValue * 100).toInt();

    return FadeInSlide(
      delay: 0.1,
      child: Row(
        children: [
          // 1. كارت إجمالي المصروفات
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4364F7).withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('إجمالي المصروفات', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      child: Text(
                        '${totalExpenses.toStringAsFixed(0)} ${provider.currency}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (totalExpenses > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('مؤشر الصرف في ازدياد', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 2. كارت مؤشر الاستهلاك (ديناميكي وقابل للضغط)
         Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                    : Colors.white,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _showBudgetDialog(context), // فتح نافذة تغيير الميزانية عند الضغط
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pie_chart_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text('الميزانية', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'الاستهلاك',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                child: Text(
                                  'من هدف ${targetBudget.toStringAsFixed(0)}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '(اضغط لضبط الميزانية)',
                                style: TextStyle(
                                  color: Colors.teal.shade300, 
                                  fontSize: 8, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 55,
                          width: 55,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: progressValue,
                                strokeWidth: 6,
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progressValue > 0.8 ? Colors.redAccent : Theme.of(context).colorScheme.primary
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                              Center(
                                child: Text(
                                  '$percentage%',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. STATISTICS GRID
// ==========================================
class _StatisticsGridSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _StatisticsGridSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    int personsCount = provider.persons.length;
    int operationsCount = provider.allExpenses.length;
    double totalExpenses = provider.allExpenses.fold(0, (sum, item) => sum + item.amount);
    double average = operationsCount > 0 ? totalExpenses / operationsCount : 0;
    
    // حساب عدد الأيام منذ أول عملية
    int cycleDays = 0;
    if (provider.allExpenses.isNotEmpty) {
      DateTime firstDate = provider.allExpenses.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
      cycleDays = DateTime.now().difference(firstDate).inDays;
      if (cycleDays == 0) cycleDays = 1;
    }

    return FadeInSlide(
      delay: 0.2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(width: width, title: 'الأشخاص', value: '$personsCount', icon: Icons.group, color: Colors.blue),
              _StatCard(width: width, title: 'العمليات', value: '$operationsCount', icon: Icons.receipt, color: Colors.orange),
              _StatCard(width: width, title: 'متوسط العملية', value: '${average.toStringAsFixed(0)} ${provider.currency}', icon: Icons.calculate, color: Colors.purple),
              _StatCard(width: width, title: 'أيام الدورة', value: '$cycleDays يوم', icon: Icons.calendar_month, color: Colors.teal),
            ],
          );
        }
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final double width;
  final String title, value;
  final IconData icon;
  final MaterialColor color;

  const _StatCard({required this.width, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.shade100, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. QUICK ACTIONS (تم التفعيل)
// ==========================================
// ==========================================
// 5. QUICK ACTIONS
// ==========================================
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return FadeInSlide(
      delay: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'الإجراءات السريعة'),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _ActionItem(icon: Icons.add, label: 'إضافة', isPrimary: true, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
                }),
                _ActionItem(icon: Icons.people_alt_outlined, label: 'الأشخاص', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonsManagementScreen()));
                }),
                // 🔹 زر المخالصة الجديد الذي قمنا بإضافته
                _ActionItem(icon: Icons.handshake_outlined, label: 'مخالصة', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettlementScreen()));
                }),
                //  🔹 تفعيل زر الإحصائيات (تقرير PDF)
                _ActionItem(icon: Icons.bar_chart, label: 'التقارير', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportScreen()));
                }),
                // 🔹 تفعيل زر الأرشيف
                _ActionItem(icon: Icons.folder_outlined, label: 'الأرشيف', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ArchiveScreen()));
                }),
                // 🔹 تفعيل زر النسخ الاحتياطي
                _ActionItem(icon: Icons.cloud_upload_outlined, label: 'نسخ احتياطي', onTap: () {
                  // إظهار رسالة سريعة تفيد بأن النسخ الاحتياطي يتم من الإعدادات
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يمكنك إدارة النسخ الاحتياطي من شاشة الإعدادات', style: TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: Colors.teal,
                      behavior: SnackBarBehavior.floating,
                    )
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionItem({required this.icon, required this.label, this.isPrimary = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Column(
        children: [
          Material(
            color: isPrimary ? colorScheme.primary : colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: Icon(icon, color: isPrimary ? colorScheme.onPrimary : colorScheme.onSurface),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

// ==========================================
// 6. SMART ALERTS
// ==========================================
class _SmartAlertsSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _SmartAlertsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final alerts = provider.smartAlerts;
    if (alerts.isEmpty) return const SizedBox.shrink(); // إخفاء إذا لم تكن هناك تنبيهات

    return FadeInSlide(
      delay: 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'التنبيهات الذكية'),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _AlertCard(
                  icon: alert['icon'] as IconData,
                  title: alert['title'] as String,
                  subtitle: alert['subtitle'] as String,
                  color: alert['color'] as MaterialColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final MaterialColor color;

  const _AlertCard({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark ? color.withValues(alpha: 0.1) : color.shade50,
      margin: const EdgeInsetsDirectional.only(end: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withValues(alpha: 0.3), width: 1)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? color.shade200 : color.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : color.shade900, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : color.shade800, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. SETTLEMENT SUGGESTION
// ==========================================
class _SettlementSuggestionSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _SettlementSuggestionSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final settlements = provider.settlementTransactions;
    if (settlements.isEmpty) return const SizedBox.shrink();

    // جلب أول اقتراح تسوية
    final suggestion = settlements.first;
    final amount = (suggestion['amount'] as double).toStringAsFixed(0);
    final from = suggestion['from'] as String;
    final to = suggestion['to'] as String;

    return FadeInSlide(
      delay: 0.5,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.tertiaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Text('اقتراح تسوية سريع', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text('$from يدفع $amount ${provider.currency} لـ $to لتسوية جزء من الرصيد.', 
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer)),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.tonal(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const SettlementScreen())
                    );
                    // الانتقال لشاشة التسويات
                  },
                  child: const Text('عرض التسويات'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 8. RECENT TRANSACTIONS
// ==========================================
class _RecentTransactionsSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _RecentTransactionsSection({required this.provider});

  // دالة لاختيار الأيقونة بناءً على التصنيف
  IconData _getCategoryIcon(String category) {
    if (category.contains('طعام') || category.contains('أكل')) return Icons.fastfood;
    if (category.contains('سكن') || category.contains('فندق')) return Icons.hotel;
    if (category.contains('مواصلات') || category.contains('سيارة')) return Icons.directions_car;
    if (category.contains('تسوق') || category.contains('شراء')) return Icons.shopping_bag;
    return Icons.receipt_long;
  }

  @override
  Widget build(BuildContext context) {
    // جلب آخر 5 عمليات فقط
    final recentExpenses = provider.expenses.take(5).toList();

    return FadeInSlide(
      delay: 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionTitle(title: 'آخر العمليات'),
              if (recentExpenses.isNotEmpty)
                TextButton(onPressed: () {}, child: const Text('عرض الكل')),
            ],
          ),
          if (recentExpenses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('لا توجد عمليات مضافة حتى الآن.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentExpenses.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final expense = recentExpenses[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(_getCategoryIcon(expense.category), color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${expense.category} • دفع: ${expense.payer} • ${DateFormat('d MMM', 'ar').format(expense.date)}'),
                  trailing: Text('${expense.amount.toStringAsFixed(0)} ${provider.currency}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  onTap: () {}, // Ripple
                );
              },
            ),
        ],
      ),
    );
  }
}

// ==========================================
// 9. PEOPLE BALANCES
// ==========================================
class _PeopleBalancesSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _PeopleBalancesSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    double totalExpenses = provider.allExpenses.fold(0, (sum, item) => sum + item.amount);
    double sharePerPerson = provider.persons.isNotEmpty ? totalExpenses / provider.persons.length : 0;

    return FadeInSlide(
      delay: 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'أرصدة الأشخاص'),
          const SizedBox(height: 12),
          if (provider.persons.isEmpty)
            const Center(child: Text('قم بإضافة أشخاص للمجموعة لعرض الأرصدة.'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.persons.length,
              itemBuilder: (context, index) {
                String person = provider.persons[index];
                double paid = provider.allExpenses.where((e) => e.payer == person).fold(0, (sum, item) => sum + item.amount);
                double balance = paid - sharePerPerson;
                bool isOwed = balance >= 0;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(person.substring(0, 1), style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(person, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('دفع: ${paid.toStringAsFixed(0)} • نصيبه: ${sharePerPerson.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${balance.abs().toStringAsFixed(0)} ${provider.currency}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isOwed ? Colors.green : Colors.red)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isOwed ? Colors.green : Colors.red).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(isOwed ? 'له' : 'عليه', style: TextStyle(fontSize: 10, color: isOwed ? Colors.green : Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ==========================================
// 10. REUSABLE COMPONENTS & ANIMATIONS
// ==========================================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class FadeInSlide extends StatefulWidget {
  final Widget child;
  final double delay;

  const FadeInSlide({super.key, required this.child, required this.delay});

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}