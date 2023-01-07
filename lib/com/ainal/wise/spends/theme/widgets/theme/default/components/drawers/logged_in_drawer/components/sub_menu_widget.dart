import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/txt.dart';

class SubMenuWidget extends StatelessWidget {
  final String title;
  final bool isTitle;

  final VoidCallback? onTap;

  const SubMenuWidget({
    required this.title,
    this.isTitle = false,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Txt(
          text: title,
          fontSize: isTitle ? 17 : 14,
          color: isTitle ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
