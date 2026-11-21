import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cova_chip.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/product_image.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../data/models/product.dart';
import 'search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    setState(() => _query = q);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final catalog = ref.watch(catalogProvider);
    final recents = ref.watch(recentSearchesProvider);
    final results = catalog.search(_query);
    final suggestions = catalog.recommended(limit: 8).map((p) => p.name(context.lang)).toList();

    Widget body;
    if (_query.trim().isEmpty) {
      body = ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (recents.isNotEmpty) ...[
            Row(
              children: [
                Expanded(child: Text(l10n.recentSearches, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                TextButton(onPressed: ref.read(recentSearchesProvider.notifier).clear, child: Text(l10n.clearAll)),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: [
                for (final r in recents) CovaChip(label: r, selected: false, icon: Icons.history_rounded, onTap: () => _setQuery(r)),
              ],
            ),
            const SizedBox(height: 26),
          ],
          Text(l10n.popularSearches, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              for (final s in suggestions) CovaChip(label: s, selected: false, onTap: () => _setQuery(s)),
            ],
          ),
        ],
      );
    } else if (results.isEmpty) {
      body = EmptyState(icon: Icons.search_off_rounded, title: l10n.noResults, subtitle: l10n.noResultsSearch);
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _ResultTile(
          product: results[i],
          onOpen: () {
            ref.read(recentSearchesProvider.notifier).add(_query);
            context.push('/product/${results[i].id}');
          },
        ).entrance(index: i),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (v) => setState(() => _query = v),
                      onSubmitted: (v) => ref.read(recentSearchesProvider.notifier).add(v),
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        prefixIcon: Icon(Icons.search_rounded, color: c.muted),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(icon: Icon(Icons.close_rounded, color: c.muted), onPressed: () => _setQuery('')),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: body)),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.product, required this.onOpen});

  final Product product;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.lang;
    return Pressable(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.line),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(width: 68, height: 68, child: ProductImage(path: product.image, categoryId: product.categoryId, cacheWidth: 200)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name(lang), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(product.unit(lang), style: TextStyle(color: c.muted, fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Text(Fmt.money(context, product.price), style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            QuickAddButton(product: product),
          ],
        ),
      ),
    );
  }
}
