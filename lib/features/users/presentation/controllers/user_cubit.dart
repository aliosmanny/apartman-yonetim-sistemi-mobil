import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';
import '../../domain/models/user.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit(this._repository) : super(UserInitial());

  Future<void> fetchUsers() async {
    emit(UserLoading());
    try {
      List<AppUser> users = [];
      try {
        users = await _repository.getUsers();
      } catch (_) {}
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      await _repository.createUser(data);
      await fetchUsers();
    } catch (e) {
      emit(UserError(e.toString()));
      throw e;
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateUser(id, data);
      await fetchUsers();
    } catch (e) {
      emit(UserError(e.toString()));
      throw e;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _repository.deleteUser(id);
      await fetchUsers();
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
