import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobsy_admin/pages/sidebar.dart';

import '../util/palette.dart';
import 'admin_layout.dart';

class AbstractTablePage<T> extends StatelessWidget {
  final Future<List<T>> futureList;
  final List<DataColumn> columns;
  final DataRow Function(T) buildRow;

  const AbstractTablePage({
    super.key,
    required this.futureList,
    required this.columns,
    required this.buildRow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FutureBuilder<List<T>>(
        future: futureList,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Ошибка: ${snap.error}'));
          }
          final items = snap.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(50, 30, 50, 24),
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final availableWidth = constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: availableWidth),
                    child: DataTableTheme(
                      data: DataTableThemeData(
                        dividerThickness: 0,
                        dataRowColor: WidgetStateProperty.all(Colors.white),
                        headingRowColor: WidgetStateProperty.all(Colors.white),
                      ),
                      child: DataTable(
                        decoration: BoxDecoration(color: Palette.white),
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        dataRowHeight: 56,
                        columns: columns,
                        rows: items.map(buildRow).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}