import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import 'package:jobsy_admin/pages/portfolio_detail_page.dart';
import '../model/portfolio_admin_list_item.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import 'abstract_table_page.dart';

class PortfoliosPage extends StatelessWidget {
  const PortfoliosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final token = context.watch<AdminAuthProvider>().token;
    final adminService = AdminService();

    return AbstractTablePage<PortfolioAdminListItem>(
      currentSection: AdminSection.portfolio,
      futureList: token == null
          ? Future.value(<PortfolioAdminListItem>[])
          : adminService.fetchPortfoliosPage(token, 0, 100).then((resp) => resp.content),
      columns: const [
        DataColumn(label: Text('Id', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
        DataColumn(label: Text('Название', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
        DataColumn(label: Text('Фрилансер', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
        DataColumn(label: Text('Дата создания', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
        DataColumn(label: Text('Подробнее', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Inter', fontSize: 16))),
      ],
      buildRow: (p) {
        final date = '${p.createdAt.day.toString().padLeft(2, '0')}.'
            '${p.createdAt.month.toString().padLeft(2, '0')}.'
            '${p.createdAt.year}';
        return DataRow(cells: [
          DataCell(Text(p.id.toString())),
          DataCell(Text(p.title)),
          DataCell(Text('${p.firstName} ${p.lastName}')),
          DataCell(Text(date)),
          DataCell(IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PortfolioDetailPage(portfolioId: p.id),
                ),
              );
            },
          )),
        ]);
      },
    );
  }
}