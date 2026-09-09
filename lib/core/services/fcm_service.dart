import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../di/injection.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? message.data['heading'];
    final body = notification?.body ?? message.data['body'] ?? message.data['message'];
    
    // Eğer notification payload yoksa (sadece data payload geldiyse) yerel bildirim tetikle
    if (notification == null && (title != null || body != null)) {
      final local = LocalNotificationService();
      await local.initialize();
      await local.showNotification(
        id: message.hashCode,
        title: title?.toString() ?? 'Apartman Bildirimi',
        body: body?.toString() ?? '',
      );
    }
  } catch (_) {}
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  bool _initialized = false;
  String? _lastToken;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp().timeout(
        const Duration(seconds: 4),
        onTimeout: () => Firebase.app(),
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // İzin iste (iOS & Android 13+)
      try {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        ).timeout(const Duration(seconds: 3));
      } catch (_) {}

      // Foreground bildirim sunumu için (iOS)
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Foreground mesaj dinleyicisi (Uygulama açıkken)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final title = notification?.title ?? message.data['title'] ?? message.data['heading'] ?? 'Yeni Bildirim';
        final body = notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';

        LocalNotificationService().showNotification(
          id: message.hashCode,
          title: title.toString(),
          body: body.toString(),
        );
      });

      // Token yenilendiğinde backend'i güncelle
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _lastToken = newToken;
        syncTokenWithBackend();
      });

      _initialized = true;
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  /// Cihaz token'ını al ve Django backend'e kaydet
  Future<void> syncTokenWithBackend() async {
    try {
      if (!_initialized) {
        await initialize().timeout(const Duration(seconds: 4), onTimeout: () => null);
      }
      final token = await FirebaseMessaging.instance.getToken().timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );
      if (token != null && token.isNotEmpty) {
        _lastToken = token;
        final remoteDs = sl<NotificationRemoteDataSource>();
        await remoteDs.registerDeviceToken(
          token,
          deviceType: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        ).timeout(const Duration(seconds: 4), onTimeout: () => null);
        debugPrint('FCM Token successfully synced with backend: $token');
      }
    } catch (e) {
      debugPrint('FCM token sync failed: $e');
    }
  }

  /// Çıkış yapıldığında token kaydını backend'den sil
  Future<void> deleteTokenOnLogout() async {
    try {
      if (_lastToken != null) {
        final remoteDs = sl<NotificationRemoteDataSource>();
        await remoteDs.deleteDeviceToken(_lastToken!).timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        );
      }
      await FirebaseMessaging.instance.deleteToken().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      _lastToken = null;
    } catch (e) {
      debugPrint('FCM token deletion failed: $e');
    }
  }
}

