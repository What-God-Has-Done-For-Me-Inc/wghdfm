// To parse this JSON data, do
//
//     final userWhoLiked = userWhoLikedFromJson(jsonString);

import 'dart:convert';

class UserWhoLiked {
  UserWhoLiked({
    this.firstname,
    this.lastname,
    this.userType,
    this.img,
    this.church,
    this.userId,
  });

  String? firstname;
  String? lastname;
  dynamic userType;
  String? img;
  String? church;
  String? userId;

  UserWhoLiked copyWith({
    String? firstname,
    String? lastname,
    dynamic userType,
    String? img,
    String? church,
    String? userId,
  }) =>
      UserWhoLiked(
        firstname: firstname ?? this.firstname,
        lastname: lastname ?? this.lastname,
        userType: userType ?? this.userType,
        img: img ?? this.img,
        church: church ?? this.church,
        userId: userId ?? this.userId,
      );

  factory UserWhoLiked.fromRawJson(String str) =>
      UserWhoLiked.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserWhoLiked.fromJson(Map<String, dynamic> json) => UserWhoLiked(
        firstname: json["firstname"],
        lastname: json["lastname"],
        userType: json["user_type"],
        img: json["img"],
        church: json["church"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "firstname": firstname,
        "lastname": lastname,
        "user_type": userType,
        "img": img,
        "church": church,
        "user_id": userId,
      };
}
