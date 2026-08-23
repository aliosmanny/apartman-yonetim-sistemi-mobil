class Announcement {
  final int id;
  final int? apartmentId;
  final String? apartmentName;
  final String title;
  final String content;
  final String status;
  final String? statusDisplay;
  final DateTime? publishDate;
  final int? createdById;
  final String? createdByName;
  final DateTime createdAt;

  const Announcement({
    required this.id,
    this.apartmentId,
    this.apartmentName,
    required this.title,
    required this.content,
    required this.status,
    this.statusDisplay,
    this.publishDate,
    this.createdById,
    this.createdByName,
    required this.createdAt,
  });

  bool get isPublished => status == 'published' || status == 'Yayında';
}
