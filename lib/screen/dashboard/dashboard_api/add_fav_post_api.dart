import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/model/user_who_liked_obj.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../../../modules/dashbord_module/controller/dash_board_controller.dart';

Future<void> setAsFav({
  required String postId,
  bool? isFrmGrp,
}) async {
  var type = "D";
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;

  APIService().callAPI(
    params: {},
    serviceUrl: isFrmGrp == true
        ? "${EndPoints.baseUrl}${EndPoints.addFavApi}$postId/$userId/G"
        : "${EndPoints.baseUrl}${EndPoints.addFavApi}$postId/$userId",
    method: APIService.getMethod,
    success: (dio.Response response) {
      // Get.back();
      snack(msg: "You have favourite this post", title: "Status");
    },
    error: (dio.Response response) {
      final decoded = jsonDecode(response.data);
      AppMethods.showLog(">>>> RESPONSE ERROR >> ${decoded['status']}");
      AppMethods.showLog(">>>> RESPONSE ERROR >> ${response}");
    },
    showProcess: true,
  );
}

Future<void> setAsUnFav(String postId) async {
  var type = "D";
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;

  APIService().callAPI(
    params: {},
    serviceUrl: "${EndPoints.baseUrl}${EndPoints.unFavApi}$postId}/$userId",
    method: APIService.getMethod,
    success: (dio.Response response) {
      // Get.back();
      snack(msg: "You have unfavourite this post", title: "Status");
    },
    error: (dio.Response response) {
      final decoded = jsonDecode(response.data);
      AppMethods.showLog(">>>> RESPONSE ERROR >> ${decoded['status']}");
      AppMethods.showLog(">>>> RESPONSE ERROR >> ${response}");
    },
    showProcess: true,
  );
}

List<UserWhoLiked> whoLiked = [];
var totalPostLikes = 0;
bool haveYouLiked = false;
var postLikeStatus = "No likes yet";

Future<dynamic> checkPostLikeStatus(String postId) async {
  if (whoLiked.isNotEmpty) whoLiked.clear();
  totalPostLikes = 0;
  haveYouLiked = false;
  postLikeStatus = "No likes yet";
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;
  //String id =AppData.selectedPostId;
  var type = "D";

  APIService().callAPI(
      params: {},
      serviceUrl: "${EndPoints.baseUrl}${EndPoints.likeUserApi}$postId/$type",
      method: APIService.getMethod,
      success: (dio.Response response) {
        Get.back();
        debugPrint(
            "postLikes statusCode: ${response.statusCode}; response: ${response.data}");
        try {
          List list = jsonDecode(response.data);
          list.forEach((element) {
            whoLiked.add(UserWhoLiked.fromJson(element));
          });

          totalPostLikes = whoLiked.length;

          for (int i = 0; i < whoLiked.length; i++) {
            if (whoLiked[i].userId == userId) {
              debugPrint("ListUserID: ${whoLiked[i].userId!}");
              debugPrint("UserID: $userId");
              haveYouLiked = true;
            }
          }
        } catch (e) {
          debugPrint(e.toString());
        } finally {
          debugPrint("Code is at end, continue on...");
        }

        if (haveYouLiked) {
          snack(msg: "This post is already liked by you.", title: "Status");
        }
        if (whoLiked.isEmpty) {
          postLikeStatus = "No likes yet";
        } else {
          postLikeStatus = "Liked by ";
          if (haveYouLiked) {
            postLikeStatus += "you";
            if (whoLiked.length > 2) {
              postLikeStatus += " & ${whoLiked.length - 1} other(s)";
            }
          } else {
            postLikeStatus += " ${whoLiked.length} other(s)";
          }
        }
      },
      error: (dio.Response response) {},
      showProcess: true);

  return haveYouLiked;
}

Future<void> setAsLiked(
    {required String postId,
    Function? callBack,
    bool? isGrpPost,
    String? postOwnerId,
    bool? isInsertLike}) async {
  // var type = "D";
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;

  await APIService().callAPI(
      params: {},
      serviceUrl: isGrpPost == true
          ? "${EndPoints.baseUrl}${EndPoints.insertLikeApi}$postId/$userId/G"
          : "${EndPoints.baseUrl}${EndPoints.insertLikeApi}$postId/$userId",
      method: APIService.getMethod,
      success: (dio.Response response) {
        print("data is >${response.data}");
        var jsonData = jsonDecode(response.data);
        print("data is > response.data ${jsonData["count_like"]}");
        int commentCount = jsonData["count_like"] ?? 0;
        // Get.back();
        if (callBack != null) {
          callBack(commentCount);
        }
        if (postOwnerId != null &&
            postOwnerId != userId &&
            isInsertLike == true) {
          NotificationHandler.to.sendNotificationToUserID(
              postId: postId,
              userId: postOwnerId,
              title: "Like Your Post",
              body:
                  "${userDetails.fname} ${userDetails.lname} Liked your post");
        }
        // snack(msg: "You have successfully liked this post.", title: "Status");
      },
      error: (dio.Response response) {},
      showProcess: true);
}
