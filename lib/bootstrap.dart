import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/injection.dart';
import 'core/services/local_notification_service.dart';
import 'app/app.dart';

/// Uygulama başlatma noktası.
/// DI container'ı başlatır, sistem UI ayarlarını yapar, uygulamayı çalıştırır.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sistem UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Dikey yön kilidi
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dependency Injection başlat
  await initDependencies();

  // Yerel bildirim servisi başlat
  final notifService = LocalNotificationService();
  await notifService.initialize();
  await notifService.createNotificationChannel();

  runApp(const App());
}
