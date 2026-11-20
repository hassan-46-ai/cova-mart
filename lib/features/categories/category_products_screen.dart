import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cova_chip.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../data/models/product.dart';
import 'filter_sheet.dart';
import 'product_filter.dart';

/// Product list for a category. Special ids: `deals` and `recommended`.
class CategoryProductsScreen extends ConsumerStatefulWidget {
  const CategoryProductsScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
  ProductFilter _filter = const ProductFilter();

  Future<void> _openFilters(List<Product> base) async {
    final result = await showFilterSheet(context, initial: _filter, base: base);
    if (result != null) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final catalog = ref.watch(catalogProvider);

    late final String title;
    late final List<Product> base;
    switch (widget.categoryId) {
      case 'deals':
        title = l10n.hotDeals;
        base = catalog.products.where((p) => p.hasDiscount).toList();
      case 'all':
        title = l10n.allProducts;
        base = catalog.products;
      case 'recommended':
        title = l10n.recommended;
        base = catalog.recommended(limit: 40);
      default:
        final cat = catalog.category(widget.categoryId);
        title = cat?.name(context.lang) ?? '';
        base = catalog.inCategory(widget.categoryId);
    }

    final shown = _filter.apply(base);
    final active = _filter.activeCount;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  RoundIconButton(icon: Icons.search_rounded, onTap: () => context.push('/search')),
                  const SizedBox(width: 10),
                  const CartButton(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Pressable(
                    onTap: () => _openFilters(base),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: c.fab,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 18, color: c.onFab),
                          const SizedBox(width: 6),
                          Text(
                            active > 0 ? '${l10n.filters} ($active)' : l10n.filters,
                            style: TextStyle(color: c.onFab, fontWeight: FontWeight.w800, fontSize: 13.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CovaChip(
                    label: l10n.sortPopular,
                    selected: _filter.sort == SortOption.popular,
                    onTap: () => setState(() => _filter = _filter.copyWith(sort: SortOption.popular)),
                  ),
                  const SizedBox(width: 8),
                  CovaChip(
                    label: l10n.sortPriceLow,
                    selected: _filter.sort == SortOption.priceLow,
                    onTap: () => setState(() => _filter = _filter.copyWith(sort: SortOption.priceLow)),
                  ),
                  const SizedBox(width: 8),
                  CovaChip(
                    label: l10n.sortRating,
                    selected: _filter.sort == SortOption.rating,
                    onTap: () => setState(() => _filter = _filter.copyWith(sort: SortOption.rating)),
                  ),
                  const SizedBox(width: 8),
                  CovaChip(
                    label: l10n.onOffer,
                    selected: _filter.onlyOffers,
                    onTap: () => setState(() => _filter = _filter.copyWith(onlyOffers: !_filter.onlyOffers)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l10n.itemsCount(shown.length), style: TextStyle(color: c.muted, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: shown.isEmpty
                  ? EmptyState(
                      icon: Icons.filter_alt_off_rounded,
                      title: l10n.noResults,
                      subtitle: l10n.noResultsFilters,
                      actionLabel: l10n.reset,
                      onAction: () => setState(() => _filter = const ProductFilter()),
                    )
                  : CustomScrollView(
                      key: ValueKey('${_filter.sort}${_filter.onlyOffers}${_filter.minRating}${_filter.priceRange}'),
                      slivers: [SliverProductGrid(products: shown)],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
