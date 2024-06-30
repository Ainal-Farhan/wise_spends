import 'package:wise_spends/bloc/impl/login/login_bloc.dart';
import 'package:wise_spends/bloc/screen.dart';

class LoginScreen
    extends StatefulWidgetScreen<LoginBloc, ScreenState<LoginBloc>> {
  const LoginScreen({
    required super.bloc,
    required super.initialEvent,
    super.key,
  });

  @override
  ScreenState<LoginBloc> createState() => ScreenState();
}
