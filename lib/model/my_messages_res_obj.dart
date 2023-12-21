// To parse this JSON data, do
//
//     final myMessages = myMessagesFromJson(jsonString);

import 'dart:convert';

class MyMessages {
  MyMessages({
    this.messages,
  });

  List<MessageObj>? messages;

  MyMessages copyWith({
    List<MessageObj>? feed,
  }) =>
      MyMessages(
        messages: feed ?? this.messages,
      );

  factory MyMessages.fromRawJson(String str) =>
      MyMessages.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyMessages.fromJson(Map<String, dynamic> json) => MyMessages(
        messages: json["feed"] == null
            ? null
            : List<MessageObj>.from(
                json["feed"].map((x) => MessageObj.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "feed": messages == null
            ? null
            : List<dynamic>.from(messages!.map((x) => x.toJson())),
      };
}

class MessageObj {
  MessageObj({
    this.id,
    this.receipt,
    this.receiptName,
    this.userId,
    this.name,
    this.timeStamp,
    this.message,
    this.profilePic,
  });

  String? id;
  String? receipt;
  String? receiptName;
  String? userId;
  String? name;
  String? timeStamp;
  String? message;
  String? profilePic;

  MessageObj copyWith({
    String? id,
    String? receipt,
    String? receiptName,
    String? userId,
    String? name,
    String? timeStamp,
    String? message,
    String? profilePic,
  }) =>
      MessageObj(
        id: id ?? this.id,
        receipt: receipt ?? this.receipt,
        receiptName: receiptName ?? this.receiptName,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        timeStamp: timeStamp ?? this.timeStamp,
        message: message ?? this.message,
        profilePic: profilePic ?? this.profilePic,
      );

  factory MessageObj.fromRawJson(String str) =>
      MessageObj.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MessageObj.fromJson(Map<String, dynamic> json) => MessageObj(
        id: json["id"] == null ? null : json["id"],
        receipt: json["receipt"] == null ? null : json["receipt"],
        receiptName: json["receipt_name"] == null ? null : json["receipt_name"],
        userId: json["user_id"] == null ? null : json["user_id"],
        name: json["name"] == null ? null : json["name"],
        timeStamp: (json["timeStamp"] == null || json["timeStamp"] == '')
            ? 'Just now'
            : json["timeStamp"],
        message: json["message"] == null ? null : json["message"],
        profilePic: json["profilePic"] == null ? null : json["profilePic"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "receipt": receipt == null ? null : receipt,
        "receipt_name": receiptName == null ? null : receiptName,
        "user_id": userId == null ? null : userId,
        "name": name == null ? null : name,
        "timeStamp": (timeStamp == null || timeStamp!.contains(''))
            ? 'Just now'
            : timeStamp,
        "message": message == null ? null : message,
        "profilePic": profilePic == null ? null : profilePic,
      };
}
