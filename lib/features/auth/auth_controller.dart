import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/local_store.dart';

/// Current signed-in user (null = signed out).
class AuthController extends Notifier<UserProfile?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  UserProfile? build() => _repo.currentUser();

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = await _repo.signUp(name: name, email: email, phone: phone, password: password);
  }

  Future<void> login({required String email, required String password}) async {
    state = await _repo.login(email: email, password: password);
  }

  Future<void> logout() async {
    await _repo.logout();
    await ref.read(localStoreProvider).remove(StoreKeys.lastRoute);
    await ref.read(notificationServiceProvider).cancelAll();
    state = null;
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    final user = state;
    if (user == null) return;
    final updated = user.copyWith(name: name.trim(), phone: phone.trim());
    await _repo.saveProfile(updated);
    state = updated;
  }
}

final authProvider = NotifierProvider<AuthController, UserProfile?>(AuthController.new);

/// Id used to namespace per-user data (cart, orders…). Rebuilds only when the
/// user changes, not when the profile is edited.
final userIdProvider = Provider<String>((ref) => ref.watch(authProvider.select((u) => u?.id)) ?? 'guest');
