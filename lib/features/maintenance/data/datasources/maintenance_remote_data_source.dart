import 'package:dio/dio.dart';
import '../dto/maintenance_dto.dart';
import 'package:image_picker/image_picker.dart';

abstract class MaintenanceRemoteDataSource {
  Future<List<MaintenanceDto>> getMaintenanceRequests({String? status, String? category});
  Future<MaintenanceDto> getMaintenanceRequestDetails(String id);
  Future<MaintenanceDto> createMaintenanceRequest(Map<String, dynamic> data, {XFile? image});
  Future<MaintenanceDto> updateMaintenanceStatus(String id, String status, {String? note});
}

class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {
  final Dio _dio;

  MaintenanceRemoteDataSourceImpl(this._dio);

  @override
  Future<List<MaintenanceDto>> getMaintenanceRequests({String? status, String? category}) async {
    final queryParameters = <String, dynamic>{};
    if (status != null && status.isNotEmpty) queryParameters['status'] = status;
    if (category != null && category.isNotEmpty) queryParameters['category'] = category;

    final response = await _dio.get('/maintenance-requests/', queryParameters: queryParameters);
    
    // Backend DRF ise pagination (results) veya direkt liste dönebilir
    final data = response.data;
    List<dynamic> listData = [];
    if (data is Map<String, dynamic> && data.containsKey('results')) {
      listData = data['results'] as List<dynamic>;
    } else if (data is List) {
      listData = data;
    }

    return listData.map((e) => MaintenanceDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<MaintenanceDto> getMaintenanceRequestDetails(String id) async {
    final response = await _dio.get('/maintenance-requests/$id/');
    return MaintenanceDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MaintenanceDto> createMaintenanceRequest(Map<String, dynamic> data, {XFile? image}) async {
    if (image != null) {
      final formData = FormData.fromMap({
        ...data,
        'image': await MultipartFile.fromFile(image.path, filename: image.name),
      });
      final response = await _dio.post('/maintenance-requests/', data: formData);
      return MaintenanceDto.fromJson(response.data as Map<String, dynamic>);
    } else {
      final response = await _dio.post('/maintenance-requests/', data: data);
      return MaintenanceDto.fromJson(response.data as Map<String, dynamic>);
    }
  }

  @override
  Future<MaintenanceDto> updateMaintenanceStatus(String id, String status, {String? note}) async {
    final data = <String, dynamic>{
      'status': status,
    };
    if (note != null && note.isNotEmpty) {
      data['note'] = note;
    }
    final response = await _dio.patch('/maintenance-requests/$id/status/', data: data);
    
    // update statu endpoint'i sadece status günceller. Tam detay dönmeyebilir, dönüyorsa parse edelim:
    if (response.data is Map<String, dynamic> && response.data.containsKey('id')) {
      return MaintenanceDto.fromJson(response.data as Map<String, dynamic>);
    }
    // Eğer dönmüyorsa güncel datayı tekrar çekelim
    return getMaintenanceRequestDetails(id);
  }
}
