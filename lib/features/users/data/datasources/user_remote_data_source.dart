import 'package:dio/dio.dart';
import '../dto/user_dto.dart';

abstract class UserRemoteDataSource {
  Future<List<UserDto>> getUsers();
  Future<UserDto> createUser(Map<String, dynamic> data);
  Future<UserDto> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<List<UserDto>> getUsers() async {
    final response = await _dio.get('/users/');
    
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
    final response = await _dio.post('/users/', data: data);
    return UserDto.fromJson(response.data);
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
}
