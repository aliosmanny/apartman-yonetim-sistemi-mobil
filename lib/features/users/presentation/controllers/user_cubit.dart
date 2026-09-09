import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';
import '../../domain/models/user.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;
  static UserLoaded? _cachedState;
  static DateTime? _lastFetch;
  static const _cacheTtl = Duration(seconds: 60);

  static bool get _isFresh =>
      _lastFetch != null && DateTime.now().difference(_lastFetch!) < _cacheTtl;

  static void clearCache() {
    _cachedState = null;
    _lastFetch = null;
  }

  UserCubit(this._repository) : super(_cachedState ?? UserInitial());

  Future<void> fetchUsers({bool forceRefresh = false}) async {
    if (!forceRefresh && _isFresh && state is UserLoaded) return;

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
      _lastFetch = DateTime.now();
      emit(loadedState);
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      await _repository.createUser(data);
      _lastFetch = null;
      await fetchUsers(forceRefresh: true);
    } catch (e) {
      emit(UserError(e.toString()));
      throw e;
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateUser(id, data);
      _lastFetch = null;
      await fetchUsers(forceRefresh: true);
    } catch (e) {
      emit(UserError(e.toString()));
      throw e;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _repository.deleteUser(id);
      _lastFetch = null;
      await fetchUsers(forceRefresh: true);
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
