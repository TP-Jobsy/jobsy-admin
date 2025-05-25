import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
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

  void _loadUsers() async {
    setState(() => _loading = true);
    final response = await adminService.searchUsers(
      firstName: _searchTerm,
      lastName: _searchTerm,
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
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : AbstractTablePage<AdminUserRow>(
                futureList: Future.value(_users),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Id',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Имя',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Фамилия',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Роль',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Статус',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Дата регистрации',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Подробнее',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
                buildRow: (u) {
                  final d = u.registeredAt;
                  final date =
                      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
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
