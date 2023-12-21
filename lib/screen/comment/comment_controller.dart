import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/common_snack.dart';

import '../../model/comment_model.dart';
import '../../networking/api_service_class.dart';
import '../../utils/endpoints.dart';

class CommentController extends GetxController {
  TextEditingController commentTEC = TextEditingController();
  RxBool commentLoading = false.obs;
  int nextPage = 0;

  Rx<CommentModel>? commentModel = CommentModel().obs;
  RxList<CommentModelCommentList?>? commentList = <CommentModelCommentList?>[].obs;
  Future getComments({
    required String postId,
    bool isFirstTime = false,
    Function? callBack,
    isFromGrp = false,
  }) async {
    print(" COMMENT API CALLING ");
    if (isFirstTime) {
      commentList?.clear();
      nextPage = 0;
    }
    commentLoading.value = true;
    await APIService().callAPI(
        params: {},
        formDatas: isFromGrp == false ? dio.FormData.fromMap({'post_id': postId, 'start': isFirstTime ? 0 : nextPage}) : null,
        serviceUrl:
            isFromGrp == false ? "${EndPoints.baseUrl}${EndPoints.commentUrl}" : "${EndPoints.baseUrl}${EndPoints.commentUrlForGrp}/$postId/G",
        method: APIService.postMethod,
        success: (dio.Response response) async {
          if (isFromGrp == true) {
            final decodedesponse = jsonDecode(response.data);
            // print()
            decodedesponse.forEach((element) {
              print(":: element $element");
              print(":: element[comment] ${element["comment"]}");
              commentList?.add(CommentModelCommentList(
                  comment: element["comment"] ?? "",
                  commentId: element["comment_id"] ?? "",
                  lastname: element["lastname"] ?? "",
                  firstname: element["firstname"] ?? "",
                  img: element["img"] ?? "",
                  userId: element["user_id"] ?? "",
                  date: ""));
            });
          } else {
            commentModel?.value = CommentModel.fromJson(jsonDecode(response.data));
            commentModel?.value.commentList?.forEach((e) {
              commentList?.add(e);
            });
          }

          await closeLoading();
          if (callBack != null) {
            callBack();
          }
          // debugPrint("commentList statusCode: ${response.statusCode}; response: ${response.data}");
          // if (commentList?.isNotEmpty == true) {
          //   commentList?.clear();
          // }
          // List list = jsonDecode(response.data);
          // list.forEach((element) {
          //   commentList?.add(Comment.fromJson(element));
          // });
          // return commentList;
        },
        error: (dio.Response response) async {
          await closeLoading();
        },
        showProcess: isFirstTime);
  }

  deleteComment({required String commentID, bool? isGrpAPI}) async {
    await APIService().callAPI(
      params: {},
      formDatas: dio.FormData.fromMap({'comment_id': commentID}),
      serviceUrl: isGrpAPI == true ? "${EndPoints.baseUrl}${EndPoints.deleteGrpCommentUrl}" : "${EndPoints.baseUrl}${EndPoints.deleteCommentUrl}",
      method: APIService.postMethod,
      success: (dio.Response response) {
        snack(title: "Success", msg: "Comment Deleted Successfully");
      },
      error: (dio.Response response) {
        snack(title: "Failed to delete comment", msg: "Please try again to delete comment");
      },
      showProcess: true,
    );
  }

  Future closeLoading() async {
    commentLoading.value = false;
  }
}
