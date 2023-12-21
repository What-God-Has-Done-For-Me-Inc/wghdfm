import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';

import '../../model/feed_res_obj.dart';
import '../../modules/dashbord_module/controller/dash_board_controller.dart';
import '../../networking/api_service_class.dart';
import '../../services/prefrence_services.dart';
import '../../services/sesssion.dart';

class FavouriteController extends GetxController {
  bool isFirstTime = true;
  RxInt currentPage = 0.obs;
  RxBool isLoading = false.obs;

  RxBool isRefreshing = false.obs;

  List<VoidCallback> postOptionOnClicks() {
    var callBacks = <VoidCallback>[
      () {
        debugPrint("Status");
      },
      () {
        debugPrint("Photo");
      },
      () {
        debugPrint("Video");
      },
    ];

    return callBacks;
  }

  RxList<PostModelFeed>? favFeeds = <PostModelFeed>[].obs;

  Future getFavPost({
    required String searchTxt,
    bool? showLoading,
    bool? isFirstTime,
    Function? callBack,
  }) async {
    // RxList<Feed>? feeds = <Feed>[].obs;
    isLoading.value = true;
    isRefreshing.value = true;
    userId = await fetchStringValuesSF(SessionManagement.KEY_ID);
    await APIService().callAPI(
        params: {},
        // params:
        //     searchTxt.isNotEmpty ? {"keywords": searchTxt} : {"keywords": ""},
        formDatas: dio.FormData.fromMap(
            searchTxt.isNotEmpty ? {"keywords": searchTxt} : {"keywords": ""}),
        // serviceUrl: EndPoints.baseUrl + EndPoints.favUrl + userId,
        serviceUrl:
            "https://whatgodhasdoneforme.com/mobile/wire/fav_more/$currentPage/$userId",
        method: APIService.postMethod,
        success: (dio.Response response) async {
          String responseBody = await response.data;
          debugPrint("loadFavFeed responseBody: $responseBody");
          // if (response.data != "") {

          // var decodedJson = ;
          PostModel resObj = response.data != ""
              ? PostModel.fromJson(jsonDecode(responseBody) ?? {})
              : PostModel();

          if (isFirstTime == true) {
            favFeeds?.clear();
            for (PostModelFeed? element in resObj.feed ?? []) {
              favFeeds?.add(element ?? PostModelFeed());
            }
            // resObj.feed?.forEach((element) {
            //   favFeeds?.add(element ?? PostModelFeed());
            // });
            favFeeds?.refresh();
            // await closeIsLoading();
          } else {
            resObj.feed?.forEach((element) {
              favFeeds?.add(element ?? PostModelFeed());
            });
            await closeIsLoading();
          }
          Timer(const Duration(milliseconds: 500), () {
            isRefreshing.value = false;
          });
          if (callBack != null) {
            callBack();
          }

          // await closeIsLoading();
          // } else {
          //   favFeeds?.clear();
          //   await closeIsLoading();
          // }
        },
        error: (dio.Response response) async {
          snack(title: "Failed to getting post", msg: "Please try again.");
          await closeIsLoading();
        },
        showProcess: showLoading ?? true);
  }

  Future closeIsLoading() async {
    isLoading.value = false;
    print(">> > IS LOADINF ${isLoading.value}");
  }
}
