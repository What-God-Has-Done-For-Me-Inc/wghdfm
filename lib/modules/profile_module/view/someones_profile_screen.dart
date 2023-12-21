import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/modules/ads_module/ads_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/profile_module/view/add_post_someones_profile.dart';
import 'package:wghdfm_java/screen/comment/comment_screen.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_texts.dart';
import 'package:wghdfm_java/utils/get_links_text.dart';
import 'package:wghdfm_java/utils/lists.dart';

import '../../../common/commons.dart';
import '../../../model/feed_res_obj.dart';
import '../../../screen/dashboard/dashboard_api/add_fav_post_api.dart';
import '../../../screen/dashboard/dashboard_api/add_to_time_line_api.dart';
import '../../../screen/dashboard/dashboard_api/delete_post_api.dart';
import '../../../screen/dashboard/dashboard_api/report_post_api.dart';
import '../../../screen/dashboard/widgets/edit_bottom_sheet.dart';
import '../../../screen/dashboard/widgets/feed_with_load_more.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_methods.dart';
import '../../../utils/endpoints.dart';
import '../../../utils/shimmer_utils.dart';
import '../../auth_module/model/login_model.dart';
import '../../notification_module/controller/notification_handler.dart';
import '../controller/profile_controller.dart';

class SomeoneProfileScreen extends StatefulWidget {
  final String profileID;

  const SomeoneProfileScreen({Key? key, required this.profileID}) : super(key: key);

  @override
  State<SomeoneProfileScreen> createState() => _SomeoneProfileScreenState();
}

class _SomeoneProfileScreenState extends State<SomeoneProfileScreen> {
  final dashBoardController = Get.put(DashBoardController());
  final profileController = Get.put(ProfileController());
  var args = Get.arguments;
  final feedScrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    profileController.currentPage = 0;

    profileController.getSomeonesProfileData(profileID: widget.profileID);
    profileController.getProfileFeed(profileId: widget.profileID, isFirstTimeLoading: true, page: profileController.currentPage);
    pagination();
    super.initState();
  }

  pagination() {
    feedScrollController.addListener(() async {
      print(">>>> pixels ${feedScrollController.position.pixels}");
      print(">>>> maxScrollExtent ${feedScrollController.position.maxScrollExtent * 0.70}");
      print(">>>> maxScrollExtent ${profileController.isProfileLoading.value}");
      if (feedScrollController.position.pixels >= feedScrollController.position.maxScrollExtent * 0.70 && profileController.isProfileLoading.value == false) {
        profileController.currentPage++;
        await profileController.getProfileFeed(profileId: widget.profileID, isFirstTimeLoading: false, page: profileController.currentPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          extendBody: true,
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            title: Text(
              'Friend\'s Profile',
              style: GoogleFonts.montserrat(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            actions: [
              StreamBuilder(
                  stream: profileController.someonesProfileData.stream,
                  builder: (context, snapshot) {
                    return StatefulBuilder(
                      builder: (context, StateSetter setStateCustom) {
                        return profileController.someonesProfileData.value.blockStatus == "0"
                            ? TextButton(
                                onPressed: () {
                                  profileController.blockUser(
                                      userID: widget.profileID,
                                      callBack: () {
                                        profileController.someonesProfileData.value.blockStatus = "1";
                                        setStateCustom(() {});
                                      });
                                },
                                child: Text("Block"),
                              )
                            : TextButton(
                                onPressed: () {
                                  profileController.unBlockUser(
                                      userID: widget.profileID,
                                      callBack: () {
                                        profileController.someonesProfileData.value.blockStatus = "0";
                                        setStateCustom(() {});
                                      });
                                },
                                child: Text("Unblock"),
                              );
                      },
                    );
                  }),

              /*PopupMenuButton<String>(
              offset: const Offset(0, 40),
              icon: const Icon(
                Icons.more_vert,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: "BlockUnblock",
                    child: profileController.someonesProfileData.value.blockStatus == "0" ? Text("Block") : Text("Unblock"),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == "BlockUnblock") {
                  if (profileController.someonesProfileData.value.blockStatus == "0") {
                    profileController.blockUser(
                        userID: widget.profileID,
                        callBack: () {
                          profileController.someonesProfileData.value.blockStatus = "1";
                        });
                  } else {
                    profileController.unBlockUser(
                        userID: widget.profileID,
                        callBack: () {
                          profileController.someonesProfileData.value.blockStatus = "0";
                        });
                  }
                }
              },
            )*/
            ],
            elevation: 0,
            centerTitle: true,
            iconTheme: Theme.of(context).iconTheme,
            backgroundColor: Theme.of(context).backgroundColor,
          ),
          body: feedsWithLoadMore(),
          floatingActionButton: StreamBuilder(
            stream: DashBoardController.uploadingProcess.stream,
            builder: (context, snapshot) => StreamBuilder(
                stream: dashBoardController.postUploading.stream,
                builder: (context, snapshot) {
                  if (DashBoardController.uploadingProcess.value == "0.0") {
                    return FloatingActionButton(
                      backgroundColor: Colors.black,
                      onPressed: () {
                        // Get.to(() => const AddNewPost());
                        // Get.to(() => const AddPost());
                        Get.to(() => SomeonesAddPost(
                              userId: "${widget.profileID}",
                              name: "${profileController.someonesProfileData.value.firstname} ${profileController.someonesProfileData.value.lastname}",
                            ));
                      },
                      child: const Icon(Icons.add),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white, boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: -1, blurRadius: 15),
                      ]),
                      child: StreamBuilder(
                        stream: DashBoardController.uploadingProcess.stream,
                        builder: (context, snapshot) {
                          print("------ PERCENTAGES ${DashBoardController.uploadingProcess.value}");
                          double value = (double.tryParse(DashBoardController.uploadingProcess.value) ?? 0.0) / 100;
                          print(" -- value is ${value}");
                          return CircularPercentIndicator(
                            radius: 25.0,
                            lineWidth: 5.0,
                            header: Text(
                              (value > 0 && value <= 0.9) ? "Uploading" : "Getting Ready ",
                              style: GoogleFonts.roboto(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            // fillColor: Colors.white,
                            circularStrokeCap: CircularStrokeCap.round,
                            percent: value,
                            center: Text("${DashBoardController.uploadingProcess.value}%",
                                style: GoogleFonts.roboto(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                )),
                            progressColor: Colors.green,
                          );
                        },
                      ),
                    );
                  }
                }),
          )
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          // Get.to(() => SomeonesAddPost(
          //       userId: "${widget.profileID}",
          //       name: "${profileController.someonesProfileData.value.firstname} ${profileController.someonesProfileData.value.lastname}",
          //     ));
          //   },
          // ),
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
                      await profileController.getProfileFeed(profileId: userId, isFirstTimeLoading: true);
                    },
                    child: ListView.builder(
                      controller: feedScrollController,
                      shrinkWrap: true,
                      cacheExtent: 5000,
                      physics: const ClampingScrollPhysics(),
                      itemCount: profileController.profileFeeds?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        // print("Dp obj::::::${profileController.profileFeeds?[index].toUserIdDetails?.lastname}");
                        //bool isLiked = await isLiked(feeds![index].id!)
                        return profileFeed(
                          index,
                          // isLoved: profileController.profileFeeds?[index].getFav!.contains("S") == true,
                          isLoved: profileController.profileFeeds?[index].isFav == 1,
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
                    child: customText(title: 'No Feeds', txtColor: Colors.white),
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
            shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(5)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: StreamBuilder(
                stream: profileController.someonesProfileData.stream,
                // ignore: invalid_use_of_protected_member
                builder: (context, snapshot) {
                  if (profileController.someonesProfileData.value == null) {
                    return shimmerProfileLoading();
                  }

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
                                imageUrl: "${profileController.someonesProfileData.value.cover}",
                                placeholder: (context, url) => Container(
                                  padding: const EdgeInsets.all(3),
                                  child: Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                                      ),
                                    ),
                                  ),
                                ),
                                // errorWidget: (context, url, error) => const Icon(Icons.error),
                                errorWidget: (context, url, error) => Image.asset(AppImages.logoImage),
                              );
                            }),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: ClipOval(
                                child: Container(
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: Theme.of(Get.context!).iconTheme.color!,
                                        width: 1,
                                      ),
                                    ),
                                    margin: const EdgeInsets.all(5),
                                    padding: EdgeInsets.zero,
                                    child: ClipOval(
                                      child: StreamBuilder(
                                          stream: profileController.someonesProfileData.stream,
                                          builder: (context, snapshot) {
                                            return CachedNetworkImage(
                                              alignment: Alignment.center,
                                              fit: BoxFit.cover,
                                              imageUrl: "${profileController.someonesProfileData.value.img}",
                                              placeholder: (context, url) => Container(
                                                padding: const EdgeInsets.all(3),
                                                child: shimmerMeUp(CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                                                )),
                                              ),
                                              // errorWidget: (context, url, error) => const Icon(Icons.error),
                                              errorWidget: (context, url, error) => Center(
                                                  child: Image.asset(
                                                AppImages.logoImage,
                                                height: 30,
                                                width: 30,
                                              )),
                                            );
                                          }),
                                    )),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            StreamBuilder(
                                stream: profileController.someonesProfileData.stream,
                                builder: (context, snapshot) {
                                  return Container(
                                    color: Colors.white.withOpacity(0.5),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(10),
                                    // margin: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      "${profileController.someonesProfileData.value.firstname ?? "Guest"} ${profileController.someonesProfileData.value.lastname ?? ""}",
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            final formKey = GlobalKey<FormState>();
                            TextEditingController messageController = TextEditingController();
                            Get.dialog(Dialog(
                                child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text("Leave a message", style: TextStyle(fontSize: 18)),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  commonTextField(
                                      maxLines: 2,
                                      controller: messageController,
                                      hint: "Enter message",
                                      baseColor: Colors.black,
                                      validator: (String? value) {
                                        return (value != null) && (value.isNotEmpty) ? null : "Please enter message";
                                      },
                                      borderColor: Colors.black),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: Text("Cancel")),
                                      TextButton(
                                          onPressed: () {
                                            if (formKey.currentState!.validate()) {
                                              profileController.addMessage(
                                                  userID: widget.profileID,
                                                  message: messageController.text,
                                                  callBack: () async {
                                                    snack(title: "Success", msg: "Message Sent Successfully");
                                                    LoginModel userDetails = await SessionManagement.getUserDetails();

                                                    NotificationHandler.to.sendNotificationToUserID(
                                                        postId: '',
                                                        userId: widget.profileID,
                                                        title: "You have new message",
                                                        body: "${userDetails.fname} ${userDetails.lname} messaged you");
                                                  });
                                            }
                                          },
                                          child: Text("Send Message")),
                                    ],
                                  ),
                                ],
                              ).paddingSymmetric(horizontal: 10),
                            )));
                          },
                          child: Container(
                            color: Colors.green,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10),
                            // margin: const EdgeInsets.only(top: 10),
                            child: const Text(
                              "Leave Message",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                height: 1,
                                // fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        if (index % 10 == 0 && index != 0) const AdsScreen(),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          //margin: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visibility(
              //     visible: profileController.profileFeeds?[index].toUserIdDetails != null,
              //     child: Text(
              //       "${profileController.profileFeeds?[index].name} shared to ${profileController.profileFeeds?[index].toUserIdDetails?.firstname ?? "Guest"} ${profileController.profileFeeds?[index].toUserIdDetails?.lastname ?? ""} ",
              //       textAlign: TextAlign.left,
              //     ).paddingSymmetric(vertical: 10, horizontal: 10)),
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
                              fit: BoxFit.fill,
                              imageUrl: "${profileController.profileFeeds?[index].profilePic}",
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
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      flex: 8,
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                            // "",

                            TextSpan(
                              text: profileController.profileFeeds?[index].toUserIdDetails != null
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
                          return PopUpOptions.feedPostMoreOptions.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                        onSelected: (value) {
                          switch (value) {
                            case PopUpOptions.edit:
                              editStatusBottomSheet(profileController.profileFeeds?[index] ?? PostModelFeed(), onEdit: () {
                                onEditClick!();
                              });
                              break;
                            case PopUpOptions.delete:
                              deletePost(
                                  postId: "${profileController.profileFeeds?[index].id}",
                                  callBack: () {
                                    profileController.profileFeeds?.removeAt(index);
                                    profileController.profileFeeds?.refresh();
                                  }).then((value) {
                                onDeleteClick!();
                              });
                              break;
                          }
                        },
                      )
                  ],
                ),
              ),

              if (profileController.profileFeeds?[index].status != null && profileController.profileFeeds?[index].status != '')
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
                        child: getLinkText(text: profileController.profileFeeds?[index].status ?? ""),
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
                                postId: "${profileController.profileFeeds?[index].id}",
                              ).then((value) {
                                if (profileController.profileFeeds?[index].isFav == 0) {
                                  profileController.profileFeeds?[index].isFav = 1;
                                } else {
                                  profileController.profileFeeds?[index].isFav = 0;
                                }
                                onFavClick!();
                              });
                            } else {
                              setAsUnFav("${profileController.profileFeeds?[index].id}").then((value) {
                                if (profileController.profileFeeds?[index].isFav == 0) {
                                  profileController.profileFeeds?[index].isFav = 1;
                                } else {
                                  profileController.profileFeeds?[index].isFav = 0;
                                }
                                setState(() {});
                              });
                            }
                          },
                          icon: Icon(
                            isLoved ? Icons.favorite : Icons.favorite_border,
                            color: isLoved ? Colors.red : Theme.of(Get.context!).iconTheme.color,
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
                              postId: "${profileController.profileFeeds?[index].id}",
                              callBack: (commentCount) {
                                if (profileController.profileFeeds?[index].isLike == 0) {
                                  profileController.profileFeeds?[index].isLike = 1;
                                } else {
                                  profileController.profileFeeds?[index].isLike = 0;
                                }
                                profileController.profileFeeds?[index].countLike = "$commentCount";
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
                                isLiked ? "assets/icon/liked_image.png" : "assets/icon/like_img.png",
                                color: isLiked ? Colors.blue : Theme.of(Get.context!).iconTheme.color,
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
                            Get.to(() => CommentScreen(
                                  isFrom: AppTexts.someoneProfile,
                                  index: index,
                                  postId: EndPoints.selectedPostId,
                                ));
                          },
                          icon: const Icon(Icons.messenger_outline)),
                    ),*/
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () async {
                          LoginModel userDetails = await SessionManagement.getUserDetails();
                          if (kDebugMode) {
                            print("user id: ${userDetails.id}");
                            print("post id: ${profileController.profileFeeds?[index].id!}");
                          }

                          debugPrint("Before: ${profileController.profileFeeds?[index].id!}");
                          EndPoints.selectedPostId = "${profileController.profileFeeds?[index].id}";
                          Get.to(() => CommentScreen(
                              index: index,
                              isFrom: AppTexts.dashBoard,
                              postOwnerId: "${profileController.profileFeeds?[index].ownerId}",
                              postId: EndPoints.selectedPostId))?.then((value) => dashBoardController.dashboardFeeds.refresh());
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
                            addToTimeline("${profileController.profileFeeds?[index].id}");
                          },
                          icon: const Icon(Icons.add_box)),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                          onPressed: () {
                            AppMethods().share("${EndPoints.socialSharePostUrl}${profileController.profileFeeds?[index].id}");
                          },
                          icon: const Icon(Icons.share)),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                          onPressed: () {
                            reportPost("${profileController.profileFeeds?[index].id}");
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
                    child: customText(title: "${profileController.profileFeeds?[index].timeStamp}", fs: 10),
                  )),
              if (profileController.profileFeeds?[index].latestComments?.isNotEmpty == true)
                Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Comments"),
                    ).paddingOnly(left: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: profileController.profileFeeds?[index].latestComments?.length ?? 0,
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
                                imageUrl: "https://wghdfm.s3.amazonaws.com/thumb/${profileController.profileFeeds?[index].latestComments?[indexOfComment]?.img}",
                                progressIndicatorBuilder: (BuildContext, String, DownloadProgress) {
                                  return const Center(child: CupertinoActivityIndicator());
                                },
                                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    "${profileController.profileFeeds?[index].latestComments?[indexOfComment]?.firstname} ${profileController.profileFeeds?[index].latestComments?[indexOfComment]?.lastname}",
                                    style: TextStyle(overflow: TextOverflow.ellipsis)),
                                Text("${profileController.profileFeeds?[index].latestComments?[indexOfComment]?.comment}", style: TextStyle(overflow: TextOverflow.ellipsis)),
                              ],
                            ),
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
}
