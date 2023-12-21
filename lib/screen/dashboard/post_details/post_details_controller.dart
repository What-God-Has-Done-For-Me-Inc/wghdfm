// import 'package:flick_video_player/flick_video_player.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PostDetailsController extends GetxController {
  List<String> media = Get.arguments;
  late WebViewController controller;
  // late FlickManager flickManager;

  @override
  void onInit() {
    // flickManager = FlickManager(
    //   videoPlayerController: VideoPlayerController.network(
    //       "https://wghdfm.s3.amazonaws.com/videowires/1659596902_1.mp4"),
    // );
    super.onInit();
  }

  @override
  void dispose() {
    // flickManager.dispose();
    super.dispose();
  }
}
