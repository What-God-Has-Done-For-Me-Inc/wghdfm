import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart' as awesome;
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';

// import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/common/video_compressor.dart';
import 'package:wghdfm_java/custom_package/zoom_drawer/config.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/model/friends_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/model/search_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/dash_board_screen.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/modules/notification_module/models/messages_model.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/post_status_bottom_sheet.dart';
import 'package:wghdfm_java/screen/donate/donate_ui.dart';
import 'package:wghdfm_java/services/prefrence_services.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/common-webview-screen.dart';
import 'package:wghdfm_java/utils/endpoints.dart';
import 'package:wghdfm_java/utils/page_res.dart';
import 'package:wghdfm_java/utils/toast_me_not.dart';
import 'package:wghdfm_java/utils/urls.dart';

import '../../../model/feed_res_obj.dart';
import '../../../utils/app_texts.dart';
import '../model/GrpModel.dart';

var userId;

class DashBoardController extends GetxController {
  final statusTEC = TextEditingController(), ytUrlTEC = TextEditingController();

  RxBool postUploading = false.obs;
  static RxString uploadingProcess = "0.0".obs;

  @override
  void onInit() {
    // feedScrollController.addListener(() {
    //   if (feedScrollController.position.pixels == feedScrollController.position.maxScrollExtent) {
    //     isLoading.value = true;
    //     previousPosition = feedScrollController.position.maxScrollExtent;
    //     isFirstTime = false;
    //     currentPage++;
    //     DashBoardApi.dashBoardLoadFeeds(
    //       isFirstTimeLoading: isFirstTime,
    //       page: currentPage,
    //     );
    //   }
    // });
    // DashBoardApi.dashBoardLoadFeeds(
    //   isFirstTimeLoading: isFirstTime,
    //   page: currentPage,
    // );

    // flickManager = FlickManager(
    //   videoPlayerController: VideoPlayerController.network("https://wghdfm.s3.amazonaws.com/videowires/1659596902_1.mp4"),
    // );
    super.onInit();
  }

  @override
  void dispose() {
    // flickManager.dispose();
    super.dispose();
  }

  bool isFirstTime = true;
  int currentPage = 0;
  int itemCount = 0;
  var isFabOpen = false;
  RxBool isLoading = false.obs;
  double previousPosition = 0;

  // late FlickManager flickManager;

  ZoomDrawerController zoomDrawerController = ZoomDrawerController();

  RxList<PostModelFeed> dashboardFeeds = <PostModelFeed>[].obs;

  Future dashBoardLoadFeeds(
      {bool isFirstTimeLoading = true, int? page, bool? isShowProcess}) async {
    if (isFirstTimeLoading) {
      dashboardFeeds.clear();
    }
    isLoading.value = true;
    userId = await fetchStringValuesSF(SessionManagement.KEY_ID);

    AppMethods.showLog(" LIST LENGHT BEFORE ${dashboardFeeds.length}");
    AppMethods.showLog(" USER ID >> $userId");
    AppMethods.showLog(" page >> $page");

    await APIService().callAPI(
        params: {},
        serviceUrl: /*isFirstTimeLoading ? ("${EndPoints.baseUrl}wire/index/$userId") : */
            ("${EndPoints.baseUrl}wire/more/$page/$userId"),
        method: APIService.postMethod,
        success: (dio.Response response) async {
          var decodedJson = jsonDecode(response.data);
          AppMethods.showLog("loadFeed responseBody: Starting >> $decodedJson"
              "<<<<<<Ending ");
          PostModel resObj = PostModel.fromJson(decodedJson);

          if (resObj.feed != null && resObj.feed!.isNotEmpty) {
            AppMethods.showLog(" LIST LENGHT API DATA ${resObj.feed?.length}");
            if (isFirstTimeLoading) {
              dashboardFeeds.clear();
              resObj.feed?.forEach((element) {
                dashboardFeeds.add(element ?? PostModelFeed());
              });
              await closeFunction();
            } else {
              try {
                resObj.feed?.forEach((element) {
                  dashboardFeeds.add(element ?? PostModelFeed());
                });
                await closeFunction();
              } finally {
                Get.back();
                await closeFunction();
              }
            }
          }
          AppMethods.showLog(" LIST LENGHT AFTER ${dashboardFeeds.length}");
        },
        error: (dio.Response response) async {
          final decoded = jsonDecode(response.data);
          AppMethods.showLog(">>>> RESPONSE SUCCESS >> ${decoded['status']}");
          AppMethods.showLog(">>>> RESPONSE ERROR >> ${response}");
          await closeFunction();

          ///Display snackbar here..
        },
        showProcess: isShowProcess ?? true);
    return null;
  }

  Future closeFunction() async {
    isLoading.value = false;
  }

  Rx<SearchModel> searchModel = SearchModel().obs;
  RxList<UserList> usersList = <UserList>[].obs;

  searchUsers({required String name, bool? isShowProcess}) async {
    await APIService().callAPI(
      params: {},
      formDatas: dio.FormData.fromMap({
        'keywords': name,
      }),
      serviceUrl: EndPoints.baseUrl + EndPoints.searchUser,
      method: APIService.postMethod,
      success: (dio.Response response) {
        searchModel.value = SearchModel.fromJson(jsonDecode(response.data));
        usersList.clear();
        searchModel.value.userList?.forEach((element) {
          usersList.add(element);
        });
        print(">> >> USrList $usersList");
      },
      error: (dio.Response response) {
        usersList.clear();
        snack(title: "Ohh Sorry", msg: "Please try again with diffrent name");
      },
      showProcess: isShowProcess ?? false,
    );
  }

  void onDrawerTileClick(int index) async {
    debugPrint("onDrawerTileClick index $index");
    switch (index) {
      case 0: //Home
        zoomDrawerController.close?.call();
        // Get.offNamed(PageRes.dashBoardScreen);
        // Get.back();
        Get.offAll(() => const DashBoardScreen());
        //pushReplaceTo(widget: DashboardUI());
        break;
      case 1: //Favorites
        zoomDrawerController.close?.call();
        // Get.back();
        Get.toNamed(PageRes.favouriteScreen);
        //todo: pushOnlyTo(widget: FavoritesUI());
        break;
      case 2: //Profile
        //var user = await SessionManagement.getUserDetails();
        zoomDrawerController.close?.call();

        LoginModel userDetails = await SessionManagement.getUserDetails();
        userId = userDetails.id;
        // Get.back();
        Get.toNamed(PageRes.profileScreen,
            arguments: {"profileId": userId, "isSelf": true});
        break;
      case 3: //Friends
        zoomDrawerController.close?.call();

        // Get.back();
        Get.toNamed(PageRes.friendScreen);
        //todo: pushOnlyTo(widget: FriendsUI());
        break;
      case 4: //Bible
        Get.back();
        // openInWeb(chatUrl);
        Get.to(() => CommonWebScreen(
              url: chatUrl,
              title: "Chat",
            ));
        break;
      case 5: //Bible
        Get.back();
        // openInWeb(bibleUrl);
        Get.to(() => CommonWebScreen(
              url: bibleUrl,
              title: "Bible",
            ));

        break;
      case 6: //Christian News
        Get.back();
        // openInWeb(christianNewsUrl);
        Get.to(() => CommonWebScreen(
              url: christianNewsUrl,
              title: "Christian News",
            ));

        break;
      case 7: //Our Daily Bread
        Get.back();
        // openInWeb(ourDailyBreadUrl);
        Get.to(() => CommonWebScreen(
              url: ourDailyBreadUrl,
              title: "Daily Bread",
            ));

        break;
      case 8: //Christian Books
        Get.back();
        // openInWeb(christianBooks);
        Get.to(() => CommonWebScreen(
              url: christianBooks,
              title: "Christian Books",
            ));

        break;
      case 9:
        zoomDrawerController.close?.call();

        // Get.back();
        Get.to(() => DonateUI());
        // Get.to(()=> PaypalPayment());
        //Partner With// Us
        /*pushTransitionedOnlyTo(widget: PaypalPayment(
          onFinish: (number) {
            if (number == null) {
              //widget.onLoading(false);
              //isPaying = false;
              return;
            } else {
              createOrder(paid: true).then((value) {
                widget.onLoading(false);
                isPaying = false;
              });
            }
          },
        ));*/
        //todo: pushTransitionedOnlyTo(widget: DonateUI());
        break;
      default:
        return null;
    }
  }

  Future<void> fabOnClicks(
      DashBoardController c, int index, BuildContext context) async {
    switch (index) {
      case 0: //Status
        postStatusBottomSheet(c, onPost: () {
          update();
        });
        break;
      case 1: //Photo
        SessionManagement.createPostSession("");
        openImageCaptureOptions(fromGallery: () {
          uploadImageFromGallery().then((_) => update());
        }, fromCamera: () {
          captureImage().then((_) => update());
        });

        break;
      case 2: //Video
        SessionManagement.createPostSession("");
        openVideoCaptureOptions(fromGallery: () {
          uploadVideoFromGallery().then((_) => update());
        }, fromCamera: () {
          captureVideo(context).then((_) => update());
        });
        break;
    }
  }

  Future<void> captureVideo(BuildContext context) async {
    if (await Permission.storage.request().isGranted) {
      // final vidPath = await navigateToCaptureImgVid(
      //     context: context, willShootVid: true);
      final vidPath = await Get.toNamed(PageRes.captureImgVidScreen,
          arguments: {"0": "true"});
      if (vidPath.trim() != "") {
        //debugPrint("Picture File Path from Camera: " + vidPath);

        File videoFile = File(vidPath);
        debugPrint("videoFile Path from captureVideo() => ${videoFile.path}");

        showProgressDialog();
        File? compressedVideoFile = await compressAndGetVideoFile(videoFile);
        Get.back();
        debugPrint(
            "compressedVideoFile Path from captureVideo() => ${compressedVideoFile!.path}");
        await uploadVideo(compressedVideoFile);
      }
    } else {
      ToastMeNot.show(
          "Unable to write to storage. Permission required.", context);
      await Permission.storage.request();
    }
  }

  Future<void> uploadVideoFromGallery() async {
    final videoFile = await fetchVideoFile();
    if (videoFile != null) {
      showProgressDialog();
      File? compressedVideoFile = await compressAndGetVideoFile(videoFile);
      Get.back();
      debugPrint(
          "compressedVideoFile Path from uploadVideoFromGallery() => ${compressedVideoFile!.path}");
      await uploadVideo(compressedVideoFile);
    }
  }

  Future<void> captureImage() async {
    // final picPath = await navigateToCaptureImgVid(
    //     context: context, willShootVid: false);
    final picPath = await Get.toNamed(PageRes.captureImgVidScreen,
        arguments: {"0": "true"});
    if (picPath.trim() != "") {
      debugPrint('Picture File Path from Camera: ' + picPath);

      File imageFile = File(picPath);
    }
  }

  Future<void> uploadImageFromGallery() async {
    final images = (await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
      allowCompression: true,
    ))
        ?.files;

    // final imagePicker = ImagePicker();
    // final List<XFile> images = await imagePicker.pickMultiImage(imageQuality: 50);
    final List<File> imageFile = <File>[];
    if (images != null) {
      for (var element in images) {
        imageFile.add(File(element.path ?? ""));
      }
    }
    if (imageFile != null && imageFile.isNotEmpty) {
      await uploadImage(imageFilePaths: imageFile);
    }
  }

  void openVideoCaptureOptions(
      {VoidCallback? fromGallery, VoidCallback? fromCamera}) {
    Get.dialog(Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: ListView(
        padding: const EdgeInsets.all(10),
        shrinkWrap: true,
        children: [
          Container(
              padding: const EdgeInsets.only(bottom: 5),
              width: Get.width,
              child: const Text("Upload Video")),
          ElevatedButton(
              onPressed: () {
                Get.back();
                fromGallery!();
              },
              child: const Text("Gallery")),
          // ElevatedButton(
          //     onPressed: () {
          //       Get.back();
          //       fromCamera!();
          //     },
          //     child: Text("Camera")),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text(
                "You posting something by agreeing",
                style: TextStyle(color: Colors.red),
              ),
              InkWell(
                  onTap: () async {
                    await launch(
                      AppTexts.eulaLink,
                    );
                  },
                  child: const Text(
                    " EULA",
                    style: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.underline),
                  )),
            ],
          ),
        ],
      ),
    ));
  }

  void openImageCaptureOptions(
      {VoidCallback? fromGallery, VoidCallback? fromCamera}) {
    Get.dialog(Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: ListView(
        padding: const EdgeInsets.all(10),
        shrinkWrap: true,
        children: [
          Container(
              padding: const EdgeInsets.only(bottom: 5),
              width: Get.width,
              child: const Text("Upload Image")),
          ElevatedButton(
              onPressed: () {
                Get.back();
                fromGallery!();
              },
              child: const Text("Gallery")),
          // ElevatedButton(
          //     onPressed: () {
          //       Get.back();
          //       fromCamera!();
          //     },
          //     child: Text("Camera")),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text(
                "You posting something by agreeing",
                style: TextStyle(color: Colors.red),
              ),
              InkWell(
                  onTap: () async {
                    await launch(
                      AppTexts.eulaLink,
                    );
                  },
                  child: const Text(
                    " EULA",
                    style: TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.underline),
                  )),
            ],
          ),
        ],
      ),
    ));
  }

  Future<File?> compressAndGetVideoFile(File file) async {
    File videoFile = file;
    return videoFile;
  }

  Future<void> uploadVideo(
    File videoFile,
  ) async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;
    var postId = await fetchStringValuesSF(SessionManagement.POST_ID);

    loader(isCancellable: false);

    APIService().callAPI(
        headers: {
          "Content-Type": "multipart/form-data",
          "Accept": "*/*",
          "Connection": "keep-alive",
        },
        params: {},
        formDatas: dio.FormData.fromMap({"files": videoFile}),
        serviceUrl:
            "${EndPoints.baseUrl} ${EndPoints.uploadVideoUrl}$userId/$postId}",
        method: APIService.postMethod,
        success: (dio.Response response) {
          Get.back();
          snack(msg: "Video has been posted successfully.", title: "Status");
        },
        error: (dio.Response response) {
          String responseBody = response.data;
          snack(
              title: "Failed",
              msg: responseBody,
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: true);
  }

  Future<File?> fetchVideoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result == null) {
      return null;
    }
    return File(result.files.single.path!);
  }

  Future<void> uploadImage({
    required List<File?> imageFilePaths,
    String? description,
    String? toOwnerId,
    bool? showProngress,
    String? taggedUsers,
    Function? callBack,
  }) async {
    postUploading.value = true;
    uploadingProcess.value = "0.0";
    // AwesomeNotifications().createNotification(
    //     content: NotificationContent(
    //   id: 1,
    //   channelKey: 'basic_channel',
    //   title: "Uploading..",
    //   body: "Your Post is uploading on What God Has Done For Me ",
    //   actionType: ActionType.Default,
    // ));
    print(">>>> PATH >> ${imageFilePaths}");

    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;

    ///In case of new image post, post id is ""
    // loader(isCancellable: false);

    ///Compressor Code
    // for (var element in image.files) {
    //   final tempImage = File(element.path ?? "");
    //   print("========= FILE PATH  ========${tempImage.path}");
    //   if (isVideo(filePath: tempImage.path)) {
    //     final compressedFile = await videoCompressor.compressVideo(originalFile: tempImage);
    //     if (compressedFile != null) {
    //       setState(() {
    //         // pickedImage = tempImage;
    //         pickedFiles?.add(compressedFile);
    //         VideoCompressor.percentage.value = 0.0;
    //       });
    //     }
    //   } else {
    //     if (tempImage != null) {
    //       setState(() {
    //         // pickedImage = tempImage;
    //         pickedFiles?.add(tempImage);
    //       });
    //     }
    //   }
    // }
    final LightCompressor _lightCompressor = LightCompressor();
    VideoCompressor videoCompressor = VideoCompressor();
    List<dio.MultipartFile> fileList = <dio.MultipartFile>[];

    try {
      for (var element in imageFilePaths) {
        ///File Compressor Added..
        // final compressedFile = await FileCompressor.compressFile(file: File(element!.path));
        if (isVideo(filePath: element?.path ?? "")) {
          final Result response = await _lightCompressor.compressVideo(
            path: element!.path,
            videoQuality: VideoQuality.medium,
            isMinBitrateCheckEnabled: false,
            video: Video(
                videoName: element.path
                    .split('/')
                    .last
                    .toString()
                    .split('.')
                    .first
                    .toString()),
            android:
                AndroidConfig(isSharedStorage: false, saveAt: SaveAt.Movies),
            ios: IOSConfig(saveInGallery: false),
          );
          /* final compressedFile = await videoCompressor.compressVideo(
              originalFile: element ?? File(""));*/
          if (response is OnSuccess) {
            /*  final bytes = (await response..readAsBytes())!.lengthInBytes;
            final kb = bytes / 1024;
            final mb = kb / 1024;
            print("=== === === === === === === === === === === === $mb mb");*/
            print(
                "=== === === === === === === === === === === === ${response.destinationPath}");
            dio.MultipartFile file =
                await dio.MultipartFile.fromFile(response.destinationPath);
            fileList.add(file);
            print('file added');
          } else if (response is OnFailure) {
            snack(
                title: "Failed",
                msg: "Compress Fail => for (var element in imageFilePaths)",
                iconColor: Colors.red,
                icon: Icons.close);
          }
        } else {
          dio.MultipartFile file =
              await dio.MultipartFile.fromFile(element?.path ?? "");
          fileList.add(file);
          print('image file added');
        }
      }

    } catch (e) {
      print("====== Error => ${e.toString()}");
      postUploading.value = false;
      uploadingProcess.value = "0.0";
      Get.back();
      snack(
          title: "Failed",
          msg: "Catch Error => for (var element in imageFilePaths)",
          iconColor: Colors.red,
          icon: Icons.close);
      // snack(title: " Catch Error => for (var element in imageFilePaths)", msg: "Code:- 001", icon: Icons.close, textColor: Colors.red.withOpacity(0.5));
    }
    print(fileList.length);

    try {
      callNodeJSUploadAPI(
          fileList: fileList,
          onSuccess: (dio.Response response) async {
            print('success');

            if (response.data["success"] == true) {
              List<String> fileNames = [];
              print("======== ${response.data}");
              response.data["data"].forEach((value) {
                print("======== POST NAME ${value}");
                fileNames.add(value);
              });

              Map<String, dynamic> data = {
                "user_id": userId,
                "to_owner_id": toOwnerId ?? "",
                "multi_wire_content": description ?? "",
                "post_id": "",
                /*imageFilePaths.toString()*/
                //    "multi_wire_content": imageFilePaths.toString()
                // "multi_wirefile[]": fileList,
                "multi_wirefile": fileNames.join('_|_'),
                "multi_wire_tag_user_id": taggedUsers,
              };

              print("uploadImage responseBody: $data ");
              await APIService().callAPI(
                  formDatas: dio.FormData.fromMap(data),
                  // percentage: uploadingProcess,
                  params: {},
                  headers: {},
                  serviceUrl: EndPoints.baseUrl + EndPoints.uploadPostData,
                  method: APIService.postMethod,
                  success: (dio.Response response) async {
                    postUploading.value = false;
                    print("---- showProngress ____${response.data}");
                    var responseData = jsonDecode(response.data);
                    snack(msg: "${responseData['message']}", title: "Status");
                    // Get.offAll(() => DashBoardScreen());
                    // currentPage = 0;
                    postUploading.value = false;
                    uploadingProcess.value = "0.0";
                    awesome.AwesomeNotifications().createNotification(
                        content: awesome.NotificationContent(
                            id: 1,
                            channelKey: 'basic_channel',
                            title: "Uploaded..",
                            body:
                                "Your Post is uploaded on What God Has Done For Me, Please refresh to see..",
                            actionType: awesome.ActionType.Default));

                    if (callBack != null) {
                      callBack();
                    }
                    await dashBoardLoadFeeds(
                      isShowProcess: showProngress ?? true,
                      isFirstTimeLoading: true,
                      page: currentPage,
                    );
                    print(
                        "UPLOADED POST ID FOR NOTIFICATION IS ${responseData['post_id']} ");
                    taggedUsers?.split("|").forEach((element) {
                      NotificationHandler.to.sendNotificationToUserID(
                        userId: element,
                        title: "Tagged in post ",
                        body: "You are tagged in post.. ",
                        postId: "${responseData['post_id']}",
                      );
                    });
                  },
                  error: (dio.Response response) {
                    postUploading.value = false;
                    uploadingProcess.value = "0.0";
                    print(
                        "---- showProngress ____ error ---  ${response.data}");
                    String responseBody = response.data;

                    debugPrint("uploadImage responseBody: $responseBody");
                    Get.back();
                    snack(
                        title: "Failed",
                        msg: responseBody,
                        iconColor: Colors.red,
                        icon: Icons.close);
                  },
                  showProcess: showProngress ?? false);
            }
          },
          onError: (dio.Response response) {
            postUploading.value = false;
            uploadingProcess.value = "0.0";
            print("---- showProngress ____ error ---  ${response.statusCode}");
            print("---- showProngress ____ error ---  ${response.data}");
            String responseBody = response.data;

            debugPrint("uploadImage responseBody: $responseBody");
            Get.back();
            snack(
                title: "Failed",
                msg: responseBody,
                iconColor: Colors.red,
                icon: Icons.close);
          });
    } catch (e) {
      snack(
          title: " Catch Error => NODEJS 00 ",
          msg: "Code:- 001",
          icon: Icons.close,
          textColor: Colors.red.withOpacity(0.5));
    }
  }

  callNodeJSUploadAPI(
      {required List<dio.MultipartFile> fileList,
      required Function onSuccess,
      required Function onError}) async {
    try {
      await APIService().callAPI(
          formDatas: dio.FormData.fromMap({"photo": fileList}),
          percentage: uploadingProcess,
          params: {},
          headers: {},
          serviceUrl: EndPoints.postUploadingURL,
          method: APIService.postMethod,
          success: (dio.Response response) async {
            print('success Recived');
            onSuccess(response);
          },
          error: (dio.Response response) {
            print("----- RESPONSE statusCode ==== ${response.statusCode}");
            print("----- RESPONSE Data ==== ${response.data}");
            onError(response);
          },
          showProcess: false);
    } catch (e) {
      onError(dio.Response(
        requestOptions: dio.RequestOptions(path: ""),
      ));
      print(
          "====== Catch Error => InSide callNodeJSUploadAPI ========${e.toString()}");
      snack(
          title: " Catch Error => InSide callNodeJSUploadAPI",
          msg: "Code:- 001",
          icon: Icons.close,
          textColor: Colors.red.withOpacity(0.5));
    }
  }

  Future<void> editImage({
    required List<File?> imageFilePaths,
    String? statusText,
    required String postId,
    Function? callBack,
  }) async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;

    ///In case of new image post, post id is ""
    loader(isCancellable: false);
    List<dio.MultipartFile> fileList = <dio.MultipartFile>[];
    for (var element in imageFilePaths) {
      dio.MultipartFile file =
          await dio.MultipartFile.fromFile(element?.path ?? "");
      fileList.add(file);
    }
    Map<String, dynamic> data = {
      "user_id": userId,
      "to_owner_id": "",
      "multi_wire_content": statusText,
      "post_id": postId,
      /*imageFilePaths.toString()*/
      //    "multi_wire_content": imageFilePaths.toString()
      "multi_wirefile[]": fileList,
      "multi_wire_tag_user_id": "",
    };
    print("uploadImage responseBody: $data ");
    await APIService().callAPI(
        formDatas: dio.FormData.fromMap(data),
        params: {},
        headers: {},
        serviceUrl: EndPoints.baseUrl + EndPoints.uploadOriginalImgUrl,
        method: APIService.postMethod,
        success: (dio.Response response) async {
          var responseData = jsonDecode(response.data);
          snack(msg: "${responseData['message']}", title: "Status");
          // Get.offAll(() => DashBoardScreen());
          currentPage = 0;
          await dashBoardLoadFeeds(
            isShowProcess: true,
            isFirstTimeLoading: true,
            page: currentPage,
          );

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
              msg: responseBody,
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: true);
  }

  RxList<GroupModelData> availableGrp = <GroupModelData>[].obs;

  getShareableGroup({Function? callBack}) {
    APIService().callAPI(
        params: {},
        serviceUrl: "${EndPoints.baseUrl}${EndPoints.getAllGrpURL}$userId}",
        method: APIService.postMethod,
        success: (dio.Response response) {
          GroupModel grpModel = GroupModel.fromJson(jsonDecode(response.data));
          availableGrp.clear();
          grpModel.data?.forEach((element) {
            availableGrp.add(element ?? GroupModelData());
          });
          if (callBack != null) {
            callBack();
          }
        },
        error: (dio.Response response) {
          String responseBody = response.data;
          snack(
              title: "Failed",
              msg: responseBody,
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: true);
  }

  sharePost(
      {String? postId, String? ownerId, String? allGrpId, Function? callBack}) {
    APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          "wire_id": postId,
          "owner_id": ownerId,
          "all_group_id": allGrpId,
        }),
        serviceUrl: "${EndPoints.baseUrl}${EndPoints.shareToGrpURL}",
        method: APIService.postMethod,
        success: (dio.Response response) {
          String responseBody = response.data;
          snack(
            title: "Success",
            msg: "Shared Post Successfully ",
          );
          if (callBack != null) {
            callBack();
          }
        },
        error: (dio.Response response) {
          String responseBody = response.data;
          snack(
              title: "Failed",
              msg: "Failed to post..! Please try again",
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: true);
  }

  sharePostToGroup({
    String? postId,
    String? ownerID,
  }) {
    RxList<String> selectedGrp = <String>[].obs;
    getShareableGroup(callBack: () {
      TextEditingController searchController = TextEditingController();
      Get.dialog(Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
        child: StatefulBuilder(
          builder: (context, StateSetter setStateSearch) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Share in Groups",
                  style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  color: Colors.white,
                  child: commonTextField(
                      baseColor: Colors.black,
                      borderColor: Colors.black,
                      controller: searchController,
                      errorColor: Colors.white,
                      hint: "Search Group",
                      onChanged: (String? value) {
                        setStateSearch(() {});
                      }),
                ),
                SizedBox(
                  height: Get.height * 0.35,
                  width: Get.width * 0.8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableGrp.length ?? 0,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (availableGrp[index]
                              .groupTitle
                              ?.toLowerCase()
                              .contains(searchController.text.toLowerCase()) ==
                          true) {
                        return StreamBuilder(
                            stream: selectedGrp.stream,
                            builder: (context, snapshot) {
                              return CheckboxListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                // tileColor: Colors.grey.withOpacity(0.5),
                                value: selectedGrp.contains(
                                        availableGrp[index].groupId) ==
                                    true,
                                onChanged: (value) {
                                  print("vlue : $value");
                                  print("selectedGrp : $selectedGrp");
                                  if (selectedGrp.contains(
                                          availableGrp[index].groupId) ==
                                      true) {
                                    selectedGrp
                                        .remove(availableGrp[index].groupId);
                                  } else {
                                    selectedGrp
                                        .add("${availableGrp[index].groupId}");
                                  }
                                  selectedGrp.refresh();
                                },
                                title:
                                    Text("${availableGrp[index].groupTitle}"),
                              ).paddingOnly(bottom: 3);
                            });
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        String selectedID = "";
                        String currentID = "";
                        for (var element in selectedGrp) {
                          currentID = "${selectedID}" + "${element}";
                          selectedID = "${currentID}|";
                        }
                        print("selectedID %{ ${selectedID}");

                        sharePost(
                          postId: postId,
                          ownerId: ownerID,
                          allGrpId: selectedID,
                        );
                      },
                      child: Text("Share"),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ));
      // Get.dialog(AlertDialog(
      //   backgroundColor: Colors.white,
      //   title: const Text("Share in Groups"),
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      //   // contentPadding: EdgeInsets.zero,
      //   content: StatefulBuilder(
      //     builder: (context, StateSetter setStateSearch) {
      //       return Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           Container(
      //             color: Colors.white,
      //             child: commonTextField(
      //                 baseColor: Colors.black,
      //                 borderColor: Colors.black,
      //                 controller: searchController,
      //                 errorColor: Colors.white,
      //                 hint: "Search Group",
      //                 onChanged: (String? value) {
      //                   setStateSearch(() {});
      //                 }),
      //           ),
      //           SizedBox(
      //             height: Get.height * 0.4,
      //             width: Get.width * 0.8,
      //             child: ListView.builder(
      //               shrinkWrap: true,
      //               itemCount: availableGrp.length ?? 0,
      //               physics: ClampingScrollPhysics(),
      //               itemBuilder: (context, index) {
      //                 if (availableGrp[index].groupTitle?.toLowerCase().contains(searchController.text.toLowerCase()) == true) {
      //                   return StreamBuilder(
      //                       stream: selectedGrp.stream,
      //                       builder: (context, snapshot) {
      //                         return CheckboxListTile(
      //                           contentPadding: EdgeInsets.symmetric(horizontal: 10),
      //                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //                           // tileColor: Colors.grey.withOpacity(0.5),
      //                           value: selectedGrp.contains(availableGrp[index].groupId) == true,
      //                           onChanged: (value) {
      //                             print("vlue : $value");
      //                             print("selectedGrp : $selectedGrp");
      //                             if (selectedGrp.contains(availableGrp[index].groupId) == true) {
      //                               selectedGrp.remove(availableGrp[index].groupId);
      //                             } else {
      //                               selectedGrp.add("${availableGrp[index].groupId}");
      //                             }
      //                             selectedGrp.refresh();
      //                           },
      //                           title: Text("${availableGrp[index].groupTitle}"),
      //                         ).paddingOnly(bottom: 3);
      //                       });
      //                 } else {
      //                   return SizedBox();
      //                 }
      //               },
      //             ),
      //           ),
      //         ],
      //       );
      //     },
      //   ),
      //   actions: [
      //     TextButton(
      //       onPressed: () {
      //         Get.back();
      //       },
      //       child: Text("Cancel"),
      //     ),
      //     TextButton(
      //       onPressed: () {
      //         String selectedID = "";
      //         String currentID = "";
      //         for (var element in selectedGrp) {
      //           currentID = "${selectedID}" + "${element}";
      //           selectedID = "${currentID}|";
      //         }
      //         print("selectedID %{ ${selectedID}");
      //
      //         sharePost(
      //           postId: postId,
      //           ownerId: ownerID,
      //           allGrpId: selectedID,
      //         );
      //       },
      //       child: Text("Share"),
      //     ),
      //   ],
      // ));
    });
  }

  RxInt notificationCount = 0.obs;

  Future getNotificationCount({bool? showProcess, Function? callBack}) async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    String? userID = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          "user_id": userID,
        }),
        serviceUrl: "${EndPoints.baseUrl}${EndPoints.getUnreadMsgCount}",
        method: APIService.postMethod,
        success: (dio.Response response) {
          print("--------------- ${response.data}");
          notificationCount.value =
              jsonDecode(response.data)['unread_msg_count'] ?? 0;
          print("............ $notificationCount");
        },
        error: (dio.Response response) {
          String responseBody = response.data;
          snack(
              title: "Failed",
              msg: "Failed to post..! Please try again",
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: showProcess ?? true);
  }

  Rx<AllMessagesModel> messagesModel = AllMessagesModel().obs;
  RxList<AllMessagesModel> allMessageList = <AllMessagesModel>[].obs;

  Future getMessages() async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    String? userID = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          "user_id": userID,
        }),
        serviceUrl: "${EndPoints.baseUrl}${EndPoints.getAllMessages}",
        method: APIService.postMethod,
        success: (dio.Response response) {
          messagesModel.value =
              AllMessagesModel.fromJson(jsonDecode(response.data));
        },
        error: (dio.Response response) {
          String responseBody = response.data;
          snack(
              title: "Failed",
              msg: "Failed to post..! Please try again",
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: true);
  }

  Rx<FriendsModel> friendsModel = FriendsModel().obs;

  Future getFriendList() async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    String? userID = userDetails.id;
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          "user_id": userID,
        }),
        serviceUrl: "${EndPoints.baseUrl}${EndPoints.friendsListAPI}",
        method: APIService.postMethod,
        success: (dio.Response response) {
          friendsModel.value = FriendsModel.fromJson(jsonDecode(response.data));
        },
        error: (dio.Response response) {
          String responseBody = response.data;
          snack(
              title: "Failed",
              msg: "Failed to post..! Please try again",
              iconColor: Colors.red,
              icon: Icons.close);
        },
        showProcess: false);
  }
}
