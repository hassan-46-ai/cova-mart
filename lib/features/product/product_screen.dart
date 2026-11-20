import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/product_image.dart';
import '../../core/widgets/qty_stepper.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/product.dart';
import '../cart/cart_controller.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  int _qty = 1;
  bool _added = false;

  void _addToCart(Product product) {
    ref.read(cartProvider.notifier).add(product.id, qty: _qty);
    HapticFeedback.mediumImpact();
    setState(() => _added = true);
    showCovaSnack(
      context,
      context.l10n.addedToCart,
      actionLabel: context.l10n.viewCart,
      onAction: () => context.push('/cart'),
    );
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _added = false);
    });
  }

  void _buyNow(Product product) {
    ref.read(cartProvider.notifier).add(product.id, qty: _qty);
    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final lang = context.lang;
    final catalog = ref.watch(catalogProvider);
    final product = catalog.product(widget.productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(leading: const Padding(padding: EdgeInsets.all(8), child: AppBackButton())),
        body: EmptyState(icon: Icons.search_off_rounded, title: l10n.productNotFound, subtitle: ''),
      );
    }

    final category = catalog.category(product.categoryId);
    final related = catalog.related(product);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(color: c.card, border: Border(top: BorderSide(color: c.line))),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                outlined: true,
                label: _added ? l10n.added : l10n.addToCart,
                icon: _added ? Icons.check_rounded : null,
                onPressed: product.inStock ? () => _addToCart(product) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: product.inStock ? l10n.buyNow : l10n.outOfStock,
                onPressed: product.inStock ? () => _buyNow(product) : null,
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 360,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(path: product.image, categoryId: product.categoryId, cacheWidth: 1000)
                      .animate()
                      .fadeIn(duration: 450.ms)
                      .scale(begin: const Offset(1.06, 1.06), end: const Offset(1, 1), duration: 700.ms, curve: Curves.easeOutCubic),
                  PositionedDirectional(
                    top: MediaQuery.paddingOf(context).top + 8,
                    start: 20,
                    child: const AppBackButton(),
                  ),
                  PositionedDirectional(
                    top: MediaQuery.paddingOf(context).top + 8,
                    end: 20,
                    child: const CartButton(),
                  ),
                  PositionedDirectional(
                    bottom: 44,
                    end: 20,
                    child: FavoriteButton(productId: product.id, size: 46),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name(lang), style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(product.unit(lang), style: TextStyle(color: c.muted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PriceBlock(price: product.price, oldPrice: product.oldPrice, large: true),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 12),
                          DiscountBadge(percent: product.discountPercent, large: true),
                        ],
                      ],
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.youSave(Fmt.money(context, product.oldPrice! - product.price)),
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        RatingStars(rating: product.rating),
                        const SizedBox(width: 8),
                        Text(
                          '${Fmt.rating(product.rating)}  ·  ${l10n.reviewsCount(product.reviews)}',
                          style: TextStyle(color: c.muted, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(child: Text(l10n.quantity, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                        QtyStepper(
                          qty: _qty,
                          onIncrement: () => setState(() => _qty = (_qty + 1).clamp(1, 20).toInt()),
                          onDecrement: () => setState(() => _qty = (_qty - 1).clamp(1, 20).toInt()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(l10n.details, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(product.description(lang), style: TextStyle(color: c.muted, height: 1.6)),
                    const SizedBox(height: 12),
                    _Accordion(
                      title: l10n.productInfo,
                      children: [
                        _InfoRow(label: l10n.size, value: product.unit(lang)),
                        _InfoRow(label: l10n.category, value: category?.name(lang) ?? ''),
                        _InfoRow(label: l10n.storage, value: category?.storage(lang) ?? ''),
                        _InfoRow(label: l10n.delivery, value: l10n.deliveryInfo),
                      ],
                    ),
                    _Accordion(
                      title: l10n.reviews,
                      children: [
                        Row(
                          children: [
                            Text(Fmt.rating(product.rating), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingStars(rating: product.rating, size: 20),
                                const SizedBox(height: 4),
                                Text(l10n.reviewsCount(product.reviews), style: TextStyle(color: c.muted)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (related.isNotEmpty) ...[
            SliverToBoxAdapter(child: SectionHeader(title: l10n.youMayAlsoLike)),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: ProductRail(products: related)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ],
      ),
    );
  }
}

class _Accordion extends StatelessWidget {
  const _Accordion({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 14),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          children: children,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92, child: Text(label, style: TextStyle(color: c.muted))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4))),
        ],
      ),
    );
  }
}
