import '../models/models.dart';

abstract class PropertiesRepository {
  Future<List<AppLeaseContract>> getContracts();
  Future<AppLeaseContract> createContract(Map<String, dynamic> data, {String? filePath});
  Future<List<AppApartment>> getApartments();
  Future<AppApartment> createApartment(Map<String, dynamic> data);
  Future<List<AppBlock>> getBlocksForApartment(int aptId);
  Future<List<AppUnit>> getUnitsForBlock(int blockId);
  Future<AppUnit> createUnit(int blockId, Map<String, dynamic> data);
  Future<List<AppOwner>> getOwners();
  Future<AppOwner> createOwner(Map<String, dynamic> data);
  Future<List<AppTenant>> getTenants();
  Future<void> deleteApartment(int id);
  Future<AppApartment> updateApartment(int id, Map<String, dynamic> data);
  Future<void> deleteBlock(int id);
  Future<AppBlock> createBlock(int aptId, Map<String, dynamic> data);
  Future<AppBlock> updateBlock(int id, Map<String, dynamic> data);
  Future<void> deleteUnit(int id);
  Future<AppUnit> updateUnit(int id, Map<String, dynamic> data);
  Future<void> deleteOwner(int id);
  Future<AppOwner> updateOwner(int id, Map<String, dynamic> data);
  Future<void> deleteTenant(int id);
  Future<AppTenant> updateTenant(int id, Map<String, dynamic> data);
}
