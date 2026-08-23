import '../../domain/models/announcement.dart';

class AnnouncementDto {
  final int id;
  final int? apartment;
  final String? apartmentName;
  final String title;
  final String content;
  final String status;
  final String? statusDisplay;
  final String? publishDate;
  final int? createdBy;
  final String? createdByName;
  final String createdAt;

  AnnouncementDto({
    required this.id,
    this.apartment,
    this.apartmentName,
    required this.title,
    required this.content,
    required this.status,
    this.statusDisplay,
    this.publishDate,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
  });

  factory AnnouncementDto.fromJson(Map<String, dynamic> json) {
    return AnnouncementDto(
      id: json['id'] as int,
      apartment: json['apartment'] as int?,
      apartmentName: json['apartment_name'] as String?,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? 'published',
      statusDisplay: json['status_display'],
      publishDate: json['publish_date'],
      createdBy: json['created_by'] as int?,
      createdByName: json['created_by_name'] as String?,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Announcement toModel() {
    return Announcement(
      id: id,
      apartmentId: apartment,
      apartmentName: apartmentName,
      title: title,
      content: content,
      status: status,
      statusDisplay: statusDisplay,
      publishDate: publishDate != null ? DateTime.tryParse(publishDate!) : null,
      createdById: createdBy,
      createdByName: createdByName,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
