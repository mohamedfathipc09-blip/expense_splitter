import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/expense_provider.dart';
import 'settlement_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // 🔹 حفظ حالة الإشعارات المقروءة محلياً لتمييزها
  final Set<String> _readAlerts = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final alerts = provider.smartAlerts;
    
    // حساب عدد الإشعارات غير المقروءة
    final unreadCount = alerts.where((alert) => !_readAlerts.contains(alert['title'])).length;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الإشعارات'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ]
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'read_all') {
                setState(() {
                  _readAlerts.addAll(alerts.map((a) => a['title'] as String));
                });
              } else if (value == 'clear_all') {
                provider.clearAllAlerts();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    const Icon(Icons.done_all, size: 20, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text('تحديد الكل كمقروء'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep, size: 20, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Text('مسح الإشعارات'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('لا توجد إشعارات حالياً'.tr(), style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final String title = alert['title'];
                final String subtitle = alert['subtitle'];
                final IconData icon = alert['icon'];
                final MaterialColor color = alert['color'];
                
                final isRead = _readAlerts.contains(title);

                return Dismissible(
                  key: Key(title),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    provider.dismissAlert(title);
                  },
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // 🔹 عند الضغط: يصبح مقروءاً، ولو كان اقتراح تسوية ينقله لصفحة التسوية
                      setState(() {
                        _readAlerts.add(title);
                      });
                      if (title.contains('تسوية')) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettlementScreen()));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // خلفية خفيفة للإشعار غير المقروء
                        color: isRead ? cardColor : color.withValues(alpha: isDark ? 0.15 : 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isRead 
                            ? (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05))
                            : color.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 أيقونة الإشعار
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: isDark ? color.shade300 : color.shade700, size: 20),
                          ),
                          const SizedBox(width: 12),
                          // 🔹 النصوص
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, // خط أسمك لغير المقروء
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle.tr(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 🔹 نقطة التمييز (Blue Dot) للإشعارات غير المقروءة
                          if (!isRead)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 1)
                                ]
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}