import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/portfolio/portfolio.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../util/palette.dart';
import 'sidebar.dart';

class PortfolioDetailPage extends StatelessWidget {
  final int portfolioId;
  const PortfolioDetailPage({
    Key? key,
    required this.portfolioId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final token = context.read<AdminAuthProvider>().token!;

    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text('Детали портфолио'),
        backgroundColor: Palette.primary,
      ),
      body: FutureBuilder<FreelancerPortfolio>(
        future: AdminService().getPortfolioById(token, portfolioId),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(child: Text('Ошибка при загрузке данных'));
          }
          final dto = snap.data!;
          final skillsStr = dto.skills.isNotEmpty
              ? dto.skills.map((s) => s.name).join(', ')
              : '—';
          return Padding(
            padding: const EdgeInsets.fromLTRB(60, 40, 60, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField('Название проекта:', dto.title),
                _buildField('Должность:', dto.roleInProject ?? '—'),
                _buildField('Описание:', dto.description),
                _buildField('Ссылка:', dto.projectLink),
                _buildField('Навыки:', skillsStr),
                _buildField('Дата создания:', _formatDate(dto.createdAt)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 180, child: Text(label, style: const TextStyle(fontSize: 16))),
          const SizedBox(width: 16),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
          '${d.month.toString().padLeft(2, '0')}.'
          '${d.year}';
}