import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobsy_admin/pages/projects_page.dart';
import 'package:provider/provider.dart';

import '../../util/palette.dart';
import '../provider/auth_provider.dart';
import '../util/routes.dart';

enum AdminSection { users, projects, portfolio }

class Sidebar extends StatelessWidget {
  final AdminSection current;
  const Sidebar({super.key, this.current = AdminSection.users});

  @override
  Widget build(BuildContext context) {
    Widget navButton({
      required String label,
      required String iconAsset,
      VoidCallback? onTap,
      bool active = false,
      Color? textColor,
      Color? iconColor,
    }) {
      final fgText = active ? Palette.white : (textColor ?? Palette.black);
      final fgIcon = active ? Palette.white : (iconColor ?? Palette.black);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? Palette.primary : Palette.white,
                borderRadius: BorderRadius.circular(8),
                border: active ? null : Border.all(color: Palette.grey7),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconAsset,
                    width: 20,
                    height: 20,
                    color: fgIcon,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: fgText,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 198,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(19, 20, 19, 25),
      decoration: const BoxDecoration(
        color: Palette.white,
        boxShadow: [BoxShadow(color: Palette.black)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SvgPicture.asset('assets/logo.svg', width: 180, height: 70),
          ),
          const SizedBox(height: 32),
          navButton(
            label: 'Пользователи',
            iconAsset: 'assets/icons/user.svg',
            active: current == AdminSection.users,
            onTap: () => Navigator.pushReplacementNamed(context, Routes.users),
          ),
          const SizedBox(height: 30),
          navButton(
            label: 'Проекты',
            iconAsset: 'assets/icons/projects.svg',
            active: current == AdminSection.projects,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProjectsPage()),
              );
            },
          ),
          const SizedBox(height: 30),
          navButton(
            label: 'Портфолио',
            iconAsset: 'assets/icons/portfolio.svg',
            active: current == AdminSection.portfolio,
            onTap:
                () => Navigator.pushReplacementNamed(context, Routes.portfolio),
          ),
          const Spacer(),
          navButton(
            label: 'Выйти',
            iconAsset: 'assets/icons/logout.svg',
            textColor: Palette.red,
            iconColor: Palette.red,
            onTap: () async {
              final auth = Provider.of<AdminAuthProvider>(
                context,
                listen: false,
              );
              await auth.logout();
              Navigator.pushReplacementNamed(context, Routes.login);
            },
          ),
        ],
      ),
    );
  }
}
