import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/screen/profile/api/block_user_api.dart';
import 'package:wghdfm_java/screen/profile/api/unblock_user_api.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../../../../model/my_profilr_details_model.dart';
import '../../../../networking/api_service_class.dart';
import '../../../../services/sesssion.dart';
import '../../../utils/app_methods.dart';
import '../../agora_module/helper/utils.dart';
import '../../agora_module/views/meeting_screen.dart';
import '../../dashbord_module/controller/dash_board_controller.dart';

class ProfileController extends GetxController {
  // bool isFirstTime = true;
  RxBool isProfileLoading = false.obs;
  int currentPage = 1;

  //LoginResOj user;
  var profileId;

  // bool? isSelf;

  var args = Get.arguments;

  @override
  void onInit() {
    if (args != null) {
      profileId = args["profileId"];
      // isSelf = args["isSelf"];
    }
    super.onInit();
  }

  // callApis() async {
  //   await getProfileData(profileId: profileId);
  //   await loadProfileFeeds(isFirstTimeLoading: isFirstTime, page: currentPage, profileId: profileId);
  //   update(["Profile"]);
  // }

  void onPressUnBlock() {
    unblockUSer(userId: profileId, profileId: userId);
  }

  Future<void> onPressBlock(BuildContext context) async {
    blocUserApi(
        context: context,
        onPressUnBlock: onPressUnBlock,
        profileId: userId,
        userId: profileId);
  }

  RxList<PostModelFeed>? profileFeeds = <PostModelFeed>[].obs;

  Future getProfileFeed(
      {bool isFirstTimeLoading = false,
      var page = 1,
      required var profileId}) async {
    isProfileLoading.value = true;
    print(">> PROFILE DATA API CALLING");
    await APIService().callAPI(
      params: {},
      serviceUrl: isFirstTimeLoading
          ? "${EndPoints.baseUrl}wire/index_profile/$profileId"
          : "${EndPoints.baseUrl}wire/more_profile/$page/$profileId",
      method: APIService.postMethod,
      success: (dio.Response response) async {
        if (response.data != null) {
          var decodedJson = jsonDecode(response.data ?? {});
          PostModel resObj = PostModel.fromJson(decodedJson);
          if (isFirstTimeLoading) {
            profileFeeds?.clear();
            resObj.feed?.forEach((element) {
              profileFeeds?.add(element ?? PostModelFeed());
            });
          } else {
            resObj.feed?.forEach((element) {
              profileFeeds?.add(element ?? PostModelFeed());
            });
          }
          await closeLoading();
        }
      },
      error: (dio.Response response) async {
        // snack(title: "Try again", msg: "Failed to load profile post");
        await closeLoading();
      },
      showProcess: isFirstTimeLoading,
    );
  }

  Future closeLoading() async {
    isProfileLoading.value = false;
  }

  Rx<MyProfile>? profileDetails = MyProfile().obs;

  Future getProfileData(
      {required String profileID, Function? callBack, bool? showLoader}) async {
    APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap(
            {"user_id": profileID, "profile_id": profileID}),
        serviceUrl: EndPoints.baseUrl + EndPoints.userDetails,
        method: APIService.postMethod,
        success: (dio.Response response) {
          dynamic decodedJson = jsonDecode(response.data);
          // print("json DECODE : ${response.data}");
          // print("json DECODE : ${decodedJson}");
          // MyProfileDetails resObj = MyProfileDetails.fromJson(jsonDecode(response.data));
          // print("USER NAME $userName PROFILE PIC $profilePic COVERPIC $coverPic");
          profileDetails?.value = MyProfile.fromJson(decodedJson);
          userName.value =
              ("${profileDetails?.value.firstname ?? ""} ${profileDetails?.value.lastname ?? ""}")
                  .trim();
          profilePic.value = profileDetails?.value.img ?? "";
          coverPic.value = profileDetails?.value.cover ?? "";
          if (callBack != null) {
            callBack();
          }
          // return decodedJson["feed"][0];
        },
        error: (dio.Response response) {},
        showProcess: showLoader ?? true);
  }

  Future updateProfileImage(
      {required File image,
      bool? isProfile,
      required String userIdCurrent}) async {
    String fileName = image.path.split('/').last;

    await APIService().callAPI(
      params: {},
      formDatas: dio.FormData.fromMap({
        "user_id": userIdCurrent,
        "image": await dio.MultipartFile.fromFile(
          image.path,
          filename: fileName,
          contentType: MediaType.parse(lookupMimeType(fileName).toString()),
        ),
      }),
      serviceUrl: EndPoints.baseUrl +
          (isProfile == true
              ? EndPoints.updateProfileImage
              : EndPoints.updateCoverImage),
      method: APIService.postMethod,
      success: (dio.Response response) async {
        await getProfileData(profileID: userIdCurrent);
      },
      error: (dio.Response response) {},
      showProcess: true,
    );
  }

  Rx<MyProfile> someonesProfileData = MyProfile().obs;

  Future getSomeonesProfileData({required String profileID}) async {
    dynamic userDetails = await SessionManagement.getUserDetails();
    String userID = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas:
            dio.FormData.fromMap({"user_id": profileID, "profile_id": userID}),
        serviceUrl: EndPoints.baseUrl + EndPoints.userDetails,
        method: APIService.postMethod,
        success: (dio.Response response) {
          dynamic jsonData = jsonDecode(response.data);
          // print("???? json Data is ${jsonData.feed[0]}");
          //
          // dynamic decodedJson = jsonDecode(response.data);
          // profileDetails?.value = MyProfile.fromJson(decodedJson["feed"][0]);
          // MyProfileDetails resObj = MyProfileDetails.fromJson(jsonDecode(response.data));
          someonesProfileData.value = MyProfile.fromJson(jsonData);
        },
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future makeVideoCAll({required String profileID}) async {
    dynamic userDetails = await SessionManagement.getUserDetails();
    var channel_name = generateRandomString(8);
    String userID = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          "user_id": userId,
          "profile_id": profileID,
          "call_type": "video_call",
          "channel_name": channel_name,
        }),
        serviceUrl: EndPoints.baseUrl + EndPoints.callNotify,
        method: APIService.postMethod,
        success: (dio.Response response) async {
          dynamic jsonData = jsonDecode(response.data);

          print(jsonData);
          if (jsonData["type"] == "success") {
            bool isPermissionGranted = await AppMethods().getPermission();

            if (isPermissionGranted == true) {
              Get.to(
                  MeetingScreen(
                    token: jsonData["token"].toString(),
                    channelName: channel_name,
                    uid: userId,
                    userName:
                        "${jsonData["caller_firstname"]} ${jsonData["caller_lastname"]}",
                  ),
                  arguments: {
                    "userId": userId,
                    "userName":
                        "${jsonData["caller_firstname"]} ${jsonData["caller_lastname"]}",
                    "channelName": channel_name,
                    "token": jsonData["token"].toString()
                  });
            }
          }
        },
        error: (dio.Response response) {},
        showProcess: false);
  }

  Future blockUser({required userID, required Function callBack}) async {
    dynamic userDetails = await SessionManagement.getUserDetails();
    String myProfileId = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap(
            {"user_id": userID, "profile_id": myProfileId}),
        serviceUrl: EndPoints.baseUrl + EndPoints.userBloc,
        method: APIService.postMethod,
        success: (dio.Response response) {
          callBack();
        },
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future unBlockUser({required userID, required Function callBack}) async {
    dynamic userDetails = await SessionManagement.getUserDetails();
    String myProfileId = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap(
            {"user_id": userID, "profile_id": myProfileId}),
        serviceUrl: EndPoints.baseUrl + EndPoints.userUnBloc,
        method: APIService.postMethod,
        success: (dio.Response response) {
          callBack();
        },
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future addMessage(
      {required userID,
      required String message,
      required Function callBack}) async {
    dynamic userDetails = await SessionManagement.getUserDetails();
    String myProfileId = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap(
            {'user_id': myProfileId, 'receipt': userID, 'message': message}),
        serviceUrl: EndPoints.baseUrl + EndPoints.addMessageApi,
        method: APIService.postMethod,
        success: (dio.Response response) {
          callBack();
        },
        error: (dio.Response response) {},
        showProcess: true);
  }

  Future changePassword({
    required oldPassword,
    required String newPassword,
    Function? callBack,
  }) async {
    dynamic userDetails = await SessionManagement.getUserDetails();
    String userID = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          "user_id": userID,
          "old_password": oldPassword,
          "password": newPassword,
          "con_password": newPassword
        }),
        serviceUrl: EndPoints.baseUrl + EndPoints.changePassword,
        method: APIService.postMethod,
        success: (dio.Response response) {
          dynamic responseBody = jsonDecode(response.data);
          if (responseBody["type"] == "success") {
            snack(
              title: "Success",
              msg: '${responseBody["text"]}',
            );
          } else {
            snack(
                title: "Opps",
                msg: '${responseBody["text"]}',
                iconColor: Colors.red,
                icon: Icons.close);
          }

          if (callBack != null) {
            callBack();
          }
        },
        error: (dio.Response response) {
          dynamic responseBody = jsonDecode(response.data);
          print(">>>> RESPONSE SUCCESS >> ${responseBody['status']}");
          print("uploadImage responseBody: ${responseBody['text']}");
          Get.back();
          snack(
              title: "Failed",
              msg: '${response.data["text"]}',
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: true);
  }

  Future deleteAccount({
    required String password,
    Function? callBack,
  }) async {
    dynamic userDetails = await SessionManagement.getUserDetails();
    String userID = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas:
            dio.FormData.fromMap({"user_id": userID, "password": password}),
        serviceUrl: EndPoints.baseUrl + EndPoints.deleteProfile,
        method: APIService.postMethod,
        success: (dio.Response response) {
          dynamic responseBody = jsonDecode(response.data);
          if (responseBody["type"] == "success") {
            snack(
              title: "Success",
              msg: '${responseBody["message"]}',
            );
            if (callBack != null) {
              callBack();
            }
          } else {
            snack(
                title: "Opps",
                msg: '${responseBody["message"]}',
                iconColor: Colors.red,
                icon: Icons.close);
          }
        },
        error: (dio.Response response) {
          dynamic responseBody = jsonDecode(response.data);
          print(">>>> RESPONSE SUCCESS >> ${responseBody['status']}");
          print("uploadImage responseBody: ${responseBody['text']}");
          Get.back();
          snack(
              title: "Failed",
              msg: '${response.data["text"]}',
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: true);
  }

  Future inviteFriend({
    required String email,
    Function? callBack,
  }) async {
    dynamic userDetails = await SessionManagement.getUserDetails();
    String userID = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({"email": email}),
        serviceUrl: EndPoints.baseUrl + EndPoints.inviteFriends,
        method: APIService.postMethod,
        success: (dio.Response response) {
          dynamic responseBody = jsonDecode(response.data);
          if (responseBody["type"] == "success") {
            snack(
              title: "Success",
              msg: '${responseBody["message"]}',
            );
            if (callBack != null) {
              callBack();
            }
          } else {
            snack(
                title: "Opps",
                msg: '${responseBody["message"]}',
                iconColor: Colors.red,
                icon: Icons.close);
          }
        },
        error: (dio.Response response) {
          dynamic responseBody = jsonDecode(response.data);
          print(">>>> RESPONSE SUCCESS >> ${responseBody['status']}");
          print("uploadImage responseBody: ${responseBody['text']}");
          Get.back();
          snack(
              title: "Failed",
              msg: '${response.data["text"]}',
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: true);
  }

  Color getBadgeColor({required String badge}) {
    switch (badge) {
      case "Basic":
        return Colors.grey.shade800;

      case "Bronze":
        return Color(0xffCD7F32);

      case "Silver":
        return Color(0xffC0C0C0);
      case "Gold":
        return Color(0xffFFD700);
      case "Platinum":
        return Color(0xffE5E4E2);
      case "Diamond":
        return Color(0xffb9f2ff);

      default:
        return Colors.blueGrey;
    }
  }

  // badge image url
  String getBadgeImage({required String badge}) {
    switch (badge) {
      case "Basic":
        return "assets/1.png";
      case "Bronze":
        return "assets/2.png";
      case "Silver":
        return "assets/3.png";
      case "Gold":
        return "assets/4.png";
      case "Platinum":
        return "assets/5.png";
      case "Diamond":
        return "assets/6.png";
      default:
        return "assets/1.png";
    }
  }
}
