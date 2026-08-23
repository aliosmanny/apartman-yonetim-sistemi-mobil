class AppApartment {
  final int id;
  final String name;
  final String province;
  final String district;
  final String? address;
  final double? monthlyLateFeeRate;
  final String? managerName;
  final int totalBlocks;
  final int totalUnits;

  AppApartment({
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
}

class AppBlock {
  final int id;
  final int apartmentId;
  final String apartmentName;
  final String name;
  final int floorCount;
  final int unitCount;

  AppBlock({
    required this.id,
    required this.apartmentId,
    required this.apartmentName,
    required this.name,
    required this.floorCount,
    required this.unitCount,
  });
}

class AppUnit {
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

  AppUnit({
    required this.id,
    required this.blockId,
    required this.blockName,
    required this.apartmentName,
    required this.number,
    required this.floor,
    required this.usageStatus,
    required this.usageStatusDisplay,
    this.currentOwner,
    this.currentTenant,
  });
}

class AppOwner {
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

  AppOwner({
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
}

class AppTenant {
  final int id;
  final int? userId;
  final int? unitId;
  final String userName;
  final String userPhone;
  final String unitDisplay;
  final String? apartmentName;
  final bool isDeleted;
  final String? deletedAt;

  AppTenant({
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
}


class AppLeaseContract {
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

  AppLeaseContract({
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
}
