import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AnimatedAppBar extends StatelessWidget {
  AnimationController colorAnimationController;
  Animation colorTween, homeTween, workOutTween, iconTween, drawerTween;
  Function onPressed;

  AnimatedAppBar({
    Key? key,
    required this.colorAnimationController,
    required this.onPressed,
    required this.colorTween,
    required this.homeTween,
    required this.iconTween,
    required this.drawerTween,
    required this.workOutTween,
  }) : super(key: key);

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
            onPressed: () => onPressed,
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
                'Ainal',
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
}
