import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/di/injection.dart';
import '../features/auth/presentation/controllers/auth_cubit.dart';
import '../features/auth/presentation/controllers/auth_state.dart';
import '../features/notifications/presentation/controllers/notification_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final AuthCubit _authCubit;
  NotificationCubit? _notificationCubit;
  Timer? _notificationTimer;
  StreamSubscription? _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authCubit = sl<AuthCubit>();

    // Auth durumuna göre bildirim polling'i başlat/durdur
    _authSub = _authCubit.stream.listen((state) {
      if (state is AuthAuthenticated) {
        _startNotificationPolling();
      } else {
        _stopNotificationPolling();
      }
    });
  }

  void _startNotificationPolling() {
    _stopNotificationPolling();
    _notificationCubit = sl<NotificationCubit>();
    // İlk yükleme
    _notificationCubit?.fetchNotifications();
    // Her 2 dakikada bir yeni bildirim kontrolü (sunucu yükünü optimize eder)
    _notificationTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _notificationCubit?.checkForNewNotifications();
    });
    // Android 13+ bildirim izni iste
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {}
  }

  void _stopNotificationPolling() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
    _notificationCubit?.close();
    _notificationCubit = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama foreground'a gelince hemen kontrol et
    if (state == AppLifecycleState.resumed) {
      _notificationCubit?.checkForNewNotifications();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    _stopNotificationPolling();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(_authCubit);
          return MaterialApp.router(
            title: 'Apartman Yönetim Sistemi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: router,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
