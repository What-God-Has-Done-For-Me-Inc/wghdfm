import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/model/friend_model.dart';

class FriendsController extends GetxController {
  var args = Get.arguments;
  TextEditingController searchTEC = TextEditingController();
  RxList<Friend>? friends = <Friend>[].obs;
  RxList<Friend>? searchedFriends = <Friend>[].obs;
  //RxList<Feed>? feeds = <Feed>[].obs;

  @override
  void onInit() {
    if (args != null) {
      searchedFriends = args["0"];
    }
    super.onInit();
  }
}
