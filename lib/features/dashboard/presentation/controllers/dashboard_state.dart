part of 'dashboard_cubit.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class ManagerDashboardLoaded extends DashboardState {
  final ManagerDashboardDto data;
  const ManagerDashboardLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class ResidentDashboardLoaded extends DashboardState {
  final ResidentDashboardDto data;
  const ResidentDashboardLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class StaffDashboardLoaded extends DashboardState {
  final StaffDashboardDto data;
  const StaffDashboardLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
