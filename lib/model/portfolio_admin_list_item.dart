class PortfolioAdminListItem {
  final int id;
  final String title;
  final DateTime createdAt;
  final String firstName;
  final String lastName;

  PortfolioAdminListItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
  });

  factory PortfolioAdminListItem.fromJson(Map<String, dynamic> json) {
    return PortfolioAdminListItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }
}