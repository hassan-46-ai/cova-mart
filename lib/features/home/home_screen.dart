import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/category_art.dart';
import '../../core/widgets/cova_header.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/category.dart';
import '../auth/auth_controller.dart';
import '../map/addresses_controller.dart';
import '../orders/order_status_ui.dart';
import '../orders/orders_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final catalog = ref.watch(catalogProvider);
    final coffee = catalog.inCategory('coffee').where((p) => p.inStock).take(10).toList();
    final produce = catalog.inCategory('produce').where((p) => p.inStock).take(10).toList();

    Widget gap(double h) => SliverToBoxAdapter(child: SizedBox(height: h));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _HomeHeader()),
          gap(20),
          const SliverToBoxAdapter(child: _ActiveOrderCard()),
          const SliverToBoxAdapter(child: _PromoCarousel()),
          gap(26),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: l10n.categories,
              actionLabel: l10n.seeAll,
              onAction: () => context.go('/categories'),
            ),
          ),
          gap(14),
          SliverToBoxAdapter(child: _CategoryRow(categories: catalog.categories)),
          gap(26),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: l10n.recommended,
              actionLabel: l10n.seeAll,
              onAction: () => context.push('/category/recommended'),
            ),
          ),
          gap(12),
          SliverToBoxAdapter(child: ProductRail(products: catalog.recommended())),
          gap(26),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: l10n.hotDeals,
              actionLabel: l10n.seeAll,
              onAction: () => context.push('/category/deals'),
            ),
          ),
          gap(12),
          SliverToBoxAdapter(child: ProductRail(products: catalog.deals())),
          gap(26),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: l10n.coffeeCorner,
              actionLabel: l10n.seeAll,
              onAction: () => context.push('/category/coffee'),
            ),
          ),
          gap(12),
          SliverToBoxAdapter(child: ProductRail(products: coffee)),
          gap(26),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: l10n.freshToday,
              actionLabel: l10n.seeAll,
              onAction: () => context.push('/category/produce'),
            ),
          ),
          gap(12),
          SliverToBoxAdapter(child: ProductRail(products: produce)),
          gap(28),
        ],
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authProvider);
    final address = ref.watch(selectedAddressProvider);

    return CovaHeader(
      bottomPadding: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.greeting(user?.firstName ?? ''),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(l10n.homeSubtitle, style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 13.5)),
                  ],
                ),
              ),
              const CartButton(onDark: true),
            ],
          ),
          const SizedBox(height: 18),
          Pressable(
            onTap: () => context.push('/search'),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(28),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withAlpha(24)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: Colors.white.withAlpha(190)),
                  const SizedBox(width: 10),
                  Text(l10n.searchHint, style: TextStyle(color: Colors.white.withAlpha(150))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.push('/addresses'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.deliveryTo,
                        style: TextStyle(color: Colors.white.withAlpha(130), fontSize: 11, letterSpacing: 0.8, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address?.details ?? l10n.addAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.cyan, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.within,
                    style: TextStyle(color: Colors.white.withAlpha(130), fontSize: 11, letterSpacing: 0.8, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppColors.cyan, size: 18),
                      Text(
                        l10n.minutesShort(AppConfig.deliveryMinutes),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows the newest order that is still on its way.
class _ActiveOrderCard extends ConsumerWidget {
  const _ActiveOrderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    // Only run the 2-second ticker while an order is young enough to still change.
    final fresh = orders.any((o) => DateTime.now().difference(o.createdAt) < const Duration(minutes: 6));
    if (!fresh) return const SizedBox.shrink();
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final active = orders.where((o) => o.statusAt(now).isActive).toList();
    if (active.isEmpty) return const SizedBox.shrink();

    final order = active.first;
    final status = order.statusAt(now);
    final c = context.colors;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Pressable(
        onTap: () => context.push('/order/${order.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cyan.withAlpha(140)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.fab),
                child: Icon(status.icon, color: c.onFab),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status.label(l10n), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('#${order.id}', style: TextStyle(color: c.muted, fontSize: 12.5)),
                  ],
                ),
              ),
              Text(l10n.track, style: const TextStyle(fontWeight: FontWeight.w800)),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ).entrance(),
    );
  }
}

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final banners = [
      _Banner(
        colors: const [AppColors.cyan, Color(0xFF14CFC7)],
        foreground: AppColors.black,
        icon: Icons.local_offer_rounded,
        big: '25%',
        title: l10n.promoOff,
        subtitle: l10n.promoFirstOrder,
        code: 'COVA25',
        onTap: () => context.push('/cart'),
      ),
      _Banner(
        colors: const [Color(0xFF111314), Color(0xFF000000)],
        foreground: Colors.white,
        icon: Icons.delivery_dining_rounded,
        title: l10n.promoFreeDelivery,
        subtitle: l10n.promoFreeDeliveryBody(Fmt.money(context, AppConfig.freeDeliveryFrom)),
        onTap: () => context.go('/categories'),
      ),
      _Banner(
        colors: const [Color(0xFF3A281C), Color(0xFF120B07)],
        foreground: Colors.white,
        accent: AppColors.cyan,
        icon: Icons.coffee_rounded,
        title: l10n.promoCoffeeTitle,
        subtitle: l10n.promoCoffeeBody,
        onTap: () => context.push('/category/coffee'),
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 158,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: banners[i],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: i == _index ? context.colors.text : context.colors.line,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.colors,
    required this.foreground,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.big,
    this.code,
    this.accent,
  });

  final List<Color> colors;
  final Color foreground;
  final Color? accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? big;
  final String? code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsetsDirectional.only(start: 20),
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
          border: Border.all(color: Colors.white.withAlpha(18)),
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -18,
              bottom: -22,
              child: Icon(icon, size: 130, color: foreground.withAlpha(30)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (big != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(big!, style: TextStyle(color: foreground, fontSize: 46, height: 1, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(title, style: TextStyle(color: foreground, fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  )
                else
                  Text(
                    title,
                    style: TextStyle(color: accent ?? foreground, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: foreground.withAlpha(200), fontSize: 13.5, height: 1.4)),
                if (code != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: foreground, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      code!,
                      style: TextStyle(color: colors.first, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12.5),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final cat = categories[i];
          return Pressable(
            onTap: () => context.push('/category/${cat.id}'),
            child: SizedBox(
              width: 80,
              child: Column(
                children: [
                  SizedBox(width: 78, height: 78, child: CategoryArt(id: cat.id, cacheWidth: 240)),
                  const SizedBox(height: 6),
                  Text(
                    cat.name(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ).entrance(index: i);
        },
      ),
    );
  }
}
