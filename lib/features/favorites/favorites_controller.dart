import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/services/local_store.dart';
import '../auth/auth_controller.dart';

class FavoritesController extends Notifier<Set<String>> {
  late String _key;

  @override
  Set<String> build() {
    _key = StoreKeys.favorites(ref.watch(userIdProvider));
    final raw = ref.read(localStoreProvider).readJson(_key);
    return raw is List ? raw.map((e) => e as String).toSet() : <String>{};
  }

  void toggle(String productId) {
    final next = {...state};
    if (!next.remove(productId)) next.add(productId);
    state = next;
    ref.read(localStoreProvider).writeJson(_key, next.toList());
  }
}

final favoritesProvider = NotifierProvider<FavoritesController, Set<String>>(FavoritesController.new);

final isFavoriteProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(favoritesProvider.select((s) => s.contains(id))),
);
