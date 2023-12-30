import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/endpoints.dart';
import 'package:wghdfm_java/utils/validation_utils.dart';

import '../../../networking/api_service_class.dart';

class RecoverPasswordController extends GetxController {
  TextEditingController emailTEC = TextEditingController();

  bool areRecoveryFieldValid() {
    bool isValid = true;

    List<String> errorList = <String>[];

    if (!validateEmail(emailTEC.text.trim())) {
      isValid = false;
      errorList.add('Please re-enter a valid email address.');
    }

    if (errorList.isNotEmpty) {
      snack(
        title: "Alert!",
        msg: errorList[0],
        icon: Icons.close,
        iconColor: Colors.red,
      );
    }

    return isValid;
  }

  void recovery({required String userEmail}) async {
    print("------- User Email is ${userEmail}");
    await APIService().callAPI(
        params: {},
        // headers: {'Accept': 'application/json'},
        formDatas: dio.FormData.fromMap({"email": userEmail}),
        serviceUrl: EndPoints.baseUrl + EndPoints.viewForgetPassUrl,
        method: APIService.postMethod,
        success: (dio.Response response) {
          debugPrint("recovery Password responseBody: ${response.data}");

          showDailogBox(
              context: Get.context!,
              title: 'Recovery email sent!',
              subTitle: 'Please check your Email or Spam\nFor further details');
        },
        error: (dio.Response response) {
          final decoded = jsonDecode(response.data);
          AppMethods.showLog(">>>> RESPONSE SUCCESS >> ${decoded['status']}");
          AppMethods.showLog(">>>> RESPONSE ERROR >> ${response}");

          ///Display snackbar here..
        },
        showProcess: true);
  }
}
