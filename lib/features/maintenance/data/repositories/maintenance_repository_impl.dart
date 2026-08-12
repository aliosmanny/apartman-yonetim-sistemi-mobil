import '../../domain/models/maintenance_request.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_mock_data_source.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceMockDataSource mockDataSource;

  MaintenanceRepositoryImpl({required this.mockDataSource});

  @override
  Future<List<MaintenanceRequest>> getMyRequests() async {
    return await mockDataSource.getMyRequests();
  }

  @override
  Future<MaintenanceRequest> createRequest({
    required String title,
    required String description,
    required String category,
    String? imagePath,
  }) async {
    return await mockDataSource.createRequest(
      title: title,
      description: description,
      category: category,
      imagePath: imagePath,
    );
  }
}
