import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:wghdfm_java/modules/ads_module/ads_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/screen/comment/comment_screen.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_binding.dart';
import 'package:wghdfm_java/utils/app_texts.dart';
import 'package:wghdfm_java/utils/lists.dart';

import '../../../common/commons.dart';
import '../../../model/feed_res_obj.dart';
import '../../../screen/dashboard/dashboard_api/add_fav_post_api.dart';
import '../../../screen/dashboard/dashboard_api/add_to_time_line_api.dart';
import '../../../screen/dashboard/dashboard_api/delete_post_api.dart';
import '../../../screen/dashboard/dashboard_api/report_post_api.dart';
import '../../../screen/dashboard/widgets/edit_bottom_sheet.dart';
import '../../../screen/dashboard/widgets/feed_with_load_more.dart';
import '../../../utils/app_methods.dart';
import '../../../utils/endpoints.dart';
import '../../../utils/get_links_text.dart';
import '../../../utils/shimmer_utils.dart';
import '../../auth_module/model/login_model.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  final bool? showTutorial;

  const ProfileScreen({Key? key, this.showTutorial}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final dashBoardController = Get.put(DashBoardController());
  final profileController = Get.put(ProfileController());
  var args = Get.arguments;
  final feedScrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState

    profileController.getProfileFeed(
        profileId: userId, isFirstTimeLoading: true);
    profileController.getProfileData(profileID: userId);
    feedScrollController.addListener(() async {
      print(">>>> pixels ${feedScrollController.position.pixels}");
      print(
          ">>>> maxScrollExtent ${feedScrollController.position.maxScrollExtent * 0.70}");
      print(">>>> maxScrollExtent ${profileController.isProfileLoading.value}");
      if (feedScrollController.position.pixels >=
              feedScrollController.position.maxScrollExtent * 0.70 &&
          profileController.isProfileLoading.value == false) {
        profileController.currentPage++;
        await profileController.getProfileFeed(
            profileId: userId,
            isFirstTimeLoading: false,
            page: profileController.currentPage);
      }
    });

    AppMethods().checkTutorial(callBack: () {
      if (AppMethods.showTutorialForProfile.isTrue) {
        getTutorial();
      }
    });

    super.initState();
  }

  List<TargetFocus> targets = [];
  GlobalKey addProfileKey = GlobalKey();
  GlobalKey clickAddProfileButtonKey = GlobalKey();
  GlobalKey profileAddedKey = GlobalKey();

  TutorialCoachMark? tutorialCoachMark;

  void showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      hideSkip: true,
      colorShadow: Colors.black,
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
        AppMethods().hideTutorialForProfile();
        print("finish");
      },
    );
    Future.delayed(Duration(milliseconds: 200),
        () => tutorialCoachMark?.show(context: context));
  }

  getTutorial() {
    targets.add(
        TargetFocus(identify: "Target 1", keyTarget: addProfileKey, contents: [
      TargetContent(
          align: ContentAlign.bottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              const Text(
                "Set your profile",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Set your photo and complete your profile.",
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
        identify: "Target 2",
        keyTarget: clickAddProfileButtonKey,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 50),
                  const Text(
                    "Add profile",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Click on the icon and select your profile which you want to set.",
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
        keyTarget: profileAddedKey,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 50),
                  const Text(
                    "Profile image set successfully.",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "You can see your profile image here..",
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          actions: [
            PopupMenuButton<String>(
              offset: const Offset(0, 40),
              icon: const Icon(
                Icons.more_vert,
              ),
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: PopUpOptions.changePassword,
                    child: Text(
                      "Change Password",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: PopUpOptions.delete,
                    child: Text(
                      "Delete Account",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                switch (value) {
                  case PopUpOptions.changePassword:
                    changePasswordDialog();
                    break;
                  case PopUpOptions.delete:
                    deleteAccountDialog();
                    break;
                  case PopUpOptions.logout:
                    SessionManagement.logoutUser();
                    break;
                }
              },
            )
          ],
          title: Text(
            'My Profile',
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        body: feedsWithLoadMore(),
      ),
    );
  }

  Widget feedsWithLoadMore() {
    return Column(children: [
      Expanded(
        child: StreamBuilder(
          // future: loadProfileFeeds(
          //     isFirstTimeLoading: p.isFirstTime,
          //     page: p.currentPage,
          //     profileId: p.profileId),
          stream: profileController.profileFeeds?.stream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (profileController.profileFeeds == null) {
              return shimmerFeedLoading();
            }

            if (snapshot.hasError) {
              return Container(
                color: Colors.white,
                child: customText(title: "${snapshot.error}"),
              );
            }
            //return buildList(allFeeds: feeds);
            return profileController.profileFeeds?.isNotEmpty == true
                ? RefreshIndicator(
                    onRefresh: () async {
                      await profileController.getProfileFeed(
                          profileId: userId, isFirstTimeLoading: true);
                    },
                    child: ListView.builder(
                      controller: feedScrollController,
                      shrinkWrap: true,
                      cacheExtent: 5000,
                      physics: const ClampingScrollPhysics(),
                      itemCount: profileController.profileFeeds?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        //bool isLiked = await isLiked(feeds![index].id!)

                        return profileFeed(
                          index,
                          // isLoved: profileController.profileFeeds?[index].getFav!.contains("S") == true,
                          isLoved:
                              profileController.profileFeeds?[index].isFav == 1,
                          isLiked:
                              profileController.profileFeeds?[index].isLike ==
                                  1,
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
                        );
                      },
                    ),
                  )
                : Center(
                    child:
                        customText(title: 'No Feeds', txtColor: Colors.white),
                  );
          },
        ),
      ),
      StreamBuilder(
        stream: profileController.isProfileLoading.stream,
        builder: (context, snapshot) {
          if (profileController.isProfileLoading.isTrue) {
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
            return SizedBox();
          }
        },
      ),
    ]);
  }

  Widget profileFeed(
    int index, {
    VoidCallback? onFavClick,
    VoidCallback? onLikeClick,
    bool isLoved = false,
    bool isLiked = false,
    VoidCallback? onEditClick,
    VoidCallback? onDeleteClick,
  }) {
    bool isOwn = isOwnPost("${profileController.profileFeeds?[index].ownerId}");
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (index == 0)
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(5)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Builder(
                // ignore: invalid_use_of_protected_member
                builder: (context) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return shimmerProfileLoading();
                  // }

                  // if (snapshot.hasError) {
                  //   return Container(
                  //     color: Colors.white,
                  //     child: customText(title: "${snapshot.error}"),
                  //   );
                  // }

                  return Stack(
                    fit: StackFit.loose,
                    // alignment: Alignment.center,
                    children: [
                      Center(
                        child: StreamBuilder(
                            stream: coverPic.stream,
                            builder: (context, snapshot) {
                              return CachedNetworkImage(
                                alignment: Alignment.center,
                                fit: BoxFit.cover,
                                imageUrl: coverPic.value,
                                placeholder: (context, url) => Container(
                                  padding: const EdgeInsets.all(3),
                                  child: Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              );
                            }),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          color: Colors.white.withOpacity(0.4),
                          height: 30,
                          child: TextButton.icon(
                              onPressed: () async {
                                //todo:
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                  allowMultiple: false,
                                  allowCompression: true,
                                );

                                if (result != null) {
                                  File file =
                                      File("${result.files.first.path}");
                                  LoginModel userDetails =
                                      await SessionManagement.getUserDetails();
                                  userId = userDetails.id;

                                  profileController.updateProfileImage(
                                      userIdCurrent: userId,
                                      image: file,
                                      isProfile: false);
                                }
                                // dashBoardController.openImageCaptureOptions(fromGallery: () {
                                //   dashBoardController.uploadImageFromGallery().then((_) {
                                //     dashBoardController.update();
                                //     profileController.update();
                                //   });
                                // }, fromCamera: () {
                                //   dashBoardController.captureImage().then((_) {
                                //     dashBoardController.update();
                                //     dashBoardController.update();
                                //   });
                                // });
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 15,
                              ),
                              label: const Text(
                                "Edit Cover",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 13),
                              )),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                                key: profileAddedKey,
                                width: 100,
                                height: 100,
                                child: Stack(children: [
                                  ClipOval(
                                    child: Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          color: Theme.of(Get.context!)
                                              .iconTheme
                                              .color,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                            color: Theme.of(Get.context!)
                                                .iconTheme
                                                .color!,
                                            width: 1,
                                          ),
                                        ),
                                        margin: const EdgeInsets.all(5),
                                        padding: EdgeInsets.zero,
                                        child: ClipOval(
                                          child: StreamBuilder(
                                              stream: profilePic.stream,
                                              builder: (context, snapshot) {
                                                return CachedNetworkImage(
                                                  alignment: Alignment.center,
                                                  fit: BoxFit.cover,
                                                  imageUrl: profilePic.value,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    child: shimmerMeUp(
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary),
                                                    )),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                );
                                              }),
                                        )),
                                  ),
                                  Align(
                                    key: addProfileKey,
                                    alignment: Alignment.bottomRight,
                                    child: InkWell(
                                      onTap: () async {
                                        ///Edit image here...
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.image,
                                          allowMultiple: false,
                                          allowCompression: true,
                                        );

                                        if (result != null) {
                                          File file = File(
                                              "${result.files.first.path}");
                                          LoginModel userDetails =
                                              await SessionManagement
                                                  .getUserDetails();
                                          userId = userDetails.id;
                                          profileController.updateProfileImage(
                                              userIdCurrent: userId,
                                              image: file,
                                              isProfile: true);
                                        }
                                      },
                                      child: Container(
                                        key: clickAddProfileButtonKey,
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black),
                                        child: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  )
                                ])),
                            const SizedBox(
                              width: 10,
                            ),
                            StreamBuilder(
                                stream: userName.stream,
                                builder: (context, snapshot) {
                                  return Container(
                                    // width: Get.width,
                                    color: Colors.white.withOpacity(0.5),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      userName.value,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        height: 1,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        if (index % 10 == 0 && index != 0)
          kDebugMode ? Container() : const AdsScreen(),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          //margin: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ClipOval(
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
                        child: InkWell(
                          onTap: () {
                            // Get.toNamed(PageRes.profileScreen, arguments: {"profileId": profileController.profileFeeds?[index].ownerId!, "isSelf": isOwn});
                          },
                          child: ClipOval(
                            child: CachedNetworkImage(
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              imageUrl:
                                  "${profileController.profileFeeds?[index].profilePic}",
                              // placeholder: (context, url) {
                              //   return Image.asset(
                              //     "assets/logo.png",
                              //     scale: 5.0,
                              //   );
                              // },
                              progressIndicatorBuilder:
                                  (BuildContext, String, DownloadProgress) {
                                return const Center(
                                    child: CupertinoActivityIndicator());
                              },
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error, color: Colors.white),
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
                          text: profileController.profileFeeds?[index].name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            height: 1.8,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              // text: "",
                              text: profileController.profileFeeds?[index]
                                          .toUserIdDetails !=
                                      null
                                  ? " shared to ${profileController.profileFeeds?[index].toUserIdDetails?.firstname ?? "Guest"} ${profileController.profileFeeds?[index].toUserIdDetails?.lastname ?? ""} "
                                  : "",
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 15.0,
                                height: 1.8,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isOwn)
                      PopupMenuButton<String>(
                        offset: const Offset(0, 40),
                        icon: const Icon(
                          Icons.more_horiz,
                        ),
                        itemBuilder: (BuildContext context) {
                          return PopUpOptions.feedPostMoreOptions
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                        onSelected: (value) {
                          switch (value) {
                            case PopUpOptions.edit:
                              editStatusBottomSheet(
                                  profileController.profileFeeds?[index] ??
                                      PostModelFeed(), onEdit: () {
                                onEditClick!();
                              });
                              break;
                            case PopUpOptions.delete:
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text(
                                          'Are you sure you want to delete this post?'),
                                      content: Text(
                                          'This will delete this post permanently'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                                context); //close Dialog
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              deletePost(
                                                  postId:
                                                      "${profileController.profileFeeds?[index].id}",
                                                  callBack: () {
                                                    profileController
                                                        .profileFeeds
                                                        ?.removeAt(index);
                                                    profileController
                                                        .profileFeeds
                                                        ?.refresh();
                                                  }).then((value) {
                                                onDeleteClick!();
                                              });
                                              //action code for "Yes" button
                                            },
                                            child: Text(
                                              'Delete',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )),
                                      ],
                                    );
                                  });

                              break;
                          }
                        },
                      )
                  ],
                ),
              ),
              if (profileController.profileFeeds?[index].status != null &&
                  profileController.profileFeeds?[index].status != '')
                Container(
                  margin: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 8,
                        child: getLinkText(
                            text:
                                profileController.profileFeeds?[index].status ??
                                    ""),
                        // child: RichText(
                        //   text: TextSpan(
                        //     text: profileController.profileFeeds?[index].status!,
                        //     style: const TextStyle(
                        //       color: Colors.black45,
                        //       fontSize: 15.0,
                        //       height: 1.8,
                        //       fontWeight: FontWeight.normal,
                        //       decoration: TextDecoration.none,
                        //     ),
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                ),
              // Text(feeds![index].status.toString()),
              customImageView(profileController.profileFeeds?[index]),
              Container(
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: IconButton(
                          onPressed: () {
                            if (!isLoved) {
                              setAsFav(
                                postId:
                                    "${profileController.profileFeeds?[index].id}",
                              ).then((value) {
                                if (profileController
                                        .profileFeeds?[index].isFav ==
                                    0) {
                                  profileController.profileFeeds?[index].isFav =
                                      1;
                                } else {
                                  profileController.profileFeeds?[index].isFav =
                                      0;
                                }
                                setState(() {});
                              });
                            } else {
                              setAsUnFav(
                                      "${profileController.profileFeeds?[index].id}")
                                  .then((value) {
                                if (profileController
                                        .profileFeeds?[index].isFav ==
                                    0) {
                                  profileController.profileFeeds?[index].isFav =
                                      1;
                                } else {
                                  profileController.profileFeeds?[index].isFav =
                                      0;
                                }
                                setState(() {});
                              });
                            }
                          },
                          icon: Icon(
                            isLoved ? Icons.favorite : Icons.favorite_border,
                            color: isLoved
                                ? Colors.red
                                : Theme.of(Get.context!).iconTheme.color,
                          )),
                    ),
                    /*Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          checkPostLikeStatus(
                            "${profileController.profileFeeds?[index].id}",
                          ).then((haveYouLiked) {
                            if (!haveYouLiked) {
                              setAsLiked(
                                postId: "${profileController.profileFeeds?[index].id!}",
                              );
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          height: 20,
                          child: Image.asset(
                            isLiked ? "assets/icon/like_feel_img.png" : "assets/icon/like_img.png",
                            color: isLiked ? Colors.blue : Theme.of(Get.context!).iconTheme.color,
                          ),
                        ),
                      ),
                    ),*/
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
                                  "${profileController.profileFeeds?[index].id}",
                              callBack: (commentCount) {
                                if (profileController
                                        .profileFeeds?[index].isLike ==
                                    0) {
                                  profileController
                                      .profileFeeds?[index].isLike = 1;
                                } else {
                                  profileController
                                      .profileFeeds?[index].isLike = 0;
                                }
                                profileController.profileFeeds?[index]
                                    .countLike = "$commentCount";
                                setState(() {});
                              });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          height: 20,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                isLiked
                                    ? "assets/icon/liked_image.png"
                                    : "assets/icon/like_img.png",
                                color: isLiked
                                    ? Colors.blue
                                    : Theme.of(Get.context!).iconTheme.color,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                "${profileController.profileFeeds?[index].countLike}",
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
                              print("post id: ${profileController.profileFeeds?[index].id!}");
                            }

                            debugPrint("Before: ${profileController.profileFeeds?[index].id!}");
                            EndPoints.selectedPostId = "${profileController.profileFeeds?[index].id}";
                            Get.to(() => CommentScreen(postId: EndPoints.selectedPostId));
                          },
                          icon: const Icon(Icons.messenger_outline)),
                    ),*/
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () async {
                          LoginModel userDetails =
                              await SessionManagement.getUserDetails();
                          if (kDebugMode) {
                            print("user id: ${userDetails.id}");
                            print(
                                "post id: ${profileController.profileFeeds?[index].id}");
                          }

                          debugPrint(
                              "Before: ${profileController.profileFeeds?[index].id}");
                          EndPoints.selectedPostId =
                              "${profileController.profileFeeds?[index].id}";
                          Get.to(() => CommentScreen(
                                    isFrom: AppTexts.profile,
                                    index: index,
                                    postId: EndPoints.selectedPostId,
                                    postOwnerId:
                                        "${profileController.profileFeeds?[index].ownerId}",
                                  ))
                              ?.then((value) =>
                                  profileController.profileFeeds?.refresh());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          height: 20,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                // color: isLiked ? Colors.blue : Theme.of(Get.context!).iconTheme.color,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                "${profileController.profileFeeds?[index].countComment}",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                          onPressed: () {
                            addToTimeline(
                                "${profileController.profileFeeds?[index].id}");
                          },
                          icon: const Icon(Icons.add_box)),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                          onPressed: () {
                            AppMethods().share(
                                "${EndPoints.socialSharePostUrl}${profileController.profileFeeds?[index].id}");
                          },
                          icon: const Icon(Icons.share)),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                          onPressed: () {
                            reportPost(
                                "${profileController.profileFeeds?[index].id}");
                          },
                          icon: const Icon(Icons.report_problem)),
                    ),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: customText(
                        title:
                            "${profileController.profileFeeds?[index].timeStamp}",
                        fs: 10),
                  )),
              if (profileController
                      .profileFeeds?[index].latestComments?.isNotEmpty ==
                  true)
                Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Comments"),
                    ).paddingOnly(left: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: profileController
                              .profileFeeds?[index].latestComments?.length ??
                          0,
                      itemBuilder: (context, indexOfComment) => Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
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
                                imageUrl:
                                    "https://wghdfm.s3.amazonaws.com/thumb/${profileController.profileFeeds?[index].latestComments?[indexOfComment]?.img}",
                                progressIndicatorBuilder:
                                    (BuildContext, String, DownloadProgress) {
                                  return const Center(
                                      child: CupertinoActivityIndicator());
                                },
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error,
                                        color: Colors.white),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  "${profileController.profileFeeds?[index].latestComments?[indexOfComment]?.firstname} ${profileController.profileFeeds?[index].latestComments?[indexOfComment]?.lastname}"),
                              Text(
                                  "${profileController.profileFeeds?[index].latestComments?[indexOfComment]?.comment}"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
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

  changePasswordDialog() {
    TextEditingController oldPassContoller = TextEditingController();
    TextEditingController newPassContoller = TextEditingController();
    TextEditingController confirmPassContoller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: StatefulBuilder(
        builder: (context, StateSetter setStateSearch) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Text(
                  "Change Password",
                  style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  color: Colors.white,
                  child: commonTextField(
                    baseColor: Colors.black,
                    borderColor: Colors.black,
                    controller: oldPassContoller,
                    errorColor: Colors.white,
                    hint: "Old password",
                    validator: (String? value) {
                      return (value == null || value.isEmpty)
                          ? "Please enter valid password"
                          : null;
                    },
                    // onChanged: (String? value) {
                    //   setStateSearch(() {});
                    // }
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: commonTextField(
                    baseColor: Colors.black,
                    borderColor: Colors.black,
                    controller: newPassContoller,
                    errorColor: Colors.white,
                    hint: "New password",
                    validator: (String? value) {
                      return (value == null || value.isEmpty)
                          ? "Please enter valid password"
                          : null;
                    },
                    // onChanged: (String? value) {
                    //   setStateSearch(() {});
                    // }
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: commonTextField(
                    baseColor: Colors.black,
                    borderColor: Colors.black,
                    controller: confirmPassContoller,
                    errorColor: Colors.white,
                    hint: "Confirm password",
                    validator: (String? value) {
                      return (value == null ||
                              value.isEmpty ||
                              newPassContoller.text != value)
                          ? "Please enter valid password"
                          : null;
                    },
                    // onChanged: (String? value) {
                    //   setStateSearch(() {});
                    // }
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await profileController.changePassword(
                          oldPassword: oldPassContoller.text,
                          newPassword: newPassContoller.text,
                          callBack: () {});
                    }
                  },
                  child: Text(
                    "Change Password",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
              ],
            ).paddingSymmetric(horizontal: 10),
          );
        },
      ),
    ));
  }

  deleteAccountDialog() {
    TextEditingController confirmPassContoller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: StatefulBuilder(
        builder: (context, StateSetter setStateSearch) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Text(
                  "Delete Password",
                  style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Text(
                  'Are you sure you want to delete your account?, you will lose all your data ',
                  style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  color: Colors.white,
                  child: commonTextField(
                    baseColor: Colors.black,
                    borderColor: Colors.black,
                    controller: confirmPassContoller,
                    errorColor: Colors.white,
                    hint: "Confirm password",
                    validator: (String? value) {
                      return (value == null || value.isEmpty)
                          ? "Please enter valid password"
                          : null;
                    },
                    // onChanged: (String? value) {
                    //   setStateSearch(() {});
                    // }
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await profileController.deleteAccount(
                          password: confirmPassContoller.text,
                          callBack: () {
                            SessionManagement.logoutUser();
                          });
                    }
                  },
                  child: Text(
                    "Delete",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
              ],
            ).paddingSymmetric(horizontal: 10),
          );
        },
      ),
    ));
  }
}
