import 'package:flutter/material.dart';
import '../../model/client/client_profile.dart';
import '../../widgets/avatar.dart';

class ClientDetailContent extends StatelessWidget {
  final ClientProfile client;

  const ClientDetailContent({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final basic = client.basic;
    final contact = client.contact;
    final field = client.field;
    final user = client.user;

    String safe(String? v, [String emptyText = 'Информация не указана']) =>
        (v != null && v.isNotEmpty) ? v : emptyText;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Avatar(
              url: client.avatarUrl,
              size: 90,
              placeholderAsset: 'assets/icons/avatar.svg',
            ),
          ),
          const SizedBox(height: 32),
          _buildField('Имя', safe(user.firstName)),
          _buildField('Фамилия', safe(user.lastName)),
          _buildField('Почта', safe(user.email)),
          _buildField('Телефон', safe(basic.phone)),
          _buildField('Дата рождения', basic.dateBirth),
          _buildField('Роль', user.role),
          _buildField('Страна', safe(basic.country)),
          _buildField('Город', safe(basic.city)),
          _buildField('Связь', safe(contact.contactLink)),
          _buildField('Рейтинг', client.averageRating.toStringAsFixed(1)),
          _buildField('Компания', safe(basic.companyName)),
          _buildField('Должность', safe(basic.position)),
          _buildField('Сфера деятельности', safe(field.fieldDescription)),
          _buildField('Дата регистрации', _formatDate(client.createdAt)),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
