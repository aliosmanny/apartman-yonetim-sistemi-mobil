import 'package:equatable/equatable.dart';

/// Backend'den gelen kullanıcı rolleri.
/// apps/api/serializers_auth.py → CustomTokenObtainPairSerializer'daki role değerleriyle birebir eşleşir.
enum UserRole {
  systemAdmin('system_admin'),
  apartmentManager('apartment_manager'),
  owner('owner'),
  tenant('tenant'),
  staff('staff');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => UserRole.tenant,
    );
  }

  String get displayName {
    switch (this) {
      case UserRole.systemAdmin:
        return 'Sistem Yöneticisi';
      case UserRole.apartmentManager:
        return 'Apartman Yöneticisi';
      case UserRole.owner:
        return 'Kat Maliki';
      case UserRole.tenant:
        return 'Kiracı';
      case UserRole.staff:
        return 'Personel';
    }
  }

  bool get isManager =>
      this == UserRole.systemAdmin || this == UserRole.apartmentManager;

  bool get isResident =>
      this == UserRole.owner || this == UserRole.tenant;
}

/// Giriş yapan kullanıcının domain modeli.
/// Backend: apps/api/serializers_auth.py → CustomTokenObtainPairSerializer.validate()
class AuthUser extends Equatable {
  final int id;
  final String phone;
  final String? email;
  final String firstName;
  final String lastName;
  final String fullName;
  final UserRole role;
  final String? companyName;
  final String accessToken;
  final String refreshToken;

  const AuthUser({
    required this.id,
    required this.phone,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    this.companyName,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [id, phone, role];
}
