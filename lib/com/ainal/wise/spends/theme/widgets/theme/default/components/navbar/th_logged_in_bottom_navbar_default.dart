import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/navbar/i_th_logged_in_bottom_navbar.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/notifiers/bottom_nav_bar_notifier.dart';

class ThLoggedInBottomNavbarDefault extends StatefulWidget
    implements IThLoggedInBottomNavbar {
  final String pageRoute;
  final BottomNavBarNotifier model;

  const ThLoggedInBottomNavbarDefault({
    Key? key,
    required this.model,
    required this.pageRoute,
  }) : super(key: key);

  @override
  State<ThLoggedInBottomNavbarDefault> createState() =>
      _ThLoggedInBottomNavbarDefaultState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}

class _ThLoggedInBottomNavbarDefaultState
    extends State<ThLoggedInBottomNavbarDefault>
    with SingleTickerProviderStateMixin {
  @override
  void didUpdateWidget(covariant ThLoggedInBottomNavbarDefault oldWidget) {
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
                currentIndex: IThLoggedInBottomNavbar
                        .indexBasedOnPageRoute[widget.pageRoute] ??
                    0,
                onTap: (int index) {
                  int selectedIndex = IThLoggedInBottomNavbar
                          .indexBasedOnPageRoute[widget.pageRoute] ??
                      0;
                  if (index != selectedIndex) {
                    Navigator.pushReplacementNamed(
                      context,
                      IThLoggedInBottomNavbar.indexBasedOnPageRoute.keys
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
