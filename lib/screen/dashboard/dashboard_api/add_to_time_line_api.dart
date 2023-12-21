import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../../../modules/dashbord_module/controller/dash_board_controller.dart';

Future<void> addToTimeline(String postId) async {
  var type = "D";
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;

  APIService().callAPI(
      params: {},
      serviceUrl: "${EndPoints.baseUrl}${EndPoints.addTimeLineApi}$postId/$userId/$type",
      method: APIService.getMethod,
      success: (dio.Response response) {
        Get.back();
        snack(msg: "You have shared this post in your timeline.", title: "Status");
      },
      error: (dio.Response response) {},
      showProcess: true);
}
