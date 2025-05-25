import 'package:flutter/material.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import '../util/palette.dart';
import 'admin_layout.dart';

class AbstractTablePage<T> extends StatefulWidget {
  final AdminSection currentSection;
  final Future<List<T>> Function(String? searchTerm) futureListBuilder;
  final List<DataColumn> columns;
  final DataRow Function(T) buildRow;

  const AbstractTablePage({
    super.key,
    required this.currentSection,
    required this.futureListBuilder,
    required this.columns,
    required this.buildRow,
  });

  @override
  State<AbstractTablePage<T>> createState() => _AbstractTablePageState<T>();
}

class _AbstractTablePageState<T> extends State<AbstractTablePage<T>> {
  late Future<List<T>> _futureList;
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureList = widget.futureListBuilder(_searchTerm);
    });
  }

  void _onSearchChanged(String value) {
    _searchTerm = value.trim().isEmpty ? null : value;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentSection: widget.currentSection,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 24, 50, 12),
            child: TextField(
              onSubmitted: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<T>>(
              future: _futureList,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Ошибка: ${snap.error}'));
                }
                final items = snap.data ?? [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(50, 10, 50, 24),
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 900),
                    child: DataTableTheme(
                      data: DataTableThemeData(
                        dividerThickness: 0,
                        dataRowColor: WidgetStateProperty.all(Colors.white),
                        headingRowColor: WidgetStateProperty.all(Colors.white),
                      ),
                      child: DataTable(
                        decoration: const BoxDecoration(color: Palette.white),
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        dataRowHeight: 56,
                        columns: widget.columns,
                        rows: items.map(widget.buildRow).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
