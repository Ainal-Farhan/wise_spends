import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/notifiers/bottom_nav_bar_notifier.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as router;

class LoggedInBottomNavigationBar extends StatefulWidget {
  static const Map<String, int> indexBasedOnPageRoute = {
    router.homeLoggedInPageRoute: 0,
    router.savingsPageRoute: 1,
    router.transactionPageRoute: 2,
  };

  final String pageRoute;
  final BottomNavBarNotifier model;

  const LoggedInBottomNavigationBar({
    Key? key,
    required this.pageRoute,
    required this.model,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoggedInBottomNavigationBarState();
}

class _LoggedInBottomNavigationBarState
    extends State<LoggedInBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  @override
  void didUpdateWidget(covariant LoggedInBottomNavigationBar oldWidget) {
    if (widget.model.hideBottomNavBar != isHidden) {
      if (!isHidden) {
        _showBottomNavBar();
      } else {
        _hideBottomNavBar();
      }
      isHidden = !isHidden;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _hideBottomNavBar() {
    _controller.reverse();
    return;
  }

  void _showBottomNavBar() {
    _controller.forward();
    return;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(microseconds: 500),
      vsync: this,
    )..addListener(() => setState(() {}));
    animation = Tween(begin: 0.0, end: 100.0).animate(_controller);
  }

  late AnimationController _controller;
  late Animation<double> animation;
  bool isHidden = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(0, animation.value),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(2, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.savings),
                    label: 'Savings',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money),
                    label: 'Transaction',
                  ),
                ],
                currentIndex: LoggedInBottomNavigationBar
                        .indexBasedOnPageRoute[widget.pageRoute] ??
                    0,
                onTap: (int index) {
                  int selectedIndex = LoggedInBottomNavigationBar
                          .indexBasedOnPageRoute[widget.pageRoute] ??
                      0;
                  if (index != selectedIndex) {
                    Navigator.pushReplacementNamed(
                      context,
                      LoggedInBottomNavigationBar.indexBasedOnPageRoute.keys
                          .elementAt(index),
                    );
                  }
                },
              ),
            ),
          );
        });
  }
}
