import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_save_button.dart';

class ThSaveButtonDefault extends StatelessWidget implements IThSaveButton {
  final VoidCallback onTap;

  const ThSaveButtonDefault({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
