import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/notifiers/bottom_nav_bar_notifier.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/i_theme_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/appbar/i_th_logged_in_appbar.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/drawer/i_th_logged_in_drawer.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/navbar/i_th_logged_in_bottom_navbar.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class ThLoggedInMainTemplateDefault extends StatefulWidget
    implements IThLoggedInMainTemplate {
  final StatefulWidget screen;
  final String pageRoute;
  final Bloc bloc;
  final BottomNavBarNotifier bottomNavBarNotifier = BottomNavBarNotifier();
  final List<FloatingActionButton> floatingActionButtons;
  final IStartupManager startupManager = IStartupManager();

  ThLoggedInMainTemplateDefault({
    Key? key,
    required this.screen,
    required this.pageRoute,
    required this.bloc,
    this.floatingActionButtons = const <FloatingActionButton>[],
  }) : super(key: key);

  @override
  State<ThLoggedInMainTemplateDefault> createState() =>
      _ThLoggedInMainTemplateDefaultState();

  @override
  List<Object?> get props => [
        screen,
        pageRoute,
        bloc,
        floatingActionButtons,
      ];

  @override
  bool? get stringify => null;
}

class _ThLoggedInMainTemplateDefaultState
    extends State<ThLoggedInMainTemplateDefault> with TickerProviderStateMixin {
  late AnimationController _colorAnimationController;

  late AnimationController _textAnimationController;
  late Animation _colorTween,
      _homeTween,
      _workOutTween,
      _iconTween,
      _drawerTween;

  @override
  void initState() {
    _colorAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 0));
    _colorTween = ColorTween(begin: Colors.transparent, end: Colors.white)
        .animate(_colorAnimationController);
    _iconTween =
        ColorTween(begin: Colors.white, end: Colors.lightBlue.withOpacity(0.5))
            .animate(_colorAnimationController);
    _drawerTween = ColorTween(begin: Colors.white, end: Colors.black)
        .animate(_colorAnimationController);
    _homeTween = ColorTween(begin: Colors.white, end: Colors.blue)
        .animate(_colorAnimationController);
    _workOutTween = ColorTween(begin: Colors.white, end: Colors.black)
        .animate(_colorAnimationController);
    _textAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 0));

    super.initState();

    _addScrollListener();
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool scrollListener(ScrollNotification scrollInfo) {
    bool scroll = false;
    if (scrollInfo.metrics.axis == Axis.vertical) {
      _colorAnimationController.animateTo(scrollInfo.metrics.pixels / 80);

      _textAnimationController.animateTo(scrollInfo.metrics.pixels);
      return scroll = true;
    }
    return scroll;
  }

  final _scrollController = ScrollController();

  void _addScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (widget.bottomNavBarNotifier.hideBottomNavBar) {
          widget.bottomNavBarNotifier.hideBottomNavBar = false;
        }
      } else {
        if (!widget.bottomNavBarNotifier.hideBottomNavBar) {
          widget.bottomNavBarNotifier.hideBottomNavBar = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: scaffoldKey,
        drawer: IThLoggedInDrawer(),
        drawerScrimColor: Colors.transparent,
        backgroundColor: IThemeManager().colorTheme.complexDrawerCanvasColor,
        body: NotificationListener<ScrollNotification>(
          onNotification: scrollListener,
          child: Stack(
            children: [
              SizedBox(
                height: double.infinity,
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: screenHeight * 0.05,
                                child: Container(),
                              ),
                              widget.screen,
                            ],
                          ),
                        ],
                      ),
                    ),
                    IThLoggedInAppbar(
                      drawerTween: _drawerTween,
                      onPressed: () {
                        scaffoldKey.currentState!.openDrawer();
                      },
                      colorAnimationController: _colorAnimationController,
                      colorTween: _colorTween,
                      homeTween: _homeTween,
                      iconTween: _iconTween,
                      workOutTween: _workOutTween,
                      loggedInUserName: widget.startupManager.currentUser.name,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Wrap(
          direction: Axis.horizontal,
          children: widget.floatingActionButtons,
        ),
        bottomNavigationBar: IThLoggedInBottomNavbar(
          pageRoute: widget.pageRoute,
          model: widget.bottomNavBarNotifier,
        ),
      ),
    );
  }
}
