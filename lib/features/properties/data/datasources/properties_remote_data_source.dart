import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import '../dto/dtos.dart';

abstract class PropertiesRemoteDataSource {
  Future<List<LeaseContractDto>> getContracts();
  Future<LeaseContractDto> createContract(Map<String, dynamic> data, {String? filePath});
  Future<List<ApartmentDto>> getApartments();
  Future<ApartmentDto> createApartment(Map<String, dynamic> data);
  Future<List<BlockDto>> getBlocksForApartment(int aptId);
  Future<List<UnitDto>> getUnitsForBlock(int blockId);
  Future<UnitDto> createUnit(int blockId, Map<String, dynamic> data);
  Future<List<OwnerDto>> getOwners();
  Future<OwnerDto> createOwner(Map<String, dynamic> data);
  Future<List<TenantDto>> getTenants();
  Future<void> deleteApartment(int id);
  Future<ApartmentDto> updateApartment(int id, Map<String, dynamic> data);
  Future<void> deleteBlock(int id);
  Future<BlockDto> createBlock(int aptId, Map<String, dynamic> data);
  Future<BlockDto> updateBlock(int id, Map<String, dynamic> data);
  Future<void> deleteUnit(int id);
  Future<UnitDto> updateUnit(int id, Map<String, dynamic> data);
  Future<void> deleteOwner(int id);
  Future<OwnerDto> updateOwner(int id, Map<String, dynamic> data);
  Future<void> deleteTenant(int id);
  Future<TenantDto> updateTenant(int id, Map<String, dynamic> data);
}


class PropertiesRemoteDataSourceImpl implements PropertiesRemoteDataSource {
  @override
  Future<LeaseContractDto> createContract(Map<String, dynamic> data, {String? filePath}) async {
    dynamic body = data;
    if (filePath != null) {
      final formData = dio.FormData.fromMap(data);
      formData.files.add(MapEntry(
        'contract_file',
        await dio.MultipartFile.fromFile(filePath),
      ));
      body = formData;
    }
    
    final response = await _dio.post('/contracts/', data: body);
    return LeaseContractDto.fromJson(response.data);
  }

  @override
  Future<List<LeaseContractDto>> getContracts() async {
    final response = await _dio.get('/contracts/', queryParameters: {'page_size': 1000, 'limit': 1000});
    final List<dynamic> data = response.data is List ? response.data : response.data['results'] ?? [];
    return data.map((json) => LeaseContractDto.fromJson(json)).toList();
  }

  final Dio _dio;
  PropertiesRemoteDataSourceImpl(this._dio);

  List<dynamic> _extractResults(dynamic data) {
    if (data is Map && data['results'] != null) return data['results'];
    if (data is List) return data;
    return [];
  }

  @override
  Future<List<ApartmentDto>> getApartments() async {
    final res = await _dio.get('/apartments/', queryParameters: {'page_size': 1000, 'limit': 1000});
    return _extractResults(res.data).map((e) => ApartmentDto.fromJson(e)).toList();
  }

  @override
  Future<ApartmentDto> createApartment(Map<String, dynamic> data) async {
    final res = await _dio.post('/apartments/', data: data);
    return ApartmentDto.fromJson(res.data);
  }

  @override
  Future<List<BlockDto>> getBlocksForApartment(int aptId) async {
    final res = await _dio.get('/apartments/$aptId/blocks/', queryParameters: {'page_size': 1000, 'limit': 1000});
    return _extractResults(res.data).map((e) => BlockDto.fromJson(e)).toList();
  }

  @override
  Future<List<UnitDto>> getUnitsForBlock(int blockId) async {
    final res = await _dio.get('/blocks/$blockId/units/', queryParameters: {'page_size': 1000, 'limit': 1000});
    return _extractResults(res.data).map((e) => UnitDto.fromJson(e)).toList();
  }

  @override
  Future<UnitDto> createUnit(int blockId, Map<String, dynamic> data) async {
    final res = await _dio.post('/units/', data: data);
    return UnitDto.fromJson(res.data);
  }

  @override
  Future<OwnerDto> createOwner(Map<String, dynamic> data) async {
    final res = await _dio.post('/owners/', data: data);
    return OwnerDto.fromJson(res.data);
  }

  @override
  Future<List<OwnerDto>> getOwners() async {
    final res = await _dio.get('/owners/', queryParameters: {'page_size': 1000, 'limit': 1000});
    return _extractResults(res.data).map((e) => OwnerDto.fromJson(e)).toList();
  }

  @override
  Future<List<TenantDto>> getTenants() async {
    final res = await _dio.get('/tenants/', queryParameters: {'page_size': 1000, 'limit': 1000});
    return _extractResults(res.data).map((e) => TenantDto.fromJson(e)).toList();
  }


  @override
  Future<ApartmentDto> updateApartment(int id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/apartments/$id/', data: data);
    return ApartmentDto.fromJson(res.data);
  }
  @override
  Future<void> deleteApartment(int id) async { await _dio.delete('/apartments/$id/'); }


  @override
  Future<BlockDto> createBlock(int aptId, Map<String, dynamic> data) async {
    final res = await _dio.post('/apartments/$aptId/blocks/', data: data);
    return BlockDto.fromJson(res.data);
  }
  @override
  Future<BlockDto> updateBlock(int id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/blocks/$id/', data: data);
    return BlockDto.fromJson(res.data);
  }
  @override
  Future<void> deleteBlock(int id) async { await _dio.delete('/blocks/$id/'); }

  @override
  Future<UnitDto> updateUnit(int id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/units/$id/', data: data);
    return UnitDto.fromJson(res.data);
  }
  @override
  Future<void> deleteUnit(int id) async { await _dio.delete('/units/$id/'); }

  @override
  Future<OwnerDto> updateOwner(int id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/owners/$id/', data: data);
    return OwnerDto.fromJson(res.data);
  }
  @override
  Future<void> deleteOwner(int id) async { await _dio.delete('/owners/$id/'); }

  @override
  Future<TenantDto> updateTenant(int id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/tenants/$id/', data: data);
    return TenantDto.fromJson(res.data);
  }
  @override
  Future<void> deleteTenant(int id) async { await _dio.delete('/tenants/$id/'); }
}
