import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(NotificationInitial());

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await _repository.getNotifications();
      final unreadCount = await _repository.getUnreadCount();
      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
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
