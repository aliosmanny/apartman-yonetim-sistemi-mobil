import '../models/maintenance_request.dart';
import 'package:image_picker/image_picker.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceRequest>> getRequests({String? status, String? category});
  Future<MaintenanceRequest> getRequestDetails(String id);
  Future<MaintenanceRequest> createRequest({
    required String title,
    required String description,
    required String category,
    String? priority,
    int? unitId,
    XFile? image,
    String? status,
    int? assignedToStaffId,
  });
  Future<MaintenanceRequest> updateRequestStatus(String id, String status, {String? note, int? assignedStaffId});
  Future<MaintenanceRequest> updateAssignedStaff(String id, int staffId);
}
