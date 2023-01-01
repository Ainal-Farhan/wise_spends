import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/components/buttons/i_th_back_button.dart';

class ThBackButtonDefault extends StatelessWidget implements IThBackButton {
  const ThBackButtonDefault({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back));
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
