import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/my_messages_res_obj.dart';
import '../../modules/auth_module/model/login_model.dart';
import '../../modules/dashbord_module/controller/dash_board_controller.dart';
import '../../networking/api_service_class.dart';
import '../../services/sesssion.dart';
import '../../utils/endpoints.dart';

class MessageController extends GetxController {
  TextEditingController commentTEC = TextEditingController();

  RxList<MessageObj>? messages = <MessageObj>[].obs;

  Future loadMessageThreads() async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;

    APIService().callAPI(
        params: {},
        serviceUrl: "${EndPoints.baseUrl}wire/messages/$userId",
        method: APIService.getMethod,
        success: (dio.Response response) {
          var decodedJson = jsonDecode(response.data);
          MyMessages resObj = MyMessages.fromJson(decodedJson);
          messages?.value = resObj.messages ?? [];
          // return messages;
        },
        error: (dio.Response response) {},
        showProcess: true);
  }
}
