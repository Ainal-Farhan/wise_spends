import 'package:wise_spends/bloc/impl/money_storage/money_storage_bloc.dart';
import 'package:wise_spends/bloc/screen.dart';

class MoneyStorageScreen extends StatefulWidgetScreen<MoneyStorageBloc,
    ScreenState<MoneyStorageBloc>> {
  const MoneyStorageScreen({
    required super.bloc,
    required super.initialEvent,
    super.key,
  });

  @override
  ScreenState<MoneyStorageBloc> createState() => ScreenState();
}
