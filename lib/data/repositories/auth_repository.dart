import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/user_profile.dart';
import '../services/local_store.dart';

enum AuthFailure { emailInUse, invalidCredentials }

class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;
}

/// LOCAL demo authentication (accounts live on the device only).
/// Keep this interface and swap the implementation for Firebase / your API.
class AuthRepository {
  AuthRepository(this._store);

  final LocalStore _store;
  static const _salt = 'cova-mart-demo-salt';

  Map<String, dynamic> _users() {
    final raw = _store.readJson(StoreKeys.users);
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  String _hash(String password) => sha256.convert(utf8.encode('$_salt$password')).toString();

  UserProfile? currentUser() {
    final email = _store.readString(StoreKeys.session);
    if (email == null) return null;
    final record = _users()[email];
    if (record is! Map) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(record['profile'] as Map));
  }

  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final users = _users();
    final key = email.trim().toLowerCase();
    if (users.containsKey(key)) throw const AuthException(AuthFailure.emailInUse);
    final profile = UserProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      email: key,
      phone: phone.trim(),
    );
    users[key] = {'profile': profile.toJson(), 'hash': _hash(password)};
    await _store.writeJson(StoreKeys.users, users);
    await _store.writeString(StoreKeys.session, key);
    return profile;
  }

  Future<UserProfile> login({required String email, required String password}) async {
    final key = email.trim().toLowerCase();
    final record = _users()[key];
    if (record is! Map || record['hash'] != _hash(password)) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    await _store.writeString(StoreKeys.session, key);
    return UserProfile.fromJson(Map<String, dynamic>.from(record['profile'] as Map));
  }

  Future<void> saveProfile(UserProfile profile) async {
    final users = _users();
    final record = users[profile.email];
    if (record is! Map) return;
    users[profile.email] = {'profile': profile.toJson(), 'hash': record['hash']};
    await _store.writeJson(StoreKeys.users, users);
  }

  Future<void> logout() => _store.remove(StoreKeys.session);
}
