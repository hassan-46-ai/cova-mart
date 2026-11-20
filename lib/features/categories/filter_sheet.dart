import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/cova_chip.dart';
import '../../data/models/product.dart';
import 'product_filter.dart';

/// Bottom sheet to sort & filter [base]. Returns the new filter, or null if dismissed.
Future<ProductFilter?> showFilterSheet(
  BuildContext context, {
  required ProductFilter initial,
  required List<Product> base,
}) {
  return showModalBottomSheet<ProductFilter>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FilterSheet(initial: initial, base: base),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial, required this.base});

  final ProductFilter initial;
  final List<Product> base;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ProductFilter _draft = widget.initial;
  late final double _min = widget.base.map((p) => p.price).reduce(math.min).floorToDouble();
  late final double _max = math.max(
    widget.base.map((p) => p.price).reduce(math.max).ceilToDouble(),
    _min + 1,
  );

  String _sortLabel(SortOption o) {
    final l10n = context.l10n;
    switch (o) {
      case SortOption.popular:
        return l10n.sortPopular;
      case SortOption.priceLow:
        return l10n.sortPriceLow;
      case SortOption.priceHigh:
        return l10n.sortPriceHigh;
      case SortOption.rating:
        return l10n.sortRating;
      case SortOption.discount:
        return l10n.sortDiscount;
    }
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 12),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final range = _draft.priceRange ?? RangeValues(_min, _max);
    final count = _draft.apply(widget.base).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.filters, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _draft = const ProductFilter()),
                    child: Text(l10n.reset),
                  ),
                ],
              ),
              _title(l10n.sortBy),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: [
                  for (final o in SortOption.values)
                    CovaChip(
                      label: _sortLabel(o),
                      selected: _draft.sort == o,
                      onTap: () => setState(() => _draft = _draft.copyWith(sort: o)),
                    ),
                ],
              ),
              _title(l10n.priceRange),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Fmt.money(context, range.start.roundToDouble()), style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(Fmt.money(context, range.end.roundToDouble()), style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              RangeSlider(
                values: RangeValues(
                  range.start.clamp(_min, _max).toDouble(),
                  range.end.clamp(_min, _max).toDouble(),
                ),
                min: _min,
                max: _max,
                divisions: ((_max - _min) / 5).clamp(1, 100).round(),
                onChanged: (v) => setState(() {
                  final isFull = v.start <= _min && v.end >= _max;
                  _draft = isFull ? _draft.copyWith(clearPrice: true) : _draft.copyWith(priceRange: v);
                }),
              ),
              _title(l10n.minRating),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: [
                  for (final r in const [0.0, 4.0, 4.5])
                    CovaChip(
                      label: r == 0 ? l10n.anyRating : '${r.toString()}+',
                      icon: r == 0 ? null : Icons.star_rounded,
                      selected: _draft.minRating == r,
                      onTap: () => setState(() => _draft = _draft.copyWith(minRating: r)),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.onlyOffers, style: const TextStyle(fontWeight: FontWeight.w700)),
                value: _draft.onlyOffers,
                onChanged: (v) => setState(() => _draft = _draft.copyWith(onlyOffers: v)),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: l10n.showItems(count),
                onPressed: count == 0 ? null : () => Navigator.of(context).pop(_draft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
