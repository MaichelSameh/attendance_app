import 'package:get/get.dart';

import '../models/user_info.dart';

class UserController extends GetxController {
  UserInfo _currentUser = UserInfo.empty();

  bool _activateEmployeeMode = true;

  bool get activeEmployeeMode => _activateEmployeeMode;

  //in this function we are changing the user mode from and to manager or employee
  void reverseManagerMode() {
    _activateEmployeeMode = !_activateEmployeeMode;
    update();
  }

  UserInfo get currentUser => this._currentUser;
  void setUser(UserInfo user) {
    _currentUser = user;
    update();
  }

  UserController();
}
