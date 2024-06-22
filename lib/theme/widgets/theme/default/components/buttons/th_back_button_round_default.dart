import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';

class ThBackButtonRoundDefault extends StatelessWidget
    implements IThBackButtonRound {
  final Function() onTap;

  const ThBackButtonRoundDefault({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        gradient: const LinearGradient(
          colors: [Colors.redAccent, Color.fromARGB(255, 209, 124, 118)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(400.0),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            Icons.arrow_back,
            size: 30.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
