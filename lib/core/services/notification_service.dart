import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/notifications/data/repositories/i_notification_repository.dart';
import 'package:wise_spends/features/notifications/data/repositories/impl/notification_repository.dart';

/// Top-level handler required by FCM for background/terminated messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by the time this runs because
  // FlutterLocalNotificationsPlugin.initialize() has been called.
  WiseLogger().info('Background FCM: ${message.messageId}', tag: 'FCM');
  await NotificationService._saveMessage(message);
}

/// Manages FCM token, message handling, and local notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  static const _channelId = 'wise_spends_main';
  static const _channelName = 'Wise Spends';
  static const _channelDesc = 'Wise Spends general notifications';

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // ── Public API ──────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    await _requestPermission();
    await _setupLocalNotifications();
    _setupForegroundHandler();
    _setupTokenRefresh();
    await _fetchToken();
    // Background handler is registered in main() before Firebase.initializeApp
  }

  /// Called from main() BEFORE Firebase.initializeApp to register the
  /// background handler.
  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Returns the current FCM token (useful for testing / server config).
  Future<String?> getToken() async {
    _fcmToken ??= await _fcm.getToken();
    return _fcmToken;
  }

  // ── Private setup ───────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    WiseLogger().info(
      'FCM permission: ${settings.authorizationStatus}',
      tag: 'FCM',
    );
  }

  Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      WiseLogger().info('Foreground FCM: ${message.messageId}', tag: 'FCM');
      await _saveMessage(message);
      _showLocalNotification(message);
    });
  }

  void _setupTokenRefresh() {
    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
      WiseLogger().info('FCM token refreshed: $token', tag: 'FCM');
    });
  }

  Future<void> _fetchToken() async {
    try {
      _fcmToken = await _fcm.getToken();
      WiseLogger().info('FCM token: $_fcmToken', tag: 'FCM');
    } catch (e) {
      WiseLogger().error('FCM token fetch error', error: e, tag: 'FCM');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    WiseLogger().info('Notification tapped: ${response.payload}', tag: 'FCM');
    // Navigation is handled at the app level via the payload
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );
    final details = NotificationDetails(android: androidDetails);

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }

  // ── Shared save logic (used by foreground + background handlers) ────────────

  static Future<void> _saveMessage(RemoteMessage message) async {
    try {
      // Ensure singleton is available (background isolate may need it)
      INotificationRepository repo;
      final existing = SingletonUtil.getSingleton<INotificationRepository>();
      if (existing != null) {
        repo = existing;
      } else {
        repo = NotificationRepository();
        SingletonUtil.registerSingleton<INotificationRepository>(repo);
      }

      final notification = message.notification;
      final title =
          notification?.title ??
          (message.data['title'] as String? ?? 'New notification');
      final body =
          notification?.body ?? (message.data['body'] as String? ?? '');
      final type = message.data['type'] as String? ?? 'general';
      final dataJson = jsonEncode(message.data);

      await repo.saveNotification(
        title: title,
        body: body,
        dataJson: dataJson,
        type: type,
        messageId: message.messageId,
      );
    } catch (e) {
      if (kDebugMode) print('[FCM] saveMessage error: $e');
    }
  }
}
