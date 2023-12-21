import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/model/friend_model.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/screen/friends/friends_controller.dart';
import 'package:wghdfm_java/screen/friends/friends_screen.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../../../modules/dashbord_module/controller/dash_board_controller.dart';

Future<List<Friend>?> reloadFriends(FriendsController c) async {
  c.friends?.value = (await loadFriends())!;

  if (isSearching) {
    if (c.searchedFriends!.isNotEmpty) c.searchedFriends!.clear();
    for (int i = 0; i < c.friends!.length; i++) {
      if (c.friends![i].name!.toLowerCase().contains(c.searchTEC.text.trim().toLowerCase())) {
        c.searchedFriends!.add(c.friends![i]);
      }
    }
  } else {}

  return isSearching ? c.searchedFriends : c.friends;
}

Future<List<Friend>?> loadFriends() async {
  final FriendsController f = Get.find<FriendsController>();
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;
  APIService().callAPI(
      params: {},
      serviceUrl: EndPoints.baseUrl + EndPoints.loadFriendsUrl + userId,
      method: APIService.getMethod,
      success: (dio.Response response) {
        var decodedJson = jsonDecode(response.data);
        MyFriends resObj = MyFriends.fromJson(decodedJson);
        f.friends?.value = resObj.friends!;
        return f.friends;
      },
      error: (dio.Response response) {
        final decoded = jsonDecode(response.data);
        AppMethods.showLog(">>>> RESPONSE SUCCESS >> ${decoded['status']}");
        AppMethods.showLog(">>>> RESPONSE ERROR >> ${response}");
        snack(
          title: 'failed!',
          msg: response.extra.toString(),
          icon: Icons.close,
          iconColor: Colors.red,
        );
      },
      showProcess: true);
  return f.friends;
}
