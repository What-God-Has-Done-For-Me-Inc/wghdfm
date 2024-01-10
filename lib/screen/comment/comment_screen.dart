import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/screen/comment/comment_controller.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/shimmer_feed_loading.dart';
import 'package:wghdfm_java/screen/groups/methods.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_binding.dart';
import 'package:wghdfm_java/utils/app_texts.dart';
import 'package:wghdfm_java/utils/endpoints.dart';
import 'package:wghdfm_java/utils/shimmer_utils.dart';

import '../../common/common_snack.dart';
import '../../modules/dashbord_module/controller/dash_board_controller.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final String? isFrom;
  final int? index;
  final String? grpId;
  final String? postOwnerId;

  const CommentScreen(
      {Key? key,
      required this.postId,
      this.postOwnerId,
      required this.isFrom,
      this.index,
      this.grpId})
      : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final DashBoardController dashBoardController =
      Get.put(DashBoardController());
  final commentController = Get.put(CommentController());
  final commentTextController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    commentController.nextPage = 0;
    if (widget.isFrom == AppTexts.group) {
      commentController.getComments(
        postId: widget.postId,
        isFirstTime: true,
        isFromGrp: true,
      );
      // scrollController.addListener(() {
      //   if (scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.7 && commentController.commentLoading.value == false) {
      //     commentController.nextPage = commentController.nextPage + 10;
      //     commentController.getComments(
      //       postId: widget.postId,
      //       isFirstTime: false,
      //       isFromGrp: true,
      //     );
      //   }
      // });
    } else {
      commentController.getComments(postId: widget.postId, isFirstTime: true);
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
                scrollController.position.maxScrollExtent * 0.7 &&
            commentController.commentLoading.value == false) {
          commentController.nextPage = commentController.nextPage + 10;
          commentController.getComments(
              postId: widget.postId, isFirstTime: false);
        }
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(">> WIDGET COMMENT COUNT isFrom < ${widget.isFrom}");
    print(">> WIDGET COMMENT COUNT index < ${widget.index}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment(s)'),
        centerTitle: true,
      ),
      bottomSheet: Container(
        color: Theme.of(Get.context!).colorScheme.background,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          margin: EdgeInsets.only(bottom: Get.height * 0.04),
          height: Get.height * 0.05,
          color: Theme.of(Get.context!).colorScheme.background,
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: commonTextField(
                    readOnly: false,
                    hint: 'Write Comment',
                    isLabelFloating: false,
                    controller: commentTextController,
                    borderColor: Theme.of(Get.context!).primaryColor,
                    baseColor: Theme.of(Get.context!).colorScheme.secondary,
                    isLastField: false,
                    obscureText: false,
                    commentBox: true),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (commentTextController.text.trim().isNotEmpty) {
                    LoginModel userDetails =
                        await SessionManagement.getUserDetails();

                    Map<String, String> bodyData = {
                      "post_id": widget.postId,
                      "user_id": userDetails.id!,
                      "comment": commentTextController.text
                    };
                    FocusManager.instance.primaryFocus?.unfocus();

                    await APIService().callAPI(
                        params: {},
                        serviceUrl: widget.isFrom != AppTexts.group
                            ? EndPoints.baseUrl + EndPoints.insertCommentUrl
                            : "${EndPoints.baseUrl}${EndPoints.insertCommentForGrpUrl}/${widget.postId}/${userDetails.id}/G",
                        method: APIService.postMethod,
                        formDatas: dio.FormData.fromMap(bodyData),
                        success: (dio.Response response) async {
                          // Get.back();
                          commentTextController.clear();
                          // NotificationHandler.to.sendNotificationToUserID(userId: userId, title: title, body: body);
                          await commentController.getComments(
                              postId: widget.postId,
                              isFirstTime: true,
                              isFromGrp: widget.isFrom == AppTexts.group,
                              callBack: () {
                                if (widget.isFrom == AppTexts.dashBoard) {
                                  print(":: INDEX IS ${widget.index}");
                                  print(
                                      ":: commentController.commentList?.length IS ${commentController.commentList?.length}");
                                  if (widget.index != null) {
                                    dashBoardController
                                            .dashboardFeeds[widget.index ?? 0]
                                            .countComment =
                                        commentController.commentList?.length ??
                                            0;
                                    dashBoardController
                                        .dashboardFeeds[widget.index ?? 0]
                                        .latestComments
                                        ?.clear();
                                    commentController.commentList
                                        ?.forEach((element) {
                                      kDashboardController
                                          .dashboardFeeds[widget.index ?? 0]
                                          .latestComments
                                          ?.add(PostModelFeedLatestComments(
                                              comment: element?.comment,
                                              commentId: element?.commentId,
                                              firstname: element?.firstname,
                                              lastname: element?.lastname,
                                              img: element?.img,
                                              date: element?.date,
                                              userId: element?.userId));
                                    });
                                    print(
                                        ">> < COMMENT COUNT ? ${dashBoardController.dashboardFeeds[widget.index ?? 0].countComment}");
                                  }
                                }
                                if (widget.isFrom == AppTexts.favorite) {
                                  kFavouriteController
                                          .favFeeds?[widget.index ?? 0]
                                          .countComment =
                                      commentController.commentList?.length ??
                                          0;
                                  kFavouriteController
                                      .favFeeds?[widget.index ?? 0]
                                      .latestComments
                                      ?.clear();
                                  commentController.commentList
                                      ?.forEach((element) {
                                    kFavouriteController
                                        .favFeeds?[widget.index ?? 0]
                                        .latestComments
                                        ?.add(PostModelFeedLatestComments(
                                            comment: element?.comment,
                                            commentId: element?.commentId,
                                            firstname: element?.firstname,
                                            lastname: element?.lastname,
                                            img: element?.img,
                                            date: element?.date,
                                            userId: element?.userId));
                                  });
                                }
                                if (widget.isFrom == AppTexts.profile) {
                                  kProfileController
                                          .profileFeeds?[widget.index ?? 0]
                                          .countComment =
                                      commentController.commentList?.length ??
                                          0;
                                  kProfileController
                                      .profileFeeds?[widget.index ?? 0]
                                      .latestComments
                                      ?.clear();
                                  commentController.commentList
                                      ?.forEach((element) {
                                    kProfileController
                                        .profileFeeds?[widget.index ?? 0]
                                        .latestComments
                                        ?.add(PostModelFeedLatestComments(
                                            comment: element?.comment,
                                            commentId: element?.commentId,
                                            firstname: element?.firstname,
                                            lastname: element?.lastname,
                                            img: element?.img,
                                            date: element?.date,
                                            userId: element?.userId));
                                  });
                                }
                                if (widget.isFrom == AppTexts.someoneProfile) {
                                  kProfileController
                                          .profileFeeds?[widget.index ?? 0]
                                          .countComment =
                                      commentController.commentList?.length ??
                                          0;
                                  kProfileController
                                      .profileFeeds?[widget.index ?? 0]
                                      .latestComments
                                      ?.clear();
                                  commentController.commentList
                                      ?.forEach((element) {
                                    kProfileController
                                        .profileFeeds?[widget.index ?? 0]
                                        .latestComments
                                        ?.add(PostModelFeedLatestComments(
                                            comment: element?.comment,
                                            commentId: element?.commentId,
                                            firstname: element?.firstname,
                                            lastname: element?.lastname,
                                            img: element?.img,
                                            date: element?.date,
                                            userId: element?.userId));
                                  });
                                }
                                if (widget.isFrom == AppTexts.group) {
                                  groupFeeds?[widget.index ?? 0].countComment =
                                      commentController.commentList?.length ??
                                          0;
                                  groupFeeds?[widget.index ?? 0]
                                      .latestComments
                                      ?.clear();
                                  commentController.commentList
                                      ?.forEach((element) {
                                    groupFeeds?[widget.index ?? 0]
                                        .latestComments
                                        ?.add(PostModelFeedLatestComments(
                                            comment: element?.comment,
                                            commentId: element?.commentId,
                                            firstname: element?.firstname,
                                            lastname: element?.lastname,
                                            img: element?.img,
                                            date: element?.date,
                                            userId: element?.userId));
                                  });
                                }
                                print(
                                    ">> INDEX ${widget.index ?? 0} COUNT >> ${kDashboardController.dashboardFeeds[widget.index ?? 0].countComment}");
                                print(
                                    ">> WIDGET COMMENT COUNT < BEFORE ${kDashboardController.dashboardFeeds[widget.index ?? 0].countComment} ");
                              });
                          if (widget.postOwnerId != userDetails.id &&
                              widget.postOwnerId != null) {
                            NotificationHandler.to.sendNotificationToUserID(
                                postId: widget.postId ?? "0",
                                userId: widget.postOwnerId ?? "0",
                                title: "Comment Your Post",
                                body:
                                    "${userDetails.fname} ${userDetails.lname} Commented your post");
                          }
                        },
                        error: (dio.Response response) {
                          snack(
                              icon: Icons.report_problem,
                              iconColor: Colors.yellow,
                              msg: "Type something first...",
                              title: "Alert!");
                        },
                        showProcess: true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: commentController.commentList?.stream,
              builder: (BuildContext context, snapshot) {
                if (commentController.commentList == null) {
                  return shimmerFeedLoading();
                }

                if (snapshot.hasError) {
                  return Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: customText(title: "${snapshot.error}"),
                  );
                }

                if (commentController.commentList?.isEmpty == true) {
                  return Stack(children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        alignment: Alignment.center,
                        child: customText(title: "Be the first to comment"),
                      ),
                    )
                  ]);
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: 5000,
                  controller: scrollController,
                  itemCount: commentController.commentList?.length ?? 0,
                  itemBuilder: (context, index) => listItem(index, setState),
                );
              },
            ),
          ),
          StreamBuilder(
            stream: commentController.commentLoading.stream,
            builder: (context, snapshot) {
              if (commentController.commentLoading.isTrue) {
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
          // Container(
          //   padding: const EdgeInsets.only(
          //     left: 10,
          //     right: 10,
          //   ),
          //   height: 60,
          //   color: Theme.of(Get.context!).backgroundColor,
          //   child: Row(
          //     children: [
          //       Expanded(
          //         flex: 9,
          //         child: commonTextField(
          //             readOnly: false,
          //             hint: 'Write Comment',
          //             isLabelFloating: false,
          //             controller: commentTextController,
          //             borderColor: Theme.of(Get.context!).primaryColor,
          //             baseColor: Theme.of(Get.context!).colorScheme.secondary,
          //             isLastField: true,
          //             obscureText: false,
          //             commentBox: true),
          //       ),
          //       IconButton(
          //         icon: const Icon(Icons.send),
          //         onPressed: () async {
          //           FocusScope.of(context).requestFocus(FocusNode());
          //           if (commentTextController.text.trim().isNotEmpty) {
          //             LoginModel userDetails =
          //                 await SessionManagement.getUserDetails();

          //             Map<String, String> bodyData = {
          //               "post_id": widget.postId,
          //               "user_id": userDetails.id!,
          //               "comment": commentTextController.text
          //             };
          //             FocusManager.instance.primaryFocus?.unfocus();

          //             await APIService().callAPI(
          //                 params: {},
          //                 serviceUrl: widget.isFrom != AppTexts.group
          //                     ? EndPoints.baseUrl + EndPoints.insertCommentUrl
          //                     : "${EndPoints.baseUrl}${EndPoints.insertCommentForGrpUrl}/${widget.postId}/${userDetails.id}/G",
          //                 method: APIService.postMethod,
          //                 formDatas: dio.FormData.fromMap(bodyData),
          //                 success: (dio.Response response) async {
          //                   // Get.back();
          //                   commentTextController.clear();
          //                   // NotificationHandler.to.sendNotificationToUserID(userId: userId, title: title, body: body);
          //                   await commentController.getComments(
          //                       postId: widget.postId,
          //                       isFirstTime: true,
          //                       isFromGrp: widget.isFrom == AppTexts.group,
          //                       callBack: () {
          //                         if (widget.isFrom == AppTexts.dashBoard) {
          //                           print(":: INDEX IS ${widget.index}");
          //                           print(
          //                               ":: commentController.commentList?.length IS ${commentController.commentList?.length}");
          //                           if (widget.index != null) {
          //                             dashBoardController
          //                                 .dashboardFeeds[widget.index ?? 0]
          //                                 .countComment = commentController
          //                                     .commentList?.length ??
          //                                 0;
          //                             dashBoardController
          //                                 .dashboardFeeds[widget.index ?? 0]
          //                                 .latestComments
          //                                 ?.clear();
          //                             commentController.commentList
          //                                 ?.forEach((element) {
          //                               kDashboardController
          //                                   .dashboardFeeds[widget.index ?? 0]
          //                                   .latestComments
          //                                   ?.add(PostModelFeedLatestComments(
          //                                       comment: element?.comment,
          //                                       commentId: element?.commentId,
          //                                       firstname: element?.firstname,
          //                                       lastname: element?.lastname,
          //                                       img: element?.img,
          //                                       date: element?.date,
          //                                       userId: element?.userId));
          //                             });
          //                             print(
          //                                 ">> < COMMENT COUNT ? ${dashBoardController.dashboardFeeds[widget.index ?? 0].countComment}");
          //                           }
          //                         }
          //                         if (widget.isFrom == AppTexts.favorite) {
          //                           kFavouriteController
          //                                   .favFeeds?[widget.index ?? 0]
          //                                   .countComment =
          //                               commentController.commentList?.length ??
          //                                   0;
          //                           kFavouriteController
          //                               .favFeeds?[widget.index ?? 0]
          //                               .latestComments
          //                               ?.clear();
          //                           commentController.commentList
          //                               ?.forEach((element) {
          //                             kFavouriteController
          //                                 .favFeeds?[widget.index ?? 0]
          //                                 .latestComments
          //                                 ?.add(PostModelFeedLatestComments(
          //                                     comment: element?.comment,
          //                                     commentId: element?.commentId,
          //                                     firstname: element?.firstname,
          //                                     lastname: element?.lastname,
          //                                     img: element?.img,
          //                                     date: element?.date,
          //                                     userId: element?.userId));
          //                           });
          //                         }
          //                         if (widget.isFrom == AppTexts.profile) {
          //                           kProfileController
          //                                   .profileFeeds?[widget.index ?? 0]
          //                                   .countComment =
          //                               commentController.commentList?.length ??
          //                                   0;
          //                           kProfileController
          //                               .profileFeeds?[widget.index ?? 0]
          //                               .latestComments
          //                               ?.clear();
          //                           commentController.commentList
          //                               ?.forEach((element) {
          //                             kProfileController
          //                                 .profileFeeds?[widget.index ?? 0]
          //                                 .latestComments
          //                                 ?.add(PostModelFeedLatestComments(
          //                                     comment: element?.comment,
          //                                     commentId: element?.commentId,
          //                                     firstname: element?.firstname,
          //                                     lastname: element?.lastname,
          //                                     img: element?.img,
          //                                     date: element?.date,
          //                                     userId: element?.userId));
          //                           });
          //                         }
          //                         if (widget.isFrom ==
          //                             AppTexts.someoneProfile) {
          //                           kProfileController
          //                                   .profileFeeds?[widget.index ?? 0]
          //                                   .countComment =
          //                               commentController.commentList?.length ??
          //                                   0;
          //                           kProfileController
          //                               .profileFeeds?[widget.index ?? 0]
          //                               .latestComments
          //                               ?.clear();
          //                           commentController.commentList
          //                               ?.forEach((element) {
          //                             kProfileController
          //                                 .profileFeeds?[widget.index ?? 0]
          //                                 .latestComments
          //                                 ?.add(PostModelFeedLatestComments(
          //                                     comment: element?.comment,
          //                                     commentId: element?.commentId,
          //                                     firstname: element?.firstname,
          //                                     lastname: element?.lastname,
          //                                     img: element?.img,
          //                                     date: element?.date,
          //                                     userId: element?.userId));
          //                           });
          //                         }
          //                         if (widget.isFrom == AppTexts.group) {
          //                           groupFeeds?[widget.index ?? 0]
          //                                   .countComment =
          //                               commentController.commentList?.length ??
          //                                   0;
          //                           groupFeeds?[widget.index ?? 0]
          //                               .latestComments
          //                               ?.clear();
          //                           commentController.commentList
          //                               ?.forEach((element) {
          //                             groupFeeds?[widget.index ?? 0]
          //                                 .latestComments
          //                                 ?.add(PostModelFeedLatestComments(
          //                                     comment: element?.comment,
          //                                     commentId: element?.commentId,
          //                                     firstname: element?.firstname,
          //                                     lastname: element?.lastname,
          //                                     img: element?.img,
          //                                     date: element?.date,
          //                                     userId: element?.userId));
          //                           });
          //                         }
          //                         print(
          //                             ">> INDEX ${widget.index ?? 0} COUNT >> ${kDashboardController.dashboardFeeds[widget.index ?? 0].countComment}");
          //                         print(
          //                             ">> WIDGET COMMENT COUNT < BEFORE ${kDashboardController.dashboardFeeds[widget.index ?? 0].countComment} ");
          //                       });
          //                   if (widget.postOwnerId != userDetails.id &&
          //                       widget.postOwnerId != null) {
          //                     NotificationHandler.to.sendNotificationToUserID(
          //                         postId: widget.postId ?? "0",
          //                         userId: widget.postOwnerId ?? "0",
          //                         title: "Comment Your Post",
          //                         body:
          //                             "${userDetails.fname} ${userDetails.lname} Commented your post");
          //                   }
          //                 },
          //                 error: (dio.Response response) {
          //                   snack(
          //                       icon: Icons.report_problem,
          //                       iconColor: Colors.yellow,
          //                       msg: "Type something first...",
          //                       title: "Alert!");
          //                 },
          //                 showProcess: true);
          //           }
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget listItem(int index, setState) {
    String? commentId = commentController.commentList?[index]?.commentId;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
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
                        // Get.to(
                        //   () => InteractiveViewer(
                        //     child: CachedNetworkImage(
                        //       alignment: Alignment.center,
                        //       fit: BoxFit.fill,
                        //       imageUrl: "${commentController.commentList?[index]?.img}",
                        //       placeholder: (context, url) => const CircularProgressIndicator(),
                        //       errorWidget: (context, url, error) => const Icon(Icons.error),
                        //     ),
                        //   ),
                        // );
                      },
                      child: ClipOval(
                        child: CachedNetworkImage(
                          alignment: Alignment.center,
                          fit: BoxFit.fill,
                          imageUrl:
                              "${EndPoints.ImageURl}${commentController.commentList?[index]?.img}",
                          placeholder: (context, url) => Container(
                            padding: const EdgeInsets.all(3),
                            child: shimmerMeUp(CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.secondary),
                            )),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                RichText(
                  text: TextSpan(
                    text: commentController
                        .commentList?[index]?.firstname?.capitalizeFirst,
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 15.0,
                      height: 1.8,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            "\n${commentController.commentList?[index]?.date!}",
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (userId == commentController.commentList?[index]?.userId)
                  const Spacer(),
                if (userId == commentController.commentList?[index]?.userId)
                  IconButton(
                      onPressed: () async {
                        commentController.deleteComment(
                          commentID:
                              "${commentController.commentList?[index]?.commentId}",
                        );
                        commentTextController.clear();
                        await commentController.getComments(
                            postId: widget.postId,
                            isFirstTime: true,
                            isFromGrp: widget.isFrom == AppTexts.group,
                            callBack: () {
                              if (widget.isFrom == AppTexts.dashBoard) {
                                dashBoardController
                                        .dashboardFeeds[widget.index ?? 0]
                                        .countComment =
                                    commentController.commentList?.length ?? 0;
                                dashBoardController
                                    .dashboardFeeds[widget.index ?? 0]
                                    .latestComments
                                    ?.clear();
                                commentController.commentList
                                    ?.forEach((element) {
                                  dashBoardController
                                      .dashboardFeeds[widget.index ?? 0]
                                      .latestComments
                                      ?.add(PostModelFeedLatestComments(
                                          comment: element?.comment,
                                          commentId: element?.commentId,
                                          firstname: element?.firstname,
                                          lastname: element?.lastname,
                                          img: element?.img,
                                          date: element?.date,
                                          userId: element?.userId));
                                });
                              }
                              if (widget.isFrom == AppTexts.favorite) {
                                kFavouriteController
                                        .favFeeds?[widget.index ?? 0]
                                        .countComment =
                                    commentController.commentList?.length ?? 0;
                                kFavouriteController
                                    .favFeeds?[widget.index ?? 0].latestComments
                                    ?.clear();
                                commentController.commentList
                                    ?.forEach((element) {
                                  kFavouriteController
                                      .favFeeds?[widget.index ?? 0]
                                      .latestComments
                                      ?.add(PostModelFeedLatestComments(
                                          comment: element?.comment,
                                          commentId: element?.commentId,
                                          firstname: element?.firstname,
                                          lastname: element?.lastname,
                                          img: element?.img,
                                          date: element?.date,
                                          userId: element?.userId));
                                });
                              }
                              if (widget.isFrom == AppTexts.profile) {
                                kProfileController
                                        .profileFeeds?[widget.index ?? 0]
                                        .countComment =
                                    commentController.commentList?.length ?? 0;
                                kProfileController
                                    .profileFeeds?[widget.index ?? 0]
                                    .latestComments
                                    ?.clear();
                                commentController.commentList
                                    ?.forEach((element) {
                                  kProfileController
                                      .profileFeeds?[widget.index ?? 0]
                                      .latestComments
                                      ?.add(PostModelFeedLatestComments(
                                          comment: element?.comment,
                                          commentId: element?.commentId,
                                          firstname: element?.firstname,
                                          lastname: element?.lastname,
                                          img: element?.img,
                                          date: element?.date,
                                          userId: element?.userId));
                                });
                              }
                              if (widget.isFrom == AppTexts.someoneProfile) {
                                kProfileController
                                        .profileFeeds?[widget.index ?? 0]
                                        .countComment =
                                    commentController.commentList?.length ?? 0;
                                kProfileController
                                    .profileFeeds?[widget.index ?? 0]
                                    .latestComments
                                    ?.clear();
                                commentController.commentList
                                    ?.forEach((element) {
                                  kProfileController
                                      .profileFeeds?[widget.index ?? 0]
                                      .latestComments
                                      ?.add(PostModelFeedLatestComments(
                                          comment: element?.comment,
                                          commentId: element?.commentId,
                                          firstname: element?.firstname,
                                          lastname: element?.lastname,
                                          img: element?.img,
                                          date: element?.date,
                                          userId: element?.userId));
                                });
                              }
                              if (widget.isFrom == AppTexts.group) {
                                groupFeeds?[widget.index ?? 0].countComment =
                                    commentController.commentList?.length ?? 0;
                                groupFeeds?[widget.index ?? 0]
                                    .latestComments
                                    ?.clear();
                                commentController.commentList
                                    ?.forEach((element) {
                                  groupFeeds?[widget.index ?? 0]
                                      .latestComments
                                      ?.add(PostModelFeedLatestComments(
                                          comment: element?.comment,
                                          commentId: element?.commentId,
                                          firstname: element?.firstname,
                                          lastname: element?.lastname,
                                          img: element?.img,
                                          date: element?.date,
                                          userId: element?.userId));
                                });
                              }
                            });
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ))
              ],
            ),
          ),
          const Divider(),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                // height: 40,
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Text(
                  "${commentController.commentList?[index]?.comment}".trim(),
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
