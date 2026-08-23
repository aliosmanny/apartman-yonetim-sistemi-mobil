/// Dashboard API yanıtları için DTO modelleri.
/// GET /api/v1/dashboard/ → role göre farklı alanlar döner.

class ManagerDashboardDto {
  final int apartmentCount;
  final int totalUnits;
  final int totalResidents;
  final int totalOwners;
  final int totalTenants;
  final double totalUnpaidAmount;
  final double totalCollected;
  final int overdueCount;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final int pendingMaintenance;
  final int inProgressMaintenance;
  final List<RecentMaintenanceDto> recentMaintenance;
  final List<RecentAnnouncementDto> recentAnnouncements;

  const ManagerDashboardDto({
    required this.apartmentCount,
    required this.totalUnits,
    required this.totalResidents,
    required this.totalOwners,
    required this.totalTenants,
    required this.totalUnpaidAmount,
    required this.totalCollected,
    required this.overdueCount,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.pendingMaintenance,
    required this.inProgressMaintenance,
    required this.recentMaintenance,
    required this.recentAnnouncements,
  });

  factory ManagerDashboardDto.fromJson(Map<String, dynamic> json) {
    return ManagerDashboardDto(
      apartmentCount: json['apartment_count'] as int? ?? 0,
      totalUnits: json['total_units'] as int? ?? 0,
      totalResidents: json['total_residents'] as int? ?? 0,
      totalOwners: json['total_owners'] as int? ?? 0,
      totalTenants: json['total_tenants'] as int? ?? 0,
      totalUnpaidAmount: double.tryParse(json['total_unpaid_amount']?.toString() ?? '0') ?? 0,
      totalCollected: double.tryParse(json['total_collected']?.toString() ?? '0') ?? 0,
      overdueCount: json['overdue_count'] as int? ?? 0,
      totalIncome: double.tryParse(json['total_income']?.toString() ?? '0') ?? 0,
      totalExpense: double.tryParse(json['total_expense']?.toString() ?? '0') ?? 0,
      netBalance: double.tryParse(json['net_balance']?.toString() ?? '0') ?? 0,
      pendingMaintenance: json['pending_maintenance'] as int? ?? 0,
      inProgressMaintenance: json['in_progress_maintenance'] as int? ?? 0,
      recentMaintenance: (json['recent_maintenance'] as List<dynamic>? ?? [])
          .map((e) => RecentMaintenanceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentAnnouncements: (json['recent_announcements'] as List<dynamic>? ?? [])
          .map((e) => RecentAnnouncementDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ResidentDashboardDto {
  final bool hasUnit;
  final List<UnitSimpleDto> units;
  final int unpaidCount;
  final int overdueCount;
  final int paidCount;
  final double totalUnpaid;
  final double totalPaid;
  final double totalLateFee;
  final List<RecentMaintenanceDto> recentMaintenance;
  final List<RecentAnnouncementDto> recentAnnouncements;

  const ResidentDashboardDto({
    required this.hasUnit,
    this.units = const [],
    required this.unpaidCount,
    required this.overdueCount,
    required this.paidCount,
    required this.totalUnpaid,
    required this.totalPaid,
    required this.totalLateFee,
    required this.recentMaintenance,
    required this.recentAnnouncements,
  });

  factory ResidentDashboardDto.fromJson(Map<String, dynamic> json) {

    final List<dynamic> rawUnits = json['units'] as List<dynamic>? ?? [];
    final List<UnitSimpleDto> parsedUnits = rawUnits.map((u) {
       final id = u['id'] as int? ?? 0;
       final display = u['display']?.toString() ?? '';
       final floor = u['floor']?.toString() ?? '';
       return UnitSimpleDto(id: id, display: '$display (Kat $floor)');
    }).toList();
    
    return ResidentDashboardDto(
      units: parsedUnits,
      hasUnit: json['has_unit'] as bool? ?? false,

      unpaidCount: json['unpaid_count'] as int? ?? 0,
      overdueCount: json['overdue_count'] as int? ?? 0,
      paidCount: json['paid_count'] as int? ?? 0,
      totalUnpaid: double.tryParse(json['total_unpaid']?.toString() ?? '0') ?? 0,
      totalPaid: double.tryParse(json['total_paid']?.toString() ?? '0') ?? 0,
      totalLateFee: double.tryParse(json['total_late_fee']?.toString() ?? '0') ?? 0,
      recentMaintenance: (json['recent_maintenance'] as List<dynamic>? ?? [])
          .map((e) => RecentMaintenanceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentAnnouncements: (json['recent_announcements'] as List<dynamic>? ?? [])
          .map((e) => RecentAnnouncementDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StaffDashboardDto {
  final int pendingCount;
  final int inProgressCount;
  final int completedCount;
  final List<RecentMaintenanceDto> recentRequests;

  const StaffDashboardDto({
    required this.pendingCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.recentRequests,
  });

  factory StaffDashboardDto.fromJson(Map<String, dynamic> json) {
    return StaffDashboardDto(
      pendingCount: json['pending_count'] as int? ?? 0,
      inProgressCount: json['in_progress_count'] as int? ?? 0,
      completedCount: json['completed_count'] as int? ?? 0,
      recentRequests: (json['recent_requests'] as List<dynamic>? ?? [])
          .map((e) => RecentMaintenanceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RecentMaintenanceDto {
  final int id;
  final String title;
  final String status;
  final String statusDisplay;
  final String? unit;
  final String createdAt;

  const RecentMaintenanceDto({
    required this.id,
    required this.title,
    required this.status,
    required this.statusDisplay,
    this.unit,
    required this.createdAt,
  });

  factory RecentMaintenanceDto.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString() ?? '';
    return RecentMaintenanceDto(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      status: rawStatus,
      statusDisplay: _mapStatus(rawStatus),
      unit: json['unit'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  // Backend status_display bazen kısa harf döndürüyor → backend bug olarak raporlandı
  static String _mapStatus(String raw) {
    switch (raw) {
      case 'pending':     return 'Beklemede';
      case 'assigned':    return 'Personel Atandı';
      case 'in_progress': return 'Devam Ediyor';
      case 'completed':   return 'Tamamlandı';
      case 'cancelled':   return 'İptal Edildi';
      case 'c': return 'Tamamlandı';
      case 'a': return 'Personel Atandı';
      case 'p': return 'Beklemede';
      case 'i': return 'Devam Ediyor';
      default:  return raw;
    }
  }
}

class RecentAnnouncementDto {
  final int id;
  final String title;
  final String? content;
  final String? publishDate;

  const RecentAnnouncementDto({
    required this.id,
    required this.title,
    this.content,
    this.publishDate,
  });

  factory RecentAnnouncementDto.fromJson(Map<String, dynamic> json) {
    return RecentAnnouncementDto(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String?,
      publishDate: json['publish_date'] as String?,
    );
  }
}

class UnitSimpleDto {
  final int id;
  final String display;
  const UnitSimpleDto({required this.id, required this.display});
}
