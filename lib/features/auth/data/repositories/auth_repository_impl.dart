import '../../domain/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_mock_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../dto/login_request_dto.dart';
import '../mappers/auth_mapper.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/network/api_exception.dart';

/// Auth repository implementasyonu.
/// [useMock] true ise mock, false ise remote veri kaynağı kullanılır.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthMockDataSource _mockDataSource;
  final SecureStorage _secureStorage;
  final bool _useMock;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthMockDataSource mockDataSource,
    required SecureStorage secureStorage,
    required bool useMock,
  })  : _remoteDataSource = remoteDataSource,
        _mockDataSource = mockDataSource,
        _secureStorage = secureStorage,
        _useMock = useMock;

  @override
  Future<AuthUser> login({
    required String phone,
    required String password,
  }) async {
    try {
      final dto = _useMock
          ? await _mockDataSource.login(phone: phone, password: password)
          : await _remoteDataSource.login(
              LoginRequestDto(phone: phone, password: password),
            );

      final user = AuthMapper.fromLoginResponse(dto);

      await _secureStorage.saveSession(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
        role: user.role.value,
        userId: user.id.toString(),
      );

      return user;
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<void> logout() async {
    try {
      if (!_useMock) {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken != null) {
          await _remoteDataSource.logout(refreshToken: refreshToken);
        }
      }
    } finally {
      await _secureStorage.clearSession();
    }
  }

  @override
  Future<AuthUser?> getStoredUser() async {
    final hasSession = await _secureStorage.hasSession();
    if (!hasSession) return null;

    final role = await _secureStorage.getUserRole();
    final userId = await _secureStorage.getUserId();
    final accessToken = await _secureStorage.getAccessToken();
    final refreshToken = await _secureStorage.getRefreshToken();

    if (role == null || userId == null || accessToken == null ||
        refreshToken == null) {
      return null;
    }

    // Minimal AuthUser — tam profil için profile/me/ çağrısı yapılacak
    return AuthUser(
      id: int.tryParse(userId) ?? 0,
      phone: '',
      firstName: '',
      lastName: '',
      fullName: '',
      role: UserRole.fromString(role),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> sendForgotPasswordOtp({required String identifier}) async {
    try {
      if (_useMock) {
        await _mockDataSource.sendForgotPasswordOtp(identifier: identifier);
      } else {
        await _remoteDataSource.sendForgotPasswordOtp(identifier: identifier);
      }
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<void> verifyForgotPasswordOtp({
    required String phone,
    required String code,
  }) async {
    try {
      if (_useMock) {
        await _mockDataSource.verifyForgotPasswordOtp(
            phone: phone, code: code);
      } else {
        await _remoteDataSource.verifyForgotPasswordOtp(
            phone: phone, code: code);
      }
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      if (_useMock) {
        await _mockDataSource.resetPassword(
          phone: phone,
          code: code,
          password: password,
          passwordConfirm: passwordConfirm,
        );
      } else {
        await _remoteDataSource.resetPassword(
          phone: phone,
          code: code,
          password: password,
          passwordConfirm: passwordConfirm,
        );
      }
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }
}
