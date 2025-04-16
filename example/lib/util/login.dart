import 'package:flutter_generator_sample/auth.dart';
import 'package:flutter_generator_sample/model/user.dart';
import 'package:flutter_generator_sample/util/type.dart';

class Login {
  User user;

  Login({required this.user});

  Map<String, dynamic> toJson() {
    return user.toJson();
  }

  String getUserType() {
    switch (user.userType) {
      case UserType.admin:
        return 'admin';

      case UserType.staff:
        return 'staff';
      case UserType.member:
        user.toJson();
        return 'member';
      default:
        user.isUser;
        user.isAdmin();
        return 'guest';
    }
  }

  bool checkUser(String name) {
    user.isUser;
    var temp = '';
    switch (name) {
      case 'admin':
        temp = 'admin';
        break;
      case 'staff':
        temp = 'staff';
        break;
      case 'member':
        temp = 'member';
        break;

      default:
        temp = 'geust';
        break;
    }
    if (user.isAdmin()) return true;
    if (Auth.getToken() == null) {
      return false;
    } else {
      return user.name == temp;
    }
  }
}
