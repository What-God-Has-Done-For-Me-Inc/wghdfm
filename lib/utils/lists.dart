import 'package:flutter/material.dart';

var drawerHeaderTitles = <String>["Home", "Favorites", "Profile", "Friends", "Chat Manager", "Bible", "Christian News", "Our Daily Bread", "Christian Books", "Partner with Us"];

var drawerHeaderIcons = <IconData>[
  Icons.home,
  Icons.favorite,
  Icons.list_alt,
  Icons.people,
  Icons.forum,
  Icons.book_outlined,
  Icons.newspaper_outlined,
  Icons.library_books_outlined,
  Icons.library_books_outlined,
  Icons.people_outline
];

class PopUpOptions {
  static const String status = 'Status';
  static const String photo = 'Photo';
  static const String video = 'Video';
  static const String message = 'Message(s)';
  static const String hide = 'Hide Reported Content';
  static const String group = 'Group(s)';
  static const String logout = 'Logout';
  static const String inviteFriends = 'Invite a friend';
  static const String report = 'Report';
  static const String view = 'View';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String changePassword = 'Change Password';

  static const List<String> homeMoreOptions = <String>[
    // hide,
    message,
    group,
    inviteFriends,
    logout,
  ];

  static const List<String> postOptions = <String>[
    status,
    photo,
    video,
  ];

  static const List<String> feedPostMoreOptions = <String>[report, edit, delete];
  static const List<String> detailOptions = <String>[view, delete];
}
