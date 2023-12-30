import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/services/prefrence_services.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

class AuthController extends GetxController {
  signIn({String? email, String? password}) async {
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({"email": email, "password": password}),
        headers: {},
        serviceUrl: EndPoints.baseUrl + EndPoints.signInApi,
        method: APIService.postMethod,
        success: (dio.Response response) {
          // AppMethods.showLog(">>>> RESPONSE SUCCESS >> ${decoded['status']}");
          /// set on success here

          debugPrint("login responseBody: ${response.data}");
          var jsonDecoded = jsonDecode(response.data);

          ///{"status":"Success","id":"69","email":"kumarsaloni@yahoo.com","church":"","user_type":null,"fname":"Kumar","lname":"Kishor","img":"1607948619.jpg"}
          LoginModel resObj = LoginModel.fromJson(jsonDecoded);
          if (resObj.status?.toLowerCase() == 'success') {
            storeStringToSF(
                SessionManagement.ACTIVE_USER_DETAILS, response.data);
            SessionManagement.createLoginSession(resObj.email!, resObj.id!);
            Future.delayed(const Duration(seconds: 0), () {
              SessionManagement.checkLoginRedirect();
            });
            snack(
              title: 'Login successful!',
              msg: 'Logging in now...',
              icon: Icons.check,
              iconColor: Colors.green,
              seconds: 1,
            );
            return loginModelFromJson(response.data);
          } else {
            snack(
              title: 'Login failed!',
              msg: 'Please check your credentials & try again.',
              icon: Icons.close,
              iconColor: Colors.red,
            );
          }
        },
        error: (dio.Response response) {
          final decoded = jsonDecode(response.data);
          AppMethods.showLog(">>>> RESPONSE SUCCESS >> ${decoded['status']}");
          AppMethods.showLog(">>>> RESPONSE ERROR >> ${response}");

          ///Display snackbar here..
        },
        showProcess: true);
  }

  signUp(
      {String? firstName,
      String? lastName,
      String? email,
      String? passWord,
      String? gender}) {
    APIService().callAPI(
        params: {},
        headers: {},
        formDatas: dio.FormData.fromMap({
          "gender": "M",
          "firstname": firstName,
          "lastname": lastName,
          "email": email,
          "password": passWord,
        }),
        serviceUrl: EndPoints.baseUrl + EndPoints.signUpApi,
        method: APIService.postMethod,
        success: (dio.Response response) {
          if (response.data.contains('success')) {
            showDailogBox(
                context: Get.context!,
                title: 'Signup successful!',
                subTitle:
                    'Please check your Email or Spam to activate your account.');

            // Future.delayed(const Duration(seconds: 4), () {
            //   Get.back();
            // });
          } else {
            snack(
              title: 'Signup failed!',
              msg: '${response.data}',
              icon: Icons.close,
              iconColor: Colors.red,
            );
          }
        },
        error: (dio.Response response) {},
        showProcess: true);
  }
}
