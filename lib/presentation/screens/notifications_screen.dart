import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/expense_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final alerts = provider.smartAlerts;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('الإشعارات'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (alerts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'تحديد الكل كمقروء'.tr(),
              onPressed: () {
                provider.clearAllAlerts();
              },
            )
        ],
      ),
      body: alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('لا توجد إشعارات جديدة'.tr(), style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final color = alert['color'] as MaterialColor;
                
                return Dismissible(
                  key: Key(alert['title']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    provider.dismissAlert(alert['title']);
                  },
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: color.withValues(alpha: 0.3), width: 1)
                    ),
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? color.withValues(alpha: 0.1) 
                        : color.shade50,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: Icon(alert['icon'], color: color.shade700),
                      ),
                      title: Text((alert['title'] as String).tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text((alert['subtitle'] as String).tr(), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ),
                      trailing: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}