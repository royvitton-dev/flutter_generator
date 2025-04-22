import 'package:flutter_generator_sample/util/type.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? password;
  String? imageUrl;
  String? token;
  bool isUser = false;
  UserType userType = UserType.member;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.imageUrl,
    this.token,
    this.isUser = false,
    required this.userType,
  });

  bool isAdmin() {
    return !isUser;
  }

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    password = json['password'];
    imageUrl = json['imageUrl'];
    token = json['token'];
    isUser = json['isUser'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'imageUrl': imageUrl,
      'token': token,
      'isUser': isUser,
    };
  }
}
