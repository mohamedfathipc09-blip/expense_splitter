import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../providers/expense_provider.dart';
import '../../core/helpers/backup_helper.dart';
import 'archive_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // 🔹 لون خلفية الشاشة ليكون متباين مع الكروت
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الإعدادات'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // ==========================================
              // 🔹 القسم الأول: المظهر والتخصيص
              // ==========================================
              _buildSectionTitle('المظهر والتخصيص'.tr(), theme),
              const SizedBox(height: 8),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _buildSettingsTile(
                    icon: Icons.dark_mode_rounded,
                    iconColor: Colors.deepPurple,
                    title: 'الوضع الليلي'.tr(),
                    subtitle: 'تغيير مظهر التطبيق'.tr(),
                    trailing: Switch.adaptive(
                      value: provider.isDarkMode,
                 activeThumbColor: Colors.deepPurple, 
                 onChanged: (value) => provider.toggleTheme(),
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.language_rounded,
                    iconColor: Colors.blue,
                    title: 'لغة التطبيق / Language'.tr(),
                    subtitle: context.locale.languageCode == 'ar' ? 'العربية' : 'English',
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    onTap: () async {
                      if (context.locale.languageCode == 'ar') {
                        await context.setLocale(const Locale('en'));
                      } else {
                        await context.setLocale(const Locale('ar'));
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.payments_rounded,
                    iconColor: Colors.green,
                    title: 'العملة الافتراضية'.tr(),
                    subtitle: '${'العملة الحالية:'.tr()} ${provider.currency.tr()}',
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    onTap: () => _showCurrencyDialog(context, provider),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 🔹 القسم الثاني: إدارة البيانات
              // ==========================================
              _buildSectionTitle('إدارة البيانات'.tr(), theme),
              const SizedBox(height: 8),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _buildSettingsTile(
                    icon: Icons.cloud_upload_rounded,
                    iconColor: Colors.teal,
                    title: 'إنشاء نسخة احتياطية'.tr(),
                    subtitle: 'حفظ بياناتك كملف لمشاركته أو حفظه'.tr(),
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
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.cloud_download_rounded,
                    iconColor: Colors.orange,
                    title: 'استرجاع نسخة احتياطية'.tr(),
                    subtitle: 'استعادة بياناتك من ملف سابق'.tr(),
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
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.archive_rounded,
                    iconColor: Colors.purple,
                    title: 'الأرشيف'.tr(),
                    subtitle: 'سجل الدورات والمصروفات السابقة'.tr(),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ArchiveScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // 🔹 رقم الإصدار
              Center(
                child: Text(
                  'Qesma Expenses v1.0.0',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // 🔹 مكونات الـ UI المساعدة (Widgets)
  // ==========================================

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // تصميم الأيقونة مع خلفية خفيفة
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              // العنصر الجانبي (سهم أو زر)
             ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, thickness: 0.5),
    );
  }

  // ==========================================
  // 🔹 النوافذ المنبثقة (Dialogs)
  // ==========================================

  void _showCurrencyDialog(BuildContext context, ExpenseProvider provider) {
    final List<String> currencies = ['ريال', 'جنيه', 'دولار', 'درهم', 'دينار', 'يورو'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('اختر العملة'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: currencies.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected = provider.currency == currency;
                return ListTile(
                  title: Text(currency.tr(), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
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
            Text('تحذير هام'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('استرجاع نسخة احتياطية سيقوم بمسح جميع البيانات الحالية واستبدالها ببيانات الملف. هل أنت متأكد؟'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('إلغاء'.tr(), style: const TextStyle(color: Colors.grey))),
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