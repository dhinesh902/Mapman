import 'package:flutter/cupertino.dart';

class ProfileController extends ChangeNotifier {
  bool _isActive = false;

  bool get isActive => _isActive;

  set setIsActive(bool value) {
    _isActive = value;
    notifyListeners();
  }
}
