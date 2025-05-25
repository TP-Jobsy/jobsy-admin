import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../util/palette.dart';
import '../widgets/avatar.dart';

class TopBar extends StatelessWidget {
  final void Function(String)? onSearch;

  const TopBar({super.key, this.onSearch});

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
              message: 'Фильтрация пока не реализована',
              child: InkWell(
                onTap: () {
                  // TODO: позже добавлю
                },
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
                    boxShadow: const [
                      BoxShadow(
                        color: Palette.black1,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/search.svg',
                        width: 20,
                        height: 20,
                        color: Palette.grey2,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Поиск',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: onSearch,
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
