import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/commonYoutubePlayer.dart';
import 'package:wghdfm_java/common/video_player.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/modules/profile_module/view/profile_screen.dart';
import 'package:wghdfm_java/modules/profile_module/view/someones_profile_screen.dart';
import 'package:wghdfm_java/utils/get_links_text.dart';

class NotificationPostDetailsScreen extends StatefulWidget {
  final String postId;

  const NotificationPostDetailsScreen({Key? key, required this.postId})
      : super(key: key);

  @override
  State<NotificationPostDetailsScreen> createState() =>
      _NotificationPostDetailsScreenState();
}

class _NotificationPostDetailsScreenState
    extends State<NotificationPostDetailsScreen> {
  NotificationHandler notificationHandler = Get.put(NotificationHandler());

  @override
  void initState() {
    // TODO: implement initState
    notificationHandler.getPostById(postID: widget.postId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoved =
        notificationHandler.notificationPostModel.value.feed?.first?.isFav == 1;
    bool isLiked =
        notificationHandler.notificationPostModel.value.feed?.first?.isLike ==
            1;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Post Details",
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: StreamBuilder(
          stream: notificationHandler.notificationPostModel.stream,
          builder: (context, snapshot) {
            return Card(
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
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      "${notificationHandler.notificationPostModel.value.feed?.first?.profilePic}",
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
                                      const Icon(Icons.error,
                                          color: Colors.white),
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
                              text: notificationHandler.notificationPostModel
                                  .value.feed?.first?.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                height: 1.8,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                              children: [
                                const TextSpan(
                                  text: " ",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 15.0,
                                    height: 1.8,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                if (notificationHandler
                                        .notificationPostModel
                                        .value
                                        .feed
                                        ?.first
                                        ?.allTagUserList
                                        ?.isNotEmpty ==
                                    true)
                                  const TextSpan(
                                    text: "is with ",
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 15.0,
                                      height: 1.8,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ...notificationHandler.notificationPostModel
                                        .value.feed?.first?.allTagUserList
                                        ?.map(
                                      (e) {
                                        int indexs = notificationHandler
                                                .notificationPostModel
                                                .value
                                                .feed
                                                ?.first
                                                ?.allTagUserList
                                                ?.indexOf(e) ??
                                            0;

                                        if (indexs > 0) {
                                          if (indexs > 1) {
                                            return const TextSpan();
                                          }
                                          return TextSpan(
                                              text:
                                                  "${(notificationHandler.notificationPostModel.value.feed?.first?.allTagUserList?.length ?? 0) - indexs} Others",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                height: 1.8,
                                                fontWeight: FontWeight.normal,
                                                decoration: TextDecoration.none,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  Get.bottomSheet(BottomSheet(
                                                    onClosing: () {},
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      12)),
                                                    ),
                                                    builder: (context) {
                                                      return Container(
                                                        width: Get.width,
                                                        decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius.vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            12))),
                                                        child: ListView.builder(
                                                          itemCount: notificationHandler
                                                                  .notificationPostModel
                                                                  .value
                                                                  .feed
                                                                  ?.first
                                                                  ?.allTagUserList
                                                                  ?.length ??
                                                              0,
                                                          shrinkWrap: true,
                                                          itemBuilder: (context,
                                                              listIndex) {
                                                            if (listIndex < 1) {
                                                              return const SizedBox();
                                                            }
                                                            return ListTile(
                                                              leading: ClipOval(
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Theme.of(
                                                                            Get.context!)
                                                                        .iconTheme
                                                                        .color,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Theme.of(
                                                                              Get.context!)
                                                                          .iconTheme
                                                                          .color!,
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          5),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  child:
                                                                      ClipOval(
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      imageUrl:
                                                                          "${notificationHandler.notificationPostModel.value.feed?.first?.allTagUserList?[listIndex].profileImg}",
                                                                      // placeholder: (context, url) {
                                                                      //   return Image.asset(
                                                                      //     "assets/logo.png",
                                                                      //     scale: 5.0,
                                                                      //   );
                                                                      // },
                                                                      progressIndicatorBuilder: (BuildContext,
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
                                                                              color: Colors.white),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              title: Text(
                                                                  "${notificationHandler.notificationPostModel.value.feed?.first?.allTagUserList?[listIndex].profileName}"),
                                                              onTap: () {
                                                                if (notificationHandler
                                                                        .notificationPostModel
                                                                        .value
                                                                        .feed
                                                                        ?.first
                                                                        ?.allTagUserList?[
                                                                            listIndex]
                                                                        .profileId
                                                                        ?.isNotEmpty ==
                                                                    true) {
                                                                  Get.back();

                                                                  if (notificationHandler
                                                                          .notificationPostModel
                                                                          .value
                                                                          .feed
                                                                          ?.first
                                                                          ?.allTagUserList?[
                                                                              listIndex]
                                                                          .profileId !=
                                                                      userId) {
                                                                    Get.to(() =>
                                                                        SomeoneProfileScreen(
                                                                            profileID:
                                                                                notificationHandler.notificationPostModel.value.feed?.first?.allTagUserList?[listIndex].profileId ?? ""));
                                                                  } else {
                                                                    Get.to(() =>
                                                                        const ProfileScreen());
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
                                                "${e.profileName} ${(indexs < (notificationHandler.notificationPostModel.value.feed?.first?.allTagUserList?.length ?? 0) && indexs > 1) ? ' & ' : ''}",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                              height: 1.8,
                                              fontWeight: FontWeight.normal,
                                              decoration: TextDecoration.none,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                if (e.profileId?.isNotEmpty ==
                                                    true) {
                                                  Get.to(() =>
                                                      SomeoneProfileScreen(
                                                          profileID:
                                                              e.profileId ??
                                                                  ""));
                                                }
                                              });
                                      },
                                    ).toList() ??
                                    [],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (notificationHandler.notificationPostModel.value.feed
                              ?.first?.status !=
                          null &&
                      notificationHandler.notificationPostModel.value.feed
                              ?.first?.status !=
                          '')
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
                                text: notificationHandler.notificationPostModel
                                        .value.feed?.first?.status ??
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
                  customImageViewForDetails(notificationHandler
                      .notificationPostModel.value.feed?.first),
                  // Container(
                  //   margin: const EdgeInsets.only(
                  //     left: 10,
                  //     right: 10,
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: <Widget>[
                  //       Expanded(
                  //         flex: 1,
                  //         child: IconButton(
                  //             onPressed: () {
                  //               if (!isLoved) {
                  //                 setAsFav(
                  //                   postId: "${notificationHandler.notificationPostModel.value.feed?.first?.id}",
                  //                 ).then((value) {
                  //                   if (notificationHandler.notificationPostModel.value.feed?.first?.isFav == 0) {
                  //                     notificationHandler.notificationPostModel.value.feed?.first?.isFav = 1;
                  //                   } else {
                  //                     notificationHandler.notificationPostModel.value.feed?.first?.isFav = 0;
                  //                   }
                  //                   setState(() {});
                  //                 });
                  //               } else {
                  //                 setAsUnFav("${notificationHandler.notificationPostModel.value.feed?.first?.id}").then((value) {
                  //                   if (notificationHandler.notificationPostModel.value.feed?.first?.isFav == 0) {
                  //                     notificationHandler.notificationPostModel.value.feed?.first?.isFav = 1;
                  //                   } else {
                  //                     notificationHandler.notificationPostModel.value.feed?.first?.isFav = 0;
                  //                   }
                  //                   setState(() {});
                  //                 });
                  //               }
                  //             },
                  //             icon: Icon(
                  //               isLoved ? Icons.favorite : Icons.favorite_border,
                  //               color: isLoved ? Colors.red : Theme.of(Get.context!).iconTheme.color,
                  //             )),
                  //       ),
                  //       /*Expanded(
                  //     flex: 1,
                  //     child: InkWell(
                  //       onTap: () {
                  //         checkPostLikeStatus(
                  //           "${profileController.profileFeeds?[index].id}",
                  //         ).then((haveYouLiked) {
                  //           if (!haveYouLiked) {
                  //             setAsLiked(
                  //               postId: "${profileController.profileFeeds?[index].id!}",
                  //             );
                  //           }
                  //         });
                  //       },
                  //       child: Container(
                  //         padding: const EdgeInsets.symmetric(horizontal: 5),
                  //         height: 20,
                  //         child: Image.asset(
                  //           isLiked ? "assets/icon/like_feel_img.png" : "assets/icon/like_img.png",
                  //           color: isLiked ? Colors.blue : Theme.of(Get.context!).iconTheme.color,
                  //         ),
                  //       ),
                  //     ),
                  //   ),*/
                  //       Expanded(
                  //         flex: 1,
                  //         child: InkWell(
                  //           onTap: () async {
                  //             // checkPostLikeStatus(
                  //             //   "${dashBoardController.dashboardFeeds?[index].id}",
                  //             // ).then((haveYouLiked) {
                  //             //   if (!haveYouLiked) {
                  //             //     setAsLiked(
                  //             //       "${dashBoardController.dashboardFeeds?[index].id!}",
                  //             //     );
                  //             //   }
                  //             // });
                  //             await setAsLiked(
                  //                 postId: "${notificationHandler.notificationPostModel.value.feed?.first?.id}",
                  //                 callBack: (commentCount) {
                  //                   if (notificationHandler.notificationPostModel.value.feed?.first?.isLike == 0) {
                  //                     notificationHandler.notificationPostModel.value.feed?.first?.isLike = 1;
                  //                   } else {
                  //                     notificationHandler.notificationPostModel.value.feed?.first?.isLike = 0;
                  //                   }
                  //                   notificationHandler.notificationPostModel.value.feed?.first?.countLike = "$commentCount";
                  //                   setState(() {});
                  //                 });
                  //           },
                  //           child: Container(
                  //             padding: const EdgeInsets.symmetric(horizontal: 5),
                  //             height: 20,
                  //             child: Row(
                  //               mainAxisSize: MainAxisSize.min,
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               children: [
                  //                 Image.asset(
                  //                   isLiked ? "assets/icon/liked_image.png" : "assets/icon/like_img.png",
                  //                   color: isLiked ? Colors.blue : Theme.of(Get.context!).iconTheme.color,
                  //                 ),
                  //                 const SizedBox(
                  //                   width: 3,
                  //                 ),
                  //                 Text(
                  //                   "${notificationHandler.notificationPostModel.value.feed?.first?.countLike}",
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       /*Expanded(
                  //     flex: 1,
                  //     child: IconButton(
                  //         onPressed: () async {
                  //           // todo:
                  //           LoginModel userDetails = await SessionManagement.getUserDetails();
                  //           if (kDebugMode) {
                  //             print("user id: ${userDetails.id}");
                  //             print("post id: ${profileController.profileFeeds?[index].id!}");
                  //           }
                  //
                  //           debugPrint("Before: ${profileController.profileFeeds?[index].id!}");
                  //           EndPoints.selectedPostId = "${profileController.profileFeeds?[index].id}";
                  //           Get.to(() => CommentScreen(postId: EndPoints.selectedPostId));
                  //         },
                  //         icon: const Icon(Icons.messenger_outline)),
                  //   ),*/
                  //       Expanded(
                  //         flex: 1,
                  //         child: InkWell(
                  //           onTap: () async {
                  //             LoginModel userDetails = await SessionManagement.getUserDetails();
                  //             // if (kDebugMode) {
                  //             print("user id: ${userDetails.id}");
                  //             print("post id: ${notificationHandler.notificationPostModel.value.feed?.first?.id}");
                  //             // }
                  //
                  //             debugPrint("Before: ${notificationHandler.notificationPostModel.value.feed?.first?.id}");
                  //             EndPoints.selectedPostId = "${notificationHandler.notificationPostModel.value.feed?.first?.id}";
                  //             Get.to(() => CommentScreen(
                  //                   isFrom: AppTexts.notification,
                  //                   // index: index,
                  //                   postId: EndPoints.selectedPostId,
                  //                 ));
                  //           },
                  //           child: Container(
                  //             padding: const EdgeInsets.symmetric(horizontal: 5),
                  //             height: 20,
                  //             child: Row(
                  //               mainAxisSize: MainAxisSize.min,
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               children: [
                  //                 Icon(
                  //                   Icons.chat_bubble_outline,
                  //                   // color: isLiked ? Colors.blue : Theme.of(Get.context!).iconTheme.color,
                  //                 ),
                  //                 SizedBox(
                  //                   width: 3,
                  //                 ),
                  //                 Text(
                  //                   "${notificationHandler.notificationPostModel.value.feed?.first?.countComment}",
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Expanded(
                  //         flex: 1,
                  //         child: IconButton(
                  //             onPressed: () {
                  //               addToTimeline("${notificationHandler.notificationPostModel.value.feed?.first?.id}");
                  //             },
                  //             icon: const Icon(Icons.add_box)),
                  //       ),
                  //       Expanded(
                  //         flex: 1,
                  //         child: IconButton(
                  //             onPressed: () {
                  //               AppMethods().share("${EndPoints.socialSharePostUrl}${notificationHandler.notificationPostModel.value.feed?.first?.id}");
                  //             },
                  //             icon: const Icon(Icons.share)),
                  //       ),
                  //       Expanded(
                  //         flex: 1,
                  //         child: IconButton(
                  //             onPressed: () {
                  //               reportPost("${notificationHandler.notificationPostModel.value.feed?.first?.id}");
                  //             },
                  //             icon: const Icon(Icons.report_problem)),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Align(
                  //     alignment: Alignment.bottomRight,
                  //     child: Container(
                  //       margin: const EdgeInsets.all(10),
                  //       child: customText(title: "${notificationHandler.notificationPostModel.value.feed?.first?.timeStamp}", fs: 10),
                  //     )),
                  // if (notificationHandler.notificationPostModel.value.feed?.first?.latestComments?.isNotEmpty == true)
                  //   Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       const Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text("Comments"),
                  //       ).paddingOnly(left: 10),
                  //       // ListView.builder(
                  //       //   shrinkWrap: true,
                  //       //   physics: const NeverScrollableScrollPhysics(),
                  //       //   itemCount: notificationHandler.postModelFeed.value.latestComments?.length ?? 0,
                  //       //   itemBuilder: (context, indexOfComment) => Row(
                  //       //     children: [
                  //       //       Container(
                  //       //         height: 40,
                  //       //         width: 40,
                  //       //         decoration: BoxDecoration(
                  //       //           color: Theme.of(Get.context!).iconTheme.color,
                  //       //           borderRadius: BorderRadius.circular(100),
                  //       //           border: Border.all(
                  //       //             color: Theme.of(Get.context!).iconTheme.color!,
                  //       //             width: 1,
                  //       //           ),
                  //       //         ),
                  //       //         margin: const EdgeInsets.all(5),
                  //       //         padding: EdgeInsets.zero,
                  //       //         child: ClipOval(
                  //       //           child: CachedNetworkImage(
                  //       //             alignment: Alignment.center,
                  //       //             fit: BoxFit.fill,
                  //       //             imageUrl: "https://wghdfm.s3.amazonaws.com/thumb/${notificationHandler.postModelFeed.value.latestComments?[indexOfComment]?.img}",
                  //       //             progressIndicatorBuilder: (BuildContext, String, DownloadProgress) {
                  //       //               return const Center(child: CupertinoActivityIndicator());
                  //       //             },
                  //       //             errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                  //       //           ),
                  //       //         ),
                  //       //       ),
                  //       //       Column(
                  //       //         mainAxisAlignment: MainAxisAlignment.center,
                  //       //         crossAxisAlignment: CrossAxisAlignment.start,
                  //       //         mainAxisSize: MainAxisSize.min,
                  //       //         children: [
                  //       //           Text(
                  //       //               "${notificationHandler.postModelFeed.value.latestComments?[indexOfComment]?.firstname} ${notificationHandler.postModelFeed.value.latestComments?[indexOfComment]?.lastname}"),
                  //       //           Text("${notificationHandler.postModelFeed.value.latestComments?[indexOfComment]?.comment}"),
                  //       //         ],
                  //       //       )
                  //       //     ],
                  //       //   ),
                  //       // ),
                  //     ],
                  //   ),
                ],
              ),
            );
          }),
    );
  }
}

Widget customImageViewForDetails(PostModelFeed? feed) {
  var listOfMedia = feed?.media?.split("_|_");
  print(">> MEDIA IS >> ${feed?.media}");
  print(">> Youtube iFrame 1 use this link >> ${feed?.url?.split("=").last}");
  print(">> Youtube iFrame 1 use this link >> ${feed?.url?.split("=").last}");
  print(">> Content Link >> ${listOfMedia}");
  // return Text(listOfMedia.length.toString());
  // kFavouriteController.isRefreshing.value = true;
  // Timer(const Duration(seconds: 1), () {
  //   kFavouriteController.isRefreshing.value = false;
  // });
  return InkWell(
    onTap: () {
      print("more");
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        (feed?.media != "" ||
                feed?.url != "" ||
                listOfMedia?.isNotEmpty == true)
            ? ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  print("=== == = = =${feed?.url}");
                  print("=== 121 2 12${listOfMedia?[index]}");
                  print("=== indexxx ${index}");
                  return ["mp4", "3gp", 'mov', 'mkv', 'avi', 'm3u8', 'webm']
                          .contains(listOfMedia?[index].split(".").last)
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CommonVideoPlayer(
                                videoLink: listOfMedia?[index] ?? ""),
                          ),
                        )
                      : ["jpg", "jpeg", "png", "gif", 'heic', 'heif']
                              .contains(listOfMedia?[index].split(".").last)
                          ? Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  child: CachedNetworkImage(
                                    imageUrl: listOfMedia?[index] ?? "",
                                    progressIndicatorBuilder: (BuildContext,
                                        String, DownloadProgress) {
                                      return const Center(
                                          child: CupertinoActivityIndicator());
                                    },
                                    errorWidget:
                                        (BuildContext, String, dynamic) {
                                      return Image.asset("assets/logo.png");
                                      // return Image.asset("assets/drawable/home.jpg");
                                    },
                                  ),
                                ),
                              ),
                            )
                          : feed?.url?.contains("youtube.com/watch?v") == true
                              ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CommonYTPlayer(
                                      videoId: feed?.url ?? "",
                                    ),
                                  ))
                              : (feed?.url?.contains("www.youtube.com/live/") ==
                                      true)
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey, width: 0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),

                                        child: CommonYTPlayer(
                                            videoId: feed?.url ?? ""),
                                        // videoId:
                                        // feed?.url?.split("/").last.split('?').first ??
                                        //     ""
                                      ),
                                    )
                                  : feed?.url?.contains("youtu.be") == true
                                      ? Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 0.5),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: CommonYTPlayer(
                                                videoId: feed?.url ?? ""),
                                            /* videoId: feed?.url
                                        ?.split("/")
                                        .last
                                        .split('?')
                                        .first ??
                                    ""*/
                                          ),
                                        )
                                      : (feed?.url?.contains(
                                                  "youtube.com/shorts/") ==
                                              true)
                                          ? Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),

                                                child: CommonYTPlayer(
                                                    videoId: feed?.url ?? ""),
                                                // videoId:
                                                // feed?.url?.split("/").last.split('?').first ??
                                                //     ""
                                              ),
                                            )
                                          : const SizedBox();
                },
                itemCount: listOfMedia?.length ?? 0,
              )
            : const SizedBox(),
        const SizedBox(
          height: 5,
        ),
      ],
    ),
  );
}
