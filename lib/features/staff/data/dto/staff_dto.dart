import '../../domain/models/staff_member.dart';

class StaffDto extends StaffMember {
  StaffDto({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userPhone,
    super.userEmail,
    required super.apartmentId,
    required super.apartmentName,
    required super.role,
    required super.roleDisplay,
    required super.isActive,
  });

  factory StaffDto.fromJson(Map<String, dynamic> json) {
    return StaffDto(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user'] is int ? json['user'] : int.tryParse(json['user']?.toString() ?? '0') ?? 0,
      userName: json['user_name']?.toString() ?? 'Bilinmeyen Kullanıcı',
      userPhone: json['user_phone']?.toString() ?? '',
      userEmail: json['user_email']?.toString(),
      apartmentId: json['apartment'] is int ? json['apartment'] : int.tryParse(json['apartment']?.toString() ?? '0') ?? 0,
      apartmentName: json['apartment_name']?.toString() ?? 'Bilinmeyen Apartman',
      role: json['role']?.toString() ?? '',
      roleDisplay: json['role_display']?.toString() ?? '',
      isActive: json['is_active'] == true,
    );
  }
}
