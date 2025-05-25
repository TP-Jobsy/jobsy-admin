import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import '../model/admin_user_row.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../service/api_client.dart';
import '../util/palette.dart';
import '../util/routes.dart';
import 'abstract_table_page.dart';
import 'user_detail_page.dart';

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();

    final adminService = AdminService(
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

    return AbstractTablePage<AdminUserRow>(
      currentSection: AdminSection.users,
      futureListBuilder: (search) async {
        final response = await adminService.searchUsers(
          firstName: search,
          lastName: search,
        );
        return response.content.map((u) => AdminUserRow(
          id: u.id,
          firstName: u.firstName,
          lastName: u.lastName,
          role: u.role,
          status: u.isActive ? 'Активен' : 'Заблокирован',
          registeredAt: u.createdAt,
        )).toList();
      },
      columns: const [
        DataColumn(label: Text('Id', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
        DataColumn(label: Text('Имя', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
        DataColumn(label: Text('Фамилия', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
        DataColumn(label: Text('Роль', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
        DataColumn(label: Text('Статус', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
        DataColumn(label: Text('Дата регистрации', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
        DataColumn(label: Text('Подробнее', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
      ],
      buildRow: (u) {
        final d = u.registeredAt;
        final date = '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
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
                      builder: (_) => UserDetailPage(userId: u.id, role: u.role),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}