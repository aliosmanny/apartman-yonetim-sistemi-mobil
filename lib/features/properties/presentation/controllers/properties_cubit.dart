import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/properties_repository.dart';
import '../../domain/models/models.dart';
import 'properties_state.dart';

class PropertiesCubit extends Cubit<PropertiesState> {
  final PropertiesRepository _repo;
  PropertiesCubit(this._repo) : super(PropertiesInitial());

  Future<void> fetchAll() async {
    emit(PropertiesLoading());
    try {
      // 1. Fetch apartments, owners, tenants, and contracts in parallel
      final results = await Future.wait([
        _repo.getApartments().catchError((_) => <AppApartment>[]),
        _repo.getOwners().catchError((_) => <AppOwner>[]),
        _repo.getTenants().catchError((_) => <AppTenant>[]),
        _repo.getContracts().catchError((_) => <AppLeaseContract>[]),
      ]);

      final apartments = results[0] as List<AppApartment>;
      final owners = results[1] as List<AppOwner>;
      final tenants = results[2] as List<AppTenant>;
      final contracts = results[3] as List<AppLeaseContract>;

      // 2. Fetch blocks for all apartments in parallel
      final blocks = <AppBlock>[];
      if (apartments.isNotEmpty) {
        final blocksResults = await Future.wait(
          apartments.map((apt) => _repo.getBlocksForApartment(apt.id).catchError((_) => <AppBlock>[]))
        );
        for (var bList in blocksResults) {
          blocks.addAll(bList);
        }
      }

      // 3. Fetch units for all blocks in parallel
      final units = <AppUnit>[];
      if (blocks.isNotEmpty) {
        final unitsResults = await Future.wait(
          blocks.map((block) => _repo.getUnitsForBlock(block.id).catchError((_) => <AppUnit>[]))
        );
        for (var uList in unitsResults) {
          units.addAll(uList);
        }
      }

      emit(PropertiesLoaded(
        apartments: apartments,
        blocks: blocks,
        units: units,
        owners: owners,
        tenants: tenants,
        contracts: contracts,
      ));
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }



Future<void> saveApartmentWithBlocks(int aptId, Map<String, dynamic> aptData, List<Map<String, dynamic>> blocksData, List<int> deletedBlockIds) async {
    try {
      emit(PropertiesLoading());
      await _repo.updateApartment(aptId, aptData);
      
      for (final id in deletedBlockIds) {
        await _repo.deleteBlock(id);
      }
      for (final b in blocksData) {
        if (b['id'] != null) {
          await _repo.updateBlock(b['id'], b);
        } else {
          await _repo.createBlock(aptId, b);
        }
      }
      
      fetchAll();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }
  Future<void> updateApartment(int id, Map<String, dynamic> data) async {
    try {
      await _repo.updateApartment(id, data);
      fetchAll();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }
  
  
  Future<void> createContract(Map<String, dynamic> data, {String? filePath}) async {
    emit(PropertiesLoading());
    try {
      await _repo.createContract(data, filePath: filePath);
      await fetchContracts();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }

  Future<void> fetchContracts() async {
    try {
      final contracts = await _repo.getContracts();
      if (state is PropertiesLoaded) emit((state as PropertiesLoaded).copyWith(contracts: contracts)); else emit(PropertiesLoaded(contracts: contracts));
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }

  Future<void> deleteApartment(int id) async {

    try { await _repo.deleteApartment(id); fetchAll(); } catch (e) { emit(PropertiesError(e.toString())); }
  }


  Future<void> saveBlockWithUnits(int blockId, Map<String, dynamic> blockData, List<Map<String, dynamic>> unitsData, List<int> deletedUnitIds) async {
    try {
      emit(PropertiesLoading());
      await _repo.updateBlock(blockId, blockData);
      
      for (final id in deletedUnitIds) {
        await _repo.deleteUnit(id);
      }
      for (final u in unitsData) {
        if (u['id'] != null) {
          // Add unit update support to repo
          await _repo.updateUnit(u['id'], u);
        }
      }
      
      fetchAll();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }

  Future<void> createBlockWithUnits(Map<String, dynamic> blockData) async {
    try {
      emit(PropertiesLoading());
      await _repo.createBlock(blockData['apartment_id'], blockData);
      fetchAll();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }

  Future<void> updateBlockDetails(int id, Map<String, dynamic> data) async {
    try {
      emit(PropertiesLoading());
      await _repo.updateBlock(id, data);
      fetchAll();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }
  Future<void> deleteBlock(int id) async {
    try { await _repo.deleteBlock(id); fetchAll(); } catch (e) { emit(PropertiesError(e.toString())); }
  }

  Future<void> updateUnitDetails(int id, Map<String, dynamic> data) async {
    try {
      emit(PropertiesLoading());
      await _repo.updateUnit(id, data);
      fetchAll();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }
  Future<void> deleteUnit(int id) async {
    try { await _repo.deleteUnit(id); fetchAll(); } catch (e) { emit(PropertiesError(e.toString())); }
  }

  Future<void> updateOwnerDetails(int id, Map<String, dynamic> data) async {
    try {
      emit(PropertiesLoading());
      await _repo.updateOwner(id, data);
      fetchAll();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }
  Future<void> deleteOwner(int id) async {
    try { await _repo.deleteOwner(id); fetchAll(); } catch (e) { emit(PropertiesError(e.toString())); }
  }

  Future<void> updateTenantDetails(int id, Map<String, dynamic> data) async {
    try {
      emit(PropertiesLoading());
      await _repo.updateTenant(id, data);
      fetchAll();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }
  Future<void> deleteTenant(int id) async {
    try { await _repo.deleteTenant(id); fetchAll(); } catch (e) { emit(PropertiesError(e.toString())); }
  }
}

