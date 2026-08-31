import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/maintenance_repository.dart';
import 'maintenance_state.dart';
import 'package:image_picker/image_picker.dart';

class MaintenanceCubit extends Cubit<MaintenanceState> {
  final MaintenanceRepository _repository;

  MaintenanceCubit(this._repository) : super(MaintenanceInitial());

  Future<void> fetchRequests({String? status, String? category}) async {
    emit(MaintenanceLoading());
    try {
      final requests = await _repository.getRequests(status: status, category: category);
      emit(MaintenanceLoaded(requests: requests));
    } catch (e) {
      emit(MaintenanceError(message: 'Talepler yüklenirken hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> createRequest({
    required String title,
    required String description,
    required String category,
    String? priority,
    int? unitId,
    XFile? image,
    String? status,
    int? assignedToStaffId,
  }) async {
    try {
      await _repository.createRequest(
        title: title,
        description: description,
        category: category,
        priority: priority,
        unitId: unitId,
        image: image,
        status: status,
        assignedToStaffId: assignedToStaffId,
      );
      await fetchRequests();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateRequestStatus(String id, String status, {String? note, int? assignedStaffId}) async {
    try {
      await _repository.updateRequestStatus(id, status, note: note, assignedStaffId: assignedStaffId);
      await fetchRequests();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Sadece personel ataması — statüyü otomatik 'assigned' yapar
  Future<void> assignStaff(String requestId, int staffId) async {
    try {
      await _repository.updateAssignedStaff(requestId, staffId);
      await _repository.updateRequestStatus(requestId, 'assigned');
      await fetchRequests();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
