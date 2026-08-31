import '../../domain/models/maintenance_request.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_remote_data_source.dart';
import 'package:image_picker/image_picker.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceRemoteDataSource _remoteDataSource;

  MaintenanceRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<MaintenanceRequest>> getRequests({String? status, String? category}) async {
    final dtos = await _remoteDataSource.getMaintenanceRequests(status: status, category: category);
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<MaintenanceRequest> getRequestDetails(String id) async {
    final dto = await _remoteDataSource.getMaintenanceRequestDetails(id);
    return dto.toModel();
  }

  @override
  Future<MaintenanceRequest> createRequest({
    required String title,
    required String description,
    required String category,
    String? priority,
    int? unitId,
    XFile? image,
    String? status,
    int? assignedToStaffId,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
    };
    if (unitId != null) {
      data['unit'] = unitId;
    }
    if (status != null) {
      data['status'] = status;
    }
    if (assignedToStaffId != null) {
      data['assigned_to'] = assignedToStaffId;
    }
    
    final dto = await _remoteDataSource.createMaintenanceRequest(data, image: image);
    return dto.toModel();
  }

  @override
  Future<MaintenanceRequest> updateRequestStatus(String id, String status, {String? note, int? assignedStaffId}) async {
    final dto = await _remoteDataSource.updateMaintenanceStatus(id, status, note: note, assignedStaffId: assignedStaffId);
    return dto.toModel();
  }

  @override
  Future<MaintenanceRequest> updateAssignedStaff(String id, int staffId) async {
    final dto = await _remoteDataSource.updateAssignedStaff(id, staffId);
    return dto.toModel();
  }
}
