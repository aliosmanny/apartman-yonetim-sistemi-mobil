import '../../domain/models/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final dtos = await remoteDataSource.getNotifications();
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<int> getUnreadCount() {
    return remoteDataSource.getUnreadCount();
  }

  @override
  Future<void> markAsRead(int id) {
    return remoteDataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() {
    return remoteDataSource.markAllAsRead();
  }
}
