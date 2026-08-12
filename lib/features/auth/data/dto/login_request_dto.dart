/// Login isteği DTO.
/// POST /api/v1/auth/login/
class LoginRequestDto {
  final String phone;
  final String password;

  const LoginRequestDto({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'password': password,
      };
}
