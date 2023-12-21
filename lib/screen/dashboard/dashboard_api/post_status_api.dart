import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../../../modules/dashbord_module/controller/dash_board_controller.dart';

Future<void> postStatus(
  String status,
  String youtubeLink,
  String taggedUsers, {
  Function? callBack,
  String? toOwnerId,
}) async {
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;
  APIService().callAPI(
      params: {},
      formDatas: dio.FormData.fromMap({
        "user_id": userId,
        "wire_content": status,
        "url": youtubeLink,
        if (toOwnerId != null) "to_owner_id": toOwnerId,
        "wire_tag_user_id": taggedUsers,
      }),
      // serviceUrl: EndPoints.baseUrl + EndPoints.addFeedStatusUrl + userId,
      serviceUrl: EndPoints.baseUrl + EndPoints.editPost,
      method: APIService.postMethod,
      success: (dio.Response response) {
        Get.back();
        var responseData = jsonDecode(response.data);
        print("---- >> ${responseData['post_id']}");

        snack(msg: "Status has been posted successfully.", title: "Status");
        if (callBack != null) {
          callBack();
        }

        print("UPLOADED POST ID FOR NOTIFICATION IS ${responseData['post_id']} ");
        taggedUsers.split("|").forEach((element) {
          NotificationHandler.to.sendNotificationToUserID(
            userId: element,
            title: "Tagged in post ",
            body: "You are tagged in post.. ",
            postId: "${responseData['post_id']}",
          );
        });
      },
      error: (dio.Response response) {},
      showProcess: true);
}
