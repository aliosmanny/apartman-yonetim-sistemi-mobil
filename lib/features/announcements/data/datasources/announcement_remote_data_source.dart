import 'package:dio/dio.dart';
import '../dto/announcement_dto.dart';

abstract class AnnouncementRemoteDataSource {
  Future<List<AnnouncementDto>> getAnnouncements({String? status});
  Future<AnnouncementDto> getAnnouncementDetails(int id);
  Future<AnnouncementDto> createAnnouncement(Map<String, dynamic> data);
  Future<AnnouncementDto> updateAnnouncement(int id, Map<String, dynamic> data);
  Future<void> deleteAnnouncement(int id);
}

class AnnouncementRemoteDataSourceImpl implements AnnouncementRemoteDataSource {
  final Dio _dio;

  AnnouncementRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AnnouncementDto>> getAnnouncements({String? status}) async {
    final Map<String, dynamic> queryParams = {};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _dio.get('/announcements/', queryParameters: queryParams);
    
    List<dynamic> data;
    if (response.data is Map && response.data['results'] != null) {
      data = response.data['results'];
    } else if (response.data is List) {
      data = response.data;
    } else {
      data = [];
    }
    
    return data.map((json) => AnnouncementDto.fromJson(json)).toList();
  }

  @override
  Future<AnnouncementDto> getAnnouncementDetails(int id) async {
    final response = await _dio.get('/announcements/$id/');
    return AnnouncementDto.fromJson(response.data);
  }

  @override
  Future<AnnouncementDto> createAnnouncement(Map<String, dynamic> data) async {
    final response = await _dio.post('/announcements/', data: data);
    return AnnouncementDto.fromJson(response.data);
  }

  @override
  Future<AnnouncementDto> updateAnnouncement(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/announcements/$id/', data: data);
    return AnnouncementDto.fromJson(response.data);
  }

  @override
  Future<void> deleteAnnouncement(int id) async {
    await _dio.delete('/announcements/$id/');
  }
}
