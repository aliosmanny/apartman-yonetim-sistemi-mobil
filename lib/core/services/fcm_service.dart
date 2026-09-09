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
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // İzin iste (iOS & Android 13+)
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Foreground mesaj dinleyicisi
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          LocalNotificationService().showNotification(
            id: message.hashCode,
            title: notification.title ?? 'Yeni Bildirim',
            body: notification.body ?? '',
          );
        }
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
      if (!_initialized) await initialize();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        _lastToken = token;
        final remoteDs = sl<NotificationRemoteDataSource>();
        await remoteDs.registerDeviceToken(
          token,
          deviceType: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        );
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
        await remoteDs.deleteDeviceToken(_lastToken!);
      }
      await FirebaseMessaging.instance.deleteToken();
      _lastToken = null;
    } catch (e) {
      debugPrint('FCM token deletion failed: $e');
    }
  }
}
