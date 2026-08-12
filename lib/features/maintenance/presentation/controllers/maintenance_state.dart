import '../../domain/models/maintenance_request.dart';

abstract class MaintenanceState {}

class MaintenanceInitial extends MaintenanceState {}

class MaintenanceLoading extends MaintenanceState {}

class MaintenanceLoaded extends MaintenanceState {
  final List<MaintenanceRequest> requests;
  MaintenanceLoaded({required this.requests});
}

class MaintenanceError extends MaintenanceState {
  final String message;
  MaintenanceError({required this.message});
}
