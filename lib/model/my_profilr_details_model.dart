// To parse this JSON data, do
//
//     final myProfileDetails = myProfileDetailsFromJson(jsonString);

import 'dart:convert';

class MyProfileDetails {
  MyProfileDetails({
    this.details,
  });

  List<MyProfile>? details;

  MyProfileDetails copyWith({
    List<MyProfile>? feed,
  }) =>
      MyProfileDetails(
        details: feed ?? this.details,
      );

  factory MyProfileDetails.fromRawJson(String str) =>
      MyProfileDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyProfileDetails.fromJson(Map<String, dynamic> json) =>
      MyProfileDetails(
        details: json["feed"] == null
            ? null
            : List<MyProfile>.from(
                json["feed"].map((x) => MyProfile.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "feed": details == null
            ? null
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class MyProfile {
  String? firstname;
  String? lastname;
  String? cover;
  String? email;
  String? img;
  String? blockStatus;
  String? badge;
  String? badgeExpiry;

  MyProfile({
    this.firstname,
    this.lastname,
    this.cover,
    this.email,
    this.img,
    this.blockStatus,
    this.badge,
    this.badgeExpiry,
  });
  MyProfile.fromJson(Map<String, dynamic> json) {
    firstname = json['firstname']?.toString();
    lastname = json['lastname']?.toString();
    cover = json['cover']?.toString();
    email = json['email']?.toString();
    img = json['img']?.toString();
    blockStatus = json['block_status']?.toString();
    badge = json['badge']?.toString();
    badgeExpiry = json['badge_expiry']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['cover'] = cover;
    data['email'] = email;
    data['img'] = img;
    data['block_status'] = blockStatus;
    data['badge'] = badge;
    data['badge_expiry'] = badgeExpiry;
    return data;
  }
}
