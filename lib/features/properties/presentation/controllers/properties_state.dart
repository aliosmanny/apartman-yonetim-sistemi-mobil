
import '../../domain/models/models.dart';

abstract class PropertiesState {}

class PropertiesInitial extends PropertiesState {}

class PropertiesLoading extends PropertiesState {}

class PropertiesLoaded extends PropertiesState {
  final List<AppApartment> apartments;
  final List<AppBlock> blocks;
  final List<AppUnit> units;
  final List<AppOwner> owners;
  final List<AppTenant> tenants;
  final List<AppLeaseContract> contracts;

  PropertiesLoaded({
    this.apartments = const [],
    this.blocks = const [],
    this.units = const [],
    this.owners = const [],
    this.tenants = const [],
    this.contracts = const [],
  });

  PropertiesLoaded copyWith({
    List<AppApartment>? apartments,
    List<AppBlock>? blocks,
    List<AppUnit>? units,
    List<AppOwner>? owners,
    List<AppTenant>? tenants,
    List<AppLeaseContract>? contracts,
  }) {
    return PropertiesLoaded(
      apartments: apartments ?? this.apartments,
      blocks: blocks ?? this.blocks,
      units: units ?? this.units,
      owners: owners ?? this.owners,
      tenants: tenants ?? this.tenants,
      contracts: contracts ?? this.contracts,
    );
  }
}

class PropertiesError extends PropertiesState {
  final String message;
  PropertiesError(this.message);
}
