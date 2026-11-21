import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/cova_header.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/snack.dart';
import '../auth/auth_controller.dart';
import '../map/addresses_controller.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _choose<T>(
    BuildContext context, {
    required String title,
    required List<(T, String)> options,
    required T current,
    required ValueChanged<T> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final o in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(o.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: o.$1 == current ? const Icon(Icons.check_circle_rounded) : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onSelected(o.$1);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleNotifications(BuildContext context, WidgetRef ref, bool enable) async {
    final l10n = context.l10n;
    final service = ref.read(notificationServiceProvider);
    if (enable) {
      final allowed = await service.requestPermission();
      if (!allowed) {
        if (context.mounted) {
          showCovaSnack(context, l10n.notifPermissionDenied, actionLabel: l10n.openSettings, onAction: service.openSettings);
        }
        return;
      }
    } else {
      await service.cancelAll();
    }
    await ref.read(settingsProvider.notifier).setNotifications(enable);
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.logout, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final user = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final address = ref.watch(selectedAddressProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final themeLabel = switch (settings.themeMode) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.themeSystem,
    };

    final tiles = <Widget>[
      _Tile(icon: Icons.person_outline_rounded, title: l10n.editProfile, onTap: () => context.push('/profile/edit')),
      _Tile(icon: Icons.receipt_long_outlined, title: l10n.myOrders, onTap: () => context.push('/orders')),
      _Tile(
        icon: Icons.location_on_outlined,
        title: l10n.savedAddresses,
        subtitle: address?.details,
        onTap: () => context.push('/addresses'),
      ),
      _Tile(
        icon: Icons.language_rounded,
        title: l10n.language,
        subtitle: settings.locale.languageCode == 'ar' ? 'العربية' : 'English',
        onTap: () => _choose<String>(
          context,
          title: l10n.language,
          options: const [('en', 'English'), ('ar', 'العربية')],
          current: settings.locale.languageCode,
          onSelected: notifier.setLanguage,
        ),
      ),
      _Tile(
        icon: Icons.dark_mode_outlined,
        title: l10n.appearance,
        subtitle: themeLabel,
        onTap: () => _choose<ThemeMode>(
          context,
          title: l10n.appearance,
          options: [
            (ThemeMode.system, l10n.themeSystem),
            (ThemeMode.light, l10n.themeLight),
            (ThemeMode.dark, l10n.themeDark),
          ],
          current: settings.themeMode,
          onSelected: notifier.setThemeMode,
        ),
      ),
      _Tile(
        icon: Icons.notifications_none_rounded,
        title: l10n.notificationsTitle,
        subtitle: l10n.notificationsSubtitle,
        onTap: () => _toggleNotifications(context, ref, !settings.notificationsEnabled),
        trailing: Switch.adaptive(
          value: settings.notificationsEnabled,
          onChanged: (v) => _toggleNotifications(context, ref, v),
        ),
      ),
      _Tile(
        icon: Icons.info_outline_rounded,
        title: l10n.about,
        onTap: () => showAboutDialog(
          context: context,
          applicationName: 'Cova Mart',
          applicationVersion: '1.0.0',
          applicationLegalese: '© Cova Mart',
        ),
      ),
      _Tile(icon: Icons.logout_rounded, title: l10n.logout, danger: true, onTap: () => _confirmLogout(context, ref)),
    ];

    return Scaffold(
      body: Column(
        children: [
          CovaHeader(
            bottomPadding: 26,
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.cyan),
                  child: Text(
                    initialOf(user?.name ?? ''),
                    style: const TextStyle(color: AppColors.black, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(user?.phone ?? '', textDirection: TextDirection.ltr, style: TextStyle(color: Colors.white.withAlpha(170))),
                    ],
                  ),
                ),
                RoundIconButton(icon: Icons.edit_outlined, onDark: true, onTap: () => context.push('/profile/edit')),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              children: [
                Container(
                  decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(26), border: Border.all(color: c.line)),
                  child: Column(
                    children: [
                      for (var i = 0; i < tiles.length; i++) ...[
                        tiles[i],
                        if (i != tiles.length - 1) Divider(indent: 68, color: c.line),
                      ],
                    ],
                  ),
                ).entrance(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.danger = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool danger;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = danger ? AppColors.danger : c.text;
    return Pressable(
      scale: 0.99,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.cardAlt),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.muted, fontSize: 12.5)),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing! else if (!danger) Icon(Icons.chevron_right_rounded, color: c.muted),
          ],
        ),
      ),
    );
  }
}
