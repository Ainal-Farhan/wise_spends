import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_commitment_manager.dart';
import 'package:wise_spends/manager/i_startup_manager.dart';
import 'package:wise_spends/resource/notifiers/bottom_nav_bar_notifier.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/theme/widgets/components/appbar/i_th_logged_in_appbar.dart';
import 'package:wise_spends/theme/widgets/components/drawer/i_th_logged_in_drawer.dart';
import 'package:wise_spends/theme/widgets/components/navbar/i_th_logged_in_bottom_navbar.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class ThLoggedInMainTemplateDefault extends StatefulWidget
    implements IThLoggedInMainTemplate {
  final StatefulWidget screen;
  final String pageRoute;
  final Bloc bloc;
  final BottomNavBarNotifier bottomNavBarNotifier = BottomNavBarNotifier();
  final List<FloatingActionButton> floatingActionButtons;
  final IStartupManager startupManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getStartupManager();
  final ICommitmentManager commitmentManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getCommitmentManager();
  final bool showBottomNavBar;

  ThLoggedInMainTemplateDefault({
    super.key,
    required this.screen,
    required this.pageRoute,
    required this.bloc,
    this.floatingActionButtons = const <FloatingActionButton>[],
    required this.showBottomNavBar,
  }) {
    if (!showBottomNavBar) {
      bottomNavBarNotifier.hideBottomNavBar = false;
    }
  }

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

  StreamController<int> streamController = StreamController<int>();

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

    streamController
        .addStream(widget.commitmentManager.retrieveTotalCommitmentTask());
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        key: scaffoldKey,
        drawer: IThLoggedInDrawer(user: widget.startupManager.currentUser),
        drawerScrimColor: Colors.transparent,
        backgroundColor: SingletonUtil.getSingleton<IManagerLocator>()!
            .getThemeManager()
            .colorTheme
            .complexDrawerCanvasColor,
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
                    StreamBuilder<int>(
                      stream: streamController.stream,
                      builder: (context, snapshot) => IThLoggedInAppbar(
                        drawerTween: _drawerTween,
                        onPressed: () {
                          scaffoldKey.currentState!.openDrawer();
                        },
                        colorAnimationController: _colorAnimationController,
                        colorTween: _colorTween,
                        homeTween: _homeTween,
                        iconTween: _iconTween,
                        workOutTween: _workOutTween,
                        loggedInUserName:
                            widget.startupManager.currentUser.name,
                        onPressedTaskIcon: () => Navigator.pushReplacementNamed(
                            context, AppRouter.commitmentTaskPageRoute),
                        totalTask: snapshot.data ?? 0,
                      ),
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
        bottomNavigationBar: widget.showBottomNavBar
            ? IThLoggedInBottomNavbar(
                pageRoute: widget.pageRoute,
                model: widget.bottomNavBarNotifier,
              )
            : null,
      ),
    );
  }
}
