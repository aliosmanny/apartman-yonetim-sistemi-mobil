class AppDocument {
  final String id;
  final String title;
  final String type; // 'pdf', 'doc', 'xls' vs.
  final String size;
  final DateTime uploadDate;

  const AppDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.size,
    required this.uploadDate,
  });
}

// Mock Data
final List<AppDocument> mockDocuments = [
  AppDocument(
    id: '1',
    title: '2025 Yılı Karar Defteri',
    type: 'pdf',
    size: '2.4 MB',
    uploadDate: DateTime.now().subtract(const Duration(days: 45)),
  ),
  AppDocument(
    id: '2',
    title: 'Apartman Yönetim Planı',
    type: 'pdf',
    size: '5.1 MB',
    uploadDate: DateTime.now().subtract(const Duration(days: 120)),
  ),
  AppDocument(
    id: '3',
    title: 'Temmuz Ayı Gider Tablosu',
    type: 'xls',
    size: '1.2 MB',
    uploadDate: DateTime.now().subtract(const Duration(days: 10)),
  ),
];
