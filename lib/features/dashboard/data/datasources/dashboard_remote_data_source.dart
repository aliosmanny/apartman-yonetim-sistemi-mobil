import 'package:dio/dio.dart';
import '../dto/dashboard_dto.dart';
import '../../../../core/network/api_exception.dart';

/// GET /api/v1/dashboard/ → Rol bazlı dashboard verisi.
class DashboardRemoteDataSource {
  final Dio _dio;
  DashboardRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> _fetch() async {
    try {
      final response = await _dio.get('/dashboard/');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ManagerDashboardDto> fetchManagerDashboard() async =>
      ManagerDashboardDto.fromJson(await _fetch());

  Future<ResidentDashboardDto> fetchResidentDashboard() async =>
      ResidentDashboardDto.fromJson(await _fetch());

  Future<StaffDashboardDto> fetchStaffDashboard() async =>
      StaffDashboardDto.fromJson(await _fetch());
}
