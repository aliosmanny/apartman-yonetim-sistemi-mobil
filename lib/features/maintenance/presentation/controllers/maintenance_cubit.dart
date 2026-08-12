import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/maintenance_repository.dart';
import 'maintenance_state.dart';

class MaintenanceCubit extends Cubit<MaintenanceState> {
  final MaintenanceRepository _repository;

  MaintenanceCubit(this._repository) : super(MaintenanceInitial());

  Future<void> fetchRequests() async {
    emit(MaintenanceLoading());
    try {
      final requests = await _repository.getMyRequests();
      emit(MaintenanceLoaded(requests: requests));
    } catch (e) {
      emit(MaintenanceError(message: 'Talepler yüklenirken hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> createRequest({
    required String title,
    required String description,
    required String category,
  }) async {
    // Liste ekranındaki mevcut veriyi korumak için state kontrolü yapmıyoruz,
    // Sadece yeni talep eklenip listeye refresh attıracağız.
    // Detaylı loading state'i form içinde yönetilebilir.
    try {
      await _repository.createRequest(
        title: title,
        description: description,
        category: category,
      );
      // Başarılı olursa listeyi yenile
      await fetchRequests();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
