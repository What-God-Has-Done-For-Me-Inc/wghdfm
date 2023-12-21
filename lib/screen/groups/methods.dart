import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/model/group_details_res_obj.dart';
import 'package:wghdfm_java/model/group_members_res_obj.dart';
import 'package:wghdfm_java/model/groups_res_obj.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/services/prefrence_services.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../../modules/dashbord_module/controller/dash_board_controller.dart';

// Rx<GroupDetailsModelData>? groupDetail = GroupDetailsModelData().obs;
Rx<GroupDetailsModel> groupDetailsModel = GroupDetailsModel().obs;

Future fetchGroupDetails({required var groupId}) async {
  userId = await fetchStringValuesSF(SessionManagement.KEY_ID);
  APIService().callAPI(
      params: {},
      serviceUrl: "${EndPoints.baseUrl}wire/group_details/$groupId/$userId",
      method: APIService.postMethod,
      success: (dio.Response response) {
        print("::: ${response.data}");
        var decodedJson = jsonDecode(response.data);
        groupDetailsModel.value = GroupDetailsModel.fromJson(decodedJson);
        //  groupDetailsModel.data.forEach((element) {
        // });

        // print(":: DATA IS >> JSON  ${groupDetail?.toJson()}");
        // return groupDetail;
      },
      error: (dio.Response response) {},
      showProcess: true);
  // return groupDetail;
}

RxList<PostModelFeed>? groupFeeds = <PostModelFeed>[].obs;

Future<void> sendGroupJoinRequest(
    {required String groupId, required String groupType, Function? callBaack}) async {
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;

  APIService().callAPI(
      params: {},
      serviceUrl:
      "${EndPoints.baseUrl}wire/group_req_send/$groupId/$userId/$groupType",
      method: APIService.getMethod,
      success: (dio.Response response) {
        // Get.back();
        snack(msg: "You have sent join request in this group", title: "Status");
        fetchGroupDetails(groupId: groupId);
        if (callBaack != null) {
          callBaack();
        }
      },
      error: (dio.Response response) {},
      showProcess: true);
}

RxList<GroupMemberModelData>? groupMembers = <GroupMemberModelData>[].obs;

Future loadMembers({required var groupId}) async {
  await APIService().callAPI(
      params: {},
      serviceUrl: "${EndPoints.baseUrl}wire/group_members/$groupId",
      method: APIService.getMethod,
      success: (dio.Response response) {
        print(":: MEMBER DATA ${response.data}");
        // if (response.data.trim() != '') {
        var decodedJson = jsonDecode(response.data);
        GroupMemberModel resObj = GroupMemberModel.fromJson(decodedJson);
        if (groupMembers?.isNotEmpty == true) groupMembers?.clear();
        resObj.data?.forEach((element) {
          groupMembers?.add(element ?? GroupMemberModelData());
        });
        // groupMembers?.value = resObj.data;
        // } else {
        // groupMembers = [];
        // }
        // return groupMembers;
      },
      error: (dio.Response response) {
        debugPrint("loadMembers");
      },
      showProcess: true);
  return groupMembers;
}

RxList<Group>? groupList = <Group>[].obs;

Future getGroups({Function? callBack}) async {
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;

  await APIService().callAPI(
      params: {},
      serviceUrl: "${EndPoints.baseUrl}wire/groups/$userId",
      method: APIService.postMethod,
      success: (dio.Response response) {
        var decodedJson = jsonDecode(response.data);
        Groups resObj = Groups.fromJson(decodedJson);
        groupList?.clear();
        resObj.data?.forEach((element) {
          groupList?.add(element ?? Group());
        });
        if (callBack != null) {
          callBack();
        }
        // groupList?.value = resObj.data ?? [];
      },
      error: (dio.Response response) {},
      showProcess: true);
}

Future<void> createNewGroup(
    {required String groupName, required String groupType}) async {
  LoginModel userDetails = await SessionManagement.getUserDetails();
  userId = userDetails.id;

  await APIService().callAPI(
      params: {},
      formDatas: dio.FormData.fromMap({"group_title": groupName.toString()}),
      serviceUrl: "${EndPoints.baseUrl}wire/add_new_group/$userId/$groupType",
      method: APIService.postMethod,
      success: (dio.Response response) {
        // Get.back();
        snack(msg: "You have created the group", title: "Status");
        getGroups();
      },
      error: (dio.Response response) {},
      showProcess: true);
}
