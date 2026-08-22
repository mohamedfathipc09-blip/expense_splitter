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
        title: Text('الإعدادات'.tr()),
        centerTitle: true,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          // 🔹 تغليف المحتوى بـ Center ثم ConstrainedBox ليناسب الويب والموبايل
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600), // أقصى عرض للشاشة
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  // --- قسم التفضيلات العامة ---
                  _buildSectionTitle(context, 'التفضيلات العامة'.tr()),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text('الوضع الليلي'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('تغيير مظهر التطبيق'.tr()),
                          secondary: Icon(provider.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.amber),
                          value: provider.isDarkMode,
                          onChanged: (value) {
                            provider.toggleTheme();
                          },
                        ),
                        const Divider(height: 1, indent: 60, endIndent: 16),
                        
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
                        const Divider(height: 1, indent: 60, endIndent: 16),

                        ListTile(
                          leading: const Icon(Icons.attach_money, color: Colors.green),
                          title: Text('العملة الافتراضية'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${'العملة الحالية:'.tr()} ${provider.currency.tr()}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showCurrencyDialog(context, provider);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- قسم البيانات والأرشيف ---
                  _buildSectionTitle(context, 'البيانات والأرشيف'.tr()),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.upload_file, color: Colors.blue),
                          title: Text('إنشاء نسخة احتياطية'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('حفظ بياناتك كملف لمشاركته أو حفظه'.tr()),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                        const Divider(height: 1, indent: 60, endIndent: 16),

                        ListTile(
                          leading: const Icon(Icons.download, color: Colors.teal),
                          title: Text('استرجاع نسخة احتياطية'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('استعادة بياناتك من ملف سابق'.tr()),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Text('تم بنجاح'.tr()),
                                    ],
                                  ),
                                  content: Text('تم استرجاع جميع بياناتك بنجاح. يرجى إعادة تشغيل التطبيق (Restart) لتحديث الشاشات.'.tr()),
                                  actions: [
                                    FilledButton(
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
                        const Divider(height: 1, indent: 60, endIndent: 16),

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
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 عنصر مساعد (Helper Widget) لإنشاء عناوين الأقسام بشكل مرتب
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary, // يأخذ اللون الرئيسي للتطبيق
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, ExpenseProvider provider) {
    final List<String> currencies = ['ريال', 'جنيه', 'دولار', 'درهم', 'دينار', 'يورو'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  trailing: provider.currency == currency ? const Icon(Icons.check_circle, color: Colors.green) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text('تحذير هام'.tr()),
          ],
        ),
        content: Text('استرجاع نسخة احتياطية سيقوم بمسح جميع البيانات الحالية واستبدالها ببيانات الملف. هل أنت متأكد؟'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('إلغاء'.tr())),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('نعم، استرجاع'.tr()),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}