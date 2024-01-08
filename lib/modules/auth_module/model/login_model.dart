// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  LoginModel({
    this.status,
    this.id,
    this.email,
    this.pass,
    this.church,
    this.userType,
    this.fname,
    this.lname,
    this.img,
  });

  String? status;
  String? id;
  String? email;
  String? pass;
  String? church;
  String? userType;
  String? fname;
  String? lname;
  String? img;

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        status: json["status"],
        id: json["id"],
        email: json["email"],
        pass: json["pass"],
        church: json["church"],
        userType: json["user_type"],
        fname: json["fname"],
        lname: json["lname"],
        img: json["img"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "id": id,
        "email": email,
        "pass": pass,
        "church": church,
        "user_type": userType,
        "fname": fname,
        "lname": lname,
        "img": img,
      };
}
