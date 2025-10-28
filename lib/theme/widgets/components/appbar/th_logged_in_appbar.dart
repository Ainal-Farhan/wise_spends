import 'package:flutter/material.dart';

class ThLoggedInAppbar extends StatelessWidget {
  final String loggedInUserName;
  final AnimationController colorAnimationController;
  final Animation colorTween, homeTween, workOutTween, iconTween, drawerTween;
  final VoidCallback onPressed;
  final VoidCallback onPressedTaskIcon;
  final int totalTask;

  const ThLoggedInAppbar({
    super.key,
    required this.loggedInUserName,
    required this.colorAnimationController,
    required this.onPressed,
    required this.colorTween,
    required this.homeTween,
    required this.iconTween,
    required this.drawerTween,
    required this.workOutTween,
    required this.onPressedTaskIcon,
    required this.totalTask,
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
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          titleSpacing: 0.0,
          title: Row(
            children: <Widget>[
              Text(
                "Hello  ",
                style: TextStyle(
                  color: homeTween.value,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                loggedInUserName,
                style: TextStyle(
                  color: workOutTween.value,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Stack(
                children: <Widget>[
                  Icon(
                    Icons.task_alt_rounded,
                    color: iconTween.value,
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$totalTask',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              onPressed: onPressedTaskIcon,
            ),
            const Padding(
              padding: EdgeInsets.all(8),
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