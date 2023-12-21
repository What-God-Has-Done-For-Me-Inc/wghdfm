// import 'package:flutter/material.dart';
// import 'package:flutter_zoom_drawer/config.dart';
// import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
// import 'package:wghdfm_java/modules/dashbord_module/views/dash_board_screen.dart';
// import 'package:wghdfm_java/modules/profile_module/view/profile_screen.dart';
// import 'package:wghdfm_java/screen/dashboard/widgets/build_drawer.dart';
// import 'package:wghdfm_java/screen/donate/donate_ui.dart';
// import 'package:wghdfm_java/screen/favourite/favourite_screen.dart';
// import 'package:wghdfm_java/screen/friends/friends_screen.dart';
// import 'package:wghdfm_java/utils/app_texts.dart';
//
// class DrawerScreen extends StatefulWidget {
//   static ZoomDrawerController zoomDrawerController = ZoomDrawerController();
//   final Widget screen;
//   const DrawerScreen({Key? key, required this.screen}) : super(key: key);
//
//   @override
//   State<DrawerScreen> createState() => _DrawerScreenState();
// }
//
// class _DrawerScreenState extends State<DrawerScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return ZoomDrawer(
//       // style: DrawerStyle.style4,
//       borderRadius: 24.0,
//       showShadow: true,
//       moveMenuScreen: false,
//       angle: 0.0,
//       drawerShadowsBackgroundColor: Colors.white,
//       menuBackgroundColor: Colors.white.withOpacity(0.5),
//       clipMainScreen: true,
//       controller: DrawerScreen.zoomDrawerController,
//       menuScreen: buildDrawer(),
//       // mainScreen: getScreens(ScreenName: widget.screen),
//       mainScreen: widget.screen,
//     );
//   }
//
//   Widget getScreens({required String ScreenName}) {
//     switch (ScreenName) {
//       case AppTexts.dashBoard:
//         return DashBoardScreen();
//       case AppTexts.profile:
//         return ProfileScreen();
//       case AppTexts.favorite:
//         return FavouriteScreen();
//       case AppTexts.friends:
//         return FriendScreen();
//       case AppTexts.donate:
//         return DonateUI();
//
//       default:
//         return DashBoardScreen();
//     }
//   }
// }
