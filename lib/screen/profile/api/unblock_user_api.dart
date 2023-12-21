import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

Future unblockUSer({required String profileId, required String userId}) async {
  try {
    Map<String, dynamic> bodyData = {"user_id": profileId, "friend_id": userId};

    APIService().callAPI(
        params: {},
        serviceUrl: EndPoints.baseUrl,
        method: APIService.postMethod,
        formDatas: dio.FormData.fromMap(bodyData),
        success: (dio.Response response) {
          var data = json.decode(response.data);
          if (data["status"] == "success") {
            Get.snackbar(
              "Success",
              "User unblocked successfully",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black,
              colorText: Colors.white,
              borderRadius: 10,
              margin: const EdgeInsets.all(10),
              borderColor: Colors.white,
              borderWidth: 1,
              duration: const Duration(seconds: 2),
            );
          } else {
            Get.snackbar(
              "Error",
              data["message"],
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black,
              colorText: Colors.white,
              borderRadius: 10,
              margin: const EdgeInsets.all(10),
              borderColor: Colors.white,
              borderWidth: 1,
              duration: const Duration(seconds: 2),
            );
          }
        },
        error: (dio.Response response) {},
        showProcess: true);
  } catch (e) {
    print("====> $e");
  }
}
