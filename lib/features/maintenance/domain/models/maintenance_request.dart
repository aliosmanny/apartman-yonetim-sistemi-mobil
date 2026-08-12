class MaintenanceRequest {
  final String id;
  final String title;
  final String description;
  final String status; // 'pending', 'in_progress', 'resolved', 'rejected'
  final String category; // 'plumbing', 'electrical', 'cleaning', 'elevator', 'other'
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminNotes;

  const MaintenanceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    this.imageUrl,
    required this.createdAt,
    this.resolvedAt,
    this.adminNotes,
  });

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'İşleme Alınmadı';
      case 'in_progress':
        return 'İşlemde';
      case 'resolved':
        return 'Çözüldü';
      case 'rejected':
        return 'İptal Edildi';
      default:
        return 'Bilinmiyor';
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case 'plumbing':
        return 'Tesisat';
      case 'electrical':
        return 'Elektrik';
      case 'cleaning':
        return 'Temizlik';
      case 'elevator':
        return 'Asansör';
      default:
        return 'Diğer';
    }
  }
}
