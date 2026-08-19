import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'report_screen.dart';
import 'persons_management_screen.dart';
import 'settlement_screen.dart';
import 'archive_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // الرئيسية هي الافتراضية

  final List<Widget> _screens = const [
    SettingsScreen(),
    ArchiveScreen(),
    _DashboardTab(), 
    ReportScreen(),
    _ExpensesListTab(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        
        appBar: _currentIndex == 2
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.black87),
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black87),
                  onPressed: () {}, 
                ),
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('مرحباً', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)),
                    SizedBox(width: 8),
                    Text('👋', style: TextStyle(fontSize: 20)),
                  ],
                ),
                centerTitle: true,
                actions: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_outlined, size: 28, color: Colors.black87),
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 8.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  )
                ],
              )
            : null,

        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),

        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: Colors.teal.withValues(alpha: 0.2),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings, color: Colors.teal), label: 'الإعدادات'),
            NavigationDestination(icon: Icon(Icons.archive_outlined), selectedIcon: Icon(Icons.archive, color: Colors.teal), label: 'الأرشيف'),
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Colors.teal), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart, color: Colors.teal), label: 'الإحصائيات'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long, color: Colors.teal), label: 'العمليات'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// الشاشة الرئيسية (Dashboard)
// ==========================================
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        double totalExpenses = provider.expenses.fold(0, (sum, item) => sum + item.amount);
        int totalTransactions = provider.expenses.length;
        int totalPersons = provider.persons.length;
        double avgTransaction = totalTransactions > 0 ? totalExpenses / totalTransactions : 0;
        double sharePerPerson = totalPersons > 0 ? totalExpenses / totalPersons : 0;

        // حساب الأرصدة الفعلية لترتيب الأشخاص (الأعلى رصيداً أولاً)
        Map<String, double> balances = {};
        for (var p in provider.persons) {
          double paid = provider.expenses.where((e) => e.payer == p).fold(0, (sum, item) => sum + item.amount);
          balances[p] = paid - sharePerPerson;
        }
        
        List<String> sortedPersons = List.from(provider.persons);
        sortedPersons.sort((a, b) => (balances[b] ?? 0).compareTo(balances[a] ?? 0));

        // جلب التنبيهات الذكية
        List<Map<String, dynamic>> alerts = provider.smartAlerts;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // تاريخ الدورة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.teal, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'الدورة الحالية: ${DateFormat('MMMM yyyy', 'ar').format(DateTime.now())}', 
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // الكروت العلوية 
                    Row(
                      children: [
                        Expanded(
                          child: _buildMainCard(
                            context,
                            title: 'إجمالي المصروفات',
                            amount: totalExpenses.toStringAsFixed(2),
                            subtitle: 'الشهر الحالي',
                            isPrimary: true,
                            icon: Icons.trending_up,
                            currency: provider.currency, // تمرير العملة
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMainCard(
                            context,
                            title: 'رصيد العمليات',
                            amount: totalExpenses.toStringAsFixed(2), 
                            subtitle: 'إجمالي العمليات التي تمت',
                            isPrimary: false,
                            icon: Icons.account_balance_wallet,
                            currency: provider.currency, // تمرير العملة
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // شريط الإحصائيات المصغر 
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(context, icon: Icons.group, iconColor: Colors.teal, title: 'الأشخاص', value: '$totalPersons', suffix: ''),
                            _buildStatColumn(context, icon: Icons.receipt, iconColor: Colors.blue, title: 'العمليات', value: '$totalTransactions', suffix: ''),
                            // استخدام العملة الديناميكية هنا
                            _buildStatColumn(context, icon: Icons.calendar_today, iconColor: Colors.deepPurple, title: 'متوسط الفرد', value: sharePerPerson.toStringAsFixed(0), suffix: provider.currency),
                            _buildStatColumn(context, icon: Icons.payments, iconColor: Colors.green, title: 'متوسط العملية', value: avgTransaction.toStringAsFixed(0), suffix: provider.currency),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // أرصدة الأشخاص (مرتبة)
                    _buildSectionTitle('أرصدة الأشخاص', 'عرض الكل', () {}),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: sortedPersons.length, 
                        itemBuilder: (context, index) {
                          String person = sortedPersons[index];
                          double bal = balances[person] ?? 0;
                          bool isPositive = bal >= 0; 
                          String amountStr = '${isPositive ? '+' : ''}${bal.toStringAsFixed(2)}';
                          return _buildPersonBalanceAvatar(context, name: person, amount: amountStr, isPositive: isPositive);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // قسم العمليات والتنبيهات
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildLatestTransactions(provider)),
                              const SizedBox(width: 16),
                              Expanded(flex: 2, child: _buildSmartAlerts(alerts, context)),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (alerts.isNotEmpty) _buildSmartAlerts(alerts, context),
                              if (alerts.isNotEmpty) const SizedBox(height: 24),
                              _buildLatestTransactions(provider),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // إجراءات سريعة 
                    const Text('إجراءات سريعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildQuickAction(context, icon: Icons.handshake_outlined, title: 'التسوية', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettlementScreen()))),
                        _buildQuickAction(context, icon: Icons.people, title: 'إدارة الأشخاص', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonsManagementScreen()))),
                        
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.teal.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 32),
                                SizedBox(height: 4),
                                Text('إضافة عملية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        
                        _buildQuickAction(context, icon: Icons.bar_chart, title: 'التقارير', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()))),
                        _buildQuickAction(context, icon: Icons.folder, title: 'الأرشيف', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchiveScreen()))),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= الدوال المساعدة لبناء عناصر الشاشة =================

  Widget _buildSmartAlerts(List<Map<String, dynamic>> alerts, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('التنبيهات الذكية', '', () {}),
        const SizedBox(height: 12),
        ...alerts.take(3).map((alert) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: alert['color'].withValues(alpha: 0.1),
            border: Border.all(color: alert['color'].withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(alert['icon'], color: alert['color'], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: alert['color'])),
                    Text(alert['subtitle'], style: const TextStyle(color: Colors.black54, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildLatestTransactions(ExpenseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('آخر العمليات', 'عرض الكل', () {}),
        const SizedBox(height: 12),
        if (provider.expenses.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('لا توجد عمليات بعد.', style: TextStyle(color: Colors.grey)),
          ))
        else
          ...provider.expenses.take(4).map((exp) => _buildDetailedTransaction(exp, provider.currency)),
      ],
    );
  }

  Widget _buildDetailedTransaction(ExpenseModel exp, String currency) {
    // تحديد الأيقونة حسب التصنيف (Fallback)
    IconData catIcon = Icons.receipt;
    Color catColor = Colors.grey;
    String categoryName = exp.category;
    
    if (categoryName == 'طعام ومطاعم') { catIcon = Icons.fastfood; catColor = Colors.orange; }
    else if (categoryName == 'مشتريات') { catIcon = Icons.shopping_cart; catColor = Colors.blue; }
    else if (categoryName == 'مواصلات') { catIcon = Icons.directions_car; catColor = Colors.redAccent; }
    else if (categoryName == 'سكن وفواتير') { catIcon = Icons.bolt; catColor = Colors.purple; }
    else if (categoryName.isEmpty) { categoryName = 'عام'; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(catIcon, color: catColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 2),
                    Text(exp.payer, style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 2),
                    Text(DateFormat('dd MMM - hh:mm a', 'ar').format(exp.date), style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // استخدام العملة الديناميكية هنا
              Text('${exp.amount.toStringAsFixed(2)} $currency', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(categoryName, style: TextStyle(color: catColor, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, {required String title, required String amount, required String subtitle, required bool isPrimary, required IconData icon, required String currency}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.teal : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: isPrimary ? Colors.white70 : Colors.grey, fontSize: 12)),
              Icon(icon, color: isPrimary ? Colors.white.withValues(alpha: 0.5) : Colors.teal.withValues(alpha: 0.5), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(color: isPrimary ? Colors.white : Colors.teal, fontSize: 22, fontWeight: FontWeight.bold)),
          // استخدام العملة الديناميكية هنا
          Text(currency, style: TextStyle(color: isPrimary ? Colors.white70 : Colors.grey, fontSize: 10)),
          const SizedBox(height: 12),
          Text(subtitle, style: TextStyle(color: isPrimary ? Colors.white70 : Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, {required IconData icon, required Color iconColor, required String title, required String value, required String suffix}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (suffix.isNotEmpty) Text(' $suffix', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String actionText, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        if (actionText.isNotEmpty)
          GestureDetector(
            onTap: onTap,
            child: Text(actionText, style: const TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildPersonBalanceAvatar(BuildContext context, {required String name, required String amount, required bool isPositive}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 25, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(amount, style: TextStyle(color: isPositive ? Colors.teal : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
            ),
            child: Icon(icon, color: Colors.teal),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ExpensesListTab extends StatelessWidget {
  const _ExpensesListTab();
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.expenses.length,
          itemBuilder: (context, index) => ExpenseCard(expense: provider.expenses[index], onEdit: (){}, onDelete: (){}),
        );
      },
    );
  }
}