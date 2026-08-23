import '../datasources/staff_remote_data_source.dart';
import '../../domain/models/staff_member.dart';

class StaffRepository {
  final StaffRemoteDataSource _remoteDataSource;

  StaffRepository(this._remoteDataSource);

  Future<List<StaffMember>> getStaffList() async {
    return await _remoteDataSource.getStaffList();
  }

  Future<StaffMember> createStaff(Map<String, dynamic> data) async {
    return await _remoteDataSource.createStaff(data);
  }

  Future<StaffMember> updateStaff(int id, Map<String, dynamic> data) async {
    return await _remoteDataSource.updateStaff(id, data);
  }

  Future<void> deleteStaff(int id) async {
    await _remoteDataSource.deleteStaff(id);
  }
}
