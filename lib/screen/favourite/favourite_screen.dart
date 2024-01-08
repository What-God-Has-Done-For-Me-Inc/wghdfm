import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/commonYoutubePlayer.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/common/video_player.dart';
import 'package:wghdfm_java/modules/ads_module/ads_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/profile_module/view/profile_screen.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/feed_with_load_more.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/shimmer_feed_loading.dart';
import 'package:wghdfm_java/screen/favourite/favourite_controller.dart';
import 'package:wghdfm_java/utils/app_texts.dart';
import 'package:wghdfm_java/utils/page_res.dart';

import '../../model/feed_res_obj.dart';
import '../../modules/auth_module/model/login_model.dart';
import '../../modules/profile_module/view/someones_profile_screen.dart';
import '../../services/sesssion.dart';
import '../../utils/app_methods.dart';
import '../../utils/endpoints.dart';
import '../../utils/get_links_text.dart';
import '../../utils/lists.dart';
import '../comment/comment_screen.dart';
import '../dashboard/dashboard_api/add_fav_post_api.dart';
import '../dashboard/dashboard_api/add_to_time_line_api.dart';
import '../dashboard/dashboard_api/delete_post_api.dart';
import '../dashboard/dashboard_api/report_post_api.dart';
import '../dashboard/widgets/edit_bottom_sheet.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final favouriteController = Get.put(FavouriteController());

  final DashBoardController d = Get.put(DashBoardController());
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    favouriteController.currentPage.value = 0;
    favouriteController.getFavPost(searchTxt: searchController.text);
    pagination();
    super.initState();
  }

  pagination() {
    scrollController.addListener(() async {
      print(
          ">> SCROLL POSITION ${scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.70}");
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent * 0.70 &&
          favouriteController.isLoading.value == false) {
        favouriteController.isLoading.value = true;
        favouriteController.currentPage.value++;
        await favouriteController.getFavPost(
            searchTxt: searchController.text, showLoading: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Favorite Feed(s)',
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          centerTitle: true,
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        // drawer: DrawerScreen(screen: FavouriteScreen()),
        // drawer: buildDrawer(),
        body: newFavFeed(),
      ),
    );
  }

  Widget newFavFeed() {
    return Container(
      // alignment: Alignment.center,
      color: Colors.black,
      padding: const EdgeInsets.all(10),
      child: StreamBuilder(
        stream: favouriteController.favFeeds?.stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (favouriteController.favFeeds == null) {
            return shimmerFeedLoading();
          }
          if (snapshot.hasError) {
            return Container(
              color: Colors.white,
              child: customText(title: "${snapshot.error}"),
            );
          }
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(5),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Search Name Or Description",
                    labelStyle: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1),
                    ),
                    enabled: true,
                  ),
                  onChanged: (value) {
                    favouriteController.currentPage.value = 0;
                    // favouriteController.favFeeds?.clear();
                    favouriteController.getFavPost(
                        searchTxt: searchController.text,
                        showLoading: false,
                        isFirstTime: true,
                        callBack: () {
                          favouriteController.favFeeds?.refresh();
                          setState(() {});
                          // favouriteController.isRefreshing.toggle();
                        });
                  },
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: (favouriteController.favFeeds != null &&
                        favouriteController.favFeeds?.isNotEmpty == true)
                    ? RefreshIndicator(
                        onRefresh: () async {
                          favouriteController.getFavPost(
                              searchTxt: searchController.text,
                              isFirstTime: true,
                              showLoading: true);
                        },
                        child: StreamBuilder(
                            stream: favouriteController.favFeeds?.stream,
                            builder: (context, snapshot) {
                              return ListView.builder(
                                shrinkWrap: true,
                                controller: scrollController,
                                physics: const ClampingScrollPhysics(),
                                itemCount:
                                    favouriteController.favFeeds?.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  bool isLoved = favouriteController
                                          .favFeeds?[index].isFav ==
                                      1;
                                  bool isLiked = favouriteController
                                          .favFeeds?[index].isLike ==
                                      1;
                                  bool isOwn = isOwnPost(
                                      "${favouriteController.favFeeds?[index].ownerId}");

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (index % 10 == 0 && index != 0)
                                        const AdsScreen(),
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
                                                          if (favouriteController
                                                                  .favFeeds?[
                                                                      index]
                                                                  .ownerId !=
                                                              userId) {
                                                            Get.off(() =>
                                                                SomeoneProfileScreen(
                                                                    profileID:
                                                                        "${favouriteController.favFeeds?[index].ownerId}"));
                                                          } else {
                                                            Get.off(() =>
                                                                const ProfileScreen());
                                                          }
                                                          // Get.toNamed(PageRes.profileScreen, arguments: {"profileId": favouriteController.favFeeds?[index].ownerId!, "isSelf": isOwn});
                                                        },
                                                        child: ClipOval(
                                                          child:
                                                              CachedNetworkImage(
                                                            alignment: Alignment
                                                                .center,
                                                            fit: BoxFit.fill,
                                                            imageUrl:
                                                                "${favouriteController.favFeeds?[index].profilePic}",
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
                                                            favouriteController
                                                                .favFeeds?[
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
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text: favouriteController
                                                                        .favFeeds?[
                                                                            index]
                                                                        .toUserIdDetails !=
                                                                    null
                                                                ? " shared to ${favouriteController.favFeeds?[index].toUserIdDetails?.firstname ?? "Guest"} ${favouriteController.favFeeds?[index].toUserIdDetails?.lastname ?? ""} "
                                                                : "",
                                                            // text: "",
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
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (isOwn)
                                                    PopupMenuButton<String>(
                                                      offset:
                                                          const Offset(0, 40),
                                                      icon: const Icon(
                                                        Icons.more_horiz,
                                                      ),
                                                      itemBuilder: (BuildContext
                                                          context) {
                                                        return PopUpOptions
                                                            .feedPostMoreOptions
                                                            .map((String
                                                                choice) {
                                                          return PopupMenuItem<
                                                              String>(
                                                            value: choice,
                                                            child: Text(choice),
                                                          );
                                                        }).toList();
                                                      },
                                                      onSelected: (value) {
                                                        switch (value) {
                                                          case PopUpOptions
                                                                .edit:
                                                            editStatusBottomSheet(
                                                                favouriteController
                                                                            .favFeeds?[
                                                                        index] ??
                                                                    PostModelFeed(),
                                                                onEdit: () {
                                                              setState(() {});
                                                            });
                                                            break;
                                                          case PopUpOptions
                                                                .delete:
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return CupertinoAlertDialog(
                                                                    title: Text(
                                                                        'Are you sure you want to delete this post?'),
                                                                    content: Text(
                                                                        'This will delete this post permanently'),
                                                                    actions: <Widget>[
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context); //close Dialog
                                                                        },
                                                                        child: Text(
                                                                            'Cancel'),
                                                                      ),
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                            deletePost(
                                                                                postId: "${favouriteController.favFeeds?[index].id}",
                                                                                callBack: () {
                                                                                  favouriteController.favFeeds?.removeAt(index);
                                                                                  favouriteController.favFeeds?.refresh();
                                                                                }).then((value) {
                                                                              setState(() {});
                                                                            });
                                                                            //action code for "Yes" button
                                                                          },
                                                                          child:
                                                                              Text(
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
                                            if (favouriteController
                                                        .favFeeds?[index]
                                                        .status !=
                                                    null &&
                                                favouriteController
                                                        .favFeeds?[index]
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
                                                            text: favouriteController
                                                                    .favFeeds?[
                                                                        index]
                                                                    .status ??
                                                                "")
                                                        /*RichText(
                                                        text: TextSpan(
                                                          text: favouriteController.favFeeds?[index].status!,
                                                          style: const TextStyle(
                                                            color: Colors.black45,
                                                            fontSize: 15.0,
                                                            height: 1.8,
                                                            fontWeight: FontWeight.normal,
                                                            decoration: TextDecoration.none,
                                                          ),
                                                        ),
                                                      ),*/
                                                        ),
                                                  ],
                                                ),
                                              ),
                                            // Text(feeds![index].status.toString()),
                                            commonImageView(favouriteController
                                                .favFeeds?[index]),
                                            // customImageView(favouriteController
                                            //     .favFeeds?[index]),
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
                                                                  "${favouriteController.favFeeds?[index].id}",
                                                            ).then((value) {
                                                              if (favouriteController
                                                                      .favFeeds?[
                                                                          index]
                                                                      .isFav ==
                                                                  0) {
                                                                favouriteController
                                                                    .favFeeds?[
                                                                        index]
                                                                    .isFav = 1;
                                                              } else {
                                                                favouriteController
                                                                    .favFeeds?[
                                                                        index]
                                                                    .isFav = 0;
                                                              }
                                                              setState(() {});
                                                            });
                                                          } else {
                                                            setAsUnFav(
                                                                    "${favouriteController.favFeeds?[index].id}")
                                                                .then((value) {
                                                              if (favouriteController
                                                                      .favFeeds?[
                                                                          index]
                                                                      .isFav ==
                                                                  0) {
                                                                favouriteController
                                                                    .favFeeds?[
                                                                        index]
                                                                    .isFav = 1;
                                                              } else {
                                                                favouriteController
                                                                    .favFeeds?[
                                                                        index]
                                                                    .isFav = 0;
                                                              }
                                                              setState(() {});
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
                                                  /*Expanded(
                                                  flex: 1,
                                                  child: InkWell(
                                                    onTap: () {
                                                      checkPostLikeStatus(
                                                        "${favouriteController.favFeeds?[index].id}",
                                                      ).then((haveYouLiked) {
                                                        if (!haveYouLiked) {
                                                          setAsLiked(
                                                            postId: "${favouriteController.favFeeds?[index].id!}",
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
                                                                "${favouriteController.favFeeds?[index].id}",
                                                            isInsertLike:
                                                                favouriteController
                                                                        .favFeeds?[
                                                                            index]
                                                                        .isLike ==
                                                                    0,
                                                            postOwnerId:
                                                                favouriteController
                                                                    .favFeeds?[
                                                                        index]
                                                                    .ownerId,
                                                            callBack:
                                                                (commentCount) {
                                                              if (favouriteController
                                                                      .favFeeds?[
                                                                          index]
                                                                      .isLike ==
                                                                  0) {
                                                                favouriteController
                                                                    .favFeeds?[
                                                                        index]
                                                                    .isLike = 1;
                                                              } else {
                                                                favouriteController
                                                                    .favFeeds?[
                                                                        index]
                                                                    .isLike = 0;
                                                              }
                                                              favouriteController
                                                                      .favFeeds?[
                                                                          index]
                                                                      .countLike =
                                                                  "$commentCount";
                                                              setState(() {});
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
                                                              "${favouriteController.favFeeds?[index].countLike}",
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
                                                          print("post id: ${favouriteController.favFeeds?[index].id!}");
                                                        }

                                                        debugPrint("Before: ${favouriteController.favFeeds?[index].id!}");
                                                        EndPoints.selectedPostId = "${favouriteController.favFeeds?[index].id}";
                                                        Get.to(() => CommentScreen(
                                                              isFrom: AppTexts.favorite,
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
                                                        LoginModel userDetails =
                                                            await SessionManagement
                                                                .getUserDetails();
                                                        if (kDebugMode) {
                                                          print(
                                                              "user id: ${userDetails.id}");
                                                          print(
                                                              "post id: ${favouriteController.favFeeds?[index].id!}");
                                                        }

                                                        debugPrint(
                                                            "Before: ${favouriteController.favFeeds?[index].id!}");
                                                        EndPoints
                                                                .selectedPostId =
                                                            "${favouriteController.favFeeds?[index].id}";
                                                        Get.to(
                                                            () => CommentScreen(
                                                                  index: index,
                                                                  isFrom: AppTexts
                                                                      .favorite,
                                                                  postId: EndPoints
                                                                      .selectedPostId,
                                                                  postOwnerId:
                                                                      "${favouriteController.favFeeds?[index].ownerId}",
                                                                ))?.then((value) =>
                                                            favouriteController
                                                                .favFeeds
                                                                ?.refresh());
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
                                                              "${favouriteController.favFeeds?[index].countComment}",
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
                                                              "${favouriteController.favFeeds?[index].id}");
                                                        },
                                                        icon: const Icon(
                                                            Icons.add_box)),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: IconButton(
                                                        onPressed: () {
                                                          AppMethods().share(
                                                              "${EndPoints.socialSharePostUrl}${favouriteController.favFeeds?[index].id}");
                                                        },
                                                        icon: const Icon(
                                                            Icons.share)),
                                                  ),
                                                  // const Spacer(),
                                                  Expanded(
                                                    flex: 1,
                                                    child: IconButton(
                                                        onPressed: () {
                                                          reportPost(
                                                              "${favouriteController.favFeeds?[index].id}");
                                                        },
                                                        icon: const Icon(Icons
                                                            .report_problem)),
                                                  ),
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
                                                          "${favouriteController.favFeeds?[index].timeStamp}",
                                                      fs: 10),
                                                )),
                                            if (favouriteController
                                                    .favFeeds?[index]
                                                    .latestComments
                                                    ?.isNotEmpty ==
                                                true)
                                              Column(
                                                children: [
                                                  const Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text("Comments"),
                                                  ).paddingOnly(left: 10),
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        favouriteController
                                                                .favFeeds?[
                                                                    index]
                                                                .latestComments
                                                                ?.length ??
                                                            0,
                                                    itemBuilder: (context,
                                                            indexOfComment) =>
                                                        Row(
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
                                                            border: Border.all(
                                                              color: Theme.of(Get
                                                                      .context!)
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
                                                              fit: BoxFit.fill,
                                                              imageUrl:
                                                                  "https://wghdfm.s3.amazonaws.com/thumb/${favouriteController.favFeeds?[index].latestComments?[indexOfComment]?.img}",
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
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                                "${favouriteController.favFeeds?[index].latestComments?[indexOfComment]?.firstname} ${favouriteController.favFeeds?[index].latestComments?[indexOfComment]?.lastname}"),
                                                            Text(
                                                                "${favouriteController.favFeeds?[index].latestComments?[indexOfComment]?.comment}"),
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
                                  // return favoriteFeed(
                                  //   index,
                                  //   isLoved: true,
                                  //   isLiked: favouriteController.favFeeds?[index].isLike == 1,
                                  //   onFavClick: () {
                                  //     setState(() {});
                                  //   },
                                  //   onLikeClick: () {
                                  //     setState(() {});
                                  //   },
                                  //   onEditClick: () {
                                  //     setState(() {});
                                  //   },
                                  //   onDeleteClick: () {
                                  //     setState(() {});
                                  //   },
                                  //   //isLiked: isLiked,
                                  // );
                                },
                              );
                            }),
                      )
                    : Center(
                        child: customText(
                            title:
                                'No Feeds for your search \n try another keyword',
                            txtColor: Colors.white),
                      ),
              ),
              StreamBuilder(
                stream: favouriteController.isLoading.stream,
                builder: (context, snapshot) {
                  if (favouriteController.isLoading.value == true) {
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
              )
            ],
          );
        },
      ),
    );
  }

  Widget commonImageView(PostModelFeed? feed) {
    var listOfMedia = feed?.media?.split("_|_");
    print(">> MEDIA IS >> ${feed?.media}");
    print(">> Youtube iFrame 1 use this link >> ${feed?.url?.split("=").last}");
    print(">> Content Link >> ${listOfMedia}");
    // return Text(listOfMedia.length.toString());
    favouriteController.isRefreshing.value = true;
    Timer(const Duration(seconds: 1), () {
      favouriteController.isRefreshing.value = false;
    });
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
              ? GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    print("=== == = = =${feed?.url}");
                    print("=== 121 2 12${listOfMedia?[index]}");
                    print("=== indexxx ${index}");
                    return ["mp4", "3gp"]
                            .contains(listOfMedia?[index].split(".").last)
                        ? Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Stack(
                                fit: StackFit.expand,
                                alignment: Alignment.center,
                                children: [
                                  CommonVideoPlayer(
                                      videoLink: listOfMedia?[index] ?? ""),
                                  Visibility(
                                    visible: index == 3 &&
                                        (listOfMedia?.length ?? 0) >= 5,
                                    child: Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Center(
                                    child: Visibility(
                                      visible: index == 3 &&
                                          (listOfMedia?.length ?? 0) >= 5,
                                      child: Text(
                                        "+${(listOfMedia?.length ?? 0) - 4} More",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
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
                        : ["jpg", "jpeg", "png", "gif"]
                                .contains(listOfMedia?[index].split(".").last)
                            ? Stack(
                                fit: StackFit.expand,
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: listOfMedia?[index] ?? "",
                                        // placeholder: (context, url) {
                                        //   return Image.asset("assets/logo.png");
                                        // },
                                        progressIndicatorBuilder: (BuildContext,
                                            String, DownloadProgress) {
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
                                            (BuildContext, String, dynamic) {
                                          return Image.asset("assets/logo.png");
                                          // return Image.asset("assets/drawable/home.jpg");
                                        },
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: index == 3 &&
                                        (listOfMedia?.length ?? 0) >= 5,
                                    child: Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Visibility(
                                    visible: index == 3 &&
                                        (listOfMedia?.length ?? 0) >= 5,
                                    child: Center(
                                      child: Text(
                                        "+${(listOfMedia?.length ?? 0) - 4} More",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  // Center(
                                  //   child: Visibility(
                                  //     visible: index == 3 && (listOfMedia?.length ?? 0) >= 5,
                                  //     child: Positioned(
                                  //         child: Text(
                                  //       "+${(listOfMedia?.length ?? 0) - 4} More",
                                  //       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  //     )),
                                  //   ),
                                  // )
                                ],
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
                                      // child: YoutubeVideoScereen(
                                      //   videoId: feed.url!.split("=").last,
                                      // ),
                                      child: StreamBuilder(
                                          stream: favouriteController
                                              .isRefreshing.stream,
                                          builder: (context, snapshot) {
                                            print(
                                                "> kFavouriteController.isRefreshing => ${favouriteController.isRefreshing.value}");
                                            return favouriteController
                                                        .isRefreshing.value ==
                                                    true
                                                ? const CupertinoActivityIndicator()
                                                : CommonYTPlayer(
                                                    videoId: feed?.url
                                                            ?.split("=")
                                                            .last ??
                                                        "");
                                          }),

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
                                : (feed?.url?.contains(
                                            "www.youtube.com/live/") ==
                                        true)
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
                                          // child: YoutubeVideoScereen(
                                          //   videoId: feed.url!.split("=").last,
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
                                              border: Border.all(
                                                  color: Colors.grey,
                                                  width: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              // child: YoutubeVideoScereen(
                                              //   videoId: feed.url!.split("/").last,
                                              // ),
                                              child: StreamBuilder(
                                                  stream: favouriteController
                                                      .isRefreshing.stream,
                                                  builder: (context, snapshot) {
                                                    print(
                                                        "> kFavouriteController.isRefreshing => 22 ${favouriteController.isRefreshing.value}");

                                                    return favouriteController
                                                                .isRefreshing
                                                                .value ==
                                                            true
                                                        ? const CupertinoActivityIndicator()
                                                        : CommonYTPlayer(
                                                            videoId: feed?.url
                                                                    ?.split("/")
                                                                    .last ??
                                                                "");
                                                  }),

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
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 3,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 3,
                    // mainAxisExtent: 100,
                    crossAxisCount: listOfMedia?.length == 1 ? 1 : 2,
                  ),
                  itemCount:
                      (listOfMedia?.length ?? 0) <= 4 ? listOfMedia?.length : 4,
                )
              : const SizedBox(),
          const SizedBox(
            height: 5,
          ),
          // feed?.media == ""
          //     ? const SizedBox()
          //     : (listOfMedia?.length ?? 0) <= 4
          //         ? Padding(
          //             padding: const EdgeInsets.only(left: 10, right: 10),
          //             child: Container(
          //               width: Get.width,
          //               decoration: BoxDecoration(
          //                 border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
          //               ),
          //               child: const Padding(
          //                 padding: EdgeInsets.all(8.0),
          //                 child: Center(
          //                     child: Text(
          //                   "View Large",
          //                   style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          //                 )),
          //               ),
          //             ),
          //           )
          //         : Padding(
          //             padding: const EdgeInsets.only(left: 10, right: 10),
          //             child: Container(
          //               width: Get.width,
          //               decoration: BoxDecoration(
          //                 border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
          //               ),
          //               child: Padding(
          //                 padding: const EdgeInsets.all(8.0),
          //                 child: Center(
          //                     child: Text(
          //                   "+${(listOfMedia?.length ?? 0) - 4} More",
          //                   style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          //                 )),
          //               ),
          //             ),
          //           )
        ],
      ),
    );
  }
}
