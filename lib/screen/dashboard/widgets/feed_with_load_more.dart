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
                        listOfMedia: listOfMedia ?? [],
                        feed: feed,
                        index: 0,
                        imgFit: BoxFit.cover)
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
                                //color: Colors.amber,
                                alignment: Alignment.center,
                                height: Get.height, //DP45
                                child: GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 0),
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
                                    print("wow === == = = =${feed?.url}");
                                    print("=== 121 2 12${listOfMedia?[index]}");
                                    print("=== indexxx ${index}");
                                    return [
                                      "mp4",
                                      "3gp",
                                      "mov",
                                      "mkv",
                                      'avi',
                                      'm3u8',
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
  return ["mp4", "3gp", 'mov', 'mkv', 'avi', 'm3u8', 'webm']
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
                    child: CommonYTPlayer(
                      videoId: feed?.url ?? "",
                    ),
                  ))
              : (feed?.url?.contains("www.youtube.com/live/") == true)
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),

                        child: CommonYTPlayer(videoId: feed?.url ?? ""),
                        // videoId:
                        // feed?.url?.split("/").last.split('?').first ??
                        //     ""
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
                            child: CommonYTPlayer(videoId: feed?.url ?? ""),
                            /* videoId: feed?.url
                                        ?.split("/")
                                        .last
                                        .split('?')
                                        .first ??
                                    ""*/
                          ),
                        )
                      : (feed?.url?.contains("youtube.com/shorts/") == true)
                          ? Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),

                                child: CommonYTPlayer(videoId: feed?.url ?? ""),
                                // videoId:
                                // feed?.url?.split("/").last.split('?').first ??
                                //     ""
                              ),
                            )
                          : const SizedBox();
}
