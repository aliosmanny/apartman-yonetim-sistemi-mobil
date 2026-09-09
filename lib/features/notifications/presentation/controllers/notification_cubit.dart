import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../../core/services/local_notification_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;
  final LocalNotificationService _notifService = LocalNotificationService();

  /// Daha önce gösterilmiş bildirim ID'leri – tekrar gösterme
  final Set<int> _shownNotificationIds = {};

  NotificationCubit(this._repository) : super(NotificationInitial());

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await _repository.getNotifications();
      final unreadCount = await _repository.getUnreadCount();

      // Yeni okunmamış bildirimleri tespit et ve local push olarak göster
      final unreadNotifications = notifications.where((n) => !n.isRead).toList();
      for (final n in unreadNotifications) {
        if (!_shownNotificationIds.contains(n.id)) {
          _shownNotificationIds.add(n.id);
          // İlk yüklemede sessizce ekle; sonraki fetch'lerde göster
        }
      }

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Arka planda yeni bildirim kontrolü – uygulama açıkken çağrılır.
  /// Shell'den periyodik olarak bu metot çağrılabilir.
  Future<void> checkForNewNotifications() async {
    try {
      final notifications = await _repository.getNotifications();
      final unreadCount = await _repository.getUnreadCount();

      // Daha önce gösterilmemiş yeni bildirimleri local push yap
      for (final n in notifications) {
        if (!n.isRead && !_shownNotificationIds.contains(n.id)) {
          _shownNotificationIds.add(n.id);
          await _notifService.showNotification(
            id: n.id,
            title: n.title,
            body: n.message,
          );
        }
      }

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (_) {
      // Arka plan kontrolü sessizce başarısız olabilir
    }
  }

  Future<void> markAsRead(int id) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    try {
      await _repository.markAsRead(id);
      
      // Update local state instead of refetching everything
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == id && !n.isRead) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      final newUnreadCount = (currentState.unreadCount - 1).clamp(0, 999);
      
      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (e) {
      // Ignore background errors for mark as read, or handle if needed
    }
  }

  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    try {
      await _repository.markAllAsRead();
      
      final updatedNotifications = currentState.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      ));
    } catch (e) {
      // Error handling
    }
  }
}
