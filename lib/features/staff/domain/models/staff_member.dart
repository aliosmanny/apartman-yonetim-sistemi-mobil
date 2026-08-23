class StaffMember {
  final int id;
  final int userId;
  final String userName;
  final String userPhone;
  final String? userEmail;
  final int apartmentId;
  final String apartmentName;
  final String role;
  final String roleDisplay;
  final bool isActive;

  StaffMember({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.userEmail,
    required this.apartmentId,
    required this.apartmentName,
    required this.role,
    required this.roleDisplay,
    required this.isActive,
  });
}
