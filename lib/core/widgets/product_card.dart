import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/product.dart';
import '../../features/cart/cart_controller.dart';
import '../../features/favorites/favorites_controller.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'pressable.dart';
import 'product_image.dart';

/// Price with optional struck-through previous price.
class PriceBlock extends StatelessWidget {
  const PriceBlock({super.key, required this.price, this.oldPrice, this.large = false});

  final double price;
  final double? oldPrice;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Fmt.money(context, price),
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: large ? 24 : 15),
        ),
        if (oldPrice != null)
          Text(
            Fmt.money(context, oldPrice!),
            style: TextStyle(
              color: c.muted,
              fontSize: large ? 14 : 11.5,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class DiscountBadge extends StatelessWidget {
  const DiscountBadge({super.key, required this.percent, this.large = false});

  final int percent;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 12 : 8, vertical: large ? 6 : 4),
      decoration: BoxDecoration(color: AppColors.cyan, borderRadius: BorderRadius.circular(999)),
      child: Text(
        '-$percent%',
        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w800, fontSize: large ? 13 : 11),
      ),
    );
  }
}

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.productId, this.size = 34});

  final String productId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final fav = ref.watch(isFavoriteProvider(productId));
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(favoritesProvider.notifier).toggle(productId);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.card.withAlpha(225)),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(fav),
            size: size * 0.55,
            color: fav ? AppColors.danger : c.text,
          ),
        ),
      ),
    );
  }
}

/// "+" button that morphs into a "− 2 +" pill once the item is in the cart.
class QuickAddButton extends ConsumerWidget {
  const QuickAddButton({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!product.inStock) return const SizedBox.shrink();
    final c = context.colors;
    final qty = ref.watch(cartQtyProvider(product.id));
    final cart = ref.read(cartProvider.notifier);

    Widget tap(IconData icon, VoidCallback onTap) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(
            width: 28,
            height: 36,
            child: Icon(icon, size: 18, color: c.onFab),
          ),
        );

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: AlignmentDirectional.centerEnd,
      child: qty == 0
          ? GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                cart.add(product.id);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.fab),
                child: Icon(Icons.add_rounded, size: 20, color: c.onFab),
              ),
            )
          : Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: c.fab),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tap(Icons.remove_rounded, () => cart.decrement(product.id)),
                  SizedBox(
                    width: 22,
                    child: Text(
                      '$qty',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.onFab, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                  tap(Icons.add_rounded, () => cart.add(product.id)),
                ],
              ),
            ),
    );
  }
}

/// Grid / rail product tile. Size is decided by the parent.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final lang = context.lang;
    final text = Theme.of(context).textTheme;

    return Pressable(
      scale: 0.98,
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(path: product.image, categoryId: product.categoryId),
                  if (!product.inStock)
                    Container(
                      color: Colors.black.withAlpha(130),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.outOfStock,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (product.hasDiscount)
                    PositionedDirectional(top: 10, start: 10, child: DiscountBadge(percent: product.discountPercent)),
                  PositionedDirectional(top: 8, end: 8, child: FavoriteButton(productId: product.id)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(product.unit(lang), style: text.bodySmall?.copyWith(color: c.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: PriceBlock(price: product.price, oldPrice: product.oldPrice),
                        ),
                      ),
                      const SizedBox(width: 6),
                      QuickAddButton(product: product),
                    ],
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

/// Two-column product grid for use inside a [CustomScrollView].
class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.66,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => ProductCard(product: products[i]),
          childCount: products.length,
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of product cards.
class ProductRail extends StatelessWidget {
  const ProductRail({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => SizedBox(width: 168, child: ProductCard(product: products[i])),
      ),
    );
  }
}
