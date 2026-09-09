import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/staff_member.dart';
import '../../data/repositories/staff_repository.dart';

abstract class StaffState {}

class StaffInitial extends StaffState {}
class StaffLoading extends StaffState {}
class StaffLoaded extends StaffState {
  final List<StaffMember> staffList;
  StaffLoaded(this.staffList);
}
class StaffError extends StaffState {
  final String message;
  StaffError(this.message);
}

class StaffCubit extends Cubit<StaffState> {
  final StaffRepository _repository;

  StaffCubit(this._repository) : super(StaffInitial());

  DateTime? _lastFetch;
  static const _cacheTtl = Duration(seconds: 60);
  bool get _isFresh =>
      _lastFetch != null && DateTime.now().difference(_lastFetch!) < _cacheTtl;

  Future<void> fetchStaff({bool forceRefresh = false}) async {
    if (!forceRefresh && _isFresh && state is StaffLoaded) return;

    emit(StaffLoading());
    try {
      final list = await _repository.getStaffList();
      _lastFetch = DateTime.now();
      emit(StaffLoaded(list));
    } catch (e) {
      emit(StaffError(e.toString()));
    }
  }
  Future<void> createStaff(Map<String, dynamic> data) async {
    try {
      await _repository.createStaff(data);
      fetchStaff(); // Refresh list
    } catch (e) {
      emit(StaffError(e.toString()));
      fetchStaff(); // Fallback to loaded state
      rethrow;
    }
  }

  Future<void> updateStaff(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateStaff(id, data);
      fetchStaff();
    } catch (e) {
      emit(StaffError(e.toString()));
      fetchStaff();
      rethrow;
    }
  }

  Future<void> deleteStaff(int id) async {
    try {
      await _repository.deleteStaff(id);
      fetchStaff();
    } catch (e) {
      emit(StaffError(e.toString()));
      fetchStaff();
      rethrow;
    }
  }
}