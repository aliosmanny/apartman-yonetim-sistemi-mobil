import '../dto/login_response_dto.dart';
import '../../domain/models/auth_user.dart';

/// DTO → Domain model dönüşümleri.
abstract class AuthMapper {
  static AuthUser fromLoginResponse(LoginResponseDto dto) {
    return AuthUser(
      id: dto.user.id,
      phone: dto.user.phone,
      email: dto.user.email,
      firstName: dto.user.firstName,
      lastName: dto.user.lastName,
      fullName: dto.user.fullName,
      role: UserRole.fromString(dto.user.role),
      companyName: dto.user.companyName,
      accessToken: dto.access,
      refreshToken: dto.refresh,
    );
  }
}
