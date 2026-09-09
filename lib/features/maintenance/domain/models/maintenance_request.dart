class MaintenanceRequest {
  final String id;
  final String title;
  final String description;
  final String status;
  final String category;
  final String? priority;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminNotes;
  final String? creatorName;
  final String? unitDisplay;
  final String? apartmentName;
  final int? assignedTo;
  final String? assignedToName;
  final String? statusDisplay;
  final String? categoryDisplay;

  const MaintenanceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    this.priority,
    this.imageUrl,
    required this.createdAt,
    this.resolvedAt,
    this.adminNotes,
    this.creatorName,
    this.unitDisplay,
    this.apartmentName,
    this.assignedTo,
    this.assignedToName,
    this.statusDisplay,
    this.categoryDisplay,
  });

  MaintenanceRequest copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? category,
    String? priority,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? adminNotes,
    String? creatorName,
    String? unitDisplay,
    String? apartmentName,
    int? assignedTo,
    String? assignedToName,
    String? statusDisplay,
    String? categoryDisplay,
  }) {
    return MaintenanceRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      creatorName: creatorName ?? this.creatorName,
      unitDisplay: unitDisplay ?? this.unitDisplay,
      apartmentName: apartmentName ?? this.apartmentName,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      categoryDisplay: categoryDisplay ?? this.categoryDisplay,
    );
  }

  String get safeStatusDisplay => statusDisplay ?? _mapStatus(status);
  String get safeCategoryDisplay => categoryDisplay ?? _mapCategory(category);

  static String _mapStatus(String s) {
    switch (s) {
      case 'pending':
      case 'p':
        return 'Beklemede';
      case 'assigned':
      case 'a':
        return 'Personel Atandı';
      case 'in_progress':
      case 'i':
        return 'İşlemde';
      case 'completed':
      case 'c':
      case 'resolved':
        return 'Tamamlandı';
      case 'cancelled':
      case 'rejected':
      case 'x':
        return 'İptal Edildi';
      default: return s;
    }
  }

  static String _mapCategory(String c) {
    switch (c) {
      case 'plumbing': return 'Tesisat';
      case 'electrical': return 'Elektrik';
      case 'cleaning': return 'Temizlik';
      case 'elevator': return 'Asansör';
      default: return c;
    }
  }
}
