import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/maintenance_repository.dart';
import 'maintenance_state.dart';
import 'package:image_picker/image_picker.dart';

class MaintenanceCubit extends Cubit<MaintenanceState> {
  final MaintenanceRepository _repository;

  MaintenanceCubit(this._repository) : super(MaintenanceInitial());

  DateTime? _lastFetch;
  static const _cacheTtl = Duration(seconds: 60);
  bool get _isFresh =>
      _lastFetch != null && DateTime.now().difference(_lastFetch!) < _cacheTtl;

  Future<void> fetchRequests({String? status, String? category, bool forceRefresh = true}) async {
    if (state is! MaintenanceLoaded) {
      emit(MaintenanceLoading());
    }
    try {
      final requests = await _repository.getRequests(status: status, category: category);
      _lastFetch = DateTime.now();
      emit(MaintenanceLoaded(requests: requests));
    } catch (e) {
      if (state is! MaintenanceLoaded) {
        emit(MaintenanceError(message: 'Talepler yüklenirken hata oluştu: ${e.toString()}'));
      }
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
      _lastFetch = null;
      await fetchRequests(forceRefresh: true);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateRequestStatus(String id, String status, {String? note, int? assignedStaffId}) async {
    // 1. Optimistic update (yerel state'i anında güncelle ki UI'da görev anında Tamamlanan'a geçsin)
    if (state is MaintenanceLoaded) {
      final currentRequests = (state as MaintenanceLoaded).requests;
      final updatedRequests = currentRequests.map((r) {
        if (r.id == id) {
          return r.copyWith(
            status: status,
            adminNotes: note ?? r.adminNotes,
          );
        }
        return r;
      }).toList();
      emit(MaintenanceLoaded(requests: updatedRequests));
    }

    try {
      await _repository.updateRequestStatus(id, status, note: note, assignedStaffId: assignedStaffId);
      _lastFetch = null;
      await fetchRequests(forceRefresh: true);
    } catch (e) {
      // Backend hatası olursa dahi fetchRequests ile sunucu durumunu eşitle
      _lastFetch = null;
      await fetchRequests(forceRefresh: true);
      throw Exception(e.toString());
    }
  }

  /// Sadece personel ataması — statüyü otomatik 'assigned' yapar
  Future<void> assignStaff(String requestId, int staffId) async {
    try {
      await _repository.updateAssignedStaff(requestId, staffId);
      await _repository.updateRequestStatus(requestId, 'assigned');
      _lastFetch = null;
      await fetchRequests(forceRefresh: true);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
