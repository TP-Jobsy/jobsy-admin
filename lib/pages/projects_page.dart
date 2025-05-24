import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobsy_admin/pages/project_detail_page.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import '../model/project_admin_list_item.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import 'abstract_table_page.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final token = context.watch<AdminAuthProvider>().token;
    final adminService = AdminService();

    return AbstractTablePage<ProjectAdminListItem>(
      currentSection: AdminSection.projects,
      futureList: token == null
          ? Future.value(<ProjectAdminListItem>[])
          : adminService.fetchProjectsPage(token, 0, 100).then((resp) => resp.content),
      columns: const [
        DataColumn(label: Text('Id')),
        DataColumn(label: Text('Название')),
        DataColumn(label: Text('Клиент')),
        DataColumn(label: Text('Статус')),
        DataColumn(label: Text('Дата создания')),
        DataColumn(label: Text('Подробнее')),
      ],
      buildRow: (p) {
        final date = '${p.createdAt.day.toString().padLeft(2, '0')}.'
            '${p.createdAt.month.toString().padLeft(2, '0')}.'
            '${p.createdAt.year}';
        return DataRow(cells: [
          DataCell(Text(p.id.toString())),
          DataCell(Text(p.title)),
          DataCell(Text('${p.client.firstName} ${p.client.lastName}')),
          DataCell(Text(p.status)),
          DataCell(Text(date)),
          DataCell(IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () async {
              final fullProject = await adminService.getProjectById(token!, p.id);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProjectDetailPage(project: fullProject),
                ),
              );
            },
          )),
        ]);
      },
    );
  }
}