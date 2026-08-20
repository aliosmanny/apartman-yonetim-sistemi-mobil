import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/dto/dashboard_dto.dart';
import '../../../../core/network/api_exception.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRemoteDataSource _dataSource;

  DashboardCubit(this._dataSource) : super(const DashboardInitial());

  Future<void> fetchManagerDashboard() async {
    emit(const DashboardLoading());
    try {
      final data = await _dataSource.fetchManagerDashboard();
      emit(ManagerDashboardLoaded(data));
    } on ApiException catch (e) {
      emit(DashboardError(e.message));
    } catch (e) {
      emit(const DashboardError('Dashboard verisi yüklenemedi.'));
    }
  }

  Future<void> fetchResidentDashboard() async {
    emit(const DashboardLoading());
    try {
      final data = await _dataSource.fetchResidentDashboard();
      emit(ResidentDashboardLoaded(data));
    } on ApiException catch (e) {
      emit(DashboardError(e.message));
    } catch (e) {
      emit(const DashboardError('Dashboard verisi yüklenemedi.'));
    }
  }

  Future<void> fetchStaffDashboard() async {
    emit(const DashboardLoading());
    try {
      final data = await _dataSource.fetchStaffDashboard();
      emit(StaffDashboardLoaded(data));
    } on ApiException catch (e) {
      emit(DashboardError(e.message));
    } catch (e) {
      emit(const DashboardError('Dashboard verisi yüklenemedi.'));
    }
  }
}
