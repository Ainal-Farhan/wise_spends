import 'package:flutter/cupertino.dart';

class DrawerNotifier extends ChangeNotifier {
  int _selectedIndex = -1;
  bool _isExpanded = false;

  int get selectedIndex => _selectedIndex;
  set selectedIndex(int x) {
    _selectedIndex = x;
    notifyListeners();
  }

  bool get isExpanded => _isExpanded;
  set isExpanded(bool x) {
    _isExpanded = x;
    notifyListeners();
  }
}
