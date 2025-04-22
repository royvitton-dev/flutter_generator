classDiagram
class Login {
  User user
  Login(User user)
  Map<String, dynamic> toJson()
  String getUserType()
  bool checkUser(String name)
}
