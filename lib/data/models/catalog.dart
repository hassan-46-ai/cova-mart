import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../../core/utils/text_utils.dart';
import 'category.dart';
import 'product.dart';

/// Immutable in-memory product catalogue loaded from `assets/data/catalog.json`.
/// Swap [Catalog.load] for an API call when a backend exists.
class Catalog {
  Catalog({required this.categories, required this.products})
      : _productById = {for (final p in products) p.id: p},
        _categoryById = {for (final c in categories) c.id: c},
        _byCategory = _group(products),
        _searchIndex = {
          for (final p in products) p.id: '${normalizeSearch(p.nameEn)} ${normalizeSearch(p.nameAr)}',
        };

  static Future<Catalog> load() async {
    final raw = await rootBundle.loadString('assets/data/catalog.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Catalog(
      categories: [for (final c in json['categories'] as List) Category.fromJson(c as Map<String, dynamic>)],
      products: [for (final p in json['products'] as List) Product.fromJson(p as Map<String, dynamic>)],
    );
  }

  static Map<String, List<Product>> _group(List<Product> products) {
    final map = <String, List<Product>>{};
    for (final p in products) {
      map.putIfAbsent(p.categoryId, () => []).add(p);
    }
    return map;
  }

  final List<Category> categories;
  final List<Product> products;
  final Map<String, Product> _productById;
  final Map<String, Category> _categoryById;
  final Map<String, List<Product>> _byCategory;
  final Map<String, String> _searchIndex;

  // Sorted once, reused on every rebuild.
  late final List<Product> _recommended = (products.where((p) => p.inStock).toList()
    ..sort((a, b) => _score(b).compareTo(_score(a))));
  late final List<Product> _deals = (products.where((p) => p.hasDiscount && p.inStock).toList()
    ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent)));
  late final Map<String, double> _startingPrice = {
    for (final e in _byCategory.entries) e.key: e.value.map((p) => p.price).reduce(math.min),
  };

  Product? product(String id) => _productById[id];
  Category? category(String id) => _categoryById[id];

  List<Product> inCategory(String categoryId) => _byCategory[categoryId] ?? const [];

  double startingPrice(String categoryId) => _startingPrice[categoryId] ?? 0;

  /// Best rated + most reviewed products that are in stock.
  List<Product> recommended({int limit = 12}) => _recommended.take(limit).toList();

  List<Product> deals({int limit = 12}) => _deals.take(limit).toList();

  List<Product> related(Product product, {int limit = 8}) => inCategory(product.categoryId)
      .where((p) => p.id != product.id && p.inStock)
      .take(limit)
      .toList();

  List<Product> search(String query) {
    final q = normalizeSearch(query);
    if (q.isEmpty) return const [];
    return [
      for (final p in products)
        if (_searchIndex[p.id]!.contains(q)) p,
    ];
  }

  double _score(Product p) => p.rating * (1 + p.reviews / 500);
}
