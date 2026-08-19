import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔹 استدعاء مكتبة الترجمة
import '../providers/expense_provider.dart';
import '../../core/helpers/backup_helper.dart';
import 'archive_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // استخدام .tr() يخبر التطبيق بتبديل هذه الكلمة حسب اللغة المختارة
        title: Text('الإعدادات'.tr()), 
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: Text('الوضع الليلي'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('تغيير مظهر التطبيق'.tr()),
                secondary: Icon(provider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                value: provider.isDarkMode,
                onChanged: (value) {
                  provider.toggleTheme();
                },
              ),
              const Divider(),

              // ==========================================
              // 🔹 زر تغيير اللغة الذي تمت إضافته
              // ==========================================
              ListTile(
                leading: const Icon(Icons.language, color: Colors.indigo),
                title: Text('لغة التطبيق / Language'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  context.locale.languageCode == 'ar' ? 'العربية' : 'English',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(Icons.sync, size: 20),
                onTap: () async {
                  if (context.locale.languageCode == 'ar') {
                    await context.setLocale(const Locale('en'));
                  } else {
                    await context.setLocale(const Locale('ar'));
                  }
                },
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text('العملة الافتراضية'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${'العملة الحالية:'.tr()} ${provider.currency}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showCurrencyDialog(context, provider);
                },
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.upload_file, color: Colors.blue),
                title: Text('إنشاء نسخة احتياطية'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('حفظ بياناتك كملف لمشاركته أو حفظه'.tr()),
                onTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('جاري تجهيز النسخة الاحتياطية...'.tr())));
                  bool success = await BackupHelper.createBackup();
                  
                  if (!context.mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إنشاء ومشاركة النسخة بنجاح!'.tr()), backgroundColor: Colors.green));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء إنشاء النسخة الاحتياطية.'.tr()), backgroundColor: Colors.red));
                  }
                },
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.download, color: Colors.teal),
                title: Text('استرجاع نسخة احتياطية'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('استعادة بياناتك من ملف سابق'.tr()),
                onTap: () async {
                  bool confirm = await _showConfirmDialog(context);
                  if (!confirm || !context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('جاري استرجاع البيانات...'.tr())));
                  bool success = await BackupHelper.restoreBackup();
                  
                  if (!context.mounted) return;
                  if (success) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => AlertDialog(
                        title: Text('تم بنجاح 🎉'.tr()),
                        content: Text('تم استرجاع جميع بياناتك بنجاح. يرجى إعادة تشغيل التطبيق (Restart) لتحديث الشاشات.'.tr()),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                            child: Text('حسناً'.tr()),
                          )
                        ],
                      )
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الاسترجاع. تأكد من اختيارك لملف صحيح.'.tr()), backgroundColor: Colors.red));
                  }
                },
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.archive_outlined, color: Colors.purple),
                title: Text('الأرشيف'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('سجل الدورات والمصروفات السابقة'.tr()),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ArchiveScreen()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, ExpenseProvider provider) {
    final List<String> currencies = ['ريال', 'جنيه', 'دولار', 'درهم', 'دينار', 'يورو'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('اختر العملة'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                return ListTile(
                  title: Text(currency.tr()),
                  trailing: provider.currency == currency ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    provider.setCurrency(currency);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      }
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تحذير هام ⚠️'.tr()),
        content: Text('استرجاع نسخة احتياطية سيقوم بمسح جميع البيانات الحالية واستبدالها ببيانات الملف. هل أنت متأكد؟'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('إلغاء'.tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('نعم، استرجاع'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}