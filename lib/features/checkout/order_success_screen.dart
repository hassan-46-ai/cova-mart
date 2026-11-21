import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../orders/orders_controller.dart';

class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final order = ref.watch(orderByIdProvider(orderId));

    Widget ring(double size, int delay) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cyan.withAlpha(120), width: 1.5),
          ),
        ).animate(delay: delay.ms).scale(begin: const Offset(0.4, 0.4), end: const Offset(1, 1), duration: 700.ms, curve: Curves.easeOutCubic).fadeIn(duration: 500.ms);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ring(240, 250),
                            ring(180, 120),
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cyan,
                                boxShadow: [BoxShadow(color: AppColors.cyan.withAlpha(110), blurRadius: 40)],
                              ),
                              child: const Icon(Icons.check_rounded, size: 64, color: AppColors.black)
                                  .animate(delay: 350.ms)
                                  .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
                            ).animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(l10n.orderApproved, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800))
                          .animate(delay: 500.ms)
                          .fadeIn()
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 12),
                      Text(
                        l10n.orderApprovedBody(AppConfig.deliveryMinutes),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: c.muted, height: 1.6, fontSize: 15),
                      ).animate(delay: 650.ms).fadeIn().slideY(begin: 0.2, end: 0),
                      if (order != null) ...[
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.line)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              Container(width: 1, height: 18, color: c.line, margin: const EdgeInsets.symmetric(horizontal: 16)),
                              Text(Fmt.money(context, order.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ).animate(delay: 800.ms).fadeIn(),
                      ],
                    ],
                  ),
                ),
                if (order != null)
                  AppButton(label: l10n.trackOrder, icon: Icons.delivery_dining_rounded, onPressed: () => context.pushReplacement('/order/${order.id}')),
                const SizedBox(height: 12),
                AppButton(label: l10n.backToHome, outlined: true, onPressed: () => context.go('/home')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
