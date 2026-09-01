import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/staff_dto.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffDto>> getStaffList();
  Future<StaffDto> createStaff(Map<String, dynamic> data);
  Future<StaffDto> updateStaff(int id, Map<String, dynamic> data);
  Future<void> deleteStaff(int id);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final ApiClient _apiClient;

  StaffRemoteDataSourceImpl(this._apiClient);

  @override
  Future<StaffDto> createStaff(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/staff/', data: data);
      return StaffDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is DioException) {
        throw ApiException(message: 'Hata detayı: ${e.response?.data}');
      }
      throw ApiException(message: 'Veri eklenirken hata: $e');
    }
  }

  @override
  Future<StaffDto> updateStaff(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/staff/$id/', data: data);
      return StaffDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is DioException) throw ApiException.fromDioException(e);
      throw ApiException(message: 'Veri güncellenirken hata: $e');
    }
  }

  @override
  Future<void> deleteStaff(int id) async {
    try {
      await _apiClient.dio.delete('/staff/$id/');
    } catch (e) {
      if (e is DioException) throw ApiException.fromDioException(e);
      throw ApiException(message: 'Veri silinirken hata: $e');
    }
  }

  @override
  Future<List<StaffDto>> getStaffList() async {
    try {
      final response = await _apiClient.dio.get('/staff/', queryParameters: {'page_size': 1000, 'limit': 1000});
      
      final data = response.data;
      List<dynamic> listData = [];
      if (data is Map<String, dynamic> && data.containsKey('results')) {
        listData = data['results'] as List<dynamic>;
      } else if (data is List) {
        listData = data;
      }
      
      return listData.map((e) => StaffDto.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is DioException) {
        throw ApiException.fromDioException(e);
      }
      throw ApiException(message: 'Veri işlenirken bir hata oluştu: $e');
    }
  }
}
