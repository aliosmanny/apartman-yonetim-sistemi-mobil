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
      List<dynamic> results;
      if (response.data is Map && response.data['results'] != null) {
        results = response.data['results'] as List;
      } else if (response.data is List) {
        results = response.data as List;
      } else {
        results = [];
      }
      return results.map((e) => NotificationDto.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count/');
      if (response.data is Map) {
        final val = response.data['unread_count'] ?? response.data['count'];
        if (val is int) return val;
        if (val is String) return int.tryParse(val) ?? 0;
      } else if (response.data is int) {
        return response.data as int;
      }
      return 0;
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
