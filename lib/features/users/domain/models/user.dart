class AppUser {
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> ownedUnits;
  final List<String> rentedUnits;

  const AppUser({
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

  String get fullName => '$firstName $lastName';
}
