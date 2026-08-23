import '../../domain/models/models.dart';
import '../../domain/repositories/properties_repository.dart';
import '../datasources/properties_remote_data_source.dart';

class PropertiesRepositoryImpl implements PropertiesRepository {
  @override
  Future<AppLeaseContract> createContract(Map<String, dynamic> data, {String? filePath}) async {
    final dto = await _remote.createContract(data, filePath: filePath);
    return dto.toModel();
  }

  @override
  Future<List<AppLeaseContract>> getContracts() async {
    final dtos = await _remote.getContracts();
    return dtos.map((dto) => dto.toModel()).toList();
  }

  final PropertiesRemoteDataSource _remote;
  PropertiesRepositoryImpl(this._remote);

  @override
  Future<List<AppApartment>> getApartments() async {
    final list = await _remote.getApartments();
    return list.map((e) => e.toModel()).toList();
  

  @override
  Future<AppApartment> updateApartment(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateApartment(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteApartment(int id) => _remote.deleteApartment(id);



  @override
  Future<AppBlock> createBlock(int aptId, Map<String, dynamic> data) async {
    final res = await _remote.createBlock(aptId, data);
    return res.toModel();
  }
  @override
  Future<AppBlock> updateBlock(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateBlock(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteBlock(int id) => _remote.deleteBlock(id);


  @override
  Future<AppUnit> updateUnit(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateUnit(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteUnit(int id) => _remote.deleteUnit(id);


  @override
  Future<AppOwner> updateOwner(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateOwner(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteOwner(int id) => _remote.deleteOwner(id);


  @override
  Future<AppTenant> updateTenant(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateTenant(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteTenant(int id) => _remote.deleteTenant(id);
}

  @override
  Future<List<AppBlock>> getBlocksForApartment(int aptId) async {
    final list = await _remote.getBlocksForApartment(aptId);
    return list.map((e) => e.toModel()).toList();
  

  @override
  Future<AppApartment> updateApartment(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateApartment(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteApartment(int id) => _remote.deleteApartment(id);



  @override
  Future<AppBlock> createBlock(int aptId, Map<String, dynamic> data) async {
    final res = await _remote.createBlock(aptId, data);
    return res.toModel();
  }
  @override
  Future<AppBlock> updateBlock(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateBlock(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteBlock(int id) => _remote.deleteBlock(id);


  @override
  Future<AppUnit> updateUnit(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateUnit(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteUnit(int id) => _remote.deleteUnit(id);


  @override
  Future<AppOwner> updateOwner(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateOwner(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteOwner(int id) => _remote.deleteOwner(id);


  @override
  Future<AppTenant> updateTenant(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateTenant(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteTenant(int id) => _remote.deleteTenant(id);
}

  @override
  Future<List<AppUnit>> getUnitsForBlock(int blockId) async {
    final list = await _remote.getUnitsForBlock(blockId);
    return list.map((e) => e.toModel()).toList();
  

  @override
  Future<AppApartment> updateApartment(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateApartment(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteApartment(int id) => _remote.deleteApartment(id);



  @override
  Future<AppBlock> createBlock(int aptId, Map<String, dynamic> data) async {
    final res = await _remote.createBlock(aptId, data);
    return res.toModel();
  }
  @override
  Future<AppBlock> updateBlock(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateBlock(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteBlock(int id) => _remote.deleteBlock(id);


  @override
  Future<AppUnit> updateUnit(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateUnit(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteUnit(int id) => _remote.deleteUnit(id);


  @override
  Future<AppOwner> updateOwner(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateOwner(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteOwner(int id) => _remote.deleteOwner(id);


  @override
  Future<AppTenant> updateTenant(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateTenant(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteTenant(int id) => _remote.deleteTenant(id);
}

  @override
  Future<List<AppOwner>> getOwners() async {
    final list = await _remote.getOwners();
    return list.map((e) => e.toModel()).toList();
  

  @override
  Future<AppApartment> updateApartment(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateApartment(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteApartment(int id) => _remote.deleteApartment(id);



  @override
  Future<AppBlock> createBlock(int aptId, Map<String, dynamic> data) async {
    final res = await _remote.createBlock(aptId, data);
    return res.toModel();
  }
  @override
  Future<AppBlock> updateBlock(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateBlock(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteBlock(int id) => _remote.deleteBlock(id);


  @override
  Future<AppUnit> updateUnit(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateUnit(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteUnit(int id) => _remote.deleteUnit(id);


  @override
  Future<AppOwner> updateOwner(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateOwner(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteOwner(int id) => _remote.deleteOwner(id);


  @override
  Future<AppTenant> updateTenant(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateTenant(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteTenant(int id) => _remote.deleteTenant(id);
}

  @override
  Future<List<AppTenant>> getTenants() async {
    final list = await _remote.getTenants();
    return list.map((e) => e.toModel()).toList();
  

  @override
  Future<AppApartment> updateApartment(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateApartment(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteApartment(int id) => _remote.deleteApartment(id);



  @override
  Future<AppBlock> createBlock(int aptId, Map<String, dynamic> data) async {
    final res = await _remote.createBlock(aptId, data);
    return res.toModel();
  }
  @override
  Future<AppBlock> updateBlock(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateBlock(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteBlock(int id) => _remote.deleteBlock(id);


  @override
  Future<AppUnit> updateUnit(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateUnit(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteUnit(int id) => _remote.deleteUnit(id);


  @override
  Future<AppOwner> updateOwner(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateOwner(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteOwner(int id) => _remote.deleteOwner(id);


  @override
  Future<AppTenant> updateTenant(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateTenant(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteTenant(int id) => _remote.deleteTenant(id);
}


  @override
  Future<AppApartment> updateApartment(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateApartment(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteApartment(int id) => _remote.deleteApartment(id);



  @override
  Future<AppBlock> createBlock(int aptId, Map<String, dynamic> data) async {
    final res = await _remote.createBlock(aptId, data);
    return res.toModel();
  }
  @override
  Future<AppBlock> updateBlock(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateBlock(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteBlock(int id) => _remote.deleteBlock(id);


  @override
  Future<AppUnit> updateUnit(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateUnit(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteUnit(int id) => _remote.deleteUnit(id);


  @override
  Future<AppOwner> updateOwner(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateOwner(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteOwner(int id) => _remote.deleteOwner(id);


  @override
  Future<AppTenant> updateTenant(int id, Map<String, dynamic> data) async {
    final res = await _remote.updateTenant(id, data);
    return res.toModel();
  }
  @override
  Future<void> deleteTenant(int id) => _remote.deleteTenant(id);
}
