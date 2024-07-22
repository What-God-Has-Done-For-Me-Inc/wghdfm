import 'dart:convert';

import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../../networking/api_service_class.dart';
import '../../../services/sesssion.dart';
import '../../../utils/app_methods.dart';
import '../../../utils/endpoints.dart';

import '../views/meeting_screen.dart';

class AgoraController extends GetxController {
  List<Map<String, dynamic>> activeUsers = [];
  String? activeUserName ;
  Future makeVideoCAll({required String channelName}) async {
    dynamic userDetails = await SessionManagement.getUserDetails();

    String userID = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          "user_id": userID,
          // "profile_id": profileID,
          "call_type": "video_call",
          "channel_name": channelName,
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
                    channelName: channelName,
                    uid: userID,
                    userName:
                        "${jsonData["caller_firstname"]}${jsonData["caller_lastname"]}",
                  ),
                  arguments: {
                    "userId": userID,
                    "userName":
                        "${jsonData["caller_firstname"]} ${jsonData["caller_lastname"]}",
                    "channelName": channelName,
                    "token": jsonData["token"].toString()
                  });
            }
          }
        },
        error: (dio.Response response) {},
        showProcess: false);
  }

  Future agoraSaveUser(
      {required String channelName,
      required String userId,
      required String uid,
      required String userName,
      required String userImage}) async {
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          "user_id": userId,
          "user_name": userName,
          "user_img": userImage,
          "uid": uid,
          "channel": channelName,
        }),
        serviceUrl: EndPoints.baseUrl + EndPoints.agoraSaveUser,
        method: APIService.postMethod,
        success: (dio.Response response) async {
          dynamic jsonData = jsonDecode(response.data);

          print(jsonData);
          if (jsonData["type"] == "success") {}
          update();
        },
        error: (dio.Response response) {},
        showProcess: false);
  }

  Future agoraGetData({required String channelName}) async {
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({"channel": channelName}),
        serviceUrl: EndPoints.baseUrl + EndPoints.agoraFetchUser,
        method: APIService.postMethod,
        success: (dio.Response response) async {
          String jsonData = jsonDecode(response.data);
          var ab = json.decode(jsonData);
           activeUsers = List.from(ab);

          print("Users Data List" +ab.toString());
          update();

        },
        error: (dio.Response response) {},
        showProcess: false);
  }
  void setActiveUserName({required int uid, required String currentUserId}) {
    print("Speacker is ");
    print(uid);


  activeUsers.forEach((userData) {
    print(userData);
      if (userData["uid"] == uid.toString()) {
        print("data is");
        print(userData);
       activeUserName = userData["user_name"].toString();
   update();

      }
    });
   }
}
