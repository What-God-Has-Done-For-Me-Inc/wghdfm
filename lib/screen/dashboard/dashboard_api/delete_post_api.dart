import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/dash_board_screen.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

Future<void> deletePost({required String postId, Function? callBack}) async {
  String reqUrl = EndPoints.deletePostApi + postId;
  debugPrint("deletePost req: $reqUrl");

  AppMethods.deleteDialog(
      headingText: 'Are you sure you want to delete this post?',
      descriptionText: "" ?? "This will delete the permanently delete your post and you can't undo it after delete.'",
      onDelete: () {
        APIService().callAPI(
            params: {},
            serviceUrl: EndPoints.baseUrl + EndPoints.deletePostApi + postId,
            method: APIService.postMethod,
            success: (dio.Response response) {
              // Get.back();
              if (callBack != null) {
                callBack();
              }
              // Get.offAll(() => DashBoardScreen());
              debugPrint("deletePost responseBody: ${response.data}");
              snack(msg: "Post has been deleted successfully.", title: "Status");
            },
            error: (dio.Response response) {
              Get.back();
              debugPrint("deletePost responseBody: ${response.data}");
            },
            showProcess: true);
      });
}
