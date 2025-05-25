import 'package:flutter/material.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import 'package:provider/provider.dart';
import '../model/client/client_profile.dart';
import '../model/free/freelancer_profile.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../service/api_client.dart';
import '../util/palette.dart';
import '../util/routes.dart';
import 'admin_layout.dart';
import 'client_detail_content.dart';
import 'freelancer_detail_content.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  final String role;

  const UserDetailPage({
    Key? key,
    required this.userId,
    required this.role,
  }) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late final AdminService _adminService;
  ClientProfile? _clientProfile;
  FreelancerProfile? _freelancerProfile;
  bool _loading = true;

  bool get isClient => widget.role == 'CLIENT';

  @override
  void initState() {
    super.initState();

    final auth = context.read<AdminAuthProvider>();

    _adminService = AdminService(
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

    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      if (isClient) {
        final client = await _adminService.getClientById(int.parse(widget.userId));
        setState(() => _clientProfile = client);
      } else {
        final freelancer = await _adminService.getFreelancerById(int.parse(widget.userId));
        setState(() => _freelancerProfile = freelancer);
      }
    } catch (e) {
      // TODO: добавить ErrorSnackbar
      debugPrint('Ошибка при загрузке профиля: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      body: AdminLayout(
        currentSection: AdminSection.users,
        child: Container(
          color: Palette.white,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      color: Colors.white,
      child: isClient && _clientProfile != null
          ? ClientDetailContent(client: _clientProfile!)
          : !isClient && _freelancerProfile != null
          ? FreelancerDetailContent(freelancer: _freelancerProfile!)
          : const Center(child: Text('Профиль не найден')),
    );
  }
}