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
            padding: const EdgeInsets.all(20),
            children: [
              // ==========================================
              // 🔹 القسم الأول: المظهر والتخصيص
              // ==========================================
              _buildSectionTitle('المظهر والتخصيص'.tr(), theme, isDark),
              const SizedBox(height: 12),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _buildSettingsTile(
                    icon: Icons.dark_mode_rounded,
                    iconColor: Colors.deepPurple,
                    title: 'الوضع الليلي'.tr(),
                    subtitle: 'تغيير مظهر التطبيق'.tr(),
                    isDark: isDark,
                    trailing: Switch.adaptive(
                      value: provider.isDarkMode,
                     activeThumbColor: Colors.deepPurple.shade400,
                      onChanged: (value) => provider.toggleTheme(),
                    ),
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    icon: Icons.language_rounded,
                    iconColor: Colors.blue,
                    title: 'لغة التطبيق / Language'.tr(),
                    subtitle: context.locale.languageCode == 'ar' ? 'العربية' : 'English',
                    isDark: isDark,
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                    onTap: () async {
                      if (context.locale.languageCode == 'ar') {
                        await context.setLocale(const Locale('en'));
                      } else {
                        await context.setLocale(const Locale('ar'));
                      }
                    },
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    icon: Icons.payments_rounded,
                    iconColor: Colors.green,
                    title: 'العملة الافتراضية'.tr(),
                    subtitle: '${'العملة الحالية:'.tr()} ${provider.currency.tr()}',
                    isDark: isDark,
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                    onTap: () => _showCurrencyDialog(context, provider, isDark),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ==========================================
              // 🔹 القسم الثاني: إدارة البيانات
              // ==========================================
              _buildSectionTitle('إدارة البيانات'.tr(), theme, isDark),
              const SizedBox(height: 12),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _buildSettingsTile(
                    icon: Icons.cloud_upload_rounded,
                    iconColor: Colors.teal,
                    title: 'إنشاء نسخة احتياطية'.tr(),
                    subtitle: 'حفظ بياناتك كملف لمشاركته أو حفظه'.tr(),
                    isDark: isDark,
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('جاري تجهيز النسخة الاحتياطية...'.tr())));
                      bool success = await BackupHelper.createBackup();
                      
                      if (!context.mounted) return;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إنشاء ومشاركة النسخة بنجاح!'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.green.shade600));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء إنشاء النسخة الاحتياطية.'.tr()), backgroundColor: Colors.red.shade600));
                      }
                    },
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    icon: Icons.cloud_download_rounded,
                    iconColor: Colors.orange,
                    title: 'استرجاع نسخة احتياطية'.tr(),
                    subtitle: 'استعادة بياناتك من ملف سابق'.tr(),
                    isDark: isDark,
                    onTap: () async {
                      bool confirm = await _showConfirmDialog(context, isDark);
                      if (!confirm || !context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('جاري استرجاع البيانات...'.tr())));
                      bool success = await BackupHelper.restoreBackup();
                      
                      if (!context.mounted) return;
                      if (success) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.green),
                                const SizedBox(width: 8),
                                Text('تم بنجاح'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            content: Text('تم استرجاع جميع بياناتك بنجاح. يرجى إعادة تشغيل التطبيق (Restart) لتحديث الشاشات.'.tr()),
                            actions: [
                              FilledButton(
                                style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الاسترجاع. تأكد من اختيارك لملف صحيح.'.tr()), backgroundColor: Colors.red.shade600));
                      }
                    },
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    icon: Icons.inventory_2_rounded,
                    iconColor: Colors.blueGrey,
                    title: 'الأرشيف'.tr(),
                    subtitle: 'سجل الدورات والمصروفات السابقة'.tr(),
                    isDark: isDark,
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ArchiveScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // 🔹 رقم الإصدار
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.account_balance_wallet_rounded, size: 32, color: isDark ? Colors.grey.shade600 : Colors.grey.shade500),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Qesma Expenses v1.0.0',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                  ],
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

  Widget _buildSectionTitle(String title, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? theme.colorScheme.primary.withValues(alpha: 0.8) : theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 15,
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
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.2) : iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isDark ? iconColor : iconColor.withRed(iconColor.r ~/ 1.2), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
             ?trailing, // 🔹 تم حل خطأ الـ Syntax هنا
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, thickness: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
    );
  }

  // ==========================================
  // 🔹 النوافذ المنبثقة (Dialogs)
  // ==========================================

  void _showCurrencyDialog(BuildContext context, ExpenseProvider provider, bool isDark) {
    final List<String> currencies = ['ريال', 'جنيه', 'دولار', 'درهم', 'دينار', 'يورو'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('اختر العملة'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          contentPadding: const EdgeInsets.only(top: 16, bottom: 8),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: currencies.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected = provider.currency == currency;
                return ListTile(
                  title: Text(currency.tr(), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
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

  Future<bool> _showConfirmDialog(BuildContext context, bool isDark) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('نعم، استرجاع'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}