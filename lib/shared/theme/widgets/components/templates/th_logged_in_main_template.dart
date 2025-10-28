import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/presentation/blocs/commitment_bloc/commitment_bloc.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/domain/usecases/i_commitment_manager.dart';
import 'package:wise_spends/domain/usecases/i_startup_manager.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/shared/resources/notifiers/bottom_nav_bar_notifier.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/shared/theme/widgets/components/appbar/th_logged_in_appbar.dart';
import 'package:wise_spends/shared/theme/widgets/components/drawer/th_logged_in_drawer.dart';
import 'package:wise_spends/shared/theme/widgets/components/navbar/th_logged_in_bottom_navbar.dart';

class ThLoggedInMainTemplate extends StatefulWidget {
  final Widget screen;
  final String pageRoute;
  final Bloc? bloc;
  final BottomNavBarNotifier bottomNavBarNotifier;
  final List<FloatingActionButton> floatingActionButtons;
  final bool showBottomNavBar;
  final IStartupManager startupManager;
  final ICommitmentManager commitmentManager;
  final StreamController<int> streamController;

  ThLoggedInMainTemplate({
    super.key,
    required this.screen,
    required this.pageRoute,
    this.bloc,
    this.floatingActionButtons = const <FloatingActionButton>[],
    this.showBottomNavBar = true,
  }) : bottomNavBarNotifier = BottomNavBarNotifier(),
       startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
           .getStartupManager(),
       commitmentManager = SingletonUtil.getSingleton<IManagerLocator>()!
           .getCommitmentManager(),
       streamController = StreamController<int>.broadcast() {
    if (!showBottomNavBar) {
      bottomNavBarNotifier.hideBottomNavBar = false;
    }

    if (bloc != null) {
      if (bloc is CommitmentBloc) {
        (bloc as CommitmentBloc).updateAppBar = updateAppBar;
      }
      if (bloc is CommitmentTaskBloc) {
        (bloc as CommitmentTaskBloc).updateAppBar = updateAppBar;
      }
    }
  }

  @override
  State<ThLoggedInMainTemplate> createState() => _ThLoggedInMainTemplateState();

  void updateAppBar() {
    streamController.addStream(commitmentManager.retrieveTotalCommitmentTask());
  }
}

class _ThLoggedInMainTemplateState extends State<ThLoggedInMainTemplate>
    with TickerProviderStateMixin {
  late AnimationController _colorAnimationController;
  late AnimationController _textAnimationController;
  late Animation _colorTween,
      _homeTween,
      _workOutTween,
      _iconTween,
      _drawerTween;

  @override
  void initState() {
    _colorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 0),
    );
    _colorTween = ColorTween(
      begin: Colors.transparent,
      end: Colors.white,
    ).animate(_colorAnimationController);
    _iconTween = ColorTween(
      begin: Colors.white,
      end: Colors.lightBlue.withValues(alpha: 0.5),
    ).animate(_colorAnimationController);
    _drawerTween = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(_colorAnimationController);
    _homeTween = ColorTween(
      begin: Colors.white,
      end: Colors.blue,
    ).animate(_colorAnimationController);
    _workOutTween = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(_colorAnimationController);
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 0),
    );

    super.initState();

    _addScrollListener();

    widget.updateAppBar();
  }

  @override
  void dispose() {
    widget.streamController.close();
    _colorAnimationController.dispose();
    _textAnimationController.dispose();
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
        drawer: ThLoggedInDrawer(pageRoute: widget.pageRoute),
        drawerScrimColor: Colors.transparent,
        backgroundColor: SingletonUtil.getSingleton<IManagerLocator>()!
            .getThemeManager()
            .colorTheme
            .complexDrawerCanvasColor,
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: scrollListener,
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.1),
                child: widget.screen,
              ),
            ),
            StreamBuilder<int>(
              stream: widget.streamController.stream,
              builder: (context, snapshot) => ThLoggedInAppbar(
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
                onPressedTaskIcon: () => Navigator.pushReplacementNamed(
                  context,
                  AppRouter.commitmentTaskPageRoute,
                ),
                totalTask: snapshot.data ?? 0,
              ),
            ),

            // Floating buttons as a vertical stack in bottom-right corner
            // Positioned above bottom navigation bar if it exists
            if (widget.floatingActionButtons.isNotEmpty)
              Positioned(
                bottom: widget.showBottomNavBar
                    ? 80.0
                    : 16.0, // 80px accounts for bottom nav bar height + padding
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: widget.floatingActionButtons.map((button) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: button,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
        bottomNavigationBar: widget.showBottomNavBar
            ? ThLoggedInBottomNavbar(
                pageRoute: widget.pageRoute,
                model: widget.bottomNavBarNotifier,
              )
            : null,
      ),
    );
  }
}
