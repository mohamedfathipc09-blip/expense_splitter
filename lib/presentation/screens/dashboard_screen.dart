import 'dart:ui' as ui; // 🔹 تم الإضافة لحل تعارض TextDirection
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'report_screen.dart';
import 'settings_screen.dart';
import 'settlement_screen.dart';
import 'add_expense_screen.dart';
import 'persons_management_screen.dart';
import 'transactions_screen.dart';
import 'privacy_policy_screen.dart'; 
import 'statistics_screen.dart'; 
import 'notifications_screen.dart'; 
import '../providers/expense_provider.dart';
import '../../core/helpers/format_helper.dart'; // 🔹 استدعاء ملف تنسيق الأرقام

// ==========================================
// 1. MAIN DASHBOARD SCREEN (شريط سفلي ثابت)
// ==========================================
class QesmaDashboardScreen extends StatefulWidget {
  const QesmaDashboardScreen({super.key});

  @override
  State<QesmaDashboardScreen> createState() => _QesmaDashboardScreenState();
}

class _QesmaDashboardScreenState extends State<QesmaDashboardScreen> {
  int _currentIndex = 1; // 1 = الرئيسية

  final List<Widget> _screens = [
    const TransactionsScreen(), // Index 0
    const _HomeTab(),           // Index 1 (الرئيسية)
    const StatisticsScreen(),   // Index 2
    const ReportScreen(),       // Index 3
  ];

  Widget _buildNavItem({
    required IconData icon, 
    required IconData activeIcon, 
    required String label, 
    required int index, 
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon, 
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      endDrawer: _buildDrawer(context, theme),
      
      bottomNavigationBar: Container(
        height: 75,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'الرئيسية'.tr(), index: 1, context: context),
            _buildNavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'العمليات'.tr(), index: 0, context: context),
            
            // 🔹 زر الإضافة الدائري العائم المدمج
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 28),
              ),
            ),
            
            _buildNavItem(icon: Icons.pie_chart_outline, activeIcon: Icons.pie_chart, label: 'الإحصائيات'.tr(), index: 2, context: context),
            _buildNavItem(icon: Icons.picture_as_pdf_outlined, activeIcon: Icons.picture_as_pdf, label: 'التقارير'.tr(), index: 3, context: context),
          ],
        ),
      ),
      
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }

  // 🔹 القائمة الجانبية (Drawer) 
  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    final bool isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded, 
                        color: isDark ? theme.colorScheme.onSurface : Colors.white, 
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'قسمة المصاريف'.tr(), 
                        style: TextStyle(
                          color: isDark ? theme.colorScheme.onSurface : Colors.white, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface),
                  title: Text('الإعدادات'.tr(), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(context); 
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined, color: theme.colorScheme.onSurface),
                  title: Text('سياسة الخصوصية'.tr(), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.email_outlined, color: theme.colorScheme.onSurface),
                  title: Text('تواصل معنا'.tr(), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  onTap: () async {
                    Navigator.pop(context); 
                    final Uri emailUri = Uri.parse("mailto:mohamedfathipc09@gmail.com?subject=تطبيق قسمة المصاريف");
                    try {
                      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('لا يوجد تطبيق بريد إلكتروني مثبت'.tr())),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Qesma Expenses', 
                  style: TextStyle(
                    fontWeight: FontWeight.w800, 
                    color: isDark ? Colors.grey.shade400 : Colors.blueGrey, 
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade600 : Colors.grey)),
                const SizedBox(height: 16),
                Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.terminal, color: isDark ? Colors.tealAccent : Colors.teal, size: 16),
                      const SizedBox(width: 6),
                      Text('Developed by ', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade500 : Colors.grey)),
                      Text(
                        'Mohamed Fathi', 
                        style: TextStyle(
                          fontSize: 13, 
                          fontWeight: FontWeight.w900, 
                          color: isDark ? Colors.tealAccent : Colors.teal,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 2. HOME TAB (الصفحة الرئيسية)
// ==========================================
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: _HeaderSection(
              provider: provider, 
              onNotificationTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
              },
            ),
          ), 
          SliverPadding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _MainCardsSection(provider: provider),
                const SizedBox(height: 24),
                _StatisticsGridSection(provider: provider),
                const SizedBox(height: 24),
                _QuickActionsSection(), 
                const SizedBox(height: 24),
                _SmartAlertsSection(provider: provider),
                const SizedBox(height: 24),
                _SettlementSuggestionSection(provider: provider),
                const SizedBox(height: 24),
                _RecentTransactionsSection(provider: provider),
                const SizedBox(height: 24),
                _PeopleBalancesSection(provider: provider),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. HEADER SECTION (تعديل اللوجو العائم)
// ==========================================
class _HeaderSection extends StatelessWidget {
  final ExpenseProvider provider;
  final VoidCallback onNotificationTap; 
  
  const _HeaderSection({required this.provider, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    final alertsCount = provider.isAlertsRead ? 0 : provider.smartAlerts.length; 
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeInSlide(
      delay: 0,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
        child: Row(
          children: [
            // 🔹 أيقونة المجموعة الاحترافية (Logo Style)
            Hero(
              tag: 'app_logo',
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? Colors.teal.shade700 : Colors.teal.shade400,
                      isDark ? Colors.blue.shade900 : Colors.blue.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.groupName.tr(), 
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${'دورة:'.tr()} ${DateFormat('MMMM yyyy', context.locale.languageCode).format(DateTime.now())}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Badge(
                isLabelVisible: alertsCount > 0, 
                label: Text('$alertsCount'),
                backgroundColor: Colors.redAccent,
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () {
                provider.markAlertsAsRead();
                onNotificationTap(); 
              }, 
            ),
            IconButton(
              icon: const Icon(Icons.menu_rounded), 
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. MAIN CARDS
// ==========================================
class _MainCardsSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _MainCardsSection({required this.provider});

  void _showBudgetDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: provider.targetBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تحديد الميزانية'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'المبلغ'.tr(),
              suffixText: provider.currency.tr(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'.tr()),
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
              child: Text('حفظ'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses = provider.allExpenses.fold(0, (sum, item) => sum + item.amount);
    
    double targetBudget = provider.targetBudget;
    double progressValue = targetBudget > 0 ? (totalExpenses / targetBudget).clamp(0.0, 1.0) : 0.0;
    int percentage = (progressValue * 100).toInt();

    return FadeInSlide(
      delay: 0.1,
      child: Row(
        children: [
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
                        const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('إجمالي المصروفات'.tr(), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      child: Text(
                        // 🔹 استخدام FormatHelper هنا
                        '${FormatHelper.formatNumber(totalExpenses)} ${provider.currency.tr()}', 
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text('مؤشر الصرف في ازدياد'.tr(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                  onTap: () => _showBudgetDialog(context), 
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
                                  const SizedBox(width: 6),
                                  Text('الميزانية'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'الاستهلاك'.tr(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                child: Text(
                                  // 🔹 استخدام FormatHelper هنا
                                  '${'من هدف'.tr()} ${FormatHelper.formatNumber(targetBudget)}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '(اضغط لضبط الميزانية)'.tr(),
                                style: TextStyle(
                                  color: Colors.teal.shade300, 
                                  fontSize: 8, 
                                  fontWeight: FontWeight.bold,
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
                                  progressValue > 0.8 ? Colors.redAccent : Theme.of(context).colorScheme.primary,
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
// 5. STATISTICS GRID
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
              _StatCard(width: width, title: 'الأشخاص'.tr(), value: '$personsCount', icon: Icons.group_rounded, color: Colors.blue),
              _StatCard(width: width, title: 'العمليات'.tr(), value: '$operationsCount', icon: Icons.receipt_long_rounded, color: Colors.orange),
              // 🔹 استخدام FormatHelper هنا
              _StatCard(width: width, title: 'متوسط العملية'.tr(), value: '${FormatHelper.formatNumber(average)} ${provider.currency.tr()}', icon: Icons.calculate_rounded, color: Colors.purple),
              _StatCard(width: width, title: 'أيام الدورة'.tr(), value: '$cycleDays ${'يوم'.tr()}', icon: Icons.calendar_month_rounded, color: Colors.teal),
            ],
          );
        },
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
                decoration: BoxDecoration(color: color.shade100.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? color.shade300 : color.shade700, size: 20),
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
// 6. QUICK ACTIONS
// ==========================================
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeInSlide(
      delay: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'الإجراءات السريعة'.tr()),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionItem(icon: Icons.people_alt_rounded, label: 'الأشخاص'.tr(), onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonsManagementScreen()));
              }),
              _ActionItem(icon: Icons.handshake_rounded, label: 'مخالصة'.tr(), onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettlementScreen()));
              }),
              _ActionItem(icon: Icons.bar_chart_rounded, label: 'التقارير'.tr(), onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportScreen()));
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Material(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: Icon(icon, color: colorScheme.onSurface),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ==========================================
// 7. SMART ALERTS 
// ==========================================
class _SmartAlertsSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _SmartAlertsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final alerts = provider.smartAlerts;
    if (alerts.isEmpty) return const SizedBox.shrink(); 

    return FadeInSlide(
      delay: 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'التنبيهات الذكية'.tr()),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final List<String> args = alert['args'] as List<String>? ?? [];
                
                final String finalTitle = (alert['titleKey'] ?? alert['title'] ?? '').toString();
                final String finalSubtitle = (alert['subtitleKey'] ?? alert['subtitle'] ?? '').toString();
                
                return _AlertCard(
                  icon: alert['icon'] as IconData? ?? Icons.notifications,
                  title: finalTitle.tr(args: args),
                  subtitle: finalSubtitle.tr(args: args),
                  color: alert['color'] as MaterialColor? ?? Colors.blue,
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
// 8. SETTLEMENT SUGGESTION
// ==========================================
class _SettlementSuggestionSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _SettlementSuggestionSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final settlements = provider.settlementTransactions;
    if (settlements.isEmpty) return const SizedBox.shrink();

    final suggestion = settlements.first;
    // 🔹 استخدام FormatHelper هنا
    final amount = FormatHelper.formatNumber(suggestion['amount'] as double);
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
                  Icon(Icons.lightbulb_rounded, color: Theme.of(context).colorScheme.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Text('اقتراح تسوية سريع'.tr(), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text('$from ${'يدفع'.tr()} $amount ${provider.currency.tr()} ${'لـ'.tr()} $to ${'لتسوية جزء من الرصيد.'.tr()}', 
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.tonal(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const SettlementScreen()),
                    );
                  },
                  child: Text('عرض التسويات'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
// 9. RECENT TRANSACTIONS
// ==========================================
class _RecentTransactionsSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _RecentTransactionsSection({required this.provider});

  IconData _getCategoryIcon(String category) {
    if (category.contains('طعام') || category.contains('أكل')) return Icons.fastfood_rounded;
    if (category.contains('سكن') || category.contains('فندق')) return Icons.hotel_rounded;
    if (category.contains('مواصلات') || category.contains('سيارة')) return Icons.directions_car_rounded;
    if (category.contains('تسوق') || category.contains('شراء')) return Icons.shopping_bag_rounded;
    return Icons.receipt_long_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final recentExpenses = provider.expenses.take(5).toList();

    return FadeInSlide(
      delay: 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle(title: 'آخر العمليات'.tr()),
              if (recentExpenses.isNotEmpty)
                TextButton(onPressed: () {}, child: Text('عرض الكل'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          if (recentExpenses.isEmpty)
             Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('لا توجد عمليات مضافة حتى الآن.'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
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
                  subtitle: Text('${expense.category.tr()} • ${'دفع:'.tr()} ${expense.payer} • ${DateFormat('d MMM', context.locale.languageCode).format(expense.date)}'),
                  // 🔹 استخدام FormatHelper هنا
                  trailing: Text('${FormatHelper.formatNumber(expense.amount)} ${provider.currency.tr()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  onTap: () {}, 
                );
              },
            ),
        ],
      ),
    );
  }
}

// ==========================================
// 10. PEOPLE BALANCES
// ==========================================
class _PeopleBalancesSection extends StatelessWidget {
  final ExpenseProvider provider;
  const _PeopleBalancesSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    double totalExpenses = provider.allExpenses.fold(0, (sum, item) => sum + item.amount);
    double sharePerPerson = provider.persons.isNotEmpty ? totalExpenses / provider.persons.length : 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeInSlide(
      delay: 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'أرصدة الأشخاص'.tr()),
          const SizedBox(height: 12),
          if (provider.persons.isEmpty)
             Center(child: Text('قم بإضافة أشخاص للمجموعة لعرض الأرصدة.'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))
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
                  margin: const EdgeInsets.only(bottom: 10),
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1), // ✅ تم التعديل هنا
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // 🔹 تعديل الحرف ليكون بشكل احترافي Premium Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.8),
                                theme.colorScheme.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            person.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(person, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 2),
                              // 🔹 استخدام FormatHelper هنا
                              Text('${'دفع:'.tr()} ${FormatHelper.formatNumber(paid)} ${provider.currency.tr()} • ${'نصيبه:'.tr()} ${FormatHelper.formatNumber(sharePerPerson)}', 
                                style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 🔹 استخدام FormatHelper هنا
                            Text('${FormatHelper.formatNumber(balance.abs())} ${provider.currency.tr()}', 
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isOwed ? Colors.green.shade500 : Colors.red.shade400)
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isOwed ? Colors.green : Colors.red).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(isOwed ? 'له'.tr() : 'عليه'.tr(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isOwed ? Colors.green.shade500 : Colors.red.shade400)),
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
// 11. REUSABLE COMPONENTS & ANIMATIONS
// ==========================================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
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