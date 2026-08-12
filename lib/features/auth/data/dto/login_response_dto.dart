/// Login yanıt DTO.
/// POST /api/v1/auth/login/ → CustomTokenObtainPairSerializer.validate()
/// Backend: apps/api/serializers_auth.py
class LoginResponseDto {
  final String access;
  final String refresh;
  final LoginUserDto user;

  const LoginResponseDto({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      user: LoginUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class LoginUserDto {
  final int id;
  final String phone;
  final String? email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String role;
  final String roleDisplay;
  final String? companyName;

  const LoginUserDto({
    required this.id,
    required this.phone,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    required this.roleDisplay,
    this.companyName,
  });

  factory LoginUserDto.fromJson(Map<String, dynamic> json) {
    return LoginUserDto(
      id: json['id'] as int,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      roleDisplay: json['role_display'] as String,
      companyName: json['company_name'] as String?,
    );
  }
}
