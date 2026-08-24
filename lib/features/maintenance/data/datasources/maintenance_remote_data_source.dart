import 'package:dio/dio.dart';
import '../dto/maintenance_dto.dart';
import 'package:image_picker/image_picker.dart';

abstract class MaintenanceRemoteDataSource {
  Future<List<MaintenanceDto>> getMaintenanceRequests({String? status, String? category});
  Future<MaintenanceDto> getMaintenanceRequestDetails(String id);
  Future<MaintenanceDto> createMaintenanceRequest(Map<String, dynamic> data, {XFile? image});
  Future<MaintenanceDto> updateMaintenanceStatus(String id, String status, {String? note, int? assignedStaffId});
  Future<MaintenanceDto> updateAssignedStaff(String id, int staffId);
  Future<MaintenanceDto> updateStaffNote(String id, {String? staffNote, XFile? staffPhoto});
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
  Future<MaintenanceDto> updateMaintenanceStatus(String id, String status, {String? note, int? assignedStaffId}) async {
    // Önce personel atamasını yap (ayrı endpoint)
    if (assignedStaffId != null) {
      await updateAssignedStaff(id, assignedStaffId);
    }

    final data = <String, dynamic>{'status': status};
    if (note != null && note.isNotEmpty) {
      data['note'] = note;
    }
    final response = await _dio.patch('/maintenance-requests/$id/status/', data: data);
    
    if (response.data is Map<String, dynamic> && response.data.containsKey('id')) {
      return MaintenanceDto.fromJson(response.data as Map<String, dynamic>);
    }
    return getMaintenanceRequestDetails(id);
  }

  @override
  Future<MaintenanceDto> updateAssignedStaff(String id, int staffId) async {
    // /maintenance-requests/{id}/ PATCH endpoint'i assigned_to alanını kabul ediyor
    final response = await _dio.patch(
      '/maintenance-requests/$id/',
      data: {'assigned_to': staffId},
    );
    if (response.data is Map<String, dynamic> && response.data.containsKey('id')) {
      return MaintenanceDto.fromJson(response.data as Map<String, dynamic>);
    }
    return getMaintenanceRequestDetails(id);
  }

  @override
  Future<MaintenanceDto> updateStaffNote(String id, {String? staffNote, XFile? staffPhoto}) async {
    if (staffPhoto != null) {
      final formData = FormData.fromMap({
        if (staffNote != null) 'staff_note': staffNote,
        'staff_photo': await MultipartFile.fromFile(staffPhoto.path, filename: staffPhoto.name),
      });
      final response = await _dio.patch('/maintenance-requests/$id/', data: formData);
      if (response.data is Map<String, dynamic> && response.data.containsKey('id')) {
        return MaintenanceDto.fromJson(response.data as Map<String, dynamic>);
      }
    } else if (staffNote != null) {
      final response = await _dio.patch('/maintenance-requests/$id/', data: {'staff_note': staffNote});
      if (response.data is Map<String, dynamic> && response.data.containsKey('id')) {
        return MaintenanceDto.fromJson(response.data as Map<String, dynamic>);
      }
    }
    return getMaintenanceRequestDetails(id);
  }
}
