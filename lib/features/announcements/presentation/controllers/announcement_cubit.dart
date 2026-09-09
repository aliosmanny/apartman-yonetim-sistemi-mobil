import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/announcement_repository.dart';
import 'announcement_state.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final AnnouncementRepository _repository;

  AnnouncementCubit(this._repository) : super(AnnouncementInitial());

  DateTime? _lastFetch;
  static const _cacheTtl = Duration(seconds: 60);
  bool get _isFresh =>
      _lastFetch != null && DateTime.now().difference(_lastFetch!) < _cacheTtl;

  Future<void> fetchAnnouncements({String? status, bool forceRefresh = false}) async {
    // Cache varsa ve taze ise tekrar API'ye gitme
    if (!forceRefresh && _isFresh && state is AnnouncementLoaded) return;

    emit(AnnouncementLoading());
    try {
      final announcements = await _repository.getAnnouncements(status: status);
      _lastFetch = DateTime.now();
      emit(AnnouncementLoaded(announcements: announcements));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> createAnnouncement({
    required String title,
    required String content,
    int? apartmentId,
    String? status,
  }) async {
    try {
      await _repository.createAnnouncement(
        title: title,
        content: content,
        apartmentId: apartmentId,
        status: status,
      );
      _lastFetch = null;
      await fetchAnnouncements(forceRefresh: true);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateAnnouncement(int id, {
    String? title,
    String? content,
    int? apartmentId,
    String? status,
  }) async {
    try {
      await _repository.updateAnnouncement(
        id,
        title: title,
        content: content,
        apartmentId: apartmentId,
        status: status,
      );
      _lastFetch = null;
      await fetchAnnouncements(forceRefresh: true);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    try {
      await _repository.deleteAnnouncement(id);
      _lastFetch = null;
      await fetchAnnouncements(forceRefresh: true);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
