import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/services/local_store.dart';
import '../auth/auth_controller.dart';

/// Last searches (newest first, max 8), stored per user.
class RecentSearchesController extends Notifier<List<String>> {
  late String _key;

  @override
  List<String> build() {
    _key = StoreKeys.recentSearches(ref.watch(userIdProvider));
    final raw = ref.read(localStoreProvider).readJson(_key);
    return raw is List ? raw.map((e) => e as String).toList() : <String>[];
  }

  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    _save([q, ...state.where((e) => e.toLowerCase() != q.toLowerCase())].take(8).toList());
  }

  void remove(String query) => _save(state.where((e) => e != query).toList());

  void clear() => _save(const []);

  void _save(List<String> next) {
    state = next;
    ref.read(localStoreProvider).writeJson(_key, next);
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesController, List<String>>(RecentSearchesController.new);
