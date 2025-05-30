import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:jobsy_admin/pages/user_detail_page.dart';
import '../model/admin_user_row.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../service/api_client.dart';
import '../util/palette.dart';
import '../util/routes.dart';
import 'abstract_table_page.dart';
import 'admin_layout.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<AdminUserRow> _users = [];
  String? _searchTerm;
  bool _loading = true;
  late final AdminService adminService;

  String? _filterRole;
  DateTime? _filterFrom;
  DateTime? _filterTo;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AdminAuthProvider>();
    adminService = AdminService(
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
    _loadUsers();
  }

  Future<_UserFilterResult?> _showUserFilterDialog() {
    String? role = _filterRole;
    DateTime? from = _filterFrom, to = _filterTo;

    return showDialog<_UserFilterResult>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Фильтры пользователей'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String?>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Роль'),
                    items: <String?>[null, 'CLIENT', 'FREELANCER']
                        .map<DropdownMenuItem<String?>>((r) {
                      final text = r == null ? 'Любая' : r;
                      return DropdownMenuItem<String?>(
                        value: r,
                        child: Text(text),
                      );
                    }).toList(),
                    onChanged: (v) => role = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Зарегистрирован с (yyyy-MM-dd)',
                    ),
                    initialValue: from?.toIso8601String().substring(0, 10),
                    onChanged:
                        (v) => from = v.isEmpty ? null : DateTime.tryParse(v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'По (yyyy-MM-dd)',
                    ),
                    initialValue: to?.toIso8601String().substring(0, 10),
                    onChanged:
                        (v) => to = v.isEmpty ? null : DateTime.tryParse(v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    ctx,
                  ).pop(const _UserFilterResult(null, null, null));
                },
                child: const Text('Сбросить'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(_UserFilterResult(role, from, to));
                },
                child: const Text('Применить'),
              ),
            ],
          ),
    );
  }

  void _onFilterTap() async {
    final res = await _showUserFilterDialog();
    if (res != null) {
      _filterRole = res.role;
      _filterFrom = res.from;
      _filterTo = res.to;
      _loadUsers();
    }
  }

  void _loadUsers() async {
    setState(() => _loading = true);
    final response = await adminService.searchUsers(
      term: _searchTerm,
      role: _filterRole,
      registeredFrom: _filterFrom,
      registeredTo: _filterTo,
    );
    setState(() {
      _users =
          response.content
              .map(
                (u) => AdminUserRow(
                  id: u.id,
                  firstName: u.firstName,
                  lastName: u.lastName,
                  role: u.role,
                  status: u.isActive ? 'Активен' : 'Заблокирован',
                  registeredAt: u.createdAt,
                ),
              )
              .toList();
      _loading = false;
    });
  }

  void _onSearch(String query) {
    _searchTerm = query.trim().isEmpty ? null : query;
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentSection: AdminSection.users,
      onSearch: _onSearch,
      onFilter: _onFilterTap,
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : AbstractTablePage<AdminUserRow>(
                futureList: Future.value(_users),
                columns: const [
                  DataColumn(label: Text('Id', style: _headerStyle)),
                  DataColumn(label: Text('Имя', style: _headerStyle)),
                  DataColumn(label: Text('Фамилия', style: _headerStyle)),
                  DataColumn(label: Text('Роль', style: _headerStyle)),
                  DataColumn(label: Text('Статус', style: _headerStyle)),
                  DataColumn(
                    label: Text('Дата регистрации', style: _headerStyle),
                  ),
                  DataColumn(label: Text('Подробнее', style: _headerStyle)),
                ],
                buildRow: (u) {
                  final d = u.registeredAt;
                  final date =
                      '${d.day.toString().padLeft(2, '0')}.'
                      '${d.month.toString().padLeft(2, '0')}.'
                      '${d.year}';
                  return DataRow(
                    cells: [
                      DataCell(Text(u.id)),
                      DataCell(Text(u.firstName)),
                      DataCell(Text(u.lastName)),
                      DataCell(Text(u.role)),
                      DataCell(Text(u.status)),
                      DataCell(Text(date)),
                      DataCell(
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/icons/ArrowRight.svg',
                            width: 16,
                            height: 16,
                            color: Palette.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => UserDetailPage(
                                      userId: u.id,
                                      role: u.role,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontWeight: FontWeight.w900,
  fontFamily: 'Inter',
  fontSize: 16,
);

class _UserFilterResult {
  final String? role;
  final DateTime? from, to;

  const _UserFilterResult(this.role, this.from, this.to);
}
