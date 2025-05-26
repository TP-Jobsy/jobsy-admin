import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../util/palette.dart';
import '../provider/auth_provider.dart';
import 'confirm_screen.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите, пожалуйста, e-mail')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await context.read<AdminAuthProvider>().requestCode(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.message)),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConfirmScreen(email: email),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final maxWidth = constraints.maxWidth > 400 ? 400.0 : constraints.maxWidth;
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset('assets/logo.svg', width: 234, height: 130),
                    const SizedBox(height: 32),
                    const Text('Администратор', style: TextStyle(fontSize: 33, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: Palette.black)),
                    const SizedBox(height: 8),
                    const Text('Введите почту, чтобы войти!', style: TextStyle(fontSize: 23, fontFamily: 'Inter', color: Palette.grey1)),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 63,
                      child: TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Почта',
                          hintStyle: const TextStyle(color: Palette.grey1),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset('assets/icons/Inbox.svg', width: 23, height: 23, color: Palette.grey1),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Palette.grey3)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Palette.grey3)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _requestCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Palette.white)
                            : const Text('Далее', style: TextStyle(fontSize: 16, fontFamily: 'Inter', color: Palette.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}