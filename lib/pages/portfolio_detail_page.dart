import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/portfolio/portfolio.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../service/api_client.dart';
import '../util/palette.dart';
import '../util/routes.dart';
import 'admin_layout.dart';
import 'sidebar.dart';

class PortfolioDetailPage extends StatefulWidget {
  final int portfolioId;

  const PortfolioDetailPage({Key? key, required this.portfolioId})
    : super(key: key);

  @override
  State<PortfolioDetailPage> createState() => _PortfolioDetailPageState();
}

class _PortfolioDetailPageState extends State<PortfolioDetailPage> {
  FreelancerPortfolio? _portfolio;
  bool _loading = true;
  late AdminService _adminService;

  @override
  void initState() {
    super.initState();
    _initServiceAndLoad();
  }

  Future<void> _initServiceAndLoad() async {
    final auth = context.read<AdminAuthProvider>();
    _adminService = AdminService(
      client: ApiClient(
        baseUrl: Routes.apiBase,
        getToken: () async {
          await auth.ensureLoaded();
          return auth.token;
        },
        refreshToken: () async {
          await auth.refreshTokens();
        },
      ),
    );

    try {
      final portfolio = await _adminService.getPortfolioById(
        widget.portfolioId,
      );
      setState(() {
        _portfolio = portfolio;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentSection: AdminSection.portfolio,
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _portfolio == null
              ? const Center(child: Text('Портфолио не найдено'))
              : _buildContent(_portfolio!),
    );
  }

  Widget _buildContent(FreelancerPortfolio dto) {
    final skillsStr =
        dto.skills.isNotEmpty ? dto.skills.map((s) => s.name).join(', ') : '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 40, 60, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back_ios, size: 20),
              ),
              const SizedBox(width: 16),
              const Text(
                'Детали портфолио',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Удалить портфолио',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Удалить портфолио?'),
                          content: Text(
                            'Вы уверены, что хотите удалить портфолио "${dto.title}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Удалить'),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    try {
                      await _adminService.deletePortfolio(
                        dto.freelancerId, dto.id,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Портфолио успешно удалено'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ошибка при удалении: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildField('Название проекта:', dto.title),
          _buildField('Должность:', dto.roleInProject ?? '—'),
          _buildField('Описание:', dto.description),
          _buildField('Ссылка:', dto.projectLink),
          _buildField('Навыки:', skillsStr),
          _buildField('Дата создания:', _formatDate(dto.createdAt)),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              readOnly: true,
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Palette.grey3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Palette.grey3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.'
      '${d.year}';
}
