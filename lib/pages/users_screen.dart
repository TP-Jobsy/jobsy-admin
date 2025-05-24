import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import '../model/admin_user_row.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../util/palette.dart';
import 'abstract_table_page.dart';
import 'user_detail_page.dart';

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final token = context.watch<AdminAuthProvider>().token;
    final adminService = AdminService();

    return AbstractTablePage<AdminUserRow>(
      currentSection: AdminSection.users,
      futureList:
          token == null
              ? Future.value(<AdminUserRow>[])
              : adminService
                  .getAllClients(token)
                  .then(
                    (profiles) =>
                        profiles.map((p) {
                          final u = p.user;
                          return AdminUserRow(
                            id: u.id.toString(),
                            firstName: u.firstName,
                            lastName: u.lastName,
                            role: u.role,
                            status: u.isActive ? 'Активен' : 'Заблокирован',
                            registeredAt: u.createdAt,
                          );
                        }).toList(),
                  ),
      columns: const [
        DataColumn(label: Text('Id')),
        DataColumn(label: Text('Имя')),
        DataColumn(label: Text('Фамилия')),
        DataColumn(label: Text('Роль')),
        DataColumn(label: Text('Статус')),
        DataColumn(label: Text('Дата регистрации')),
        DataColumn(label: Text('Подробнее')),
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
                          (_) => UserDetailPage(userId: u.id, role: u.role),
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
