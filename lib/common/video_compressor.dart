import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import 'package:light_compressor/light_compressor.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';

// import 'package:video_compress/video_compress.dart';
import 'package:video_compress_ds/video_compress_ds.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/utils/app_images.dart';

class VideoCompressor {
  // static LightCompressor lightCompressor = LightCompressor();

  //
  // Future<File?> compressVideo({required File originalFile}) async {
  //   final dynamic response = await lightCompressor.compressVideo(
  //     path: originalFile.path,
  //     disableAudio: false,
  //     videoQuality: VideoQuality.very_high,
  //     isMinBitrateCheckEnabled: false,
  //     video: Video(videoName: DateTime.now().toString(), videoBitrateInMbps: 1000),
  //     android: AndroidConfig(isSharedStorage: false, saveAt: SaveAt.Pictures),
  //     ios: IOSConfig(saveInGallery: false),
  //   );
  //   print("++++++++Pictures+++++++++++${SaveAt.Pictures}");
  //
  //   // await showPercentagesDialog();
  //
  //   print("====== complete");
  //
  //   if (response is OnSuccess) {
  //     // hideProgressDialog();
  //     final String outputFile = response.destinationPath;
  //     print("+++++++OnSuccess++++++++++${OnSuccess}");
  //     return File(outputFile);
  //     // use the file
  //   } else if (response is OnFailure) {
  //     // failure message
  //     hideProgressDialog();
  //     print("----message----------------${response.message}");
  //     return null;
  //   } else if (response is OnCancelled) {
  //     print("+++++isCancelled++++++++++++++++++++${response.isCancelled}");
  //     hideProgressDialog();
  //     return null;
  //   }
  //   return null;
  // }

  static Subscription? subscription;
  static RxDouble percentage = 0.0.obs;

  Future<File?> compressVideo({required File originalFile}) async {
    // if (Platform.isIOS) {
    //   return originalFile;
    // }
    await VideoCompress.deleteAllCache();
    final mimeType = lookupMimeType(originalFile.path);
    if (mimeType!.startsWith('image/')) {
      return originalFile;
    } else if (mimeType.startsWith('video/')) {
      final info = await VideoCompress.compressVideo(
        originalFile.path,
        frameRate: Platform.isAndroid ? 12000 : 30,
        quality: Platform.isAndroid
            ? VideoQuality.HighestQuality
            : VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: Platform.isAndroid ? true : null,
      );
      return (info?.file == null ||
              info?.path?.isEmpty == true ||
              info?.file?.path.isEmpty == true)
          ? null
          : File(info!.file!.path);
    }
    return null;
  }

  subscribeVideo() {
    subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: ====== $progress');
      percentage.value = progress;
      debugPrint('percentage: ====== ${percentage.value}');
    });
  }

  unSubscribe() {
    percentage.value = 0.0;
    subscription?.unsubscribe();
  }

  cancelCompressing() {
    percentage.value = 0.0;
    VideoCompress.cancelCompression();
  }

// Future showPercentagesDialog() async {
//   // if (Get.isDialogOpen ?? false) {
//   //   Get.back();
//   //   // FeedListController.to.isFetching.value = true;
//   // }
//   // if (Get.isSnackbarOpen) {
//   //   Get.closeCurrentSnackbar();
//   //   print("===================dialog ${Get.isSnackbarOpen}");
//   // }
//   print("===================dialog 11111111111");
//
//   Get.dialog(
//       WillPopScope(
//         onWillPop: () => Future.value(false),
//         child: Container(
//           alignment: Alignment.center,
//           color: Colors.red.withOpacity(0.1),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Lottie.asset(
//                 AppImages.loadingJson,
//                 height: 100,
//                 repeat: true,
//               ),
//               StreamBuilder<double>(
//                 stream: VideoCompressor.lightCompressor.onProgressUpdated,
//                 builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//                   print("===================dialog 5555555555555555555");
//
//                   print("===== VideoCompressor.lightCompressor.onProgressUpdated ${VideoCompressor.lightCompressor.onProgressUpdated}");
//                   if (snapshot.data != null && snapshot.data > 0) {
//                     // --> use snapshot.data
//                     return Text("${snapshot.data}");
//                   } else {
//                     // if (Get.isDialogOpen ?? false) {
//                     //   print("===================dialog 66666666666");
//                     //
//                     //   Get.back(result: true);
//                     // }
//                   }
//                   return Container();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       barrierDismissible: false);
// }
}
