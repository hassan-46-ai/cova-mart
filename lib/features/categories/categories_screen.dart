import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/category_art.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/round_icon_button.dart';

/// Picture grid of all categories (plus "Hot deals" and "All products").
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final lang = context.lang;
    final catalog = ref.watch(catalogProvider);

    final tiles = <_TileData>[
      _TileData('deals', l10n.hotDeals, catalog.products.where((p) => p.hasDiscount).length),
      for (final cat in catalog.categories) _TileData(cat.id, cat.name(lang), catalog.inCategory(cat.id).length),
      _TileData('all', l10n.allProducts, catalog.products.length),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Pressable(
                      onTap: () => context.push('/search'),
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: c.line),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: c.muted),
                            const SizedBox(width: 10),
                            Text(l10n.searchHint, style: TextStyle(color: c.muted, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CartButton(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(l10n.categories, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.browseCategories, style: TextStyle(color: c.muted)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.6,
                ),
                itemCount: tiles.length,
                itemBuilder: (context, i) => _CategoryTile(data: tiles[i]).entrance(index: i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileData {
  const _TileData(this.id, this.label, this.count);

  final String id;
  final String label;
  final int count;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.data});

  final _TileData data;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: () => context.push('/category/${data.id}'),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: c.line),
              ),
              child: CategoryArt(id: data.id),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            data.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, height: 1.25),
          ),
          const SizedBox(height: 2),
          Text(context.l10n.itemsCount(data.count), style: TextStyle(color: c.muted, fontSize: 11.5)),
        ],
      ),
    );
  }
}
