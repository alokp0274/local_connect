// features/settings/screens/settings_screen.dart
// Feature: App Settings & Legal
//
// App settings hub with theme, notifications, privacy, and account options.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = true;
  bool _emailNotifs = true;
  String _language = 'English';
  String _currency = 'INR (\u20b9)';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            // PREFERENCES
            _SectionHeader(title: 'Preferences'),
            const SizedBox(height: 8),
            GlassContainer(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Push Notifications',
                        trailing: Switch(
                          value: _notifications,
                          onChanged: (v) => setState(() => _notifications = v),
                          activeThumbColor: AppTheme.accentGold,
                          activeTrackColor: AppTheme.accentGold.withAlpha(60),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark Mode',
                        trailing: Switch(
                          value: _darkMode,
                          onChanged: (v) => setState(() => _darkMode = v),
                          activeThumbColor: AppTheme.accentGold,
                          activeTrackColor: AppTheme.accentGold.withAlpha(60),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.email_outlined,
                        title: 'Email Notifications',
                        trailing: Switch(
                          value: _emailNotifs,
                          onChanged: (v) => setState(() => _emailNotifs = v),
                          activeThumbColor: AppTheme.accentGold,
                          activeTrackColor: AppTheme.accentGold.withAlpha(60),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        trailing: _ValueChip(value: _language),
                        onTap: () => _showLanguagePicker(),
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.currency_exchange_rounded,
                        title: 'Currency',
                        trailing: _ValueChip(value: _currency),
                        onTap: () => _showCurrencyPicker(),
                      ),
                    ],
                  ),
                )
                .animate(delay: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 20),
            _SectionHeader(title: 'Account & Security'),
            const SizedBox(height: 8),
            GlassContainer(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.shield_outlined,
                        title: 'Privacy',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.privacyPolicy,
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.security_rounded,
                        title: 'Security',
                        onTap: () {},
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.link_rounded,
                        title: 'Linked Accounts',
                        onTap: () {},
                      ),
                    ],
                  ),
                )
                .animate(delay: 200.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 20),
            _SectionHeader(title: 'App'),
            const SizedBox(height: 8),
            GlassContainer(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About App',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.aboutApp),
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.termsConditions,
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.privacyPolicy,
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.star_outline_rounded,
                        title: 'Rate App',
                        onTap: () => _showSnack('Thanks for rating!'),
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.share_outlined,
                        title: 'Share App',
                        onTap: () => _showSnack('Share link copied!'),
                      ),
                    ],
                  ),
                )
                .animate(delay: 300.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 20),
            _SectionHeader(title: 'Danger Zone', color: AppTheme.accentCoral),
            const SizedBox(height: 8),
            GlassContainer(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  border: Border.all(
                    color: AppTheme.accentCoral.withAlpha(40),
                    width: 0.5,
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        iconColor: AppTheme.accentCoral,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (route) => false,
                          );
                        },
                      ),
                      const Divider(
                        height: 1,
                        indent: 54,
                        color: AppTheme.border,
                      ),
                      _SettingsTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete Account',
                        iconColor: AppTheme.accentCoral,
                        onTap: () => _showDeleteConfirmation(),
                      ),
                    ],
                  ),
                )
                .animate(delay: 400.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'LocalConnect v2.0.0',
                style: tt.labelSmall?.copyWith(color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        title: const Text(
          'Delete Account?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This action cannot be undone. All your data will be permanently removed.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnack('Account deletion request sent');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.accentCoral),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    _showPickerSheet(
      'Select Language',
      ['English', 'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Bengali'],
      _language,
      (v) => setState(() => _language = v),
    );
  }

  void _showCurrencyPicker() {
    _showPickerSheet(
      'Select Currency',
      ['INR (\u20b9)', 'USD (\$)', 'EUR (\u20ac)', 'GBP (\u00a3)'],
      _currency,
      (v) => setState(() => _currency = v),
    );
  }

  void _showPickerSheet(
    String title,
    List<String> options,
    String current,
    ValueChanged<String> onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 16),
            ...options.map(
              (opt) => ListTile(
                title: Text(
                  opt,
                  style: TextStyle(
                    color: current == opt
                        ? AppTheme.accentGold
                        : AppTheme.textPrimary,
                  ),
                ),
                trailing: current == opt
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppTheme.accentGold,
                      )
                    : null,
                onTap: () {
                  onSelect(opt);
                  Navigator.pop(ctx);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, this.color = AppTheme.textMuted});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: color, fontSize: 13),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor,
  });
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.accentGold, size: 22),
      title: Text(title, style: tt.titleMedium?.copyWith(color: iconColor)),
      trailing:
          trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMuted,
            size: 20,
          ),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String value;
  const _ValueChip({required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.accentGold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textMuted,
          size: 20,
        ),
      ],
    );
  }
}
