import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class AdminLayout extends StatelessWidget {
  final AdminSection currentSection;
  final Widget child;
  final void Function(String)? onSearch;
  final VoidCallback? onFilter;

  const AdminLayout({
    super.key,
    required this.currentSection,
    required this.child,
    this.onSearch,
    this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(current: currentSection),
          Expanded(
            child: Column(
              children: [
                const Divider(height:0, thickness:0),
                TopBar(
                    onSearch: onSearch,
                    onFilter: onFilter,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}