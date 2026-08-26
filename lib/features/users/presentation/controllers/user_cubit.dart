import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';
import '../../domain/models/user.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;
  static UserLoaded? _cachedState;

  static void clearCache() {
    _cachedState = null;
  }

  UserCubit(this._repository) : super(_cachedState ?? UserInitial());

  Future<void> fetchUsers() async {
    if (state is! UserLoaded) {
      emit(UserLoading());
    }
    try {
      List<AppUser> users = [];
      try {
        users = await _repository.getUsers();
      } catch (_) {}
      final loadedState = UserLoaded(users);
      _cachedState = loadedState;
      emit(loadedState);
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
