import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String? link;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.link,
    required this.createdAt,
  });

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    bool? isRead,
    String? link,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, message, isRead, link, createdAt];
}
