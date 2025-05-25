class ProjectAdminListItem {
  final int id;
  final String title;
  final DateTime createdAt;
  final String status;
  final String clientFirstName;
  final String clientLastName;

  ProjectAdminListItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.status,
    required this.clientFirstName,
    required this.clientLastName,
  });

  factory ProjectAdminListItem.fromJson(Map<String, dynamic> json) {
    return ProjectAdminListItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      clientFirstName: json['clientFirstName'] ?? '-',
      clientLastName: json['clientLastName'] ?? '-',
    );
  }
}
