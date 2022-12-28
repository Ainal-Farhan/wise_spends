import 'package:flutter/material.dart';

class LoggedInAppBar extends AppBar {
  final String screenTitle;

  LoggedInAppBar({Key? key, required this.screenTitle})
      : super(
          key: key,
          title: Text(screenTitle),
          automaticallyImplyLeading: false,
        );
}
