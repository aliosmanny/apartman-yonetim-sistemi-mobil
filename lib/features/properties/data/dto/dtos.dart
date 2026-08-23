import '../../domain/models/models.dart';

class ApartmentDto {
  final int id;
  final String name;
  final String province;
  final String district;
  final String? address;
  final double? monthlyLateFeeRate;
  final String? managerName;
  final int totalBlocks;
  final int totalUnits;

  ApartmentDto({
    required this.id,
    required this.name,
    required this.province,
    required this.district,
    this.address,
    this.monthlyLateFeeRate,
    this.managerName,
    required this.totalBlocks,
    required this.totalUnits,
  });

  factory ApartmentDto.fromJson(Map<String, dynamic> json) {
    return ApartmentDto(
      id: json['id'],
      name: json['name'] ?? '',
      province: json['city'] ?? '',
      district: json['district'] ?? '',
      address: json['address'],
      monthlyLateFeeRate: json['monthly_late_fee_rate'] != null ? double.tryParse(json['monthly_late_fee_rate'].toString()) : null,
      managerName: json['manager_name'],
      totalBlocks: json['total_blocks'] ?? 0,
      totalUnits: json['total_units'] ?? 0,
    );
  }

  AppApartment toModel() => AppApartment(
    id: id, name: name, province: province, district: district, address: address, monthlyLateFeeRate: monthlyLateFeeRate, 
    managerName: managerName, totalBlocks: totalBlocks, totalUnits: totalUnits
  );
}

class BlockDto {
  final int id;
  final int apartmentId;
  final String apartmentName;
  final String name;
  final int floorCount;
  final int unitCount;

  BlockDto({
    required this.id,
    required this.apartmentId, required this.apartmentName,
    required this.name, required this.floorCount, required this.unitCount,
  });

  factory BlockDto.fromJson(Map<String, dynamic> json) {
    return BlockDto(
      id: json['id'],
      apartmentId: json['apartment'] ?? 0,
      apartmentName: json['apartment_name'] ?? '',
      name: json['name'] ?? '',
      floorCount: json['floor_count'] ?? 0,
      unitCount: json['unit_count'] ?? 0,
    );
  }

  AppBlock toModel() => AppBlock(
    id: id, apartmentId: apartmentId, apartmentName: apartmentName,
    name: name, floorCount: floorCount, unitCount: unitCount
  );
}

class UnitDto {
  final int id;
  final int blockId;
  final String blockName;
  final String apartmentName;
  final String number;
  final int floor;
  final String usageStatus;
  final String usageStatusDisplay;
  final Map<String, dynamic>? currentOwner;
  final Map<String, dynamic>? currentTenant;

  UnitDto({
    required this.id,
    required this.blockId, required this.blockName, required this.apartmentName,
    required this.number, required this.floor, required this.usageStatus,
    required this.usageStatusDisplay, this.currentOwner, this.currentTenant,
  });

  factory UnitDto.fromJson(Map<String, dynamic> json) {
    return UnitDto(
      id: json['id'],
      blockId: json['block'] ?? 0,
      blockName: json['block_name'] ?? '',
      apartmentName: json['apartment_name'] ?? '',
      number: json['number']?.toString() ?? '',
      floor: json['floor'] ?? 0,
      usageStatus: json['usage_status'] ?? '',
      usageStatusDisplay: json['usage_status_display'] ?? '',
      currentOwner: json['current_owner'],
      currentTenant: json['current_tenant'],
    );
  }

  AppUnit toModel() => AppUnit(
    id: id, blockId: blockId, blockName: blockName, apartmentName: apartmentName,
    number: number, floor: floor, usageStatus: usageStatus,
    usageStatusDisplay: usageStatusDisplay, currentOwner: currentOwner, currentTenant: currentTenant
  );
}

class OwnerDto {
  final int id;
  final int? userId;
  final int? unitId;
  final String userName;
  final String userPhone;
  final String unitDisplay;
  final String? apartmentName;
  final bool isDeleted;
  final String? deletedAt;
  final bool isResident;

  OwnerDto({
    required this.id,
    this.userId,
    this.unitId,
    required this.userName, 
    required this.userPhone,
    required this.unitDisplay, 
    this.apartmentName,
    this.isDeleted = false,
    this.deletedAt,
    this.isResident = false,
  });

  factory OwnerDto.fromJson(Map<String, dynamic> json) {
    return OwnerDto(
      id: json['id'],
      userId: json['user'],
      unitId: json['unit'],
      userName: json['user_name'] ?? '',
      userPhone: json['user_phone'] ?? '',
      unitDisplay: json['unit_display'] ?? '',
      apartmentName: json['apartment_name'],
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'],
      isResident: json['is_resident'] ?? false,
    );
  }

  AppOwner toModel() => AppOwner(
    id: id, userId: userId, unitId: unitId, 
    userName: userName, userPhone: userPhone, 
    unitDisplay: unitDisplay, apartmentName: apartmentName,
    isDeleted: isDeleted, deletedAt: deletedAt, isResident: isResident
  );
}

class TenantDto {
  final int id;
  final int? userId;
  final int? unitId;
  final String userName;
  final String userPhone;
  final String unitDisplay;
  final String? apartmentName;
  final bool isDeleted;
  final String? deletedAt;

  TenantDto({
    required this.id,
    this.userId,
    this.unitId,
    required this.userName, 
    required this.userPhone,
    required this.unitDisplay, 
    this.apartmentName,
    this.isDeleted = false,
    this.deletedAt,
  });

  factory TenantDto.fromJson(Map<String, dynamic> json) {
    return TenantDto(
      id: json['id'],
      userId: json['user'],
      unitId: json['unit'],
      userName: json['user_name'] ?? '',
      userPhone: json['user_phone'] ?? '',
      unitDisplay: json['unit_display'] ?? '',
      apartmentName: json['apartment_name'],
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'],
    );
  }

  AppTenant toModel() => AppTenant(
    id: id, userId: userId, unitId: unitId, 
    userName: userName, userPhone: userPhone, 
    unitDisplay: unitDisplay, apartmentName: apartmentName,
    isDeleted: isDeleted, deletedAt: deletedAt
  );
}


class LeaseContractDto {
  final int id;
  final String title;
  final int unitId;
  final String unitDisplay;
  final int ownerId;
  final String ownerName;
  final int tenantId;
  final String tenantName;
  final String startDate;
  final String endDate;
  final double monthlyRent;
  final double depositAmount;
  final String status;
  final String statusDisplay;
  final String? contractFileUrl;

  LeaseContractDto({
    required this.id,
    required this.title,
    required this.unitId,
    required this.unitDisplay,
    required this.ownerId,
    required this.ownerName,
    required this.tenantId,
    required this.tenantName,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.depositAmount,
    required this.status,
    required this.statusDisplay,
    this.contractFileUrl,
  });

  factory LeaseContractDto.fromJson(Map<String, dynamic> json) {
    return LeaseContractDto(
      id: json['id'],
      title: json['title'] ?? '',
      unitId: json['unit'] ?? 0,
      unitDisplay: json['unit_display'] ?? '',
      ownerId: json['owner'] ?? 0,
      ownerName: json['owner_name'] ?? '',
      tenantId: json['tenant'] ?? 0,
      tenantName: json['tenant_name'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      monthlyRent: double.tryParse(json['monthly_rent']?.toString() ?? '0') ?? 0,
      depositAmount: double.tryParse(json['deposit_amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      contractFileUrl: json['contract_file_url'],
    );
  }

  AppLeaseContract toModel() => AppLeaseContract(
    id: id, title: title, unitId: unitId, unitDisplay: unitDisplay,
    ownerId: ownerId, ownerName: ownerName, tenantId: tenantId, tenantName: tenantName,
    startDate: startDate, endDate: endDate, monthlyRent: monthlyRent, depositAmount: depositAmount,
    status: status, statusDisplay: statusDisplay, contractFileUrl: contractFileUrl,
  );
}
