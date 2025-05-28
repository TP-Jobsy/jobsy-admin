import 'package:flutter/material.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import 'package:provider/provider.dart';
import '../../model/client/client_profile.dart';
import '../../model/free/freelancer_profile.dart';
import '../../model/portfolio/portfolio.dart';
import '../../model/project/project.dart';
import '../../provider/auth_provider.dart';
import '../../service/admin_service.dart';
import '../../service/api_client.dart';
import '../../util/palette.dart';
import '../../util/routes.dart';
import '../../widgets/avatar.dart';
import 'admin_layout.dart';
import 'pagination_bar.dart';
import 'portfolio_detail_page.dart';
import 'project_detail_page.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  final String role;

  const UserDetailPage({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool get isClient => widget.role == 'CLIENT';
  int _currentPage = 1;
  String _status = 'Активен';

  ClientProfile? _client;
  FreelancerProfile? _freelancer;
  List<Project> _projects = [];
  List<FreelancerPortfolio> _portfolios = [];
  late final ApiClient _apiClient;
  late final AdminService _service;

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    final auth = context.read<AdminAuthProvider>();
    _apiClient = ApiClient(
      baseUrl: Routes.apiBase,
      getToken: () async {
        await auth.ensureLoaded();
        return auth.token;
      },
      refreshToken: () async => auth.refreshTokens(),
    );
    _service = AdminService(client: _apiClient);

    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AdminAuthProvider>();
    final service = AdminService(
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
      if (isClient) {
        final client = await service.getClientById(int.parse(widget.userId));
        final projects = await service.getClientProjects(int.parse(widget.userId));
        setState(() {
          _client = client;
          _projects = projects;
          _status = client.user.isActive ? 'Активен' : 'Заблокирован';
        });
      } else {
        final freelancer = await service.getFreelancerById(int.parse(widget.userId));
        final portfolios = await service.getFreelancerPortfolio(int.parse(widget.userId));
        setState(() {
          _freelancer = freelancer;
          _portfolios = portfolios;
          _status = freelancer.user.isActive ? 'Активен' : 'Заблокирован';
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  int get totalPages => isClient ? 2 : 3;

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentSection: AdminSection.users,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _status == 'Активен'
                  ? const Color(0xFFE6F4EA)
                  : const Color(0xFFFDEAEA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _status == 'Активен'
                    ? const Color(0xFF1E8E3E)
                    : const Color(0xFFB00020),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _status,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: _status == 'Активен'
                      ? const Color(0xFF1E8E3E)
                      : const Color(0xFFB00020),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Активен',
                    child: Text('Активен'),
                  ),
                  DropdownMenuItem(
                    value: 'Заблокирован',
                    child: Text('Заблокирован'),
                  ),
                ],
                onChanged: (newStatus) async {
                  if (newStatus == null || newStatus == _status) return;
                  setState(() => _loading = true);
                  try {
                    final id = int.parse(widget.userId);
                    if (newStatus == 'Заблокирован') {
                      if (isClient) {
                        await _service.deactivateClient(id);
                      } else {
                        await _service.deactivateFreelancer(id);
                      }
                    } else {
                      if (isClient) {
                        await _service.activateClient(id);
                      } else {
                        await _service.activateFreelancer(id);
                      }
                    }
                    setState(() {
                      _status = newStatus;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(newStatus == 'Активен'
                            ? 'Пользователь активирован'
                            : 'Пользователь заблокирован'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: $e')),
                    );
                  } finally {
                    setState(() => _loading = false);
                  }
                },
                dropdownColor: Colors.white,
                style: TextStyle(
                  color: _status == 'Активен'
                      ? const Color(0xFF1E8E3E)
                      : const Color(0xFFB00020),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(child: _buildContent()),
          PaginationBar(
            currentPage: _currentPage,
            totalPages: totalPages,
            onPageChanged: (p) => setState(() => _currentPage = p),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_currentPage == 1) return _buildUserInfo();
    if (_currentPage == 2) return _buildProjectList();
    if (_currentPage == 3 && !isClient) return _buildPortfolioList();
    return const Center(child: Text('Нет данных'));
  }

  Widget _buildUserInfo() {
    final user = isClient ? _client?.user : _freelancer?.user;
    if (user == null) return const SizedBox.shrink();

    final map = isClient
        ? {
      'Имя': user.firstName,
      'Фамилия': user.lastName,
      'Почта': user.email,
      'Телефон': _client?.basic.phone,
      'Дата рождения': _client?.basic.dateBirth,
      'Роль': user.role,
      'Город': _client?.basic.city,
      'Страна': _client?.basic.country,
      'Компания': _client?.basic.companyName,
      'Должность': _client?.basic.position,
      'Сфера деятельности': _client?.field.fieldDescription,
      'Связь': _client?.contact.contactLink,
      'Рейтинг': _client?.averageRating.toStringAsFixed(1),
    }
        : {
      'Имя': user.firstName,
      'Фамилия': user.lastName,
      'Почта': user.email,
      'Телефон': _freelancer?.basic.phone,
      'Дата рождения': _freelancer?.basic.dateBirth,
      'Роль': user.role,
      'Город': _freelancer?.basic.city,
      'Страна': _freelancer?.basic.country,
      'Сфера деятельности': _freelancer?.about.categoryName,
      'Специализация': _freelancer?.about.specializationName,
      'Опыт': _freelancer?.about.experienceLevel,
      'О себе': _freelancer?.about.aboutMe,
      'Связь': _freelancer?.contact.contactLink,
      'Рейтинг': _freelancer?.averageRating.toStringAsFixed(1),
      'Навыки': _freelancer!.skills.map((s) => s.name).join(', '),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(60, 0, 50, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Avatar(
              url: isClient ? _client?.avatarUrl : _freelancer?.avatarUrl,
              size: 90,
              placeholderAsset: 'assets/icons/avatar.svg',
            ),
          ),
          const SizedBox(height: 40),
          ...map.entries.map((e) => _buildField(e.key, e.value ?? '')),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    if (_projects.isEmpty) {
      return const Center(child: Text('Нет проектов'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
      itemCount: _projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final project = _projects[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailPage(projectId: project.id),
              ),
            );
          },
          child: ListTile(
            title: Text(project.title),
            subtitle: Text('ID: ${project.id} | ${_formatDate(project.createdAt)}'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }

  Widget _buildPortfolioList() {
    if (_portfolios.isEmpty) {
      return const Center(child: Text('Нет портфолио'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
      itemCount: _portfolios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final pf = _portfolios[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PortfolioDetailPage(portfolioId: pf.id),
              ),
            );
          },
          child: ListTile(
            title: Text(pf.title),
            subtitle: Text('ID: ${pf.id} | ${_formatDate(pf.createdAt)}'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text('$label:', style: const TextStyle(fontSize: 16))),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              readOnly: true,
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}