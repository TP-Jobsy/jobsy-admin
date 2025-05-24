class ProjectAdminListItem {
  final int id;
  final String title;
  final DateTime createdAt;
  final String status;
  final ClientInfo client;

  ProjectAdminListItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.status,
    required this.client,
  });

  factory ProjectAdminListItem.fromJson(Map<String, dynamic> json) {
    final clientJson = json['client'];
    return ProjectAdminListItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      client:
          clientJson != null
              ? ClientInfo.fromJson(clientJson as Map<String, dynamic>)
              : ClientInfo(firstName: '-', lastName: '-'),
    );
  }
}

class ClientInfo {
  final String firstName;
  final String lastName;

  ClientInfo({required this.firstName, required this.lastName});

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }
}
