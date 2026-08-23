class AppDocument {
  final int id;
  final int? apartmentId;
  final String? apartmentName;
  final String title;
  final String? description;
  final String category;
  final String? categoryDisplay;
  final String status;
  final String? statusDisplay;
  final String? fileUrl;
  final int? uploadedById;
  final String? uploadedByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppDocument({
    required this.id,
    this.apartmentId,
    this.apartmentName,
    required this.title,
    this.description,
    required this.category,
    this.categoryDisplay,
    required this.status,
    this.statusDisplay,
    this.fileUrl,
    this.uploadedById,
    this.uploadedByName,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fileExtension {
    if (fileUrl == null) return 'unknown';
    final parts = fileUrl!.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return 'unknown';
  }
}
