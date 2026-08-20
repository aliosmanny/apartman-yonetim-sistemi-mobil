import 'package:dio/dio.dart';
import '../dto/notification_dto.dart';
import '../../../../core/network/api_exception.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationDto>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NotificationDto>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications/');
      final results = response.data['results'] as List;
      return results.map((e) => NotificationDto.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count/');
      return response.data['unread_count'] as int? ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    try {
      await _dio.post('/notifications/$id/read/');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/notifications/mark-all-read/');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
