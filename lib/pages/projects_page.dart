import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:jobsy_admin/pages/project_detail_page.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import '../model/project_admin_list_item.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../service/api_client.dart';
import '../util/palette.dart';
import '../util/routes.dart';
import 'abstract_table_page.dart';
import 'admin_layout.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<ProjectAdminListItem> _projects = [];
  String? _searchTerm;
  bool _loading = true;
  late final AdminService adminService;

  String? _filterStatus;
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
    _loadProjects();
  }

  Future<_FilterResult?> _showProjectFilter() {
    String? status = _filterStatus;
    DateTime? from = _filterFrom;
    DateTime? to = _filterTo;

    return showDialog<_FilterResult>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Фильтры проектов'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(labelText: 'Статус'),
                    items:
                        ['OPEN', 'IN_PROGRESS', 'COMPLETED', 'DRAFT']
                            .map(
                              (s) => DropdownMenuItem(child: Text(s), value: s),
                            )
                            .toList(),
                    onChanged: (v) => status = v,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'С (yyyy-MM-dd)'),
                    initialValue: from?.toIso8601String().substring(0, 10),
                    onChanged:
                        (v) => from = v.isEmpty ? null : DateTime.tryParse(v),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'По (yyyy-MM-dd)'),
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
                  Navigator.of(ctx).pop(_FilterResult(null, null, null));
                },
                child: Text('Сбросить'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(_FilterResult(status, from, to));
                },
                child: Text('Применить'),
              ),
            ],
          ),
    );
  }

  void _onFilterTap() async {
    final res = await _showProjectFilter();
    if (res != null) {
      _filterStatus = res.status;
      _filterFrom = res.from;
      _filterTo = res.to;
      _loadProjects();
    }
  }

  void _loadProjects() async {
    setState(() => _loading = true);
    final response = await adminService.searchProjects(
      term: _searchTerm,
      status: _filterStatus,
      createdFrom: _filterFrom,
      createdTo: _filterTo,
    );
    setState(() {
      _projects = response.content;
      _loading = false;
    });
  }

  void _onSearch(String query) {
    _searchTerm = query.trim().isEmpty ? null : query;
    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentSection: AdminSection.projects,
      onFilter: _onFilterTap,
      onSearch: _onSearch,
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : AbstractTablePage<ProjectAdminListItem>(
                futureList: Future.value(_projects),
                columns: const [
                  DataColumn(label: Text('Id', style: _headerStyle)),
                  DataColumn(label: Text('Название', style: _headerStyle)),
                  DataColumn(label: Text('Клиент', style: _headerStyle)),
                  DataColumn(label: Text('Статус', style: _headerStyle)),
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
                      DataCell(
                        Text('${p.clientFirstName} ${p.clientLastName}'),
                      ),
                      DataCell(Text(p.status)),
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
                                    (_) => ProjectDetailPage(projectId: p.id),
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

class _FilterResult {
  final String? status;
  final DateTime? from, to;

  _FilterResult(this.status, this.from, this.to);
}
