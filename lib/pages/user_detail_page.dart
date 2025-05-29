import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
import '../model/error_snackbar.dart';
import 'admin_layout.dart';
import 'pagination_bar.dart';
import 'portfolio_detail_page.dart';
import 'project_detail_page.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  final String role;

  const UserDetailPage({super.key, required this.userId, required this.role});

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
    _initAdminService();
  }

  Future<void> _initAdminService() async {
    final auth = context.read<AdminAuthProvider>();
    await auth.ensureLoaded();

    _service = AdminService(
      client: ApiClient(
        baseUrl: Routes.apiBase,
        getToken: () async => auth.token,
        refreshToken: () async => auth.refreshTokens(),
      ),
    );

    await _loadInfo();
  }

  Future<void> _loadInfo() async {
    setState(() => _loading = true);
    final id = int.parse(widget.userId);
    try {
      if (isClient) {
        _client = await _service.getClientById(id);
        _status = _client!.user.isActive ? 'Активен' : 'Заблокирован';
      } else {
        _freelancer = await _service.getFreelancerById(id);
        _status = _freelancer!.user.isActive ? 'Активен' : 'Заблокирован';
      }
    } catch (e) {
      ErrorSnackbar.show(
        context,
        type: ErrorType.error,
        title: 'Ошибка загрузки профиля',
        message: '$e',
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadProjects() async {
    setState(() => _loading = true);
    final id = int.parse(widget.userId);
    try {
      if (isClient) {
        _projects = await _service.getClientProjects(id);
      } else {
        _projects = await _service.getFreelancerProjects(id);
      }
    } catch (e) {
      ErrorSnackbar.show(
        context,
        type: ErrorType.error,
        title: 'Ошибка загрузки проектов',
        message: '$e',
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadPortfolios() async {
    setState(() => _loading = true);
    final id = int.parse(widget.userId);
    try {
      _portfolios = await _service.getFreelancerPortfolio(id);
    } catch (e) {
      ErrorSnackbar.show(
        context,
        type: ErrorType.error,
        title: 'Ошибка загрузки портфолио',
        message: '$e',
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    if (page == 1) {
      _loadInfo();
    } else if (page == 2) {
      _loadProjects();
    } else if (page == 3 && !isClient) {
      _loadPortfolios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentSection: AdminSection.users,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_currentPage == 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 30, 50, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _status == 'Активен'
                            ? Palette.grey3
                            : Palette.bloodred,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _status,
                        icon: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: SvgPicture.asset(
                            'assets/icons/ArrowDown.svg',
                            width: 15,
                            height: 15,
                            color: _status == 'Активен'
                                ? Palette.grey3
                                : Palette.bloodred,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Активен', child: Text('Активен')),
                          DropdownMenuItem(
                              value: 'Заблокирован', child: Text('Заблокирован')),
                        ],
                        onChanged: (newStatus) async {
                          if (newStatus == null || newStatus == _status) return;
                          setState(() => _loading = true);
                          final id = int.parse(widget.userId);
                          try {
                            if (newStatus == 'Заблокирован') {
                              isClient
                                  ? await _service.deactivateClient(id)
                                  : await _service.deactivateFreelancer(id);
                            } else {
                              isClient
                                  ? await _service.activateClient(id)
                                  : await _service.activateFreelancer(id);
                            }
                            setState(() => _status = newStatus);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  newStatus == 'Активен'
                                      ? 'Пользователь активирован'
                                      : 'Пользователь заблокирован',
                                ),
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
                        dropdownColor: Palette.white,
                        style: TextStyle(
                          fontSize: 14,
                          color: _status == 'Активен'
                              ? Palette.black
                              : Palette.bloodred,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(child: _buildContent()),
          PaginationBar(
            currentPage: _currentPage,
            totalPages: isClient ? 2 : 3,
            onPageChanged: _onPageChanged,
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

    final map =
        isClient
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
      itemBuilder: (_, i) {
        final p = _projects[i];
        return ListTile(
          title: Text(p.title),
          subtitle: Text('ID: ${p.id} | ${_formatDate(p.createdAt)}'),
          trailing: SvgPicture.asset(
            'assets/icons/ArrowRight.svg',
            width: 16,
            height: 16,
            color: Palette.black,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailPage(projectId: p.id),
              ),
            );
          },
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
      itemBuilder: (_, i) {
        final pf = _portfolios[i];
        return ListTile(
          title: Text(pf.title),
          subtitle: Text('ID: ${pf.id} | ${_formatDate(pf.createdAt)}'),
          trailing: SvgPicture.asset(
            'assets/icons/ArrowRight.svg',
            width: 16,
            height: 16,
            color: Palette.black,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PortfolioDetailPage(portfolioId: pf.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text('$label:', style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Palette.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Palette.grey3),
              ),
              child: Text(
                value.isNotEmpty ? value : '—',
                style: const TextStyle(fontSize: 16),
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
