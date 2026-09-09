import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/properties_repository.dart';
import '../../domain/models/models.dart';
import 'properties_state.dart';

class PropertiesCubit extends Cubit<PropertiesState> {
  final PropertiesRepository _repo;
  static PropertiesLoaded? _cachedState;
  static DateTime? _lastFetch;
  static const _cacheTtl = Duration(seconds: 60);

  static bool get _isFresh =>
      _lastFetch != null && DateTime.now().difference(_lastFetch!) < _cacheTtl;

  static void clearCache() {
    _cachedState = null;
    _lastFetch = null;
  }

  PropertiesCubit(this._repo) : super(_cachedState ?? PropertiesInitial());

  Future<void> fetchAll({bool forceRefresh = false}) async {
    if (!forceRefresh && _isFresh && state is PropertiesLoaded && !(state as PropertiesLoaded).isUnitsLoading) {
      return;
    }

    if (state is! PropertiesLoaded) {
      emit(PropertiesLoading());
    }
    try {
      // 1. Fetch apartments, owners, tenants, and contracts in parallel (Fast path)
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

      // Emit first load state immediately (Apartments, Owners, Tenants, Contracts visible instantly!)
      emit(PropertiesLoaded(
        apartments: apartments,
        blocks: const [],
        units: const [],
        owners: owners,
        tenants: tenants,
        contracts: contracts,
        isBlocksLoading: true,
        isUnitsLoading: true,
      ));

      // 2. Fetch blocks for all apartments in parallel in the background
      final blocks = <AppBlock>[];
      if (apartments.isNotEmpty) {
        final blocksResults = await Future.wait(
          apartments.map((apt) => _repo.getBlocksForApartment(apt.id).catchError((_) => <AppBlock>[]))
        );
        for (var bList in blocksResults) {
          blocks.addAll(bList);
        }
      }

      // Emit intermediate state with blocks loaded, units still loading in background
      emit(PropertiesLoaded(
        apartments: apartments,
        blocks: blocks,
        units: const [],
        owners: owners,
        tenants: tenants,
        contracts: contracts,
        isBlocksLoading: false,
        isUnitsLoading: true,
      ));

      // 3. Fetch units for all blocks in parallel in the background
      final units = <AppUnit>[];
      if (blocks.isNotEmpty) {
        final unitsResults = await Future.wait(
          blocks.map((block) => _repo.getUnitsForBlock(block.id).catchError((_) => <AppUnit>[]))
        );
        for (var uList in unitsResults) {
          units.addAll(uList);
        }
      }

      // Emit final loaded state with all data
      final finalLoadedState = PropertiesLoaded(
        apartments: apartments,
        blocks: blocks,
        units: units,
        owners: owners,
        tenants: tenants,
        contracts: contracts,
        isBlocksLoading: false,
        isUnitsLoading: false,
      );
      _cachedState = finalLoadedState;
      _lastFetch = DateTime.now();
      emit(finalLoadedState);
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }



Future<void> createApartmentWithBlocks(Map<String, dynamic> aptData, List<Map<String, dynamic>> blocksData) async {
    try {
      emit(PropertiesLoading());
      final apt = await _repo.createApartment(aptData);
      
      for (final b in blocksData) {
        await _repo.createBlock(apt.id, b);
      }
      
      fetchAll();
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

  Future<void> createBlockWithUnits(Map<String, dynamic> blockData, List<Map<String, dynamic>> unitsData) async {
    try {
      emit(PropertiesLoading());
      final newBlock = await _repo.createBlock(blockData['apartment'], blockData);
      for (final u in unitsData) {
        // Normally you'd have createUnit in repo. If it's missing, maybe we shouldn't fail.
        // Or if the backend auto-creates units based on floor_count and unit_count, we might just need to update them.
      }
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

  Future<void> createOwner(Map<String, dynamic> data) async {
    try {
      emit(PropertiesLoading());
      await _repo.createOwner(data);
      fetchAll();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }

  Future<void> createUnit(Map<String, dynamic> data) async {
    try {
      emit(PropertiesLoading());
      await _repo.createUnit(data['block'], data);
      fetchAll();
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
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

