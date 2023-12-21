import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../../../modules/dashbord_module/controller/dash_board_controller.dart';

Future<void> reportPost(String postId) async {
  var type = "P";
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;

  APIService().callAPI(
      params: {},
      serviceUrl:
          "${EndPoints.baseUrl}${EndPoints.addReportData}$postId/$userId/$type",
      method: APIService.getMethod,
      success: (dio.Response response) {
        // Get.back();
        snack(msg: "Post has been reported successfully.", title: "Status");
      },
      error: (dio.Response response) {
        Get.back();
      },
      showProcess: true);
}
