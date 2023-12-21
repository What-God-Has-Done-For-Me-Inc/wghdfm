import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/dash_board_screen.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

Future blocUserApi({required String userId, required String profileId, required VoidCallback onPressUnBlock, required BuildContext context}) async {
  try {
    log(
      "friendId $userId and profileId $profileId",
      name: "block",
    );

    Map<String, dynamic> bodyData = {
      "user_id": profileId,
      "profile_id": userId,
    };
    APIService().callAPI(
        params: {},
        serviceUrl: EndPoints.baseUrl + EndPoints.userBloc,
        method: APIService.postMethod,
        formDatas: dio.FormData.fromMap(bodyData),
        success: (dio.Response response) async {
          var data = json.decode(response.data);
          if (data["status"] == "success") {
            Get.snackbar(
              "Success",
              "User blocked successfully",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black,
              colorText: Colors.white,
              borderRadius: 10,
              margin: const EdgeInsets.all(10),
              borderColor: Colors.white,
              borderWidth: 1,
              duration: const Duration(seconds: 2),
              mainButton: TextButton(
                child: const Text(
                  "UNBLOCK",
                  style: TextStyle(color: Colors.white, fontSize: 15.0, height: 1, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                ),
                onPressed: () async {
                  onPressUnBlock();
                },
              ),
            );
          }

          Get.to(() => const DashBoardScreen());
          await ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "User Blocked!",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          );
        },
        error: (dio.Response response) {},
        showProcess: true);
  } catch (e) {
    print("=====> $e");
  }
}
