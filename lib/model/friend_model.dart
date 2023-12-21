// To parse this JSON data, do
//
//     final myFriends = myFriendsFromJson(jsonString);

import 'dart:convert';

class MyFriends {
  MyFriends({
    this.friends,
  });

  List<Friend>? friends;

  MyFriends copyWith({
    List<Friend>? feed,
  }) =>
      MyFriends(
        friends: feed ?? friends,
      );

  factory MyFriends.fromRawJson(String str) =>
      MyFriends.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyFriends.fromJson(Map<String, dynamic> json) => MyFriends(
        friends: json["feed"] == null
            ? null
            : List<Friend>.from(json["feed"].map((x) => Friend.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "feed": friends == null
            ? null
            : List<dynamic>.from(friends!.map((x) => x.toJson())),
      };
}

class Friend {
  Friend({
    this.name,
    this.ownerId,
    this.profilePic,
    this.address,
  });

  String? name;
  String? ownerId;
  String? profilePic;
  String? address;

  Friend copyWith({
    String? name,
    String? ownerId,
    String? profilePic,
    String? address,
  }) =>
      Friend(
        name: name ?? this.name,
        ownerId: ownerId ?? this.ownerId,
        profilePic: profilePic ?? this.profilePic,
        address: address ?? this.address,
      );

  factory Friend.fromRawJson(String str) => Friend.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        name: json["name"] == null ? null : json["name"],
        ownerId: json["owner_id"] == null ? null : json["owner_id"],
        profilePic: json["profilePic"] == null ? null : json["profilePic"],
        address: json["address"] == null ? null : json["address"],
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "owner_id": ownerId == null ? null : ownerId,
        "profilePic": profilePic == null ? null : profilePic,
        "address": address == null ? null : address,
      };
}
