import '../models/maintenance_request.dart';
import 'package:image_picker/image_picker.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceRequest>> getRequests({String? status, String? category});
  Future<MaintenanceRequest> getRequestDetails(String id);
  Future<MaintenanceRequest> createRequest({
    required String title,
    required String description,
    required String category,
    String? priority, // Backend desteklemese bile formda olabilir, şimdilik data'ya ekleyelim.
    int? unitId, // Sakinler için gerekli
    XFile? image,
  });
  Future<MaintenanceRequest> updateRequestStatus(String id, String status, {String? note});
}
