import '../../domain/models/notification.dart';

class NotificationDto {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String? link;
  final String createdAt;

  const NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.link,
    required this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      link: json['link'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  NotificationModel toModel() {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      isRead: isRead,
      link: link,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
