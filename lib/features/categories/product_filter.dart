import 'package:flutter/material.dart';

import '../../data/models/product.dart';

enum SortOption { popular, priceLow, priceHigh, rating, discount }

/// Immutable filter + sort settings for a product list.
class ProductFilter {
  const ProductFilter({
    this.sort = SortOption.popular,
    this.priceRange,
    this.onlyOffers = false,
    this.minRating = 0,
  });

  final SortOption sort;
  final RangeValues? priceRange;
  final bool onlyOffers;
  final double minRating;

  /// Number of non-default settings (shown on the filter button).
  int get activeCount =>
      (sort != SortOption.popular ? 1 : 0) +
      (priceRange != null ? 1 : 0) +
      (onlyOffers ? 1 : 0) +
      (minRating > 0 ? 1 : 0);

  ProductFilter copyWith({
    SortOption? sort,
    RangeValues? priceRange,
    bool clearPrice = false,
    bool? onlyOffers,
    double? minRating,
  }) =>
      ProductFilter(
        sort: sort ?? this.sort,
        priceRange: clearPrice ? null : (priceRange ?? this.priceRange),
        onlyOffers: onlyOffers ?? this.onlyOffers,
        minRating: minRating ?? this.minRating,
      );

  List<Product> apply(List<Product> input) {
    final list = input.where((p) {
      if (onlyOffers && !p.hasDiscount) return false;
      if (p.rating < minRating) return false;
      final range = priceRange;
      if (range != null && (p.price < range.start || p.price > range.end)) return false;
      return true;
    }).toList();

    list.sort((a, b) {
      if (a.inStock != b.inStock) return a.inStock ? -1 : 1; // out-of-stock last
      switch (sort) {
        case SortOption.popular:
          return b.reviews.compareTo(a.reviews);
        case SortOption.priceLow:
          return a.price.compareTo(b.price);
        case SortOption.priceHigh:
          return b.price.compareTo(a.price);
        case SortOption.rating:
          final byRating = b.rating.compareTo(a.rating);
          return byRating != 0 ? byRating : b.reviews.compareTo(a.reviews);
        case SortOption.discount:
          return b.discountPercent.compareTo(a.discountPercent);
      }
    });
    return list;
  }
}
