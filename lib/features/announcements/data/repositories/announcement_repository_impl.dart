import '../../domain/models/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_data_source.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource _remoteDataSource;

  AnnouncementRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Announcement>> getAnnouncements({String? status}) async {
    final dtos = await _remoteDataSource.getAnnouncements(status: status);
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<Announcement> getAnnouncementDetails(int id) async {
    final dto = await _remoteDataSource.getAnnouncementDetails(id);
    return dto.toModel();
  }

  @override
  Future<Announcement> createAnnouncement({
    required String title,
    required String content,
    int? apartmentId,
    String? status,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'content': content,
    };
    if (status != null) data['status'] = status;
    if (apartmentId != null) data['apartment_id'] = apartmentId;
    
    final dto = await _remoteDataSource.createAnnouncement(data);
    return dto.toModel();
  }

  @override
  Future<Announcement> updateAnnouncement(int id, {
    String? title,
    String? content,
    int? apartmentId,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (status != null) data['status'] = status;
    if (apartmentId != null) data['apartment_id'] = apartmentId;

    final dto = await _remoteDataSource.updateAnnouncement(id, data);
    return dto.toModel();
  }

  @override
  Future<void> deleteAnnouncement(int id) async {
    await _remoteDataSource.deleteAnnouncement(id);
  }
}
