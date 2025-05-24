import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/portfolio_admin_list_item.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../util/palette.dart';
import 'sidebar.dart';
import 'portfolio_detail_page.dart';

class PortfoliosPage extends StatefulWidget {
  const PortfoliosPage({Key? key}) : super(key: key);

  @override
  _PortfoliosPageState createState() => _PortfoliosPageState();
}

class _PortfoliosPageState extends State<PortfoliosPage> {
  final _scrollController = ScrollController();
  final List<PortfolioAdminListItem> _items = [];
  bool _isLoading = false;
  int _currentPage = 0;
  int _totalPages = 1;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadNextPage();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _currentPage < _totalPages - 1) {
        _loadNextPage();
      }
    });
  }

  Future<void> _loadNextPage() async {
    setState(() => _isLoading = true);
    final token = context.read<AdminAuthProvider>().token!;
    final resp = await AdminService().fetchPortfoliosPage(
      token,
      _currentPage,
      _pageSize,
    );
    setState(() {
      _items.addAll(resp.content);
      _currentPage = resp.number + 1;
      _totalPages = resp.totalPages;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildRow(PortfolioAdminListItem p) {
    final d = p.createdAt;
    final date =
        '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year}';
    return ListTile(
      title: Text(p.title),
      subtitle: Text('${p.firstName} ${p.lastName}'),
      trailing: Text(date, style: const TextStyle(fontSize: 12)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PortfolioDetailPage(portfolioId: p.id),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text('Портфолио'),
        backgroundColor: Palette.primary,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + (_isLoading ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i < _items.length) {
            return _buildRow(_items[i]);
          } else {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}