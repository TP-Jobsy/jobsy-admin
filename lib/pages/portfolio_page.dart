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
import 'admin_layout.dart';

class PortfoliosPage extends StatefulWidget {
  const PortfoliosPage({super.key});

  @override
  State<PortfoliosPage> createState() => _PortfoliosPageState();
}

class _PortfoliosPageState extends State<PortfoliosPage> {
  List<PortfolioAdminListItem> _portfolios = [];
  String? _searchTerm;
  bool _loading = true;
  late final AdminService adminService;

  DateTime? _filterFrom, _filterTo;

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
    _loadPortfolios();
  }

  Future<_DateFilterResult?> _showDateFilterDialog() {
    DateTime? from = _filterFrom;
    DateTime? to = _filterTo;

    return showDialog<_DateFilterResult>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Фильтр по дате создания'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'С (yyyy-MM-dd)',
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
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(
                      ctx,
                    ).pop(const _DateFilterResult(null, null)),
                child: const Text('Сбросить'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(ctx).pop(_DateFilterResult(from, to)),
                child: const Text('Применить'),
              ),
            ],
          ),
    );
  }

  void _onFilterTap() async {
    final res = await _showDateFilterDialog();
    if (res != null) {
      _filterFrom = res.from;
      _filterTo = res.to;
      _loadPortfolios();
    }
  }

  void _loadPortfolios() async {
    setState(() => _loading = true);
    final resp = await adminService.searchPortfolios(
      term: _searchTerm,
      createdFrom: _filterFrom,
      createdTo: _filterTo,
    );
    setState(() {
      _portfolios = resp.content;
      _loading = false;
    });
  }

  void _onSearch(String query) {
    _searchTerm = query.trim().isEmpty ? null : query;
    _loadPortfolios();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentSection: AdminSection.portfolio,
      onSearch: _onSearch,
      onFilter: _onFilterTap,
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : AbstractTablePage<PortfolioAdminListItem>(
                futureList: Future.value(_portfolios),
                columns: const [
                  DataColumn(label: Text('Id', style: _headerStyle)),
                  DataColumn(label: Text('Название', style: _headerStyle)),
                  DataColumn(label: Text('Фрилансер', style: _headerStyle)),
                  DataColumn(label: Text('Дата создания', style: _headerStyle)),
                  DataColumn(label: Text('Подробнее', style: _headerStyle)),
                ],
                buildRow: (p) {
                  final date =
                      '${p.createdAt.day.toString().padLeft(2, '0')}.${p.createdAt.month.toString().padLeft(2, '0')}.${p.createdAt.year}';
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
                                builder:
                                    (_) =>
                                        PortfolioDetailPage(portfolioId: p.id),
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

class _DateFilterResult {
  final DateTime? from, to;
  const _DateFilterResult(this.from, this.to);
}
