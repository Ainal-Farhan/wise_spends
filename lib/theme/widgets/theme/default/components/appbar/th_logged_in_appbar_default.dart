import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/appbar/i_th_logged_in_appbar.dart';

class ThLoggedInAppbarDefault extends StatelessWidget
    implements IThLoggedInAppbar {
  final String loggedInUserName;
  final AnimationController colorAnimationController;
  final Animation colorTween, homeTween, workOutTween, iconTween, drawerTween;
  final VoidCallback onPressed;

  const ThLoggedInAppbarDefault({
    super.key,
    required this.loggedInUserName,
    required this.colorAnimationController,
    required this.onPressed,
    required this.colorTween,
    required this.homeTween,
    required this.iconTween,
    required this.drawerTween,
    required this.workOutTween,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: AnimatedBuilder(
        animation: colorAnimationController,
        builder: (context, child) => AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.dehaze,
              color: drawerTween.value,
            ),
            onPressed: onPressed,
          ),
          backgroundColor: colorTween.value,
          elevation: 0,
          titleSpacing: 0.0,
          title: Row(
            children: <Widget>[
              Text(
                "Hello  ",
                style: TextStyle(
                    color: homeTween.value,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1),
              ),
              Text(
                loggedInUserName,
                style: TextStyle(
                    color: workOutTween.value,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1),
              ),
            ],
          ),
          actions: <Widget>[
            Icon(
              Icons.notifications,
              color: iconTween.value,
            ),
            const Padding(
              padding: EdgeInsets.all(7),
              child: CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  List<Object?> get props => [
        loggedInUserName,
        colorAnimationController,
        colorTween,
        homeTween,
        workOutTween,
        iconTween,
        drawerTween,
        onPressed,
      ];

  @override
  bool? get stringify => null;
}
