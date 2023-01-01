import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/i_th_back_button.dart';

class ThBackButtonDefault extends StatelessWidget implements IThBackButton {
  const ThBackButtonDefault({Key? key}) : super(key: key);

  @override
  Future<Widget> build(BuildContext context) async {
    return IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back));
  }
}
