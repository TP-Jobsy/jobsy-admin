import 'package:flutter/material.dart';
import '../util/palette.dart';

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
      color: Palette.white,
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

          return Theme(
            data: Theme.of(context).copyWith(
              dividerTheme: DividerThemeData(
                color: Palette.grey3.withOpacity(0.4),
                space: 1,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(50, 30, 50, 24),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        dividerThickness: 1,
                        dataRowHeight: 56,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: columns,
                        rows: items.map(buildRow).toList(),
                        decoration: BoxDecoration(
                          color: Palette.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}