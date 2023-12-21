import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/model/my_messages_res_obj.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../../modules/dashbord_module/controller/dash_board_controller.dart';

List<MessageObj>? conversations = [];

Future<List<MessageObj>?> loadConversation(var msgId) async {
  String reqUrl = "wire/messages_convo/" + msgId;
  debugPrint("loadConversation reqUrl: $reqUrl");

  APIService().callAPI(
      params: {},
      serviceUrl: "${EndPoints.baseUrl}wire/messages_convo/$msgId",
      method: APIService.getMethod,
      success: (dio.Response response) {
        var decodedJson = jsonDecode(response.data);
        MyMessages resObj = MyMessages.fromJson(decodedJson);
        conversations = resObj.messages;
        return conversations;
      },
      error: (dio.Response response) {},
      showProcess: true);
}

Future<void> addMessage(
  MessageObj msgObj,
  String message,
) async {
  APIService().callAPI(
      params: {},
      formDatas: dio.FormData.fromMap({"message": message}),
      serviceUrl: " ${EndPoints.baseUrl}wire/add_message/${msgObj.receipt!}/${msgObj.userId!}/${msgObj.id!}",
      method: APIService.postMethod,
      success: (dio.Response response) {
        Get.back();
        snack(msg: "Post has been reported successfully.", title: "Status");
      },
      error: (dio.Response response) {},
      showProcess: true);
}

Future<void> deleteMessageThread(var subId) async {
  showProgressDialog();
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;

  APIService().callAPI(
      params: {},
      serviceUrl: "${EndPoints.baseUrl}wire/message_delete/$subId/$userId",
      method: APIService.getMethod,
      success: (dio.Response response) {
        Get.back();
        snack(title: 'Status', msg: 'Conversation thread successfully deleted');
      },
      error: (dio.Response response) {},
      showProcess: true);
}
