import '../models/maintenance_request.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceRequest>> getMyRequests();
  Future<MaintenanceRequest> createRequest({
    required String title,
    required String description,
    required String category,
    String? imagePath,
  });
}
