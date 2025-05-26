class AdminUserRow {
  final String id;
  final String firstName;
  final String lastName;
  final String role;
  final String status;
  final DateTime registeredAt;

  AdminUserRow({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    required this.registeredAt,
  });
}