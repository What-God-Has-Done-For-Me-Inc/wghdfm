import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';

// import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/commonYoutubePlayer.dart';
import 'package:wghdfm_java/common/video_player.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/utils/page_res.dart';

// import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../modules/dashbord_module/controller/dash_board_controller.dart';

bool isOwnPost(var ownerId) {
  bool isOwn = false;
  isOwn = (ownerId == userId) ? true : false;
  return isOwn;
}

/*Widget listItem(
  int index, {
  VoidCallback? onFavClick,
  VoidCallback? onLikeClick,
  bool isLoved = false,
  bool isLiked = false,
  VoidCallback? onEditClick,
  VoidCallback? onDeleteClick,
}) {
  bool isOwn = isOwnPost("${kDashboardController.dashboardFeeds[index].ownerId}");
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
                      // if (kDashboardController.dashboardFeeds?[index].ownerId != userId) {
                      Get.to(() => SomeoneProfileScreen(profileID: "${kDashboardController.dashboardFeeds[index].ownerId}"));
                      // } else {
                      //   Get.to(() => const ProfileScreen());
                      // }
                      // Get.toNamed(PageRes.profileScreen, arguments: {"profileId": kDashboardController.dashboardFeeds?[index].ownerId!, "isSelf": isOwn});
                    },
                    child: ClipOval(
                      child: CachedNetworkImage(
                        alignment: Alignment.center,
                        fit: BoxFit.fill,
                        imageUrl: "${kDashboardController.dashboardFeeds[index].profilePic}",
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
                  text: TextSpan(
                    text: kDashboardController.dashboardFeeds[index].name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      height: 1.8,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                    children: const <TextSpan>[
                      TextSpan(
                        text: "",
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
                        editStatusBottomSheet(kDashboardController.dashboardFeeds[index] ?? PostModelFeed(), onEdit: () {
                          onEditClick!();
                        });
                        break;
                      case PopUpOptions.delete:
                        deletePost("${kDashboardController.dashboardFeeds[index].id}").then((value) {
                          onDeleteClick!();
                        });
                        break;
                    }
                  },
                )
            ],
          ),
        ),
        if (kDashboardController.dashboardFeeds?[index].status != null && kDashboardController.dashboardFeeds?[index].status != '')
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
                  child: RichText(
                    text: TextSpan(
                      text: kDashboardController.dashboardFeeds?[index].status!,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 15.0,
                        height: 1.8,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Text(feeds![index].status.toString()),
        customImageView(kDashboardController.dashboardFeeds[index]),
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
                          "${kDashboardController.dashboardFeeds?[index].id}",
                        ).then((value) {
                          onFavClick!();
                        });
                      }
                    },
                    icon: Icon(
                      isLoved ? Icons.favorite : Icons.favorite_border,
                      color: isLoved ? Colors.red : Theme.of(Get.context!).iconTheme.color,
                    )),
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    setAsLiked(postId: "${kDashboardController.dashboardFeeds[index].id}", callBack: () {});

                    // checkPostLikeStatus(
                    //   "${kDashboardController.dashboardFeeds[index].id}",
                    // ).then((haveYouLiked) {
                    //   if (!haveYouLiked) {
                    //     setAsLiked(
                    //       "${kDashboardController.dashboardFeeds[index].id!}",
                    //     );
                    //   }
                    // });
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
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: () async {
                      // todo:
                      LoginModel userDetails = await SessionManagement.getUserDetails();
                      if (kDebugMode) {
                        print("user id: ${userDetails.id}");
                        print("post id: ${kDashboardController.dashboardFeeds[index].id!}");
                      }

                      debugPrint("Before: ${kDashboardController.dashboardFeeds[index].id!}");
                      EndPoints.selectedPostId = "${kDashboardController.dashboardFeeds[index].id}";
                      Get.to(() => CommentScreen(postId: EndPoints.selectedPostId));
                    },
                    icon: const Icon(Icons.messenger_outline)),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: () {
                      addToTimeline("${kDashboardController.dashboardFeeds[index].id}");
                    },
                    icon: const Icon(Icons.add_box)),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: () {
                      AppMethods().share("${EndPoints.socialSharePostUrl}${kDashboardController.dashboardFeeds[index].id}");
                    },
                    icon: const Icon(Icons.share)),
              ),
              const Spacer(),
              Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: () {
                      reportPost("${kDashboardController.dashboardFeeds[index].id}");
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
              child: customText(title: "${kDashboardController.dashboardFeeds[index].timeStamp}", fs: 10),
            )),
        */ /*if (kDashboardController.dashboardFeeds[index].cmntpic1 != null &&
            kDashboardController.dashboardFeeds[index].cmntname1 != null &&
            kDashboardController.dashboardFeeds[index].cmnt1 != null &&
            kDashboardController.dashboardFeeds[index].cmntpic1?.isNotEmpty == true &&
            kDashboardController.dashboardFeeds[index].cmntname1?.isNotEmpty == true &&
            kDashboardController.dashboardFeeds[index].cmnt1?.isNotEmpty == true)
          Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Comments"),
              ).paddingOnly(left: 10),
              Row(
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
                        imageUrl: "${kDashboardController.dashboardFeeds?[index].cmntpic1}",
                        progressIndicatorBuilder: (BuildContext, String, DownloadProgress) {
                          return const Center(child: CupertinoActivityIndicator());
                        },
                        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${kDashboardController.dashboardFeeds[index].cmntname1}"),
                      Text("${kDashboardController.dashboardFeeds[index].cmnt1}"),
                    ],
                  )
                ],
              ),
            ],
          ),*/ /*
      ],
    ),
  );
}*/

Widget customImageView(PostModelFeed? feed) {
  var listOfMedia = feed?.media?.split("_|_");
  print(">> MEDIA IS >> ${feed?.media}");
  print(">> Youtube iFrame 1 use this link >> ${feed?.url}");
  print(">> Youtube iFrame 1 use this link >> ${feed?.url?.split("=").last}");
  print(
      ">> Youtube iFrame 1 use this link >> ${feed?.url?.split("/").last.split('?').first}");
  print(">> Content Link >> ${listOfMedia}");

  return InkWell(
    onTap: () {
      feed?.media == ""
          ? const Offstage()
          : Get.toNamed(PageRes.postDetailScreen, arguments: listOfMedia);
      print("more");
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        (feed?.media != "" || feed?.url != "")
            ? Container(
                height: (listOfMedia?.length ?? 0) == 2
                    ? Get.height * 0.2
                    : Get.height * 0.5,
                child: (listOfMedia?.length ?? 0) <= 1
                    ? mediaView(
                        listOfMedia: listOfMedia ?? [], feed: feed, index: 0)
                    : (listOfMedia?.length ?? 0) == 2
                        ? SizedBox(
                            height: Get.height,
                            width: Get.width,
                            child: Row(
                              // mainAxisSize: MainAxisSize.min,
                              children: listOfMedia
                                      ?.asMap()
                                      .entries
                                      .map((e) => Expanded(
                                          child: mediaView(
                                              listOfMedia: listOfMedia,
                                              feed: feed,
                                              index: e.key,
                                              imgFit: BoxFit.cover)))
                                      .toList() ??
                                  [],
                            ),
                          )
                        : (listOfMedia?.length ?? 0) == 3
                            ? SizedBox(
                                height: Get.height * 0.5,
                                child: Column(
                                  children: [
                                    Expanded(
                                      // height: Get.height * 0.2,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: mediaView(
                                                  listOfMedia:
                                                      listOfMedia ?? [],
                                                  feed: feed,
                                                  index: 0)),
                                          Expanded(
                                              child: mediaView(
                                                  listOfMedia:
                                                      listOfMedia ?? [],
                                                  feed: feed,
                                                  index: 1))
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height: Get.height * 0.25,
                                        width: Get.width,
                                        child: mediaView(
                                            listOfMedia: listOfMedia ?? [],
                                            feed: feed,
                                            index: 2))
                                  ],
                                ),
                              )
                            : Container(
                                // color: Colors.amber,
                                height: Get.height * 0.42, //DP45
                                child: GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0),
                                  shrinkWrap: true,
                                  primary: false,
                                  // scrollDirection: Axis.horizontal,
                                  // pageSnapping: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: 3,
                                    childAspectRatio: 1.0,
                                    mainAxisSpacing: 3,
                                    // mainAxisExtent: 100,
                                    crossAxisCount:
                                        listOfMedia?.length == 1 ? 1 : 2,
                                  ),
                                  itemCount: (listOfMedia?.length ?? 0) <= 4
                                      ? listOfMedia?.length
                                      : 4,
                                  itemBuilder: (context, index) {
                                    print("=== == = = =${feed?.url}");
                                    print("=== 121 2 12${listOfMedia?[index]}");
                                    print("=== indexxx ${index}");
                                    return [
                                      "mp4",
                                      "3gp",
                                      "mov",
                                      "mkv",
                                      'avi',
                                      'webm'
                                    ].contains(
                                            listOfMedia?[index].split(".").last)
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
                                              child: Stack(
                                                fit: StackFit.expand,
                                                alignment: Alignment.center,
                                                children: [
                                                  CommonVideoPlayer(
                                                      videoLink:
                                                          listOfMedia?[index] ??
                                                              ""),
                                                  Visibility(
                                                    visible: index == 3 &&
                                                        (listOfMedia?.length ??
                                                                0) >=
                                                            5,
                                                    child: Container(
                                                      height: 200,
                                                      width: double.infinity,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Visibility(
                                                      visible: index == 3 &&
                                                          (listOfMedia?.length ??
                                                                  0) >=
                                                              5,
                                                      child: Text(
                                                        "+${(listOfMedia?.length ?? 0) - 4} More",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              // child: FlickVideoPlayer(
                                              //     flickManager: FlickManager(
                                              //   autoPlay: false,
                                              //   videoPlayerController: VideoPlayerController.network(listOfMedia[index] ?? "-"),
                                              // )),
                                            ),
                                          )
                                        : [
                                            "jpg",
                                            "jpeg",
                                            "png",
                                            "gif",
                                            'heic',
                                            'pvt',
                                            'heif'
                                          ].contains(listOfMedia?[index]
                                                .split(".")
                                                .last) //DP45
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
                                                  child: Container(
                                                    child: Stack(
                                                      fit: StackFit.expand,
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        Container(
                                                          child:
                                                              CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            imageUrl:
                                                                listOfMedia?[
                                                                        index] ??
                                                                    "",
                                                            // placeholder: (context, url) {
                                                            //   return Image.asset("assets/logo.png");
                                                            // },
                                                            progressIndicatorBuilder:
                                                                (BuildContext,
                                                                    String,
                                                                    DownloadProgress) {
                                                              return const Center(
                                                                  child:
                                                                      CupertinoActivityIndicator());
                                                            },
                                                            // progressIndicatorBuilder: (BuildContext, String, DownloadProgress){
                                                            //   return SizedBox(
                                                            //     height: 35,
                                                            //     width: 35,
                                                            //     child: Platform.isAndroid ? CircularProgressIndicator() : CupertinoActivityIndicator(),);
                                                            // },
                                                            errorWidget:
                                                                (BuildContext,
                                                                    String,
                                                                    dynamic) {
                                                              return Image.asset(
                                                                  "assets/logo.png");
                                                              // return Image.asset("assets/drawable/home.jpg");
                                                            },
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: index == 3 &&
                                                              (listOfMedia?.length ??
                                                                      0) >=
                                                                  5,
                                                          child: Container(
                                                            height: 200,
                                                            width:
                                                                double.infinity,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                        Center(
                                                          child: Visibility(
                                                            visible: index ==
                                                                    3 &&
                                                                (listOfMedia?.length ??
                                                                        0) >=
                                                                    5,
                                                            child: Text(
                                                              "+${(listOfMedia?.length ?? 0) - 4} More",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : feed?.url?.contains(
                                                        "youtube.com/watch?v") ==
                                                    true
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      child: CommonYTPlayer(
                                                          videoId: feed?.url
                                                                  ?.split("=")
                                                                  .last ??
                                                              ""),
                                                    ),
                                                  )
                                                : (feed?.url?.contains(
                                                            "www.youtube.com/live/") ==
                                                        true)
                                                    ? Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          child: CommonYTPlayer(
                                                              videoId: feed?.url
                                                                      ?.split(
                                                                          "/")
                                                                      .last
                                                                      .split(
                                                                          '?')
                                                                      .first ??
                                                                  ""),
                                                        ),
                                                      )
                                                    : feed?.url?.contains(
                                                                "youtu.be") ==
                                                            true
                                                        ? Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              child: CommonYTPlayer(
                                                                  videoId: feed
                                                                          ?.url
                                                                          ?.split(
                                                                              "/")
                                                                          .last
                                                                          .split(
                                                                              '?')
                                                                          .first ??
                                                                      ""),
                                                            ),
                                                          )
                                                        : const SizedBox();
                                  },
                                ),
                              ),
              )
            : SizedBox(),
      ],
    ),
  );
}

Widget mediaView({required List listOfMedia, index, feed, BoxFit? imgFit}) {
  return ["mp4", "3gp", 'mov', 'mkv', 'avi', 'webm']
          .contains(listOfMedia[index].split(".").last)
      ? Container(
          height: Get.height * 0.5,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CommonVideoPlayer(videoLink: listOfMedia[index] ?? ""),
            // child: FlickVideoPlayer(
            //     flickManager: FlickManager(
            //   autoPlay: false,
            //   videoPlayerController: VideoPlayerController.network(listOfMedia[index] ?? "-"),
            // )),
          ),
        )
      : ["jpg", "jpeg", "png", "gif", 'heic', 'heif']
              .contains(listOfMedia[index].split(".").last)
          ? Container(
              width: Get.width,
              height: Get.height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Container(
                child: CachedNetworkImage(
                  fit: imgFit ?? BoxFit.cover,
                  imageUrl: listOfMedia[index] ?? "",
                  // placeholder: (context, url) {
                  //   return Image.asset("assets/logo.png");
                  // },
                  progressIndicatorBuilder:
                      (BuildContext, String, DownloadProgress) {
                    return const Center(child: CupertinoActivityIndicator());
                  },
                  // progressIndicatorBuilder: (BuildContext, String, DownloadProgress){
                  //   return SizedBox(
                  //     height: 35,
                  //     width: 35,
                  //     child: Platform.isAndroid ? CircularProgressIndicator() : CupertinoActivityIndicator(),);
                  // },
                  errorWidget: (BuildContext, String, dynamic) {
                    return Image.asset("assets/logo.png");
                    // return Image.asset("assets/drawable/home.jpg");
                  },
                ),
              ),
            )
          : feed?.url?.contains("youtube.com/watch?v") == true
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    // child: YoutubeVideoScereen(
                    //   videoId: feed.url!.split("=").last,
                    // ),
                    child: CommonYTPlayer(
                        videoId: feed?.url?.split("=").last ?? ""),

                    /*child: YoutubePlayer(
                                        controller: YoutubePlayerController(
                                          initialVideoId: feed?.url?.split("=").last ?? "",
                                          flags: YoutubePlayerFlags(
                                            autoPlay: true,
                                            mute: true,
                                          ),
                                        ),
                                        showVideoProgressIndicator: true,
                                        // videoProgressIndicatorColor: Colors.amber,
                                        // progressColors: ProgressColors(
                                        //   playedColor: Colors.amber,
                                        //   handleColor: Colors.amberAccent,
                                        // ),

                                        // child: YoutubePlayerIFrame(
                                        //   controller: YoutubePlayerController(
                                        //     params: YoutubePlayerParams(autoPlay: false),
                                        //     initialVideoId: feed?.url?.split("=").last ?? "",
                                        //   ),
                                      ),*/
                  ),
                )
              : (feed?.url?.contains("www.youtube.com/live/") == true)
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        // child: YoutubeVideoScereen(
                        //   videoId: feed.url!.split("=").last,
                        // ),

                        child: CommonYTPlayer(
                            videoId:
                                feed?.url?.split("/").last.split('?').first ??
                                    ""),

                        /*child: YoutubePlayer(
                                        controller: YoutubePlayerController(
                                          initialVideoId: feed?.url?.split("=").last ?? "",
                                          flags: YoutubePlayerFlags(
                                            autoPlay: true,
                                            mute: true,
                                          ),
                                        ),
                                        showVideoProgressIndicator: true,
                                        // videoProgressIndicatorColor: Colors.amber,
                                        // progressColors: ProgressColors(
                                        //   playedColor: Colors.amber,
                                        //   handleColor: Colors.amberAccent,
                                        // ),

                                        // child: YoutubePlayerIFrame(
                                        //   controller: YoutubePlayerController(
                                        //     params: YoutubePlayerParams(autoPlay: false),
                                        //     initialVideoId: feed?.url?.split("=").last ?? "",
                                        //   ),
                                      ),*/
                      ),
                    )
                  : feed?.url?.contains("youtu.be") == true
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            // child: YoutubeVideoScereen(
                            //   videoId: feed.url!.split("/").last,
                            // ),
                            child: CommonYTPlayer(
                                videoId: feed?.url
                                        ?.split("/")
                                        .last
                                        .split('?')
                                        .first ??
                                    ""),

                            /*child: YoutubePlayer(
                                            controller: YoutubePlayerController(
                                              initialVideoId: feed?.url?.split("/").last ?? "",
                                              flags: YoutubePlayerFlags(
                                                autoPlay: true,
                                                mute: true,
                                              ),
                                            ),
                                            showVideoProgressIndicator: true,
                                            // videoProgressIndicatorColor: Colors.amber,
                                            // progressColors: ProgressColors(
                                            //   playedColor: Colors.amber,
                                            //   handleColor: Colors.amberAccent,
                                            // ),
                                          ),*/

                            /*child: YoutubePlayerIFrame(
                                            controller: YoutubePlayerController(
                                              params: const YoutubePlayerParams(
                                                autoPlay: false,
                                              ),
                                              initialVideoId: feed?.url?.split("/").last ?? "",
                                              // initialVideoId: feed.url!.split("/").last
                                            ),
                                          ),*/
                          ),
                        )
                      : const SizedBox();
}
