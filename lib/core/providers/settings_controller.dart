import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/local_store.dart';
import 'app_providers.dart';

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.locale,
    required this.onboardingSeen,
    this.notificationsEnabled = true,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final bool onboardingSeen;
  final bool notificationsEnabled;

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale, bool? onboardingSeen, bool? notificationsEnabled}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        onboardingSeen: onboardingSeen ?? this.onboardingSeen,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );
}

class SettingsController extends Notifier<AppSettings> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  AppSettings build() {
    final theme = ThemeMode.values.asNameMap()[_store.readString(StoreKeys.theme)] ?? ThemeMode.system;
    final deviceLang = ui.PlatformDispatcher.instance.locale.languageCode == 'ar' ? 'ar' : 'en';
    final lang = _store.readString(StoreKeys.language) ?? deviceLang;
    return AppSettings(
      themeMode: theme,
      locale: Locale(lang),
      onboardingSeen: _store.readBool(StoreKeys.onboardingSeen) ?? false,
      notificationsEnabled: _store.readBool(StoreKeys.notifications) ?? true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _store.writeString(StoreKeys.theme, mode.name);
  }

  Future<void> setLanguage(String languageCode) async {
    state = state.copyWith(locale: Locale(languageCode));
    await _store.writeString(StoreKeys.language, languageCode);
  }

  Future<void> setNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _store.writeBool(StoreKeys.notifications, enabled);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingSeen: true);
    await _store.writeBool(StoreKeys.onboardingSeen, true);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
