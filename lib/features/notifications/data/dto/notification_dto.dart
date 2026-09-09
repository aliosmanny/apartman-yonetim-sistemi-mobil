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
    int parsedId = 0;
    if (json['id'] is int) {
      parsedId = json['id'] as int;
    } else if (json['id'] != null) {
      parsedId = int.tryParse(json['id'].toString()) ?? 0;
    }

    return NotificationDto(
      id: parsedId,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 'true' || json['is_read'] == 1,
      link: json['link']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
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
