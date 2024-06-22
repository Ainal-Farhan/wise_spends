import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/home_logged_in/event/impl/load_home_logged_in_event.dart';
import 'package:wise_spends/bloc/home_logged_in/index.dart';
import 'package:wise_spends/bloc/home_logged_in/state/home_logged_in_state.dart';

class HomeLoggedInScreen extends StatefulWidget {
  const HomeLoggedInScreen({
    required HomeLoggedInBloc homeLoggedInBloc,
    super.key,
  })  : _homeLoggedInBloc = homeLoggedInBloc;

  final HomeLoggedInBloc _homeLoggedInBloc;

  @override
  HomeLoggedInScreenState createState() {
    return HomeLoggedInScreenState();
  }
}

class HomeLoggedInScreenState extends State<HomeLoggedInScreen> {
  HomeLoggedInScreenState();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeLoggedInBloc, HomeLoggedInState>(
        bloc: widget._homeLoggedInBloc,
        builder: (
          BuildContext context,
          HomeLoggedInState currentState,
        ) =>
            currentState.build(context, _load));
  }

  void _load([bool isError = false]) {
    widget._homeLoggedInBloc.add(LoadHomeLoggedInEvent(isError));
  }
}
