import 'package:uuid/uuid.dart';
import '../../domain/models/maintenance_request.dart';
import '../../../../core/network/api_exception.dart';

class MaintenanceMockDataSource {
  final _uuid = const Uuid();
  late List<MaintenanceRequest> _requests;

  MaintenanceMockDataSource() {
    _requests = [
      MaintenanceRequest(
        id: _uuid.v4(),
        title: 'Asansör Bozuk',
        description: 'A blok 1. asansör 3. katta takılı kaldı, kapıları kapanmıyor.',
        status: 'in_progress',
        category: 'elevator',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        adminNotes: 'Teknik servis çağrıldı, yarın sabah müdahale edilecek.',
      ),
      MaintenanceRequest(
        id: _uuid.v4(),
        title: 'Koridor Lambası',
        description: '5. kat merdiven boşluğundaki sensörlü lamba yanmıyor.',
        status: 'resolved',
        category: 'electrical',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 4)),
        adminNotes: 'Ampul değiştirildi.',
      ),
      MaintenanceRequest(
        id: _uuid.v4(),
        title: 'Sızıntı Var',
        description: 'Otopark tavanından su damlıyor.',
        status: 'pending',
        category: 'plumbing',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  Future<List<MaintenanceRequest>> getMyRequests() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // En yeniler en üstte
    final sortedList = List<MaintenanceRequest>.from(_requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedList;
  }

  Future<MaintenanceRequest> createRequest({
    required String title,
    required String description,
    required String category,
    String? imagePath,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (title.isEmpty || description.isEmpty) {
      throw const ApiException(message: 'Başlık ve açıklama boş olamaz', statusCode: 400);
    }

    final newRequest = MaintenanceRequest(
      id: _uuid.v4(),
      title: title,
      description: description,
      status: 'pending',
      category: category,
      imageUrl: imagePath != null ? 'mock_image_url.jpg' : null,
      createdAt: DateTime.now(),
    );

    _requests.add(newRequest);
    return newRequest;
  }
}
