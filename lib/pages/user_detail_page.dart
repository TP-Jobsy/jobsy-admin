import 'package:flutter/material.dart';
import 'package:jobsy_admin/pages/sidebar.dart';
import 'package:provider/provider.dart';
import '../model/client/client_profile.dart';
import '../model/free/freelancer_profile.dart';
import '../provider/auth_provider.dart';
import '../service/admin_service.dart';
import '../util/palette.dart';
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
    final token = context.read<AdminAuthProvider>().token!;
    _adminService = AdminService();

    if (isClient) {
      _adminService
          .getClientById(token, int.parse(widget.userId))
          .then((p) => setState(() => _clientProfile = p))
          .catchError((e) {
        // TODO: показать ErrorSnackbar
      })
          .whenComplete(() => setState(() => _loading = false));
    } else {
      _adminService
          .getFreelancerById(token, int.parse(widget.userId))
          .then((p) => setState(() => _freelancerProfile = p))
          .catchError((e) {
        // TODO: показать ErrorSnackbar
      })
          .whenComplete(() => setState(() => _loading = false));
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