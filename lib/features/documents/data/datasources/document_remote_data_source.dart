import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../dto/document_dto.dart';

abstract class DocumentRemoteDataSource {
  Future<List<DocumentDto>> getDocuments({String? category, String? status});
  Future<DocumentDto> createDocument(Map<String, dynamic> data, {XFile? file});
  Future<DocumentDto> updateDocument(int id, Map<String, dynamic> data, {XFile? file});
  Future<void> deleteDocument(int id);
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final Dio _dio;

  DocumentRemoteDataSourceImpl(this._dio);

  @override
  Future<List<DocumentDto>> getDocuments({String? category, String? status}) async {
    final Map<String, dynamic> queryParams = {};
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await _dio.get('/documents/', queryParameters: queryParams);
    
    List<dynamic> data;
    if (response.data is Map && response.data['results'] != null) {
      data = response.data['results'];
    } else if (response.data is List) {
      data = response.data;
    } else {
      data = [];
    }
    
    return data.map((json) => DocumentDto.fromJson(json)).toList();
  }

  @override
  Future<DocumentDto> createDocument(Map<String, dynamic> data, {XFile? file}) async {
    FormData formData = FormData.fromMap(data);
    
    if (file != null) {
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(file.path, filename: file.name),
      ));
    }

    final response = await _dio.post('/documents/', data: formData);
    return DocumentDto.fromJson(response.data);
  }

  @override
  Future<DocumentDto> updateDocument(int id, Map<String, dynamic> data, {XFile? file}) async {
    FormData formData = FormData.fromMap(data);
    
    if (file != null) {
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(file.path, filename: file.name),
      ));
    }

    final response = await _dio.patch('/documents/$id/', data: formData);
    return DocumentDto.fromJson(response.data);
  }

  @override
  Future<void> deleteDocument(int id) async {
    await _dio.delete('/documents/$id/');
  }
}
