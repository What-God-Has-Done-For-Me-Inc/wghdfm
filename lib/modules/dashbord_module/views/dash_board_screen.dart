import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:upgrader/upgrader.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/custom_package/percentage_indicator/linear_percent_indicator.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/modules/ads_module/ads_screen.dart';
import 'package:wghdfm_java/modules/agora_module/views/call_screen.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/add_post.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/search_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/setting_screeen.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/modules/notification_module/view/messages_screen.dart';
import 'package:wghdfm_java/modules/profile_module/view/profile_screen.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/screen/comment/comment_controller.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/add_fav_post_api.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/add_to_time_line_api.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/delete_post_api.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/report_post_api.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/donation_banner.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/edit_bottom_sheet.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/feed_with_load_more.dart';
import 'package:wghdfm_java/screen/favourite/favourite_screen.dart';
import 'package:wghdfm_java/screen/groups/group_details_screen.dart';
import 'package:wghdfm_java/screen/groups/group_screen.dart';
import 'package:wghdfm_java/screen/messages/message_threads_ui.dart';
import 'package:wghdfm_java/utils/app_colors.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/common-webview-screen.dart';
import 'package:wghdfm_java/utils/emoji_keybord_custom.dart';
import 'package:wghdfm_java/utils/endpoints.dart';
import 'package:wghdfm_java/utils/get_links_text.dart';
import 'package:wghdfm_java/utils/lists.dart';
import 'package:wghdfm_java/utils/urls.dart';

import '../../../common/video_player.dart';
import '../../../screen/comment/comment_screen.dart';
import '../../../services/prefrence_services.dart';
import '../../../services/sesssion.dart';
import '../../../utils/app_texts.dart';
import '../../../utils/pref_keys.dart';
import '../../../utils/shimmer_utils.dart';
import '../../profile_module/controller/profile_controller.dart';
import '../../profile_module/view/someones_profile_screen.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final dashBoardController = Get.put(DashBoardController());
  Widget _selectedScreen = const MainScreen();

  int ind = 0;
  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime ?? DateTime.now()) >
            const Duration(seconds: 2)) {
      currentBackPressTime = now;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Double Tap to exit')));
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void initState() {
    // TODO: implement initState
    NotificationHandler.to.setListener();
    NotificationHandler.to.getPermission();
    NotificationHandler.to.setFCMbyUserID();

    AppMethods().getEULA(context);
    super.initState();
  }

  screenSelector(int index) async {
    switch (index) {
      case 0:
        setState(() {
          _selectedScreen = const MainScreen();
          ind = 0;
        });
        break;

      case 1:
        setState(() {
          _selectedScreen = const FavouriteScreen();
          ind = 1;
        });
        break;

      case 2:
        LoginModel userDetails = await SessionManagement.getUserDetails();
        Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
        String encoded =
            stringToBase64Url.encode(userDetails.pass.toString() + "|^{}^|");
        var parsedData = Uri.encodeComponent(encoded);
        String userToken =
            "?F=${userDetails.fname}&L=${userDetails.lname}&E=${userDetails.email}&P=${parsedData}";

        setState(() {
          _selectedScreen = CommonWebScreen(
            url: chatUrl + userToken,
            title: "Chat",
          );
          ind = 2;
        });
        break;

      case 3:
        setState(() {
          _selectedScreen = const SettingScreen();
          ind = 3;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGrey,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomAppBar(
        height: Get.height * 0.07,
        shape: CircularNotchedRectangle(), //shape of notch
        notchMargin: 4,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  screenSelector(0);
                },
                child: Icon(
                  ind == 0 ? MingCute.home_4_fill : MingCute.home_4_line,
                  color: ind == 0 ? AppColors.primery : Colors.grey.shade500,
                  size: 28,
                ),
              ),
              GestureDetector(
                onTap: () {
                  screenSelector(1);
                },
                child: Icon(
                  ind == 1 ? MingCute.heart_fill : MingCute.heart_line,
                  color: ind == 1 ? AppColors.primery : Colors.grey.shade500,
                  size: 28,
                ),
              ),
              GestureDetector(
                onTap: () {
                  screenSelector(2);
                },
                child: Icon(
                  ind == 2 ? MingCute.comment_2_fill : MingCute.comment_2_line,
                  color: ind == 2 ? AppColors.primery : Colors.grey.shade500,
                  size: 28,
                ),
              ),
              GestureDetector(
                onTap: () {
                  screenSelector(3);
                },
                child: Icon(
                  ind == 3 ? MingCute.user_3_fill : MingCute.user_3_line,
                  color: ind == 3 ? AppColors.primery : Colors.grey.shade500,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
      body: PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (ind == 0) {
              bool value = await onWillPop();
              if (value == true) {
                SystemNavigator.pop();
              }
            }
            screenSelector(0);
          },
          child: _selectedScreen),
      // body: ZoomDrawer(
      //   borderRadius: 24.0,
      //   showShadow: true,
      //   moveMenuScreen: false,
      //   // angle: 0.0,
      //   drawerShadowsBackgroundColor: Colors.white,
      //   menuBackgroundColor: AppColors.darkGrey,
      //   clipMainScreen: true,
      //   boxShadow: const [
      //     BoxShadow(
      //       color: Colors.black,
      //       spreadRadius: 0.5,
      //       blurRadius: 5,
      //     )
      //   ],
      //   controller: dashBoardController.zoomDrawerController,
      //  menuScreen: buildDrawer(),
      //   androidCloseOnBackTap: true,
      //   mainScreen: const MainScreen(),
      //   // mainScreen: const AddNewsTip(),
      // ),
    );
  }
}

GlobalKey itemsDrawerKey = GlobalKey();

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final dashBoardController = Get.put(DashBoardController());
  final feedScrollController = ScrollController();
  final commentController = Get.put(CommentController());

  List<TargetFocus> targets = [];
  GlobalKey addButtonKey = GlobalKey();
  GlobalKey menuButtonKey = GlobalKey();
  GlobalKey notificationButtonKey = GlobalKey();
  final profileController = Get.put(ProfileController());

  getTutorial() {
    targets.add(
        TargetFocus(identify: "Target 1", keyTarget: addButtonKey, contents: [
      TargetContent(
          align: ContentAlign.top,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              const Text(
                "Add New Post",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Share your faith and connect with fellow believers through posts on our Christian Social Network",
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  tutorialCoachMark?.next();
                },
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
            ],
          ))
    ]));
    targets.add(
        TargetFocus(identify: "Target 2", keyTarget: menuButtonKey, contents: [
      TargetContent(
          align: ContentAlign.bottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              const Text(
                "Messages",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Connecting Christians through meaningful messages and fostering a digital community of faith",
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Groups",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Connect with like-minded believers, foster community, and deepen your faith through our Groups module on our Christian Social Network",
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Log out",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Log out and find solace in His grace, your Christian social journey continues with faith and community",
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  tutorialCoachMark?.next();
                },
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
            ],
          ))
    ]));
    targets.add(TargetFocus(
        identify: "Target 3",
        keyTarget: notificationButtonKey,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 50),
                  const Text(
                    "Notifications",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Stay connected with your Christian community through real-time notifications that bring you closer to God's love and guidance",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      dashBoardController.zoomDrawerController.toggle?.call();
                      tutorialCoachMark?.next();
                    },
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ],
              ))
        ]));

    targets.add(TargetFocus(
        identify: "Target 4",
        shape: ShapeLightFocus.RRect,
        keyTarget: itemsDrawerKey,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 50),
                  Text(
                    "Menu",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Explore the spiritual journey with our Christian Social Network: Connect with Home, Favorites, Profile, Bible, and Partner with us for a faith-filled experience",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      dashBoardController.zoomDrawerController.toggle?.call();
                      tutorialCoachMark?.next();
                    },
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ],
              ))
        ]));

    showTutorial();
  }

  getProfile() async {
    userId = await fetchStringValuesSF(SessionManagement.KEY_ID);
    profileController.getProfileData(
      showLoader: false,
      profileID: userId,
      callBack: () {
        if (profileController.profileDetails?.value.img?.isEmpty ?? true) {
          showDialog<bool?>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.black87.withOpacity(0.1),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    height: 200,
                    child: Material(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topCenter,
                            child: const Text(
                              'You have not set your profile yet..!!',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            alignment: Alignment.topCenter,
                            child: const Text('Do you want to set it now.? ',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14)),
                          ),
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                MaterialButton(
                                  child: const Text('No'),
                                  onPressed: () {
                                    Get.back();
                                  },
                                ),
                                const SizedBox(width: 20),
                                MaterialButton(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  child: const Text('Yes',
                                      style: TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Get.to(() => const ProfileScreen());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  TutorialCoachMark? tutorialCoachMark;

  void showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      hideSkip: true,
      colorShadow: Colors.black,
      // DEFAULT Colors.black
      // alignSkip: Alignment.bottomRight,
      // textSkip: "SKIP",
      // paddingFocus: 10,
      // opacityShadow: 0.8,

      onClickTarget: (target) {
        print(target);
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        if (target.identify == 'Target 3') {
          dashBoardController.zoomDrawerController.toggle?.call();
        }
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print(target);
      },
      // onSkip: () {
      //
      // },
      onFinish: () {
        AppMethods().hideTutorial();
        print("finish");
      },
    );
    Future.delayed(Duration(milliseconds: 200),
        () => tutorialCoachMark?.show(context: context));
  }

  @override
  void initState() {
    // TODO: implement initState

    AppMethods().checkTutorial(callBack: () {
      if (AppMethods.showTutorial.isTrue) {
        getTutorial();
      }
    });
    Future.delayed(Duration(seconds: 7), () {
      print("================ ${profilePic.value}");
      if (profilePic.value == null ||
          profilePic.value ==
              'https://wghdfm.s3.amazonaws.com/thumb/default_profile.jpg') {
        AppMethods.tutorialDialog();
      }
    });
    dashBoardController.getFriendList();

    dashBoardController.dashBoardLoadFeeds(
      isFirstTimeLoading: dashBoardController.isFirstTime,
      page: dashBoardController.currentPage,
    );
    dashBoardController.getNotificationCount();
    // dashBoardController.flickManager = FlickManager(
    //   videoPlayerController: VideoPlayerController.network("https://wghdfm.s3.amazonaws.com/videowires/1659596902_1.mp4"),
    // );
    WidgetsBinding.instance.addObserver(this);

    pagination();
    getProfile();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("Dispose");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  pagination() {
    feedScrollController.addListener(() async {
      if (feedScrollController.position.pixels >=
              feedScrollController.position.maxScrollExtent * 0.70 &&
          dashBoardController.isLoading.value == false) {
        dashBoardController.isLoading.value = true;
        dashBoardController.previousPosition =
            feedScrollController.position.maxScrollExtent;
        dashBoardController.isFirstTime = false;
        dashBoardController.currentPage = dashBoardController.currentPage + 12;
        await dashBoardController.dashBoardLoadFeeds(
            isFirstTimeLoading: dashBoardController.isFirstTime,
            page: dashBoardController.currentPage,
            isShowProcess: false);
      }
    });
  }

  String formatTime(String utcStringTime) {
    DateTime utcTime = DateTime.parse(utcStringTime);
    DateTime localTime = utcTime.toLocal();
    print(
        "====${localTime.minute}-${localTime.hour}-${localTime.day}--${localTime.month}-${localTime.year}=====");

    String formattedTime = DateFormat('mm-HH dd-MM-yyyy').format(localTime);
    return formattedTime;
  }

  String convertUTCToLocalFormatted(String utcTime) {
    // Create a DateTime object from the UTC time string
    DateTime utcDateTime = DateTime.parse(utcTime);

    // Get the local time zone
    String localTimeZone = DateTime.now().timeZoneOffset.toString();

    // Create a new DateTime object by adding the local time zone offset
    DateTime localDateTime = utcDateTime.add(Duration(
      hours: int.parse(localTimeZone.split(':')[0]),
      minutes: int.parse(localTimeZone.split(':')[1]),
    ));

    // Format the local DateTime object to "03:46 PM 29 June 2023" format
    String formattedTime =
        DateFormat('hh:mm a dd MMMM yyyy').format(localDateTime);

    return formattedTime;
  }

  String convertUTCToLocal(String utcTime) {
    // Create a DateTime object from the UTC time string
    DateTime utcDateTime = DateTime.parse(utcTime);

    // Get the local time zone
    String localTimeZone = DateTime.now().timeZoneOffset.toString();

    // Create a new DateTime object by adding the local time zone offset

    DateTime localDateTime = utcDateTime.add(Duration(
      hours: int.parse(localTimeZone.split(':')[0]),
      minutes: int.parse(localTimeZone.split(':')[1]),
    ));

    // Format the local DateTime object to your desired format
    String formattedTime =
        DateFormat('yyyy-MMWhat-dd hh:mm:ss a').format(localDateTime);

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    // print("--- -- convertUTCToLocal ${formatTime('2023-06-29 10:10:26.808699Z')}");
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      extendBody: true,
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        // leading: IconButton(
        //     onPressed: () {
        //       dashBoardController.zoomDrawerController.toggle?.call();
        //     },
        //     icon: const Icon(
        //       Icons.menu,
        //       color: Colors.black,
        //     )),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => const SearchScreen());
              },
              icon: const Icon(MingCute.search_3_line)),
          // IconButton(
          //     onPressed: () {
          //       Get.to(() => const CallScreen());
          //     },
          //     icon: const Icon(MingCute.phone_line)),
          IconButton(
              key: notificationButtonKey,
              onPressed: () {
                Get.to(() => const MessageScreens())?.then((value) {
                  dashBoardController.getNotificationCount(showProcess: false);
                });
              },
              icon: StreamBuilder(
                  stream: dashBoardController.notificationCount.stream,
                  builder: (context, snapshot) {
                    return Stack(children: [
                      const Icon(MingCute.notification_line),
                      Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            child: Text(
                              "${dashBoardController.notificationCount.value}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ))
                    ]);
                  })),
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            key: menuButtonKey,
            icon: const Icon(
              Icons.more_vert,
            ),
            padding: EdgeInsets.all(10),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            itemBuilder: (BuildContext context) {
              return PopUpOptions.homeMoreOptions.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            onSelected: (value) {
              switch (value) {
                //todo:2
                case PopUpOptions.message:
                  Get.to(() => MessageThreadsUI());
                  // pushTransitionedOnlyTo(widget: MessageThreadsUI());
                  break;
                case PopUpOptions.group:
                  Get.to(() => const GroupScreen());

                  // pushTransitionedOnlyTo(widget: GroupsUI());
                  break;
                case PopUpOptions.inviteFriends:
                  final emailController = TextEditingController();
                  final formKey = GlobalKey<FormState>();
                  Get.dialog(
                    Dialog(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: Get.height * 0.02),
                                const Text(
                                  "Invite Friends",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: Get.height * 0.02),
                                const Text(
                                  'Write a Email address of your friends that you want to Invite.',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: Get.height * 0.02),
                                Container(
                                  color: Colors.white,
                                  child: commonTextField(
                                      baseColor: Colors.black,
                                      borderColor: Colors.black,
                                      controller: emailController,
                                      errorColor: Colors.white,
                                      hint: "Email of your friends",
                                      validator: (String? value) {
                                        return (value == null || value.isEmpty)
                                            ? "Please enter valid email"
                                            : null;
                                      },
                                      commentBox: true),
                                ),
                                SizedBox(height: Get.height * 0.01),
                                const Text(
                                  'Note: Enter maximum 5 emails all separated by comma..',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                SizedBox(height: Get.height * 0.02),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      await profileController.inviteFriend(
                                          email: emailController.text,
                                          callBack: () {});
                                    }
                                  },
                                  child: Text(
                                    "Invite",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.02),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                  // SessionManagement.logoutUser();
                  break;
                case PopUpOptions.logout:
                  Get.dialog(
                    CupertinoAlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to logout.? "),
                      actions: [
                        MaterialButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text("No")),
                        MaterialButton(
                            onPressed: () {
                              SessionManagement.logoutUser();
                            },
                            child: const Text("Yes")),
                      ],
                    ),
                  );
                  // SessionManagement.logoutUser();
                  break;
              }
            },
          )
        ],
        title: const Text(
          'My Feed',
          style: TextStyle(
              color: AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: false,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      // drawer: buildDrawer(),
      body: feedWithLoadMore(),
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomInset: false,
      floatingActionButton: StreamBuilder(
        stream: DashBoardController.uploadingProcess.stream,
        builder: (context, snapshot) => StreamBuilder(
            stream: dashBoardController.postUploading.stream,
            builder: (context, snapshot) {
              if (dashBoardController.postUploading.value == false) {
                return FloatingActionButton.extended(
                  key: addButtonKey,
                  backgroundColor: const Color(0xff132ba2),
                  onPressed: () {
                    Get.to(() => const AddPost());
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  label: const Text(
                    'Post',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  icon: Lottie.asset('assets/json/post.json',
                      fit: BoxFit.fill,
                      height: Get.height * 0.05,
                      width: Get.width * 0.09),
                );
              } else {
                return StreamBuilder(
                  stream: DashBoardController.uploadingProcess.stream,
                  builder: (context, snapshot) {
                    print(
                        "------ PERCENTAGES ${DashBoardController.uploadingProcess.value}");
                    double value = (double.tryParse(
                                DashBoardController.uploadingProcess.value) ??
                            0.0) /
                        100;
                    print(" -- value is ${value}");
                    return FloatingActionButton(
                        backgroundColor: (value > 0 && value <= 0.95)
                            ? Color(0xff132ba2)
                            : Colors.grey.shade50,
                        onPressed: () {},
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1000000)),
                        child: (value > 0 && value <= 0.95)
                            ? Center(
                                child: CircularPercentIndicator(
                                  radius: 25.0,
                                  lineWidth: 5.0,
                                  animation: false,
                                  percent: value,
                                  backgroundColor: Colors.white,
                                  center: Text(
                                    "${value.toStringAsFixed(2).split(".").last}%",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 14.0),
                                  ),
                                  circularStrokeCap: CircularStrokeCap.round,
                                  progressColor: Colors.amber,
                                ),
                              )
                            : Lottie.asset('assets/json/upload.json'));

                    // return Column(
                    //   mainAxisSize: MainAxisSize.min,
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     Text(
                    //       "${(value > 0 && value <= 0.95) ? 'Please wait, your media files are uploading' : 'Sit tight, we are processing your files to upload'}",
                    //       // "${(value > 0 && value <= 0.95) ? 'Your post is Uploading Now' : 'Your post is Under Progress, you  will be notified soon'}",
                    //       style: GoogleFonts.inter(
                    //           fontSize: 13, fontWeight: FontWeight.w600),
                    //     ),
                    //     SizedBox(height: 5),
                    //     if (value > 0 && value <= 0.95)
                    //       ClipRRect(
                    //         borderRadius:
                    //             BorderRadius.all(Radius.circular(10)),
                    //         child: LinearPercentIndicator(
                    //           lineHeight: 13.0,
                    //           percent: value,
                    //           backgroundColor: Colors.grey,
                    //           progressColor: Colors.blue,
                    //           barRadius: Radius.circular(10),
                    //         ),
                    //       )
                    //     else
                    //       ClipRRect(
                    //         borderRadius:
                    //             BorderRadius.all(Radius.circular(10)),
                    //         child: LinearProgressIndicator(
                    //           backgroundColor: Colors.blue,
                    //           minHeight: 13,
                    //           valueColor:
                    //               AlwaysStoppedAnimation<Color>(Colors.red),
                    //         ),
                    //       ),
                    //   ],
                    // );
                    // return CircularPercentIndicator(
                    //   radius: 25.0,
                    //   lineWidth: 5.0,
                    //   header: Text(
                    //     (value > 0 && value <= 0.9) ? "Uploading" : "Getting Ready ",
                    //     style: GoogleFonts.roboto(
                    //       fontStyle: FontStyle.italic,
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 12,
                    //     ),
                    //   ),
                    //   // fillColor: Colors.white,
                    //   circularStrokeCap: CircularStrokeCap.round,
                    //   percent: value,
                    //   center: Text("${DashBoardController.uploadingProcess.value}%",
                    //       style: GoogleFonts.roboto(
                    //         fontStyle: FontStyle.italic,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 10,
                    //       )),
                    //   progressColor: Colors.green,
                    // );
                  },
                );
              }
            }),
      ),
    );
  }

  String getGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget feedWithLoadMore() {
    return Container(
      alignment: Alignment.center,
      child: StatefulBuilder(
        builder: (context, StateSetter setStateCustom) {
          return StreamBuilder(
            stream: dashBoardController.dashboardFeeds.stream,
            builder: (context, snapshot) {
              if (dashBoardController.dashboardFeeds == null ||
                  (dashBoardController.dashboardFeeds.isEmpty == true)) {
                return shimmerFeedLoading();
              }

              if (snapshot.hasError) {
                return Container(
                  color: Colors.white,
                  child: customText(title: "${snapshot.error}"),
                );
              }

              if ((dashBoardController.dashboardFeeds != null &&
                  dashBoardController.dashboardFeeds.isNotEmpty == true)) {
                return UpgradeAlert(
                  upgrader: Upgrader(
                    durationUntilAlertAgain: const Duration(days: 0),
                    shouldPopScope: () => false,
                    canDismissDialog: false,
                    dialogStyle: UpgradeDialogStyle.cupertino,
                    showIgnore: false,
                    showLater: false,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          triggerMode: RefreshIndicatorTriggerMode.anywhere,
                          onRefresh: () async {
                            if (dashBoardController.postUploading.isFalse) {
                              dashBoardController.dashboardFeeds.clear();
                              dashBoardController.currentPage = 0;
                              dashBoardController.dashBoardLoadFeeds(
                                isFirstTimeLoading: true,
                                page: dashBoardController.currentPage,
                                isShowProcess: true,
                              );
                            }
                          },
                          child: StreamBuilder(
                              stream: dashBoardController.dashboardFeeds.stream,
                              builder: (context, snapshot) {
                                return ListView.builder(
                                  cacheExtent: 100000,
                                  controller: feedScrollController,
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: dashBoardController
                                          .dashboardFeeds.length ??
                                      0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    bool isOwn = isOwnPost(
                                        "${dashBoardController.dashboardFeeds[index].ownerId}");
                                    // bool isLoved = dashBoardController.dashboardFeeds[index].getFav!.contains("S") == true;
                                    bool isLoved = dashBoardController
                                            .dashboardFeeds[index].isFav ==
                                        1;
                                    // bool isLiked = false;
                                    bool isLiked = dashBoardController
                                            .dashboardFeeds[index].isLike ==
                                        1;
                                    // TextEditingController commentTextController = TextEditingController();
                                    RxBool emojiShowing = false.obs;
                                    FocusNode focusNode = FocusNode();

                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (index == 0)
                                          StreamBuilder(
                                              stream: userName.stream,
                                              builder: (context, snapshot) {
                                                return Container(
                                                  width: Get.width,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Hello ${userName},",
                                                        style: GoogleFonts.itim(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        "${getGreeting()}..!",
                                                        style: GoogleFonts.itim(
                                                            fontSize: 24),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),

                                        if (index % 10 == 0 && index != 0)
                                          const AdsScreen(),
                                        // if (index % 2 == 0 && index != 0)  NativeAdWidget(),
                                        if (index % 25 == 0 && index != 0)
                                          const DonateBanner(),

                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    ClipOval(
                                                      child: Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Theme.of(
                                                                  Get.context!)
                                                              .iconTheme
                                                              .color,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          border: Border.all(
                                                            color: Theme.of(Get
                                                                    .context!)
                                                                .iconTheme
                                                                .color!,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        margin: const EdgeInsets
                                                            .all(5),
                                                        padding:
                                                            EdgeInsets.zero,
                                                        child: InkWell(
                                                          onTap: () {
                                                            if (dashBoardController
                                                                    .dashboardFeeds[
                                                                        index]
                                                                    .ownerId !=
                                                                userId) {
                                                              Get.to(() =>
                                                                  SomeoneProfileScreen(
                                                                      profileID:
                                                                          "${dashBoardController.dashboardFeeds[index].ownerId}"));
                                                            } else {
                                                              Get.to(() =>
                                                                  const ProfileScreen());
                                                            }
                                                            // Get.toNamed(PageRes.profileScreen, arguments: {"profileId": kDashboardController.dashboardFeeds?[index].ownerId!, "isSelf": isOwn});
                                                          },
                                                          child: ClipOval(
                                                            child:
                                                                CachedNetworkImage(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              fit: BoxFit.cover,
                                                              imageUrl:
                                                                  "${dashBoardController.dashboardFeeds[index].profilePic}",
                                                              // placeholder: (context, url) {
                                                              //   return Image.asset(
                                                              //     "assets/logo.png",
                                                              //     scale: 5.0,
                                                              //   );
                                                              // },
                                                              progressIndicatorBuilder:
                                                                  (BuildContext,
                                                                      String,
                                                                      DownloadProgress) {
                                                                return const Center(
                                                                    child:
                                                                        CupertinoActivityIndicator());
                                                              },
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(
                                                                      Icons
                                                                          .error,
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Expanded(
                                                      flex: 8,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          text: dashBoardController
                                                              .dashboardFeeds[
                                                                  index]
                                                              .name,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: dashBoardController
                                                                          .dashboardFeeds[
                                                                              index]
                                                                          .toUserIdDetails !=
                                                                      null
                                                                  ? " shared to ${dashBoardController.dashboardFeeds[index].toUserIdDetails?.firstname ?? "Guest"} ${dashBoardController.dashboardFeeds[index].toUserIdDetails?.lastname ?? ""} "
                                                                  : " ",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black45,
                                                                fontSize: 15.0,
                                                                height: 1.8,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                              ),
                                                            ),
                                                            if (dashBoardController
                                                                    .dashboardFeeds[
                                                                        index]
                                                                    .allTagUserList
                                                                    ?.isNotEmpty ==
                                                                true)
                                                              const TextSpan(
                                                                text:
                                                                    "is with ",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black45,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                ),
                                                              ),
                                                            ...dashBoardController
                                                                    .dashboardFeeds[
                                                                        index]
                                                                    .allTagUserList
                                                                    ?.map(
                                                                  (e) {
                                                                    int indexs = dashBoardController
                                                                            .dashboardFeeds[index]
                                                                            .allTagUserList
                                                                            ?.indexOf(e) ??
                                                                        0;

                                                                    if (indexs >
                                                                        0) {
                                                                      if (indexs >
                                                                          1) {
                                                                        return const TextSpan();
                                                                      }
                                                                      return TextSpan(
                                                                          text:
                                                                              "${(dashBoardController.dashboardFeeds[index].allTagUserList?.length ?? 0) - indexs} Others",
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                14.0,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            decoration:
                                                                                TextDecoration.none,
                                                                          ),
                                                                          recognizer: TapGestureRecognizer()
                                                                            ..onTap = () {
                                                                              Get.bottomSheet(BottomSheet(
                                                                                onClosing: () {},
                                                                                shape: const RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                                                                ),
                                                                                builder: (context) {
                                                                                  return Container(
                                                                                    width: Get.width,
                                                                                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                                                                                    child: ListView.builder(
                                                                                      itemCount: dashBoardController.dashboardFeeds[index].allTagUserList?.length ?? 0,
                                                                                      shrinkWrap: true,
                                                                                      itemBuilder: (context, listIndex) {
                                                                                        if (listIndex < 1) {
                                                                                          return const SizedBox();
                                                                                        }
                                                                                        return ListTile(
                                                                                          leading: ClipOval(
                                                                                            child: Container(
                                                                                              height: 50,
                                                                                              width: 50,
                                                                                              decoration: BoxDecoration(
                                                                                                color: Theme.of(Get.context!).iconTheme.color,
                                                                                                borderRadius: BorderRadius.circular(100),
                                                                                                border: Border.all(
                                                                                                  color: Theme.of(Get.context!).iconTheme.color!,
                                                                                                  width: 1,
                                                                                                ),
                                                                                              ),
                                                                                              margin: const EdgeInsets.all(5),
                                                                                              padding: EdgeInsets.zero,
                                                                                              child: ClipOval(
                                                                                                child: CachedNetworkImage(
                                                                                                  alignment: Alignment.center,
                                                                                                  fit: BoxFit.cover,
                                                                                                  imageUrl: "${dashBoardController.dashboardFeeds[index].allTagUserList?[listIndex].profileImg}",
                                                                                                  progressIndicatorBuilder: (BuildContext, String, DownloadProgress) {
                                                                                                    return const Center(child: CupertinoActivityIndicator());
                                                                                                  },
                                                                                                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          title: Text("${dashBoardController.dashboardFeeds[index].allTagUserList?[listIndex].profileName}"),
                                                                                          onTap: () {
                                                                                            if (dashBoardController.dashboardFeeds[index].allTagUserList?[listIndex].profileId?.isNotEmpty == true) {
                                                                                              Get.back();
                                                                                              if (dashBoardController.dashboardFeeds[index].allTagUserList?[listIndex].profileId != userId) {
                                                                                                Get.to(() => SomeoneProfileScreen(profileID: dashBoardController.dashboardFeeds[index].allTagUserList?[listIndex].profileId ?? ""));
                                                                                              } else {
                                                                                                Get.to(() => const ProfileScreen());
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ));
                                                                              // (e.profileId?.isNotEmpty == true) {
                                                                              //   Get.to(() => SomeoneProfileScreen(profileID: e.profileId ?? ""));
                                                                              // }
                                                                            });
                                                                    }

                                                                    return TextSpan(
                                                                        text:
                                                                            "${e.profileName} ${(indexs < (dashBoardController.dashboardFeeds[index].allTagUserList?.length ?? 0) && indexs > 1) ? ' & ' : ''}",
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              15.0,
                                                                          height:
                                                                              1.8,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          decoration:
                                                                              TextDecoration.none,
                                                                        ),
                                                                        recognizer: TapGestureRecognizer()
                                                                          ..onTap = () {
                                                                            if (e.profileId?.isNotEmpty ==
                                                                                true) {
                                                                              if (e.profileId != userId) {
                                                                                Get.to(() => SomeoneProfileScreen(profileID: e.profileId ?? ""));
                                                                              } else {
                                                                                Get.to(() => const ProfileScreen());
                                                                              }
                                                                            }
                                                                          });
                                                                  },
                                                                ).toList() ??
                                                                [],
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    PopupMenuButton<String>(
                                                      offset:
                                                          const Offset(0, 40),
                                                      icon: const Icon(
                                                        Icons.more_horiz,
                                                      ),
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      15.0))),
                                                      itemBuilder: (BuildContext
                                                          context) {
                                                        return [
                                                          const PopupMenuItem<
                                                              String>(
                                                            value: PopUpOptions
                                                                .report,
                                                            child: Text(
                                                                PopUpOptions
                                                                    .report),
                                                          ),
                                                          if (isOwn)
                                                            const PopupMenuItem<
                                                                String>(
                                                              value:
                                                                  PopUpOptions
                                                                      .edit,
                                                              child: Text(
                                                                  PopUpOptions
                                                                      .edit),
                                                            ),
                                                          if (isOwn)
                                                            const PopupMenuItem<
                                                                String>(
                                                              value:
                                                                  PopUpOptions
                                                                      .delete,
                                                              child: Text(
                                                                  PopUpOptions
                                                                      .delete),
                                                            ),
                                                        ];
                                                      },
                                                      onSelected: (value) {
                                                        switch (value) {
                                                          case PopUpOptions
                                                                .report:
                                                            reportPost(
                                                                "${dashBoardController.dashboardFeeds[index].id}");
                                                            break;
                                                          case PopUpOptions
                                                                .edit:
                                                            editStatusBottomSheet(
                                                                dashBoardController
                                                                        .dashboardFeeds[
                                                                    index],
                                                                onEdit: () {
                                                              setStateCustom(
                                                                  () {});
                                                            });
                                                            break;
                                                          case PopUpOptions
                                                                .delete:
                                                            // AppMethods.deleteDialog(
                                                            //     headingText: 'Are you sure you want to delete this post?',
                                                            //     descriptionText: "" ?? "This will delete the permanently delete your post and you can't undo it after delete.'",
                                                            //     onDelete: () {
                                                            //
                                                            //     });
                                                            deletePost(
                                                                postId:
                                                                    "${dashBoardController.dashboardFeeds[index].id}",
                                                                callBack: () {
                                                                  dashBoardController
                                                                      .dashboardFeeds
                                                                      .removeAt(
                                                                          index);
                                                                  dashBoardController
                                                                      .dashboardFeeds
                                                                      .refresh();
                                                                }).then((value) {
                                                              setStateCustom(
                                                                  () {});
                                                            });
                                                            break;
                                                        }
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                              if (dashBoardController
                                                          .dashboardFeeds[index]
                                                          .status !=
                                                      null &&
                                                  dashBoardController
                                                          .dashboardFeeds[index]
                                                          .status !=
                                                      '')
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 8,
                                                        child: getLinkText(
                                                            text: dashBoardController
                                                                    .dashboardFeeds[
                                                                        index]
                                                                    .status ??
                                                                ""),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (dashBoardController
                                                          .dashboardFeeds[index]
                                                          .promoteGroupDetails
                                                          ?.groupId !=
                                                      null &&
                                                  dashBoardController
                                                          .dashboardFeeds[index]
                                                          .promoteGroupDetails
                                                          ?.groupId !=
                                                      '' &&
                                                  dashBoardController
                                                          .dashboardFeeds[index]
                                                          .promoteGroupDetails
                                                          ?.groupTitle !=
                                                      null &&
                                                  dashBoardController
                                                          .dashboardFeeds[index]
                                                          .promoteGroupDetails
                                                          ?.groupTitle !=
                                                      '')
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Expanded(
                                                            flex: 8,
                                                            child: RichText(
                                                              text: TextSpan(
                                                                  text:
                                                                      "Please join this group ",
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15.0,
                                                                    height: 1.8,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .none,
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                      text: dashBoardController
                                                                              .dashboardFeeds[index]
                                                                              .promoteGroupDetails
                                                                              ?.groupTitle ??
                                                                          "",
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            15.0,
                                                                        height:
                                                                            1.8,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        decoration:
                                                                            TextDecoration.none,
                                                                      ),
                                                                      recognizer:
                                                                          TapGestureRecognizer()
                                                                            ..onTap =
                                                                                () {
                                                                              Get.to(() => GroupDetailsScreen(
                                                                                    groupId: dashBoardController.dashboardFeeds[index].promoteGroupDetails?.groupId,
                                                                                  ));
                                                                              // openInWeb(linkText);
                                                                              // Handle link tap here
                                                                            },
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      ///Promote Group Description.
                                                      if (dashBoardController
                                                              .dashboardFeeds[
                                                                  index]
                                                              .promoteGroupDetails
                                                              ?.groupDescription !=
                                                          null)
                                                        Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          width: Get.width,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5),
                                                          child: Text(
                                                            "Description: ${dashBoardController.dashboardFeeds[index].promoteGroupDetails?.groupDescription}",
                                                            maxLines: 2,
                                                            style:
                                                                const TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontSize: 15.0,
                                                            ),
                                                          ),
                                                        ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 10),
                                                        // height: 200,
                                                        // width: 400,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          // image: DecorationImage(image:),
                                                        ),
                                                        child:
                                                            CachedNetworkImage(
                                                          // alignment:
                                                          //     Alignment.center,
                                                          fit: BoxFit.contain,
                                                          imageUrl:
                                                              "https://wghdfm.s3.amazonaws.com/medium/${dashBoardController.dashboardFeeds[index].promoteGroupDetails?.coverPic}",
                                                          progressIndicatorBuilder:
                                                              (BuildContext,
                                                                  String,
                                                                  DownloadProgress) {
                                                            return const SizedBox(
                                                              height: 50,
                                                              width: 50,
                                                              child: Center(
                                                                  child:
                                                                      CupertinoActivityIndicator()),
                                                            );
                                                          },
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                                  Icons.error,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              // Text(feeds![index].status.toString()),
                                              customImageView(
                                                  dashBoardController
                                                      .dashboardFeeds[index]),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 1,
                                                      child: IconButton(
                                                          onPressed: () {
                                                            if (!isLoved) {
                                                              setAsFav(
                                                                postId:
                                                                    "${dashBoardController.dashboardFeeds[index].id}",
                                                              ).then((value) {
                                                                if (dashBoardController
                                                                        .dashboardFeeds[
                                                                            index]
                                                                        .isFav ==
                                                                    0) {
                                                                  dashBoardController
                                                                      .dashboardFeeds[
                                                                          index]
                                                                      .isFav = 1;
                                                                } else {
                                                                  dashBoardController
                                                                      .dashboardFeeds[
                                                                          index]
                                                                      .isFav = 0;
                                                                }
                                                                setStateCustom(
                                                                    () {});
                                                              });
                                                            } else {
                                                              setAsUnFav(
                                                                      "${dashBoardController.dashboardFeeds[index].id}")
                                                                  .then(
                                                                      (value) {
                                                                if (dashBoardController
                                                                        .dashboardFeeds[
                                                                            index]
                                                                        .isFav ==
                                                                    0) {
                                                                  dashBoardController
                                                                      .dashboardFeeds[
                                                                          index]
                                                                      .isFav = 1;
                                                                } else {
                                                                  dashBoardController
                                                                      .dashboardFeeds[
                                                                          index]
                                                                      .isFav = 0;
                                                                }
                                                                setStateCustom(
                                                                    () {});
                                                              });
                                                            }
                                                          },
                                                          icon: Icon(
                                                            isLoved
                                                                ? MingCute
                                                                    .heart_fill
                                                                : MingCute
                                                                    .heart_line,
                                                            color: isLoved
                                                                ? Colors.red
                                                                : Theme.of(Get
                                                                        .context!)
                                                                    .iconTheme
                                                                    .color,
                                                          )),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          await setAsLiked(
                                                              postId:
                                                                  "${dashBoardController.dashboardFeeds[index].id}",
                                                              postOwnerId:
                                                                  "${dashBoardController.dashboardFeeds[index].ownerId}",
                                                              isInsertLike: dashBoardController
                                                                      .dashboardFeeds[
                                                                          index]
                                                                      .isLike ==
                                                                  0,
                                                              callBack:
                                                                  (commentCount) {
                                                                if (dashBoardController
                                                                        .dashboardFeeds[
                                                                            index]
                                                                        .isLike ==
                                                                    0) {
                                                                  dashBoardController
                                                                      .dashboardFeeds[
                                                                          index]
                                                                      .isLike = 1;
                                                                } else {
                                                                  dashBoardController
                                                                      .dashboardFeeds[
                                                                          index]
                                                                      .isLike = 0;
                                                                }
                                                                dashBoardController
                                                                        .dashboardFeeds[
                                                                            index]
                                                                        .countLike =
                                                                    "${commentCount}";
                                                                setStateCustom(
                                                                    () {});
                                                              });
                                                        },
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              isLiked
                                                                  ? MingCute
                                                                      .thumb_up_2_fill
                                                                  : MingCute
                                                                      .thumb_up_line,
                                                              color: isLiked
                                                                  ? Colors.blue
                                                                  : Theme.of(Get
                                                                          .context!)
                                                                      .iconTheme
                                                                      .color,
                                                            ),
                                                            const SizedBox(
                                                              width: 3,
                                                            ),
                                                            Text(
                                                              "${dashBoardController.dashboardFeeds[index].countLike}",
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          LoginModel
                                                              userDetails =
                                                              await SessionManagement
                                                                  .getUserDetails();
                                                          if (kDebugMode) {
                                                            print(
                                                                "user id: ${userDetails.id}");
                                                            print(
                                                                "post id: ${dashBoardController.dashboardFeeds[index].id}");
                                                            print(
                                                                ">> > Before Comment Count ${dashBoardController.dashboardFeeds[index].countComment}");
                                                            print(
                                                                ":: CURRENT INDEX IS ${index}");
                                                            print(
                                                                "Before: ${dashBoardController.dashboardFeeds[index].id!}");
                                                          }
                                                          EndPoints
                                                                  .selectedPostId =
                                                              "${dashBoardController.dashboardFeeds[index].id}";
                                                          Get.to(() =>
                                                              CommentScreen(
                                                                index: index,
                                                                isFrom: AppTexts
                                                                    .dashBoard,
                                                                postId: EndPoints
                                                                    .selectedPostId,
                                                                postOwnerId:
                                                                    "${dashBoardController.dashboardFeeds[index].ownerId}",
                                                              ))?.then((value) {
                                                            dashBoardController
                                                                .dashboardFeeds
                                                                .refresh();
                                                            print(
                                                                ">> >> > After Comment Count ${dashBoardController.dashboardFeeds[index].countComment}");
                                                          });
                                                        },
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Icon(
                                                              MingCute
                                                                  .message_4_line,
                                                              // color: isLiked ? Colors.blue : Theme.of(Get.context!).iconTheme.color,
                                                            ),
                                                            const SizedBox(
                                                              width: 3,
                                                            ),
                                                            Text(
                                                              "${dashBoardController.dashboardFeeds[index].countComment}",
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    /*Expanded(
                                                            flex: 1,
                                                            child: IconButton(
                                                                onPressed: () async {
                                                                  // todo:
                                                                  LoginModel userDetails = await SessionManagement.getUserDetails();
                                                                  if (kDebugMode) {
                                                                    print("user id: ${userDetails.id}");
                                                                    print("post id: ${dashBoardController.dashboardFeeds[index].id!}");
                                                                  }

                                                                  debugPrint("Before: ${dashBoardController.dashboardFeeds[index].id!}");
                                                                  EndPoints.selectedPostId = "${dashBoardController.dashboardFeeds[index].id}";
                                                                  Get.to(() => CommentScreen(postId: EndPoints.selectedPostId));
                                                                },
                                                                icon: Row(
                                                                  children: [
                                                                    const Icon(Icons.messenger_outline),
                                                                    SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    Text(
                                                                      "${dashBoardController.dashboardFeeds[index].countComment ?? 0}",
                                                                    ),
                                                                  ],
                                                                )),
                                                          ),*/
                                                    Expanded(
                                                      flex: 1,
                                                      child: PopupMenuButton(
                                                        onSelected: (value) {
                                                          if (value ==
                                                              "Timeline") {
                                                            addToTimeline(
                                                                "${dashBoardController.dashboardFeeds[index].id}");
                                                          }
                                                          if (value ==
                                                              "Groups") {
                                                            dashBoardController
                                                                .sharePostToGroup(
                                                                    postId:
                                                                        "${dashBoardController.dashboardFeeds[index].id}",
                                                                    ownerID:
                                                                        userId);
                                                          }
                                                          if (value ==
                                                              "Other") {
                                                            AppMethods().share(
                                                                string:
                                                                    "${EndPoints.socialSharePostUrl}${dashBoardController.dashboardFeeds[index].id}",
                                                                context:
                                                                    context);
                                                          }
                                                        },
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15)),
                                                        position:
                                                            PopupMenuPosition
                                                                .under,
                                                        icon: const Icon(
                                                            MingCute
                                                                .share_2_line),
                                                        itemBuilder: (context) {
                                                          return [
                                                            PopupMenuItem(
                                                                value:
                                                                    "Timeline",
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(Icons
                                                                            .add_box)
                                                                        .paddingOnly(
                                                                            right:
                                                                                7),
                                                                    const Text(
                                                                        "Timeline"),
                                                                  ],
                                                                )),
                                                            PopupMenuItem(
                                                                value: "Groups",
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(Icons
                                                                            .group)
                                                                        .paddingOnly(
                                                                            right:
                                                                                7),
                                                                    const Text(
                                                                        "Groups"),
                                                                  ],
                                                                )),
                                                            PopupMenuItem(
                                                                value: "Other",
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(Icons
                                                                            .ios_share)
                                                                        .paddingOnly(
                                                                            right:
                                                                                7),
                                                                    const Text(
                                                                        "Share"),
                                                                  ],
                                                                )),
                                                          ];
                                                        },
                                                      ),
                                                      /*IconButton(
                                                                  onPressed: () {

                                                                    addToTimeline("${dashBoardController.dashboardFeeds[index].id}");
                                                                  },
                                                                  icon: const Icon(Icons.add_box)),*/
                                                    ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: IconButton(
                                                    //       onPressed: () {
                                                    //         AppMethods().share(
                                                    //             "${EndPoints.socialSharePostUrl}${dashBoardController.dashboardFeeds[index].id}");
                                                    //       },
                                                    //       icon: const Icon(Icons.share)),
                                                    // ),

                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: IconButton(
                                                    //       onPressed: () {
                                                    //         reportPost(
                                                    //             "${dashBoardController.dashboardFeeds[index].id}");
                                                    //       },
                                                    //       icon: const Icon(Icons
                                                    //           .report_problem)),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 4),
                                                    child: customText(
                                                        title:
                                                            "${dashBoardController.dashboardFeeds[index].timeStamp}",
                                                        fs: 11),
                                                  )),
                                              if (dashBoardController
                                                      .dashboardFeeds[index]
                                                      .latestComments
                                                      ?.isNotEmpty ==
                                                  true)
                                                Column(
                                                  children: [
                                                    const Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        "Comments",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ).paddingOnly(left: 10),
                                                    ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount: (dashBoardController
                                                                      .dashboardFeeds[
                                                                          index]
                                                                      .latestComments
                                                                      ?.length ??
                                                                  0) >
                                                              3
                                                          ? 3
                                                          : dashBoardController
                                                                  .dashboardFeeds[
                                                                      index]
                                                                  .latestComments
                                                                  ?.length ??
                                                              0,
                                                      itemBuilder: (context,
                                                          indexOfComment) {
                                                        int listLength =
                                                            dashBoardController
                                                                    .dashboardFeeds[
                                                                        index]
                                                                    .latestComments
                                                                    ?.length ??
                                                                0;
                                                        return Row(
                                                          children: [
                                                            Container(
                                                              height: 40,
                                                              width: 40,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        Get.context!)
                                                                    .iconTheme
                                                                    .color,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                border:
                                                                    Border.all(
                                                                  color: Theme.of(
                                                                          Get.context!)
                                                                      .iconTheme
                                                                      .color!,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          5),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              child: ClipOval(
                                                                child:
                                                                    CachedNetworkImage(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  imageUrl:
                                                                      "https://wghdfm.s3.amazonaws.com/thumb/${dashBoardController.dashboardFeeds[index].latestComments?[listLength - (listLength >= 3 ? 3 : listLength >= 2 ? 2 : 1) + indexOfComment]?.img}",
                                                                  // "https://wghdfm.s3.amazonaws.com/thumb/${dashBoardController.dashboardFeeds[index].latestComments?.last.img}",
                                                                  progressIndicatorBuilder:
                                                                      (BuildContext,
                                                                          String,
                                                                          DownloadProgress) {
                                                                    return const Center(
                                                                        child:
                                                                            CupertinoActivityIndicator());
                                                                  },
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const Icon(
                                                                          Icons
                                                                              .error,
                                                                          color:
                                                                              Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                      "${dashBoardController.dashboardFeeds[index].latestComments?[listLength - (listLength >= 3 ? 3 : listLength >= 2 ? 2 : 1) + indexOfComment]?.firstname} ${dashBoardController.dashboardFeeds[index].latestComments?[listLength - (listLength >= 3 ? 3 : listLength >= 2 ? 2 : 1) + indexOfComment]?.lastname}",
                                                                      style: GoogleFonts.montserrat(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500)),
                                                                  Text(
                                                                    "${dashBoardController.dashboardFeeds[index].latestComments?[listLength - (listLength >= 3 ? 3 : listLength >= 2 ? 2 : 1) + indexOfComment]?.comment}",
                                                                    style: GoogleFonts
                                                                        .montserrat(
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                ),
                                                height: 60,
                                                color: AppColors.background,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 9,
                                                      child: commonTextField(
                                                        readOnly: false,
                                                        focusNode: focusNode,
                                                        leading: IconButton(
                                                          icon: const Icon(
                                                              MingCute
                                                                  .emoji_line,
                                                              color: AppColors
                                                                  .darkGrey,
                                                              size: 25),
                                                          onPressed: () async {
                                                            emojiShowing
                                                                .toggle();
                                                            if (emojiShowing
                                                                .isFalse) {
                                                              print(" ooo");
                                                              // FocusScope.of(context).requestFocus(focusNode);
                                                            }
                                                          },
                                                        ),
                                                        hint: 'Write Comment',
                                                        isLabelFloating: false,
                                                        controller:
                                                            dashBoardController
                                                                .dashboardFeeds[
                                                                    index]
                                                                .commentTextController,
                                                        borderColor: Theme.of(
                                                                Get.context!)
                                                            .primaryColor,
                                                        baseColor:
                                                            AppColors.black,
                                                        commentBox: true,
                                                        isLastField: true,
                                                        obscureText: false,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(HeroIcons
                                                          .paper_airplane),
                                                      onPressed: () async {
                                                        print(
                                                            ":: ${dashBoardController.dashboardFeeds[index].latestComments?.length}");
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        EndPoints
                                                                .selectedPostId =
                                                            "${dashBoardController.dashboardFeeds[index].id}";

                                                        if (dashBoardController
                                                                .dashboardFeeds[
                                                                    index]
                                                                .commentTextController
                                                                ?.text
                                                                .trim()
                                                                .isNotEmpty ==
                                                            true) {
                                                          LoginModel
                                                              userDetails =
                                                              await SessionManagement
                                                                  .getUserDetails();

                                                          Map<String, String>
                                                              bodyData = {
                                                            "post_id": EndPoints
                                                                .selectedPostId,
                                                            "user_id":
                                                                userDetails.id!,
                                                            "comment": dashBoardController
                                                                    .dashboardFeeds[
                                                                        index]
                                                                    .commentTextController
                                                                    ?.text ??
                                                                ""
                                                          };

                                                          await APIService()
                                                              .callAPI(
                                                                  params: {},
                                                                  serviceUrl: EndPoints
                                                                          .baseUrl +
                                                                      EndPoints
                                                                          .insertCommentUrl,
                                                                  method:
                                                                      APIService
                                                                          .postMethod,
                                                                  formDatas: dio
                                                                          .FormData
                                                                      .fromMap(
                                                                          bodyData),
                                                                  success: (dio
                                                                      .Response
                                                                      response) async {
                                                                    // Get.back();
                                                                    print(
                                                                        ":: RESPONSE : ${response.data}");
                                                                    print(
                                                                        ":: RESPONSE Comment Id  : ${jsonDecode(response.data)["comment_id"]}");
                                                                    print(
                                                                        ":: INDEX IS ${index}");
                                                                    setStateCustom(
                                                                        () {
                                                                      // print(":: commentController.commentList?.length IS ${commentController.commentList?.length}");
                                                                      dashBoardController
                                                                          .dashboardFeeds[
                                                                              index]
                                                                          .latestComments
                                                                          ?.add(
                                                                              PostModelFeedLatestComments(
                                                                        comment: dashBoardController
                                                                            .dashboardFeeds[index]
                                                                            .commentTextController
                                                                            ?.text,
                                                                        commentId:
                                                                            "${jsonDecode(response.data)["comment_id"]}",
                                                                        firstname:
                                                                            userDetails.fname ??
                                                                                "",
                                                                        lastname:
                                                                            userDetails.lname ??
                                                                                "",
                                                                        img: userDetails.img ??
                                                                            "",
                                                                        date: DateTime.now()
                                                                            .toString(),
                                                                        userId:
                                                                            userDetails.id ??
                                                                                "",
                                                                      ));
                                                                      dashBoardController
                                                                          .dashboardFeeds[
                                                                              index]
                                                                          .countComment = (dashBoardController.dashboardFeeds[index].countComment ??
                                                                              0) +
                                                                          1;
                                                                      dashBoardController
                                                                          .dashboardFeeds[
                                                                              index]
                                                                          .commentTextController
                                                                          ?.clear();
                                                                      dashBoardController
                                                                          .dashboardFeeds
                                                                          .refresh();
                                                                    });
                                                                    if (dashBoardController.dashboardFeeds[index].ownerId !=
                                                                            userDetails
                                                                                .id &&
                                                                        dashBoardController.dashboardFeeds[index].ownerId !=
                                                                            null) {
                                                                      NotificationHandler.to.sendNotificationToUserID(
                                                                          postId: dashBoardController.dashboardFeeds[index].id ??
                                                                              "0",
                                                                          userId: dashBoardController.dashboardFeeds[index].ownerId ??
                                                                              "0",
                                                                          title:
                                                                              "New Comments on Your Post",
                                                                          body:
                                                                              "${userDetails.fname} ${userDetails.lname} Commented your post");
                                                                    }
                                                                    print(
                                                                        ">> < COMMENT COUNT ? ${dashBoardController.dashboardFeeds[index].countComment}");
                                                                    print(
                                                                        ">> ::  COMMENT COUNT ? ${dashBoardController.dashboardFeeds[index].latestComments?.length}");
                                                                  },
                                                                  error: (dio
                                                                      .Response
                                                                      response) {
                                                                    snack(
                                                                        icon: Icons
                                                                            .report_problem,
                                                                        iconColor:
                                                                            Colors
                                                                                .yellow,
                                                                        msg:
                                                                            "Type something first...",
                                                                        title:
                                                                            "Alert!");
                                                                  },
                                                                  showProcess:
                                                                      true);
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              StreamBuilder(
                                                  stream: emojiShowing.stream,
                                                  builder: (context, snapshot) {
                                                    return Offstage(
                                                      offstage:
                                                          emojiShowing.isFalse,
                                                      child: SizedBox(
                                                        height:
                                                            Get.height * 0.4,
                                                        child: EmojiKeybord(
                                                          textController:
                                                              dashBoardController
                                                                  .dashboardFeeds[
                                                                      index]
                                                                  .commentTextController,
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
                        ),
                      ),
                      StreamBuilder(
                        stream: dashBoardController.isLoading.stream,
                        builder: (context, snapshot) {
                          if (dashBoardController.isLoading.isTrue) {
                            return Container(
                              // width: Get.width,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(10),
                              child:
                                  const CupertinoActivityIndicator(radius: 10),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: customText(title: 'No Feeds'),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget shimmerFeedLoading() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    shimmerMeUp(
                      const CircleAvatar(
                        child: SizedBox(width: 70, height: 70),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: shimmerMeUp(Container(
                        height: 20,
                        color: Colors.grey,
                      )),
                    ),
                  ],
                ),
              ),
              shimmerMeUp(
                AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      width: Get.width,
                      color: Colors.grey,
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.favorite_border)),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: 20,
                        child: Image.asset(
                          "assets/icon/like_img.png",
                          color: Theme.of(Get.context!).iconTheme.color,
                        ),
                      )),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.messenger_outline)),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.add_box)),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.share)),
                    ),
                    const Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(
                        const Icon(
                          Icons.report_problem,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: shimmerMeUp(Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  height: 20,
                  color: Colors.grey,
                )),
              ),
            ],
          ),
        ),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    shimmerMeUp(
                      const CircleAvatar(
                        child: SizedBox(width: 70, height: 70),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: shimmerMeUp(Container(
                        height: 20,
                        color: Colors.grey,
                      )),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: shimmerMeUp(
                        const Icon(
                          Icons.more_horiz,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              shimmerMeUp(
                AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      width: Get.width,
                      color: Colors.grey,
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: 20,
                        child: Image.asset(
                          "assets/icon/like_img.png",
                          color: Theme.of(Get.context!).iconTheme.color,
                        ),
                      )),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.messenger_outline)),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.share)),
                    ),
                    const Expanded(
                      flex: 4,
                      child: SizedBox(),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.favorite_border)),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: shimmerMeUp(Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  height: 20,
                  color: Colors.grey,
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget shimmerProfileLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        shimmerMeUp(
          ClipOval(
            child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).iconTheme.color,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Theme.of(Get.context!).iconTheme.color!,
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.all(5),
                padding: EdgeInsets.zero,
                child: const ClipOval(
                  child: SizedBox(),
                )),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: shimmerMeUp(Container(
            width: 200,
            height: 20,
            color: Colors.grey,
          )),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
