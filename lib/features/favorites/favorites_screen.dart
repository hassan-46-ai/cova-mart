import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/cova_header.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/round_icon_button.dart';
import 'favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final catalog = ref.watch(catalogProvider);
    final ids = ref.watch(favoritesProvider);
    final liked = [for (final id in ids) if (catalog.product(id) != null) catalog.product(id)!];

    return Scaffold(
      body: Column(
        children: [
          CovaHeader(
            bottomPadding: 26,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.favouritesTitle, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(l10n.savedItems(liked.length), style: TextStyle(color: Colors.white.withAlpha(160))),
                    ],
                  ),
                ),
                RoundIconButton(icon: Icons.search_rounded, onDark: true, onTap: () => context.push('/search')),
                const SizedBox(width: 10),
                const CartButton(onDark: true),
              ],
            ),
          ),
          Expanded(
            child: liked.isEmpty
                ? EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: l10n.noFavourites,
                    subtitle: l10n.noFavouritesBody,
                    actionLabel: l10n.browseProducts,
                    onAction: () => context.go('/categories'),
                  )
                : CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      SliverProductGrid(products: liked),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
