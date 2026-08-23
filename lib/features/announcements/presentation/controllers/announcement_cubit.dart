import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/announcement_repository.dart';
import 'announcement_state.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final AnnouncementRepository _repository;

  AnnouncementCubit(this._repository) : super(AnnouncementInitial());

  Future<void> fetchAnnouncements({String? status}) async {
    emit(AnnouncementLoading());
    try {
      final announcements = await _repository.getAnnouncements(status: status);
      emit(AnnouncementLoaded(announcements: announcements));
    } catch (e) {
      emit(AnnouncementError(message: e.toString()));
    }
  }

  Future<void> createAnnouncement({
    required String title,
    required String content,
    String? status,
  }) async {
    try {
      await _repository.createAnnouncement(
        title: title,
        content: content,
        status: status,
      );
      await fetchAnnouncements();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateAnnouncement(int id, {
    String? title,
    String? content,
    String? status,
  }) async {
    try {
      await _repository.updateAnnouncement(
        id,
        title: title,
        content: content,
        status: status,
      );
      await fetchAnnouncements();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    try {
      await _repository.deleteAnnouncement(id);
      await fetchAnnouncements();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
