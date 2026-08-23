import '../../domain/models/user.dart';

class UserDto {
  final int id;
  final String phone;
  final String? email;
  final String firstName;
  final String lastName;
  final String role;
  final String? roleDisplay;
  final String? companyName;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final String createdAt;
  final String updatedAt;
  final List<String> ownedUnits;
  final List<String> rentedUnits;

  UserDto({
    required this.id,
    required this.phone,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.roleDisplay,
    this.companyName,
    required this.isActive,
    required this.isStaff,
    required this.isSuperuser,
    required this.createdAt,
    required this.updatedAt,
    this.ownedUnits = const [],
    this.rentedUnits = const [],
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      phone: json['phone'] ?? '',
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'owner',
      roleDisplay: json['role_display'],
      companyName: json['company_name'],
      isActive: json['is_active'] ?? true,
      isStaff: json['is_staff'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
      ownedUnits: (json['owned_units'] as List?)?.map((e) => e.toString()).toList() ?? [],
      rentedUnits: (json['rented_units'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  AppUser toModel() {
    return AppUser(
      id: id,
      phone: phone,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      roleDisplay: roleDisplay,
      companyName: companyName,
      isActive: isActive,
      isStaff: isStaff,
      isSuperuser: isSuperuser,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      ownedUnits: ownedUnits,
      rentedUnits: rentedUnits,
    );
  }
}
