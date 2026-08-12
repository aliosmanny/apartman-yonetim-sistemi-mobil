import '../../domain/models/auth_user.dart';
import '../dto/login_response_dto.dart';

/// Mock veri kaynağı.
/// Backend erişilemediğinde geliştirme senaryolarında kullanılır.
/// AppEnvironment.enableMock() ile etkinleştirilir.
class AuthMockDataSource {
  static const _mockDelay = Duration(milliseconds: 800);

  /// Test hesapları — her rol için bir kullanıcı.
  /// Şifre kontrolü yapılmaz (development only).
  static const _mockUsers = {
    '5001234567': (
      role: 'system_admin',
      name: 'Ali',
      surname: 'Yıldız',
      company: 'Yönetim A.Ş.',
    ),
    '5001234568': (
      role: 'apartment_manager',
      name: 'Mehmet',
      surname: 'Kaya',
      company: 'Kaya Yönetim',
    ),
    '5001234569': (
      role: 'owner',
      name: 'Ayşe',
      surname: 'Demir',
      company: null,
    ),
    '5001234570': (
      role: 'tenant',
      name: 'Fatma',
      surname: 'Çelik',
      company: null,
    ),
    '5001234571': (
      role: 'staff',
      name: 'Hasan',
      surname: 'Öztürk',
      company: null,
    ),
  };

  Future<LoginResponseDto> login({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(_mockDelay);

    final mockData = _mockUsers[phone];
    if (mockData == null) {
      // Kayıtlı test kullanıcısı değilse → varsayılan tenant rolü ver
      return _buildResponse(
        phone: phone,
        role: 'tenant',
        firstName: 'Test',
        lastName: 'Kullanıcı',
        companyName: null,
        id: 999,
      );
    }

    return _buildResponse(
      phone: phone,
      role: mockData.role,
      firstName: mockData.name,
      lastName: mockData.surname,
      companyName: mockData.company,
      id: _mockUsers.keys.toList().indexOf(phone) + 1,
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> sendForgotPasswordOtp({required String identifier}) async {
    await Future.delayed(_mockDelay);
  }

  Future<void> verifyForgotPasswordOtp({
    required String phone,
    required String code,
  }) async {
    await Future.delayed(_mockDelay);
    if (code != '123456') {
      throw Exception('Geçersiz kod. Mock\'ta doğru kod: 123456');
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirm,
  }) async {
    await Future.delayed(_mockDelay);
  }

  LoginResponseDto _buildResponse({
    required String phone,
    required String role,
    required String firstName,
    required String lastName,
    required String? companyName,
    required int id,
  }) {
    return LoginResponseDto(
      access: 'mock_access_token_$phone',
      refresh: 'mock_refresh_token_$phone',
      user: LoginUserDto(
        id: id,
        phone: phone,
        email: '$phone@mock.dev',
        firstName: firstName,
        lastName: lastName,
        fullName: '$firstName $lastName',
        role: role,
        roleDisplay: UserRole.fromString(role).displayName,
        companyName: companyName,
      ),
    );
  }
}
