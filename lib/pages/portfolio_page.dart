import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import 'package:jobsy_admin/pages/portfolio_detail_page.dart';
import '../model/portfolio_admin_list_item.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../service/api_client.dart';
import '../util/palette.dart';
import '../util/routes.dart';
import 'abstract_table_page.dart';

class PortfoliosPage extends StatelessWidget {
  const PortfoliosPage({Key? key}) : super(key: key);

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

    return AbstractTablePage<PortfolioAdminListItem>(
      currentSection: AdminSection.portfolio,
      futureListBuilder: (search) async {
        if (!auth.isLoggedIn) return [];
        final response = await adminService.searchPortfolios(
          term: search,
          freelancerName: search,
        );
        return response.content;
      },
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
            'Название',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontFamily: 'Inter',
              fontSize: 16,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Фрилансер',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontFamily: 'Inter',
              fontSize: 16,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Дата создания',
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
      buildRow: (p) {
        final date =
            '${p.createdAt.day.toString().padLeft(2, '0')}.'
            '${p.createdAt.month.toString().padLeft(2, '0')}.'
            '${p.createdAt.year}';

        return DataRow(
          cells: [
            DataCell(Text(p.id.toString())),
            DataCell(Text(p.title)),
            DataCell(Text('${p.firstName} ${p.lastName}')),
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
                      builder: (_) => PortfolioDetailPage(portfolioId: p.id),
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
