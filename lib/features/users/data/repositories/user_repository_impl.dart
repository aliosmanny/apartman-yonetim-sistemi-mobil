import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AppUser>> getUsers() async {
    final dtos = await _remoteDataSource.getUsers();
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<AppUser> createUser(Map<String, dynamic> data) async {
    final dto = await _remoteDataSource.createUser(data);
    return dto.toModel();
  }

  @override
  Future<AppUser> updateUser(int id, Map<String, dynamic> data) async {
    final dto = await _remoteDataSource.updateUser(id, data);
    return dto.toModel();
  }

  @override
  Future<void> deleteUser(int id) async {
    await _remoteDataSource.deleteUser(id);
  }
}
