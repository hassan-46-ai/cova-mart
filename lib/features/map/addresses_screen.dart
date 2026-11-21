import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../data/models/address.dart';
import 'address_ui.dart';
import 'addresses_controller.dart';
import 'map_picker_screen.dart';

/// Manage saved delivery addresses. In [pickMode] tapping one selects it and closes.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key, this.pickMode = false});

  final bool pickMode;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final picked = await context.push<PickedLocation>('/map-picker');
    if (picked == null) return;
    ref.read(addressesProvider.notifier).add(
          label: picked.label,
          details: picked.details,
          lat: picked.point.latitude,
          lng: picked.point.longitude,
        );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Address a) async {
    final picked = await context.push<PickedLocation>(
      '/map-picker',
      extra: MapPickerArgs(initial: a.point, details: a.details, label: a.label),
    );
    if (picked == null) return;
    ref.read(addressesProvider.notifier).update(
          a.copyWith(
            label: picked.label,
            details: picked.details,
            lat: picked.point.latitude,
            lng: picked.point.longitude,
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final state = ref.watch(addressesProvider);
    final selectedId = state.selected?.id;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 14),
                  Text(l10n.savedAddresses, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: state.items.isEmpty
                  ? EmptyState(
                      icon: Icons.location_off_outlined,
                      title: l10n.noAddresses,
                      subtitle: l10n.noAddressesBody,
                      actionLabel: l10n.addAddress,
                      onAction: () => _add(context, ref),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: [
                        for (var i = 0; i < state.items.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Pressable(
                              onTap: () {
                                ref.read(addressesProvider.notifier).select(state.items[i].id);
                                if (pickMode) context.pop();
                              },
                              child: AddressCard(
                                address: state.items[i],
                                selected: state.items[i].id == selectedId,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, color: c.muted, size: 20),
                                      onPressed: () => _edit(context, ref, state.items[i]),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline_rounded, color: c.muted, size: 20),
                                      onPressed: () => ref.read(addressesProvider.notifier).remove(state.items[i].id),
                                    ),
                                  ],
                                ),
                              ),
                            ).entrance(index: i),
                          ),
                        const SizedBox(height: 4),
                        Pressable(
                          onTap: () => _add(context, ref),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: c.line, width: 1.4)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline_rounded),
                                const SizedBox(width: 10),
                                Text(l10n.addNewAddress, style: const TextStyle(fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
