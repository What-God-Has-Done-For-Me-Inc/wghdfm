import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/screen/groups/methods.dart';
import 'package:wghdfm_java/services/prefrence_services.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

class GroupController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isPostUploading = false.obs;
  TextEditingController searchTEC = TextEditingController();
  TextEditingController groupTypeTEC = TextEditingController();
  TextEditingController groupNameTEC = TextEditingController();

  List<GroupType> groupTypes = <GroupType>[
    GroupType('Public', 'O', true),
    GroupType('Private', 'P', false),
  ];

  List<Gender> genders = <Gender>[
    Gender('Male', 'M', true),
    Gender('Female', 'F', false),
  ];

  Future removeMember(
      {required String grpMemberID, required String grpID}) async {
    await APIService().callAPI(
        params: {},
        serviceUrl: "${EndPoints.baseUrl}wire/remove_member/$grpMemberID",
        method: APIService.postMethod,
        success: (dio.Response response) async {
          snack(title: "Success", msg: "Member Removed");
          await loadMembers(groupId: grpID);
          // groupList?.value = resObj.data ?? [];
        },
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future removeGroup({required String grpID}) async {
    await APIService().callAPI(
        params: {},
        serviceUrl: "${EndPoints.baseUrl}wire/delete_group/$grpID",
        method: APIService.postMethod,
        success: (dio.Response response) async {
          snack(title: "Success", msg: "Member Removed");
          getGroups();
          // groupList?.value = resObj.data ?? [];
        },
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future acceptMember({required String grpMemberID,
    required String grpID,
    Function? callBack}) async {
    await APIService().callAPI(
        params: {},
        serviceUrl: "${EndPoints.baseUrl}wire/accept_member/$grpMemberID",
        method: APIService.postMethod,
        success: (dio.Response response) async {
          snack(title: "Success", msg: "Member Accepted");
          await loadMembers(groupId: grpID);
          if (callBack != null) callBack();
          // groupList?.value = resObj.data ?? [];
        },
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future makeAdmin({
    required String grpMemberID,
    required String grpID,
    Function? callBack,
  }) async {
    await APIService().callAPI(
        params: {},
        serviceUrl: "${EndPoints.baseUrl}wire/make_admin/$grpMemberID",
        method: APIService.postMethod,
        success: (dio.Response response) async {
          snack(title: "Success", msg: "Admin Created");
          await loadMembers(groupId: grpID);
          if (callBack != null) callBack();
          // groupList?.value = resObj.data ?? [];
        },
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future<void> postStatus(String status,
      String youtubeLink,
      String grpID,) async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;

    await APIService().callAPI(
        params: {},
        formDatas:
        dio.FormData.fromMap({"status": status, "vurl": youtubeLink}),
        serviceUrl:
        EndPoints.baseUrl + EndPoints.addFeedStatusInGroupUrl + userId,
        method: APIService.postMethod,
        success: (dio.Response response) {
          Get.back();
          snack(msg: "Status has been posted successfully.", title: "Status");
        },
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future<void> uploadImage({
    required List<File?> imageFilePaths,
    required String groupID,
    String? status,
    Function? callBack,
  }) async {
    print(">>>> PATH >> ${imageFilePaths}");
    isPostUploading.value = true;

    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;

    ///In case of new image post, post id is ""
    List<dio.MultipartFile> fileList = <dio.MultipartFile>[];
    for (var element in imageFilePaths) {
      dio.MultipartFile file =
      await dio.MultipartFile.fromFile(element?.path ?? "");
      fileList.add(file);
    }
    Map<String, dynamic> data = {
      "user_id": userId,
      "multi_wire_content": status ?? "",
      /*imageFilePaths.toString()*/
      //    "multi_wire_content": imageFilePaths.toString()
      "multi_wirefile[]": fileList,
      "group_id": groupID,
    };
    print("uploadImage responseBody: $data ");
    await APIService().callAPI(
        formDatas: dio.FormData.fromMap(data),
        params: {},
        headers: {},
        serviceUrl: EndPoints.baseUrl + EndPoints.uploadImageInGrp,
        method: APIService.postMethod,
        success: (dio.Response response) async {
          var responseData = jsonDecode(response.data);
          snack(msg: "${responseData['message']}", title: "Status");
          // Get.offAll(() => DashBoardScreen());
          isPostUploading.value = false;
          if (callBack != null) {
            callBack();
          }
        },
        error: (dio.Response response) {
          String responseBody = response.data;
          debugPrint("uploadImage responseBody: $responseBody");
          isPostUploading.value = false;
          Get.back();
          snack(
              title: "Failed",
              msg: "Failed to post ",
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: false);
  }

  Future<void> uploadText({
    required String groupID,
    required String textStatus,
    String? url,
    Function? callBack,
  }) async {
    isPostUploading.value = true;
    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;

    Map<String, dynamic> data = {
      "user_id": userId,
      "wire_content": textStatus,
      /*imageFilePaths.toString()*/
      //    "multi_wire_content": imageFilePaths.toString()
      "url": url,
      "group_id": groupID,
    };
    print("uploadImage responseBody: $data ");
    await APIService().callAPI(
        formDatas: dio.FormData.fromMap(data),
        params: {},
        headers: {},
        serviceUrl: EndPoints.baseUrl + EndPoints.uploadLinkStatusInGrp,
        method: APIService.postMethod,
        success: (dio.Response response) async {
          var responseData = jsonDecode(response.data);
          snack(msg: "${responseData['message']}", title: "Status");
          isPostUploading.value = false;
          // Get.offAll(() => DashBoardScreen());
          if (callBack != null) {
            callBack();
          }
        },
        error: (dio.Response response) {
          String responseBody = response.data;
          debugPrint("uploadImage responseBody: $responseBody");
          isPostUploading.value = false;
          Get.back();
          snack(
              title: "Failed",
              msg: responseBody,
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: false);
  }

  Future<void> editGroupCover({
    required File? imagePath,
    required String groupID,
    String? status,
    Function? callBack,
  }) async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;

    Map<String, dynamic> data = {
      "group_id": groupID,
      "cover_pic": imagePath?.path != null
          ? await dio.MultipartFile.fromFile(imagePath?.path ?? "")
          : null,
    };
    print("uploadImage responseBody: $data ");
    await APIService().callAPI(
        formDatas: dio.FormData.fromMap(data),
        params: {},
        headers: {},
        serviceUrl: "${EndPoints.baseUrl}wire/change_group_cover",
        method: APIService.postMethod,
        success: (dio.Response response) async {
          snack(msg: "Cover Pic Changed", title: "Success");
          // Get.offAll(() => DashBoardScreen());
          if (callBack != null) {
            callBack();
          }
        },
        error: (dio.Response response) {
          String responseBody = response.data;
          debugPrint("uploadImage responseBody: $responseBody");
          Get.back();
          snack(
              title: "Failed",
              msg: "Failed to post ",
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: true);
  }

  Future getGrpFeed({var isFirstTimeLoading,
    var page = 0,
    var groupId = 0,
    bool? showProcess}) async {
    userId = await fetchStringValuesSF(SessionManagement.KEY_ID);
    isLoading.value = true;
    await APIService().callAPI(
        params: {},
        serviceUrl:
        "${EndPoints.baseUrl}wire/group_more/$page/$groupId/$userId",
        method: APIService.postMethod,
        success: (dio.Response response) {
          if (response.data.trim() != '') {
            var decodedJson = jsonDecode(response.data);
            print(" ---- response json ${decodedJson}");
            PostModel resObj = PostModel.fromJson(decodedJson);
            print("_____ RES OBJ ___ ${resObj.feed?.length}");
            if (isFirstTimeLoading) groupFeeds?.clear();
            resObj.feed?.forEach((element) {
              groupFeeds?.add(element ?? PostModelFeed());
            });
            isLoading.value = false;
            // groupFeeds = resObj.feed  ;
          }
          isLoading.value = false;
        },
        error: (dio.Response response) {
          isLoading.value = false;
        },
        showProcess: showProcess ?? true);
  }

  Future likeGrpPost() async {
    await APIService().callAPI(
        params: {},
        serviceUrl: EndPoints.signUpApi,
        method: APIService.postMethod,
        success: (dio.Response response) {},
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future sharePostToTimeline({
    required String postOwnerId,
    required String ownerId,
    required String wireId,
  }) async {
    await APIService().callAPI(
      params: {},
      formDatas: dio.FormData.fromMap({
        'post_owner_id': postOwnerId,
        "owner_id": ownerId,
        "wire_id": wireId,
      }),
      serviceUrl: "${EndPoints.baseUrl}wire/share_from_group_to_timeline",
      method: APIService.postMethod,
      success: (dio.Response response) {
        snack(title: "Success", msg: "Added in Timeline Successfully");
      },
      error: (dio.Response response) {
        snack(
            title: "Failed to delete comment",
            msg: "Please try again to delete comment");
      },
      showProcess: true,
    );
  }

  Future promoteGroups({
    required String groupName,
    required String groupId,
  }) async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          'group_name': groupName,
          "group_id": groupId,
          "user_id": userId,
        }),
        serviceUrl: "${EndPoints.baseUrl}wire/promote_group",
        method: APIService.postMethod,
        success: (dio.Response response) async {
          snack(title: "Success", msg: "Group Promoted. ");
          // groupList?.value = resObj.data ?? [];
        },
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future editGroupDetails({
    required String groupName,
    required String groupDescription,
    required String groupId,
    Function? callBack,
  }) async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          "group_id": groupId,
          'group_title': groupName,
          "group_description": groupDescription,
        }),
        serviceUrl: "${EndPoints.baseUrl}wire/edit_group",
        method: APIService.postMethod,
        success: (dio.Response response) async {
          snack(title: "Success", msg: "Group Details Updated. ");
          if (callBack != null) {
            callBack();
          }
          fetchGroupDetails(groupId: groupId);
          // groupList?.value = resObj.data ?? [];
        },
        error: (dio.Response response) {},
        showProcess: true);
  }
}

class Gender {
  String sexState = "";
  String sexCode = "";
  bool isSelected = false;

  Gender(this.sexState,
      this.sexCode,
      this.isSelected,);
}

class GroupType {
  String groupState = "";
  String groupCode = "";
  bool isSelected = false;

  GroupType(this.groupState,
      this.groupCode,
      this.isSelected,);
}
