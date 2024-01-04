import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/custom_package/percentage_indicator/circular_percent_indicator.dart';
import 'package:wghdfm_java/custom_package/percentage_indicator/linear_percent_indicator.dart';
import 'package:wghdfm_java/custom_package/zoom_drawer/zoom_drawer.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/modules/ads_module/ads_screen.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/ProfileSetupScreen.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/add_post.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/search_screen.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/modules/notification_module/view/messages_screen.dart';
import 'package:wghdfm_java/modules/profile_module/view/profile_screen.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/screen/comment/comment_controller.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/add_fav_post_api.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/add_to_time_line_api.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/delete_post_api.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/report_post_api.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/build_drawer.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/edit_bottom_sheet.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/feed_with_load_more.dart';
import 'package:wghdfm_java/screen/groups/group_details_screen.dart';
import 'package:wghdfm_java/screen/groups/group_screen.dart';
import 'package:wghdfm_java/screen/messages/message_threads_ui.dart';
import 'package:wghdfm_java/utils/app_binding.dart';
import 'package:wghdfm_java/utils/app_colors.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/emoji_keybord_custom.dart';
import 'package:wghdfm_java/utils/endpoints.dart';
import 'package:wghdfm_java/utils/get_links_text.dart';
import 'package:wghdfm_java/utils/lists.dart';

import '../../../screen/comment/comment_screen.dart';
import '../../../services/prefrence_services.dart';
import '../../../services/sesssion.dart';
import '../../../utils/app_texts.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    NotificationHandler.to.setListener();
    NotificationHandler.to.getPermission();
    NotificationHandler.to.setFCMbyUserID();

    AppMethods().getEULA(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGrey,
      resizeToAvoidBottomInset: false,
      body: ZoomDrawer(
        borderRadius: 24.0,
        showShadow: true,
        moveMenuScreen: false,
        // angle: 0.0,
        drawerShadowsBackgroundColor: Colors.white,
        menuBackgroundColor: AppColors.darkGrey,
        clipMainScreen: true,
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            spreadRadius: 0.5,
            blurRadius: 5,
          )
        ],
        controller: dashBoardController.zoomDrawerController,
        menuScreen: buildDrawer(),
        androidCloseOnBackTap: true,
        mainScreen: const MainScreen(),
        // mainScreen: const AddNewsTip(),
      ),
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
  DateTime? currentBackPressTime;

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

          // Get.dialog(
          //   CupertinoAlertDialog(
          //     title: const Text("You have not set your profile yet..!!"),
          //     content: const Text("Do you want to set now.? "),
          //     actions: [
          //       MaterialButton(
          //           onPressed: () {
          //             Get.back();
          //           },
          //           child: const Text("No")),
          //       MaterialButton(
          //         onPressed: () {
          //           Get.to(() => const ProfileScreen());
          //         },
          //         child: const Text("Yes"),
          //       ),
          //     ],
          //   ),
          // );
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

    Future.delayed(Duration(seconds: 5), () {
      print("================ ${profilePic.value}");
      if (profilePic.value == null ||
          profilePic.value ==
              'https://wghdfm.s3.amazonaws.com/thumb/default_profile.jpg') {
        AppMethods.tutorialDialog();
      }
    });

    super.initState();
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime ?? DateTime.now()) >
            const Duration(seconds: 2)) {
      currentBackPressTime = now;
      // Fluttertoast.showToast(msg: exit_warning);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Double Tap to exit')));
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeMetrics() {
  //   final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
  //   final newValue = bottomInset > 0.0;
  //   if (newValue != _isKeyboardVisible) {
  //     setState(() {
  //       _isKeyboardVisible = newValue;
  //     });
  //   }
  // }

  // bool? _isKeyboardVisible;

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
    return WillPopScope(
      onWillPop: onWillPop,
      /*() async {
        await onWillPop();
        // Future<bool> b = (exitAppAlertDialog(
        //   context: context,
        //   onExit: () {
        //     exit(0);
        //   },
        //   onCancel: () {
        //     Get.back();
        //     // Get.offAll(() => const DashBoardScreen());
        //     // Get.offNamed(PageRes.dashBoardScreen);
        //     // pushReplaceTo(widget: DashboardUI());
        //   },
        // )) as Future<bool>;
        // return Future.value(false);
      }*/
      child: Scaffold(
        backgroundColor: Colors.grey,
        extendBody: true,
        // extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                dashBoardController.zoomDrawerController.toggle?.call();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              )),
          actions: [
            // IconButton(
            //     onPressed: () {
            //       Get.to(() => NotificationPostDetailsScreen(
            //             postId: "8676",
            //           ));
            //     },
            //     icon: const Icon(Icons.flutter_dash)),
            IconButton(
                onPressed: () {
                  Get.to(() => const SearchScreen());
                },
                icon: const Icon(Icons.search_outlined)),
            IconButton(
                key: notificationButtonKey,
                onPressed: () {
                  Get.to(() => const MessageScreens())?.then((value) {
                    dashBoardController.getNotificationCount(
                        showProcess: false);
                  });
                },
                icon: StreamBuilder(
                    stream: dashBoardController.notificationCount.stream,
                    builder: (context, snapshot) {
                      return Stack(children: [
                        const Icon(Icons.notifications),
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
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "Invite Friends",
                                style: TextStyle(fontSize: 22),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              const Text(
                                  'Write a Email address of your friend that you want to Invite. '),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                color: Colors.white,
                                child: commonTextField(
                                  baseColor: Colors.black,
                                  borderColor: Colors.black,
                                  controller: emailController,
                                  errorColor: Colors.white,
                                  hint: "Email of your friend",
                                  validator: (String? value) {
                                    return (value == null ||
                                            value.isEmpty ||
                                            !value.isEmail)
                                        ? "Please enter valid email"
                                        : null;
                                  },
                                ),
                              ),
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
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                            ],
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
                        content:
                            const Text("Are you sure you want to logout.? "),
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
          title: Text(
            'My Feed(s)',
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).backgroundColor,
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
                    backgroundColor: Colors.black,
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
                    icon: const Icon(Icons.add_circle_outline),
                  );
                } else {
                  return Container(
                    // alignment: Alignment.center,
                    // height: 45,
                    width: Get.width,
                    padding: const EdgeInsets.all(10),
                    margin: EdgeInsets.only(left: 30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: -1,
                              blurRadius: 15),
                        ]),
                    child: StreamBuilder(
                      stream: DashBoardController.uploadingProcess.stream,
                      builder: (context, snapshot) {
                        print(
                            "------ PERCENTAGES ${DashBoardController.uploadingProcess.value}");
                        double value = (double.tryParse(DashBoardController
                                    .uploadingProcess.value) ??
                                0.0) /
                            100;
                        print(" -- value is ${value}");

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "${(value > 0 && value <= 0.9) ? 'Your post is Uploading Now' : 'Your post is Under Progress, you  will be notified soon'}",
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 5),
                            if (value > 0 && value <= 0.9)
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                child: LinearPercentIndicator(
                                  lineHeight: 13.0,
                                  percent: value,
                                  backgroundColor: Colors.grey,
                                  progressColor: Colors.blue,
                                  barRadius: Radius.circular(10),
                                ),
                              )
                            else
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.blue,
                                  minHeight: 13,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.red),
                                ),
                              ),
                          ],
                        );

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
                    ),
                  );
                }
              }),
        )
        // floatingActionButton: ExpandableFab(
        //   fabIcon: Icons.add,
        //   initialOpen: dashBoardController.isFabOpen,
        //   distance: 120.0,
        //   children: [
        //     // ActionButton(
        //     //   onPressed: () {
        //     //     Get.to(()=>AddNewPost());
        //     //     // dashBoardController.friendsModel.value.data?.forEach((element) {
        //     //     //   element?.isSelected.value = false;
        //     //     // });
        //     //     // dashBoardController.fabOnClicks(dashBoardController, 0, context).then((_) {
        //     //     //   dashBoardController.update();
        //     //     // });
        //     //   },
        //     //   icon: const Icon(
        //     //     Icons.upload_file_outlined,
        //     //     semanticLabel: "Post",
        //     //   ),
        //     // ),
        //     // ActionButton(
        //     //   onPressed: () async {
        //     //     dashBoardController.fabOnClicks(dashBoardController, 1, context).then((_) {
        //     //       dashBoardController.update();
        //     //     });
        //     //   },
        //     //   icon: const Icon(
        //     //     Icons.perm_media,
        //     //     semanticLabel: "Photo",
        //     //   ),
        //     // ),
        //     // ActionButton(
        //     //   onPressed: () async {
        //     //     if (await AppMethods().checkPermission()) {
        //     //       // Get a specific camera from the list of available cameras.
        //     //       final cameras = await availableCameras();
        //     //       final firstCamera = cameras.first;
        //     //       Get.to(() => TakePictureScreen(
        //     //             camera: firstCamera,
        //     //           ));
        //     //       // init();
        //     //     }
        //     //   },
        //     //   icon: const Icon(
        //     //     Icons.camera_alt,
        //     //     semanticLabel: "Photo",
        //     //   ),
        //     // ),
        //     // ActionButton(
        //     //   onPressed: () async {
        //     //     if (await AppMethods().checkPermission()) {
        //     //       // Get a specific camera from the list of available cameras.
        //     //       final cameras = await availableCameras();
        //     //       final firstCamera = cameras.first;
        //     //       // Get.to(() => TakePictureScreen(
        //     //       //       camera: firstCamera,
        //     //       //     ));
        //     //       Get.to(() => TakeVideoScreen(
        //     //             camera: firstCamera,
        //     //           ));
        //     //     }
        //     //   },
        //     //   icon: const Icon(
        //     //     Icons.videocam,
        //     //     semanticLabel: "Video",
        //     //   ),
        //     // ),
        //   ],
        // )
        /*SmartFAB(
                margin: EdgeInsets.only(
                  bottom: 60,
                  right: 20,
                ),
                options: PopUpOptions.postOptions,
                optionHandlers: postOptionOnClicks(),
              )*/
        ,
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
      // padding: const EdgeInsets.all(10),
      child: StatefulBuilder(
        builder: (context, StateSetter setStateCustom) {
          return StreamBuilder(
            // ignore: invalid_use_of_protected_member
            // future: loadFeeds(
            //   isFirstTimeLoading: isFirstTime,
            //   page: currentPage,
            // ),
            stream: dashBoardController.dashboardFeeds.stream,
            builder: (context, snapshot) {
              if (dashBoardController.dashboardFeeds == null ||
                  (dashBoardController.dashboardFeeds.isEmpty == true)) {
                return shimmerFeedLoading();
              }

              // if (snapshot.hasData && dashBoardController.currentPage != 0) {
              //   feedScrollController.animateTo(dashBoardController.previousPosition, duration: const Duration(seconds: 3), curve: Curves.fastOutSlowIn);
              // }

              if (snapshot.hasError) {
                return Container(
                  color: Colors.white,
                  child: customText(title: "${snapshot.error}"),
                );
              }

              if ((dashBoardController.dashboardFeeds != null &&
                  dashBoardController.dashboardFeeds.isNotEmpty == true)) {
                return Column(
                  children: [
                    // StreamBuilder(
                    //   stream: dashBoardController.postUploading.stream,
                    //   builder: (context, snapshot) {
                    //     if (!dashBoardController.postUploading.isTrue) {
                    //       return Container(
                    //         margin: const EdgeInsets.all(5),
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(12),
                    //           color: Colors.white,
                    //         ),
                    //         child: Column(
                    //           children: [
                    //             Row(
                    //               mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //               children: [
                    //                 const Text("Your Post is uploading.. \n Please don't close app."),
                    //                 Container(
                    //                   // width: Get.width,
                    //                   decoration: const BoxDecoration(
                    //                     shape: BoxShape.circle,
                    //                     color: Colors.white,
                    //                   ),
                    //                   padding: const EdgeInsets.all(10),
                    //                   child: const CupertinoActivityIndicator(radius: 10),
                    //                 ),
                    //               ],
                    //             ),
                    //
                    //             // LinearPercentIndicator(
                    //             //   width: 140.0,
                    //             //   lineHeight: 14.0,
                    //             //   percent: 0.5,
                    //             //   backgroundColor: Colors.grey,
                    //             //   progressColor: Colors.blue,
                    //             // ),
                    //           ],
                    //         ),
                    //       );
                    //     } else {
                    //       return const SizedBox();
                    //     }
                    //   },
                    // ),

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
                                itemCount:
                                    dashBoardController.dashboardFeeds.length ??
                                        0,
                                itemBuilder: (BuildContext context, int index) {
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

                                  // bool isLiked = await isLiked(feeds![index].id!)
                                  /*(index == feeds!.length)
                                        ?*/

                                  ///CircularProgressIndicator
                                  /*StreamBuilder(
                                            stream: isLoading.stream,
                                            builder: (context, snapshot) => Visibility(
                                                visible: true,
                                                child: CupertinoActivityIndicator(
                                                  color: Colors.black,
                                                )),
                                          )*/

                                  ///Load more button..
                                  // loadMoreItem(onLoad: () {
                                  //     snack(
                                  //       title: "Syncing...",
                                  //       msg: "Loading older post feeds...",
                                  //       icon: Icons.sync,
                                  //       seconds: 13,
                                  //     );
                                  //     setState(() {
                                  //       previousPosition = feedScrollController.position.maxScrollExtent;
                                  //       isFirstTime = false;
                                  //       currentPage++;
                                  //     });
                                  //   })

                                  ///Old Code
                                  /*listItem(
                                      index,
                                      isLoved: dashBoardController.dashboardFeeds[index].getFav!.contains("S") == true,
                                      onFavClick: () {
                                        setState(() {});
                                      },
                                      onLikeClick: () {
                                        setState(() {});
                                      },
                                      onEditClick: () {
                                        setState(() {});
                                      },
                                      onDeleteClick: () {
                                        setState(() {});
                                      },
                                      //isLiked: isLiked,
                                    );*/

                                  // if (index % 10 == 0 && index != 0) {
                                  //   AdsScreen.loadInterstitialAd();
                                  // }
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
                                                            12)),
                                                padding: EdgeInsets.all(20),
                                                margin: EdgeInsets.all(5),
                                                alignment: Alignment.center,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Hello ${userName},",
                                                      style: GoogleFonts.itim(
                                                          fontSize: 17),
                                                    ),
                                                    Text(
                                                      "${getGreeting()}..!",
                                                      style: GoogleFonts.itim(
                                                          fontSize: 25),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),

                                      if (index % 10 == 0 && index != 0)
                                        const AdsScreen(),
                                      // if (index % 2 == 0 && index != 0)  NativeAdWidget(),
                                      Card(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        //margin: EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  ClipOval(
                                                    child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(
                                                                Get.context!)
                                                            .iconTheme
                                                            .color,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        border: Border.all(
                                                          color: Theme.of(
                                                                  Get.context!)
                                                              .iconTheme
                                                              .color!,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      padding: EdgeInsets.zero,
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
                                                            alignment: Alignment
                                                                .center,
                                                            fit: BoxFit.fill,
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
                                                                    Icons.error,
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
                                                        text:
                                                            dashBoardController
                                                                .dashboardFeeds[
                                                                    index]
                                                                .name,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15.0,
                                                          height: 1.8,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                              text: "is with ",
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
                                                          ...dashBoardController
                                                                  .dashboardFeeds[
                                                                      index]
                                                                  .allTagUserList
                                                                  ?.map(
                                                                (e) {
                                                                  int indexs = dashBoardController
                                                                          .dashboardFeeds[
                                                                              index]
                                                                          .allTagUserList
                                                                          ?.indexOf(
                                                                              e) ??
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
                                                                                                fit: BoxFit.fill,
                                                                                                imageUrl: "${dashBoardController.dashboardFeeds[index].allTagUserList?[listIndex].profileImg}",
                                                                                                // placeholder: (context, url) {
                                                                                                //   return Image.asset(
                                                                                                //     "assets/logo.png",
                                                                                                //     scale: 5.0,
                                                                                                //   );
                                                                                                // },
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
                                                                        color: Colors
                                                                            .black,
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
                                                                              if (e.profileId?.isNotEmpty == true) {
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
                                                    offset: const Offset(0, 40),
                                                    icon: const Icon(
                                                      Icons.more_horiz,
                                                    ),
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15.0))),
                                                    itemBuilder:
                                                        (BuildContext context) {
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
                                                            value: PopUpOptions
                                                                .edit,
                                                            child: Text(
                                                                PopUpOptions
                                                                    .edit),
                                                          ),
                                                        if (isOwn)
                                                          const PopupMenuItem<
                                                              String>(
                                                            value: PopUpOptions
                                                                .delete,
                                                            child: Text(
                                                                PopUpOptions
                                                                    .delete),
                                                          ),
                                                      ];
                                                      // return PopUpOptions.feedPostMoreOptions.map((String choice) {
                                                      //       return PopupMenuItem<String>(
                                                      //         value: choice,
                                                      //         child: Text(choice),
                                                      //       );
                                                      // }).toList();
                                                    },
                                                    onSelected: (value) {
                                                      switch (value) {
                                                        case PopUpOptions
                                                              .report:
                                                          reportPost(
                                                              "${dashBoardController.dashboardFeeds[index].id}");
                                                          break;
                                                        case PopUpOptions.edit:
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
                                                      // child: RichText(
                                                      //   text: TextSpan(
                                                      //     text: dashBoardController
                                                      //         .dashboardFeeds[
                                                      //             index]
                                                      //         .status!,
                                                      //     style:
                                                      //         const TextStyle(
                                                      //       color: Colors
                                                      //           .black45,
                                                      //       fontSize: 15.0,
                                                      //       height: 1.8,
                                                      //       fontWeight:
                                                      //           FontWeight
                                                      //               .normal,
                                                      //       decoration:
                                                      //           TextDecoration
                                                      //               .none,
                                                      //     ),
                                                      //   ),
                                                      // ),
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
                                                                          FontWeight
                                                                              .normal,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none,
                                                                    ),
                                                                    recognizer:
                                                                        TapGestureRecognizer()
                                                                          ..onTap =
                                                                              () {
                                                                            Get.to(() =>
                                                                                GroupDetailsScreen(
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
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      // height: 200,
                                                      // width: 400,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        // image: DecorationImage(image:),
                                                      ),
                                                      child: CachedNetworkImage(
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
                                            customImageView(dashBoardController
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
                                                                .then((value) {
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
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
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
                                                        // checkPostLikeStatus(
                                                        //   "${dashBoardController.dashboardFeeds?[index].id}",
                                                        // ).then((haveYouLiked) {
                                                        //   if (!haveYouLiked) {
                                                        //     setAsLiked(
                                                        //       "${dashBoardController.dashboardFeeds?[index].id!}",
                                                        //     );
                                                        //   }
                                                        // });

                                                        await setAsLiked(
                                                            postId:
                                                                "${dashBoardController.dashboardFeeds[index].id}",
                                                            postOwnerId:
                                                                "${dashBoardController.dashboardFeeds[index].ownerId}",
                                                            isInsertLike:
                                                                dashBoardController
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
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 5),
                                                        height: 20,
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
                                                            Image.asset(
                                                              isLiked
                                                                  ? "assets/icon/liked_image.png"
                                                                  : "assets/icon/like_img.png",
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
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        LoginModel userDetails =
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
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 5),
                                                        height: 20,
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
                                                              Icons
                                                                  .chat_bubble_outline,
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
                                                        if (value == "Groups") {
                                                          dashBoardController
                                                              .sharePostToGroup(
                                                                  postId:
                                                                      "${dashBoardController.dashboardFeeds[index].id}",
                                                                  ownerID:
                                                                      userId);
                                                        }
                                                        if (value == "Other") {
                                                          AppMethods().share(
                                                              "${EndPoints.socialSharePostUrl}${dashBoardController.dashboardFeeds[index].id}");
                                                        }
                                                      },
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                      position:
                                                          PopupMenuPosition
                                                              .under,
                                                      icon: const Icon(
                                                          Icons.share),
                                                      itemBuilder: (context) {
                                                        return [
                                                          PopupMenuItem(
                                                              value: "Timeline",
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
                                                    Alignment.bottomRight,
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  child: customText(
                                                      title:
                                                          "${dashBoardController.dashboardFeeds[index].timeStamp}",
                                                      fs: 10),
                                                )),
                                            if (dashBoardController
                                                    .dashboardFeeds[index]
                                                    .latestComments
                                                    ?.isNotEmpty ==
                                                true)
                                              Column(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Comments",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ).paddingOnly(left: 10),
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    // reverse: true,
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
                                                              color: Theme.of(Get
                                                                      .context!)
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
                                                                    .all(5),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            child: ClipOval(
                                                              child:
                                                                  CachedNetworkImage(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                fit:
                                                                    BoxFit.fill,
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
                                                                        color: Colors
                                                                            .white),
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
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              ],
                                                            ),
                                                          ),
                                                          // Text("${listLength - (listLength >= 3 ? 3 : listLength >= 2 ? 2 : 0) + indexOfComment}"),
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
                                              color: Colors.white,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 9,
                                                    child: commonTextField(
                                                      readOnly: false,
                                                      focusNode: focusNode,
                                                      leading: IconButton(
                                                        icon: const Icon(
                                                            Icons
                                                                .emoji_emotions_outlined,
                                                            size: 25),
                                                        onPressed: () async {
                                                          emojiShowing.toggle();
                                                          if (emojiShowing
                                                              .isFalse) {
                                                            print(" ooo");
                                                            // FocusScope.of(context).requestFocus(focusNode);
                                                          }
                                                          // setState(() {});
                                                        },
                                                      ),
                                                      hint: 'Write Comment',
                                                      isLabelFloating: false,
                                                      controller:
                                                          dashBoardController
                                                              .dashboardFeeds[
                                                                  index]
                                                              .commentTextController,
                                                      borderColor:
                                                          Theme.of(Get.context!)
                                                              .primaryColor,
                                                      baseColor:
                                                          Theme.of(Get.context!)
                                                              .colorScheme
                                                              .secondary,
                                                      isLastField: true,
                                                      obscureText: false,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.send),
                                                    onPressed: () async {
                                                      print(
                                                          ":: ${dashBoardController.dashboardFeeds[index].latestComments?.length}");
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                      EndPoints.selectedPostId =
                                                          "${dashBoardController.dashboardFeeds[index].id}";

                                                      if (dashBoardController
                                                              .dashboardFeeds[
                                                                  index]
                                                              .commentTextController
                                                              ?.text
                                                              .trim()
                                                              .isNotEmpty ==
                                                          true) {
                                                        LoginModel userDetails =
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
                                                                method: APIService
                                                                    .postMethod,
                                                                formDatas:
                                                                    dio.FormData.fromMap(
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
                                                                          .dashboardFeeds[
                                                                              index]
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
                                                                      img: userDetails
                                                                              .img ??
                                                                          "",
                                                                      date: DateTime
                                                                              .now()
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
                                                                  if (dashBoardController
                                                                              .dashboardFeeds[
                                                                                  index]
                                                                              .ownerId !=
                                                                          userDetails
                                                                              .id &&
                                                                      dashBoardController
                                                                              .dashboardFeeds[index]
                                                                              .ownerId !=
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
                                                      height: Get.height * 0.4,
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
                            child: const CupertinoActivityIndicator(radius: 10),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ],
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
