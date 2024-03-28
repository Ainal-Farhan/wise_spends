import 'package:wise_spends/bloc/home_logged_in/event/home_logged_in_event.dart';
import 'package:wise_spends/bloc/home_logged_in/event/impl/un_home_logged_in_event.dart';

class HomeLoggedInEventFactory {
  HomeLoggedInEventFactory._privateConstructor();

  static final HomeLoggedInEventFactory _homeLoggedInEventFactory =
      HomeLoggedInEventFactory._privateConstructor();

  factory HomeLoggedInEventFactory() {
    return _homeLoggedInEventFactory;
  }

  HomeLoggedInEvent getHomeLoggedInEvent(final String eventName) {
    switch (eventName) {
      default:
        return UnHomeLoggedInEvent();
    }
  }
}
