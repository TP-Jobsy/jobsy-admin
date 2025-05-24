import 'package:flutter/material.dart';
import '../../model/free/freelancer_profile.dart';
import '../../util/palette.dart';
import '../../widgets/avatar.dart';

class FreelancerDetailContent extends StatelessWidget {
  final FreelancerProfile freelancer;

  const FreelancerDetailContent({Key? key, required this.freelancer})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final basic = freelancer.basic;
    final contact = freelancer.contact;
    final about = freelancer.about;
    final user = freelancer.user;
    final skills = freelancer.skills.map((s) => s.name).toList();

    String safe(String? v, [String emptyText = 'Информация не указана']) =>
        (v != null && v.isNotEmpty) ? v : emptyText;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Avatar(
              url: freelancer.avatarUrl,
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
          _buildField('Рейтинг', freelancer.averageRating.toStringAsFixed(1)),
          _buildField('Сфера деятельности', safe(about.categoryName)),
          _buildField('Специализация', safe(about.specializationName)),
          _buildField('Опыт', about.experienceLevel),
          _buildField('О себе', safe(about.aboutMe)),
          const SizedBox(height: 8),
          Text('Навыки:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children:
                skills.isEmpty
                    ? [
                      const Text(
                        '— нет навыков',
                        style: TextStyle(color: Palette.thin),
                      ),
                    ]
                    : skills.map((n) => Chip(label: Text(n))).toList(),
          ),
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
}
