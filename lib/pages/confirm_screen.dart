import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../util/palette.dart';
import '../util/routes.dart';

class ConfirmScreen extends StatefulWidget {
  final String email;
  const ConfirmScreen({super.key, required this.email});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final List<TextEditingController> _codeCtrls =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _loading = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) {
      _codeCtrls[i].addListener(() {
        if (_codeCtrls[i].text.length == 1 && i < 3) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var c in _codeCtrls) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  Widget _buildDigitField(int index) {
    return SizedBox(
      width: 75,
      height: 75,
      child: TextField(
        controller: _codeCtrls[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Palette.grey3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Palette.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    final code = _codeCtrls.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите полный 4-значный код')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<AdminAuthProvider>().confirmCode(widget.email, code);
      Navigator.of(context).pushReplacementNamed(Routes.users);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка подтверждения: ${e.toString()}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _resending = true);
    try {
      final resp =
      await context.read<AdminAuthProvider>().requestCode(widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.message)),
      );
      for (var c in _codeCtrls) c.clear();
      _focusNodes[0].requestFocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось выслать код: ${e.toString()}')),
      );
    } finally {
      setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final maxWidth =
          constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/logo.svg',
                            height: 130,
                            width: 234,
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Введите код подтверждения',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'На ваш адрес ${widget.email} отправлен 4-значный код',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, color: Palette.grey1),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                            List.generate(4, (i) => Padding(
                              padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
                              child: _buildDigitField(i),
                            )),
                          ),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: _resending ? null : _resendCode,
                            child: _resending
                                ? const CircularProgressIndicator()
                                : const Text(
                              'Отправить ещё раз код',
                              style: TextStyle(
                                  color: Palette.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _confirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Palette.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: _loading
                                  ? const CircularProgressIndicator(
                                  color: Palette.white)
                                  : const Text(
                                'Далее',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Palette.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}