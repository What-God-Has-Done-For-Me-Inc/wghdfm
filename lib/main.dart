import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/screen/dashboard/post_details/post_details_screen.dart';
import 'package:wghdfm_java/screen/favourite/favourite_screen.dart';
import 'package:wghdfm_java/screen/friends/friends_screen.dart';
import 'package:wghdfm_java/utils/app_binding.dart';
import 'package:wghdfm_java/utils/page_res.dart';
import 'modules/auth_module/views/login_screen.dart';
import 'modules/auth_module/views/sign_up_screen.dart';
import 'modules/auth_module/views/splash_screen.dart';
import 'modules/dashbord_module/views/dash_board_screen.dart';
import 'modules/profile_module/view/profile_screen.dart';
import 'modules/recover_password/views/recover_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  NotificationHandler.initializeHandler();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AppBinding(),
      debugShowCheckedModeBanner: false,
      title: "What God Has Done For me",
      theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
            },
          ),
          primaryColor: const Color(0xff132ba2),
          backgroundColor: const Color(0xffF3FCFB),
          iconTheme: const IconThemeData(
            color: Color(0xff4b4b4b),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: const Color(0xff1742cb).withOpacity(0.7),
            ),
          ),
          fontFamily: 'Gilroy',
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(secondary: const Color(0xff1742cb).withOpacity(0.7))),
      home: SplashScreen(),
      getPages: [
        GetPage(name: PageRes.loginScreen, page: () => LoginScreen()),
        GetPage(name: PageRes.signUpScreen, page: () => const SignUpScreen()),
        GetPage(
            name: PageRes.dashBoardScreen, page: () => const DashBoardScreen()),
        GetPage(
            name: PageRes.postDetailScreen, page: () => PostDetailsScreen()),
        GetPage(name: PageRes.profileScreen, page: () => const ProfileScreen()),
        // GetPage(name: PageRes.captureImgVidScreen, page: () => CaptureImgVidScreen()),
        GetPage(
            name: PageRes.recoverPassword, page: () => RecoverPasswordScreen()),
        GetPage(
            name: PageRes.favouriteScreen, page: () => const FavouriteScreen()),
        GetPage(name: PageRes.friendScreen, page: () => FriendScreen()),
        // GetPage(name: PageRes.commentScreen, page: ()=>CommentScreen(postId: postId)),
      ],
      // GetPage()
    );
  }
}
