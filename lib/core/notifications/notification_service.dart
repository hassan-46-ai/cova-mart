import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/order.dart';
import '../l10n/app_localizations.dart';

/// Order-status notifications.
///
/// Today these are LOCAL notifications: when an order is placed, the three
/// upcoming status changes are scheduled on the phone (so they also arrive when
/// the app is closed). When a backend exists, replace [scheduleOrderUpdates]
/// with Firebase Cloud Messaging: the server sends the push when the real
/// status changes. Everything else (permission, tap handling, settings switch)
/// stays the same.
class NotificationService {
  NotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  String? _launchPayload;

  /// Called when the user taps a notification while the app is running.
  void Function(String payload)? onOpen;

  static const _channelId = 'order_updates';

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null) onOpen?.call(payload);
        },
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _launchPayload = launch!.notificationResponse?.payload;
      }
      _ready = true;
    } catch (_) {
      _ready = false; // notifications must never block app start-up
    }
  }

  /// Route of the notification that cold-started the app (returned once).
  String? takeLaunchPayload() {
    final p = _launchPayload;
    _launchPayload = null;
    return p;
  }

  /// Asks the OS for permission. Returns true when notifications are allowed.
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) return await android.requestNotificationsPermission() ?? false;
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();

  /// Schedules "preparing", "on the way" and "delivered" for [order].
  Future<void> scheduleOrderUpdates(Order order, Locale locale) async {
    if (!_ready) return;
    final l10n = AppLocalizations(locale);
    final bodies = <OrderStatus, String>{
      OrderStatus.preparing: l10n.notifPreparingBody,
      OrderStatus.onTheWay: l10n.notifOnTheWayBody,
      OrderStatus.delivered: l10n.notifDeliveredBody,
    };
    final now = DateTime.now();

    for (final entry in bodies.entries) {
      final seconds = Order.stageSeconds[entry.key]!;
      final fireAt = order.createdAt.add(Duration(seconds: seconds));
      if (!fireAt.isAfter(now)) continue;
      await _schedule(
        id: _id(order.id, entry.key),
        title: l10n.notifOrderTitle(order.id),
        body: entry.value,
        when: tz.TZDateTime.from(fireAt, tz.UTC),
        payload: '/order/${order.id}',
        l10n: l10n,
      );
    }
  }

  Future<void> cancelOrder(String orderId) async {
    if (!_ready) return;
    for (final status in Order.stageSeconds.keys) {
      await _plugin.cancel(_id(orderId, status));
    }
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }

  int _id(String orderId, OrderStatus status) {
    final digits = int.tryParse(orderId.replaceAll(RegExp(r'\D'), '')) ?? orderId.hashCode.abs() % 1000000;
    return digits * 10 + status.index;
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required String payload,
    required AppLocalizations l10n,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.notifChannelName,
        channelDescription: l10n.notifChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    Future<void> go(AndroidScheduleMode mode) => _plugin.zonedSchedule(
          id,
          title,
          body,
          when,
          details,
          androidScheduleMode: mode,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );

    try {
      await go(AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException {
      // Exact alarms not allowed on this device: fall back (may arrive a bit later).
      try {
        await go(AndroidScheduleMode.inexactAllowWhileIdle);
      } catch (_) {}
    } catch (_) {}
  }
}
