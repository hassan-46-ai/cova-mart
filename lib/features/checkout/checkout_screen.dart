import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/input_formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/cova_chip.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/address.dart';
import '../../data/models/cart.dart';
import '../../data/models/order.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_screen.dart' show PriceBreakdown;
import '../map/address_ui.dart';
import '../map/addresses_controller.dart';
import '../map/map_picker_screen.dart';
import '../orders/orders_controller.dart';

extension DeliverySlotLabel on DeliverySlot {
  String label(AppLocalizations l10n) {
    switch (this) {
      case DeliverySlot.asap:
        return l10n.slotAsap;
      case DeliverySlot.withinHour:
        return l10n.slotWithinHour;
      case DeliverySlot.evening:
        return l10n.slotEvening;
      case DeliverySlot.tomorrow:
        return l10n.slotTomorrow;
    }
  }
}

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _cardForm = GlobalKey<FormState>();
  final _holder = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  final _note = TextEditingController();

  DeliverySlot _slot = DeliverySlot.asap;
  PaymentMethod _payment = PaymentMethod.cash;
  bool _placing = false;

  @override
  void dispose() {
    for (final c in [_holder, _number, _expiry, _cvc, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addAddress() async {
    final picked = await context.push<PickedLocation>('/map-picker');
    if (picked == null) return;
    ref.read(addressesProvider.notifier).add(
          label: picked.label,
          details: picked.details,
          lat: picked.point.latitude,
          lng: picked.point.longitude,
        );
  }

  Future<void> _review() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = context.l10n;
    final summary = ref.read(cartSummaryProvider);
    final address = ref.read(selectedAddressProvider);
    if (address == null) {
      showCovaSnack(context, l10n.selectAddressFirst);
      return;
    }
    if (_payment == PaymentMethod.card && !(_cardForm.currentState?.validate() ?? false)) {
      return;
    }

    final approved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ApproveSheet(
        summary: summary,
        address: address,
        slot: _slot,
        payment: _payment,
      ),
    );
    if (approved != true || !mounted) return;
    await _place(summary, address);
  }

  Future<void> _place(CartSummary summary, Address address) async {
    setState(() => _placing = true);
    if (ref.read(settingsProvider).notificationsEnabled) {
      await ref.read(notificationServiceProvider).requestPermission();
    }
    await Future<void>.delayed(const Duration(milliseconds: 900)); // simulated network call
    final digits = _number.text.replaceAll(' ', '');
    final order = ref.read(ordersProvider.notifier).place(
          summary: summary,
          address: address,
          payment: _payment,
          slot: _slot,
          cardLast4: _payment == PaymentMethod.card && digits.length >= 4 ? digits.substring(digits.length - 4) : null,
          note: _note.text,
        );
    HapticFeedback.heavyImpact();
    if (mounted) context.go('/order-success/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final summary = ref.watch(cartSummaryProvider);
    final address = ref.watch(selectedAddressProvider);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    if (summary.isEmpty && !_placing) {
      return Scaffold(
        appBar: AppBar(leading: const Padding(padding: EdgeInsets.all(8), child: AppBackButton())),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: l10n.cartEmpty,
          subtitle: l10n.cartEmptyBody,
          actionLabel: l10n.startShopping,
          onAction: () => context.go('/categories'),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
            Row(
              children: [
                const AppBackButton(),
                const SizedBox(width: 14),
                Text(l10n.checkout, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 22),
            _Section(
              title: l10n.deliveryAddress,
              trailing: address == null
                  ? null
                  : TextButton(onPressed: () => context.push('/addresses', extra: 'pick'), child: Text(l10n.change)),
              child: address == null
                  ? Pressable(
                      onTap: _addAddress,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: c.line, width: 1.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_location_alt_outlined),
                            const SizedBox(width: 10),
                            Text(l10n.addAddress, style: const TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    )
                  : AddressCard(address: address, selected: true),
            ).entrance(),
            const SizedBox(height: 16),
            _Section(
              title: l10n.deliveryTime,
              child: Wrap(
                spacing: 8,
                runSpacing: 10,
                children: [
                  for (final s in DeliverySlot.values)
                    CovaChip(label: s.label(l10n), selected: _slot == s, onTap: () => setState(() => _slot = s)),
                ],
              ),
            ).entrance(index: 1),
            const SizedBox(height: 16),
            _Section(
              title: l10n.paymentMethod,
              child: Column(
                children: [
                  _PayOption(
                    icon: Icons.payments_outlined,
                    title: l10n.cashOnDelivery,
                    subtitle: l10n.cashOnDeliveryBody,
                    selected: _payment == PaymentMethod.cash,
                    onTap: () => setState(() => _payment = PaymentMethod.cash),
                  ),
                  const SizedBox(height: 10),
                  _PayOption(
                    icon: Icons.credit_card_rounded,
                    title: l10n.payByCard,
                    subtitle: l10n.payByCardBody,
                    selected: _payment == PaymentMethod.card,
                    onTap: () => setState(() => _payment = PaymentMethod.card),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: _payment == PaymentMethod.card ? _cardFields(l10n, c.muted) : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ).entrance(index: 2),
            const SizedBox(height: 16),
            _Section(
              title: l10n.orderNote,
              child: TextField(
                controller: _note,
                maxLines: 2,
                keyboardType: TextInputType.text, // single-line keyboard: Enter = Done
                textInputAction: TextInputAction.done,
                scrollPadding: const EdgeInsets.only(bottom: 160),
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                decoration: InputDecoration(hintText: l10n.orderNoteHint),
              ),
            ).entrance(index: 3),
            const SizedBox(height: 16),
            _Section(title: l10n.orderSummary, child: PriceBreakdown(summary: summary)).entrance(index: 4),
                ],
              ),
            ),
          ),
          // Stays visible right above the keyboard, so you can place the order without closing it.
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, keyboardOpen ? 12 : 12 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(color: c.card, border: Border(top: BorderSide(color: c.line))),
            child: AppButton(
              loading: _placing,
              label: '${l10n.placeOrder}  ·  ${Fmt.money(context, summary.total)}',
              onPressed: (address != null && summary.meetsMinimum) ? _review : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardFields(AppLocalizations l10n, Color muted) {
    return Form(
      key: _cardForm,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            AppTextField(
              controller: _holder,
              label: l10n.cardHolder,
              icon: Icons.person_outline_rounded,
              validator: (v) => (v ?? '').trim().length < 3 ? l10n.errRequired : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _number,
              label: l10n.cardNumber,
              icon: Icons.credit_card_rounded,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              inputFormatters: [CardNumberFormatter()],
              validator: (v) => CardValidators.number(v ?? '') ? null : l10n.errCardNumber,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _expiry,
                    label: l10n.expiry,
                    icon: Icons.event_outlined,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    inputFormatters: [ExpiryFormatter()],
                    validator: (v) => CardValidators.expiry(v ?? '', DateTime.now()) ? null : l10n.errExpiry,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _cvc,
                    label: 'CVC',
                    icon: Icons.lock_outline_rounded,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                    validator: (v) => CardValidators.cvc(v ?? '') ? null : l10n.errCvc,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(l10n.cardDemoNote, style: TextStyle(color: muted, fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: c.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  const _PayOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? c.cardAlt : Colors.transparent,
          border: Border.all(color: selected ? AppColors.cyan : c.line, width: selected ? 1.8 : 1.2),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: c.muted, fontSize: 12.5)),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                key: ValueKey(selected),
                color: selected ? c.text : c.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Final "approve your order" step shown before the order is placed.
class _ApproveSheet extends StatelessWidget {
  const _ApproveSheet({required this.summary, required this.address, required this.slot, required this.payment});

  final CartSummary summary;
  final Address address;
  final DeliverySlot slot;
  final PaymentMethod payment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: c.muted),
              const SizedBox(width: 12),
              SizedBox(width: 84, child: Text(label, style: TextStyle(color: c.muted))),
              Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35))),
            ],
          ),
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.approveOrder, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(l10n.approveOrderBody, style: TextStyle(color: c.muted)),
            const SizedBox(height: 16),
            row(Icons.shopping_bag_outlined, l10n.items, l10n.itemsCount(summary.itemCount)),
            row(Icons.location_on_outlined, l10n.deliverTo, address.details),
            row(Icons.schedule_rounded, l10n.deliveryTime, slot.label(l10n)),
            row(
              payment == PaymentMethod.cash ? Icons.payments_outlined : Icons.credit_card_rounded,
              l10n.paymentMethod,
              payment == PaymentMethod.cash ? l10n.cashOnDelivery : l10n.payByCard,
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
            Row(
              children: [
                Expanded(child: Text(l10n.total, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
                Text(Fmt.money(context, summary.total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(label: l10n.confirmOrder, icon: Icons.check_rounded, onPressed: () => Navigator.of(context).pop(true)),
            const SizedBox(height: 10),
            AppButton(label: l10n.reviewOrder, outlined: true, onPressed: () => Navigator.of(context).pop(false)),
          ],
        ),
      ),
    );
  }
}
