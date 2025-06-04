import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../util/palette.dart';
import '../model/error_snackbar.dart';
import '../widgets/avatar.dart';

class TopBar extends StatefulWidget {
  final void Function(String)? onSearch;
  final VoidCallback? onFilter;

  const TopBar({super.key, this.onSearch, this.onFilter});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isInputInvalid = false;
  String _currentInput = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: Palette.white,
      child: Container(
        height: 110,
        padding: const EdgeInsets.only(left: 50, right: 24),
        child: Row(
          children: [
            Tooltip(
              message: 'Фильтрация',
              child: InkWell(
                onTap: widget.onFilter,
                borderRadius: BorderRadius.circular(8),
                child: SvgPicture.asset(
                  'assets/icons/Filter.svg',
                  width: 24,
                  height: 24,
                  color: Palette.black,
                ),
              ),
            ),
            const SizedBox(width: 50),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                  MediaQuery.of(context).size.width -
                      (50 + 24 + 50 + 75 + 24),
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Palette.white,
                    borderRadius: BorderRadius.circular(24),
                    border: _isInputInvalid
                        ? Border.all(color: Colors.red, width: 1)
                        : null,
                    boxShadow: const [
                      BoxShadow(
                        color: Palette.black1,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Search.svg',
                        width: 20,
                        height: 20,
                        color: _isInputInvalid ? Colors.red : Palette.grey2,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Поиск',
                            border: InputBorder.none,
                            isDense: true,
                            errorText: _isInputInvalid ? 'Превышен лимит в 30 символов' : null,
                            errorStyle: const TextStyle(fontSize: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _currentInput = value;
                              _isInputInvalid = value.length > 30;
                            });
                          },
                          onSubmitted: (value) {
                            if (value.length <= 30) {
                              widget.onSearch?.call(value);
                            } else {
                              setState(() {
                                _isInputInvalid = true;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Avatar(size: 75, placeholderAsset: 'assets/icons/avatar.svg'),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}