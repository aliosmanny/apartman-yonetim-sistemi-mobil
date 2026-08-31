import '../models/announcement.dart';

abstract class AnnouncementRepository {
  Future<List<Announcement>> getAnnouncements({String? status});
  Future<Announcement> getAnnouncementDetails(int id);
  Future<Announcement> createAnnouncement({
    required String title,
    required String content,
    int? apartmentId,
    String? status,
  });
  Future<Announcement> updateAnnouncement(int id, {
    String? title,
    String? content,
    int? apartmentId,
    String? status,
  });
  Future<void> deleteAnnouncement(int id);
}
