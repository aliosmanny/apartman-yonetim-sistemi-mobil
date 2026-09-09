import '../../domain/models/maintenance_request.dart';

class MaintenanceDto {
  final int id;
  final String title;
  final String description;
  final String category;
  final String categoryDisplay;
  final String status;
  final String statusDisplay;
  final int? unitId;
  final String? unitDisplay;
  final String? apartmentName;
  final String? createdByName;
  final int? assignedTo;
  final String? assignedToName;
  final String? imageUrl;
  final String? staffNote;
  final String? staffPhotoUrl;
  final String createdAt;
  final String updatedAt;

  const MaintenanceDto({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryDisplay,
    required this.status,
    required this.statusDisplay,
    this.unitId,
    this.unitDisplay,
    this.apartmentName,
    this.createdByName,
    this.assignedTo,
    this.assignedToName,
    this.imageUrl,
    this.staffNote,
    this.staffPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceDto.fromJson(Map<String, dynamic> json) {
    int? parseAssignedTo(dynamic val) {
      if (val is int) return val;
      if (val is Map && val['id'] != null) return val['id'] as int?;
      if (val is String) return int.tryParse(val);
      return null;
    }

    return MaintenanceDto(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryDisplay: json['category_display'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusDisplay: json['status_display'] as String? ?? '',
      unitId: json['unit'] as int?,
      unitDisplay: json['unit_display'] as String?,
      apartmentName: json['apartment_name'] as String?,
      createdByName: json['created_by_name'] as String?,
      assignedTo: parseAssignedTo(json['assigned_to'] ?? json['assigned_staff'] ?? json['assigned_to_id']),
      assignedToName: json['assigned_to_name'] as String?,
      imageUrl: json['image_url'] as String?,
      staffNote: json['staff_note'] as String?,
      staffPhotoUrl: json['staff_photo_url'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  MaintenanceRequest toModel() {
    return MaintenanceRequest(
      id: id.toString(),
      title: title,
      description: description,
      status: status,
      category: category,
      imageUrl: imageUrl,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      adminNotes: staffNote,
      priority: 'normal',
      creatorName: createdByName,
      unitDisplay: unitDisplay,
      apartmentName: apartmentName,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      statusDisplay: statusDisplay,
      categoryDisplay: categoryDisplay,
    );
  }
}
