import 'package:dio/dio.dart';
import '../dto/user_dto.dart';

abstract class UserRemoteDataSource {
  Future<List<UserDto>> getUsers();
  Future<UserDto> createUser(Map<String, dynamic> data);
  Future<UserDto> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id);
  Future<void> saveDeviceToken(String token, String deviceType);
  Future<Map<String, dynamic>> getNotificationPreferences();
  Future<void> updateNotificationPreferences(Map<String, dynamic> data);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<List<UserDto>> getUsers() async {
    final response = await _dio
        .get('/users/', queryParameters: {'page_size': 1000, 'limit': 1000});

    List<dynamic> data;
    if (response.data is Map && response.data['results'] != null) {
      data = response.data['results'];
    } else if (response.data is List) {
      data = response.data;
    } else {
      data = [];
    }

    return data.map((json) => UserDto.fromJson(json)).toList();
  }

  @override
  Future<UserDto> createUser(Map<String, dynamic> data) async {
    try {
      final role = data['role'];
      if (role == 'owner') {
        await _dio.post('/owners/', data: data);
        return UserDto(
            id: 0,
            phone: '',
            firstName: '',
            lastName: '',
            role: '',
            isActive: true,
            isStaff: false,
            isSuperuser: false,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String());
      } else if (role == 'tenant') {
        await _dio.post('/tenants/', data: data);
        return UserDto(
            id: 0,
            phone: '',
            firstName: '',
            lastName: '',
            role: '',
            isActive: true,
            isStaff: false,
            isSuperuser: false,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String());
      } else {
        final response = await _dio.post('/users/', data: data);
        return UserDto.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw Exception('API Hatası: ${e.response?.data}');
    }
  }

  @override
  Future<UserDto> updateUser(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/users/$id/', data: data);
    return UserDto.fromJson(response.data);
  }

  @override
  Future<void> deleteUser(int id) async {
    await _dio.delete('/users/$id/');
  }

  @override
  Future<void> saveDeviceToken(String token, String deviceType) async {
    try {
      await _dio.post(
        '/users/device-token/',
        data: {
          'fcm_token': token,
          'device_type': deviceType,
        },
      );
    } catch (e) {
      // Sessizce yut, ana akışı bozmasın
    }
  }

  @override
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final response = await _dio.get('/users/notification-preferences/');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> updateNotificationPreferences(Map<String, dynamic> data) async {
    await _dio.patch('/users/notification-preferences/', data: data);
  }
}
