import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/errors/i_th_error_widget.dart';

class ThErrorWidgetDefault extends StatelessWidget implements IThErrorWidget {
  final String errorMessage;
  final VoidCallback onPressed;
  static VoidCallback _defaultOnPressed() => () {};

  const ThErrorWidgetDefault({
    super.key,
    required this.errorMessage,
    VoidCallback? onPressed,
  })  : onPressed = onPressed ?? _defaultOnPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(errorMessage),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: onPressed,
              child: const Text('reload'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
