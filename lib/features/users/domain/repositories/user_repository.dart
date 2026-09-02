import '../models/user.dart';

abstract class UserRepository {
  Future<List<AppUser>> getUsers();
  Future<AppUser> createUser(Map<String, dynamic> data);
  Future<AppUser> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id);
  Future<void> saveDeviceToken(String token, String deviceType);
  Future<Map<String, dynamic>> getNotificationPreferences();
  Future<void> updateNotificationPreferences(Map<String, dynamic> data);
}
