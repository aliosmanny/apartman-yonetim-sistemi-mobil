import '../../domain/models/document.dart';

class DocumentDto {
  final int id;
  final int? apartment;
  final String? apartmentName;
  final String title;
  final String? description;
  final String category;
  final String? categoryDisplay;
  final String status;
  final String? statusDisplay;
  final String? fileUrl;
  final int? uploadedBy;
  final String? uploadedByName;
  final String createdAt;
  final String updatedAt;

  DocumentDto({
    required this.id,
    this.apartment,
    this.apartmentName,
    required this.title,
    this.description,
    required this.category,
    this.categoryDisplay,
    required this.status,
    this.statusDisplay,
    this.fileUrl,
    this.uploadedBy,
    this.uploadedByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentDto.fromJson(Map<String, dynamic> json) {
    return DocumentDto(
      id: json['id'] as int,
      apartment: json['apartment'] as int?,
      apartmentName: json['apartment_name'] as String?,
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'management_plan',
      categoryDisplay: json['category_display'],
      status: json['status'] ?? 'active',
      statusDisplay: json['status_display'],
      fileUrl: json['file_url'],
      uploadedBy: json['uploaded_by'] as int?,
      uploadedByName: json['uploaded_by_name'] as String?,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  AppDocument toModel() {
    return AppDocument(
      id: id,
      apartmentId: apartment,
      apartmentName: apartmentName,
      title: title,
      description: description,
      category: category,
      categoryDisplay: categoryDisplay,
      status: status,
      statusDisplay: statusDisplay,
      fileUrl: fileUrl,
      uploadedById: uploadedBy,
      uploadedByName: uploadedByName,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
