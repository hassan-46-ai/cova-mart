import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/address.dart';
import '../auth/auth_controller.dart';
import '../map/addresses_controller.dart';
import '../map/map_picker_screen.dart';

/// Change name, phone and delivery location.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: ref.read(authProvider)?.name ?? '');
  late final _phone = TextEditingController(text: ref.read(authProvider)?.phone ?? '');
  late final _email = TextEditingController(text: ref.read(authProvider)?.email ?? '');
  late final _location = TextEditingController(text: ref.read(selectedAddressProvider)?.details ?? '');
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _location]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final current = ref.read(selectedAddressProvider);
    final picked = await context.push<PickedLocation>(
      '/map-picker',
      extra: current == null ? null : MapPickerArgs(initial: current.point, details: current.details, label: current.label),
    );
    if (picked == null) return;
    final addresses = ref.read(addressesProvider.notifier);
    if (current == null) {
      addresses.add(label: AddressLabel.home, details: picked.details, lat: picked.point.latitude, lng: picked.point.longitude);
    } else {
      addresses.update(current.copyWith(
        label: picked.label,
        details: picked.details,
        lat: picked.point.latitude,
        lng: picked.point.longitude,
      ));
    }
    setState(() => _location.text = picked.details);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(authProvider.notifier).updateProfile(name: _name.text, phone: _phone.text);
    if (!mounted) return;
    setState(() => _saving = false);
    showCovaSnack(context, context.l10n.profileSaved);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppBackButton(),
                    const SizedBox(width: 14),
                    Text(l10n.editProfile, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 28),
                AppTextField(
                  controller: _name,
                  label: l10n.fullName,
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v ?? '').trim().length < 2 ? l10n.errRequired : null,
                ).entrance(),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phone,
                  label: l10n.phone,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  validator: (v) => Validators.egyptPhone(v ?? '') ? null : l10n.errPhone,
                ).entrance(index: 1),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _location,
                  label: l10n.deliveryLocation,
                  icon: Icons.location_on_outlined,
                  readOnly: true,
                  maxLines: 2,
                  onTap: _pickLocation,
                  suffix: const Icon(Icons.map_outlined),
                ).entrance(index: 2),
                const SizedBox(height: 16),
                Opacity(
                  opacity: 0.6,
                  child: AppTextField(
                    controller: _email,
                    label: l10n.email,
                    icon: Icons.mail_outline_rounded,
                    readOnly: true,
                    textDirection: TextDirection.ltr,
                  ),
                ).entrance(index: 3),
                const SizedBox(height: 32),
                AppButton(label: l10n.saveChanges, loading: _saving, onPressed: _save).entrance(index: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
