import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_binding.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../../../modules/dashbord_module/controller/dash_board_controller.dart';

Future editPost(String postId, var status, var videoUrl) async {
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;
  Map<String, String> header = {"Content-Type": "multipart/form-data", "Accept": "*/*", "Connection": "keep-alive"};

  APIService().callAPI(
      params: {},
      // headers: bodyData,
      formDatas: dio.FormData.fromMap({
        "user_id": userId,
        "wire_content": status,
        // "status": status,
        "vurl": videoUrl,
      }),
      serviceUrl: "${EndPoints.baseUrl}${EndPoints.editPost + userId}/$postId",
      method: APIService.postMethod,
      success: (dio.Response response) async {
        Get.back();
        kDashboardController.currentPage = 0;
        await kDashboardController.dashBoardLoadFeeds(
          isShowProcess: true,
          isFirstTimeLoading: true,
          page: kDashboardController.currentPage,
        );
        snack(msg: "Post has been edited successfully.", title: "Status");
      },
      error: (dio.Response response) {
        Get.back();
        snack(msg: "Network connectivity not found. Try again.", title: "Alert!", icon: Icons.report_problem, iconColor: Colors.red);
      },
      showProcess: true);
}
