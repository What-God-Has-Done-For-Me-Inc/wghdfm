// import 'dart:io';
//
// import 'package:camera/camera.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:wghdfm_java/common/common_snack.dart';
// import 'package:wghdfm_java/common/commons.dart';
// import 'package:wghdfm_java/modules/dashbord_module/views/dash_board_screen.dart';
// import 'package:wghdfm_java/modules/dashbord_module/views/take_picture_screen.dart';
// import 'package:wghdfm_java/modules/dashbord_module/views/take_video_screen.dart';
// import 'package:wghdfm_java/screen/dashboard/dashboard_api/post_status_api.dart';
// import 'package:wghdfm_java/utils/app_binding.dart';
// import 'package:wghdfm_java/utils/app_methods.dart';
//
// import '../../../utils/app_texts.dart';
//
// class AddNewPost extends StatefulWidget {
//   const AddNewPost({Key? key}) : super(key: key);
//
//   @override
//   State<AddNewPost> createState() => _AddNewPostState();
// }
//
// class _AddNewPostState extends State<AddNewPost> {
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   File? pickedImage;
//   RxList<File>? pickedFiles = <File>[].obs;
//   File? _video;
//
//   // VideoPlayerController? _videoPlayerController;
//   final pick = ImagePicker();
//
//   pickVideo() async {
//     final video = await pick.pickVideo(source: ImageSource.camera);
//     _video = File(video?.path ?? "");
//     // _videoPlayerController = VideoPlayerController.file(_video!)
//     //   ..initialize().then((_) {
//     //     setState(() {
//     //       _video = File(video?.path ?? "");
//     //     });
//     //   });
//     // _videoPlayerController?.play();
//   }
//
//   takeImage() async {
//     final image = await pick.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 40,
//     );
//     if (image != null) {
//       pickedFiles?.add(File(image.path));
//     }
//   }
//
//   takeVideo() async {
//     final image = await pick.pickVideo(source: ImageSource.camera);
//     if (image != null) {
//       pickedFiles?.add(File(image.path));
//     }
//   }
//
//   addPhotoScreen() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;
//     Get.to(() => TakePictureScreen(
//           camera: firstCamera,
//         ))?.then((value) {
//       pickedFiles?.add(value);
//     });
//   }
//
//   addVideoScreen() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;
//     Get.to(() => TakeVideoScreen(
//           camera: firstCamera,
//         ))?.then((value) {
//       pickedFiles?.add(value);
//     });
//   }
//
//   Future getImage() async {
//     final image = await FilePicker.platform.pickFiles(allowCompression: true, allowMultiple: true, withData: false, dialogTitle: "Pick Photo or Video", type: FileType.media);
//     if (image == null) return;
//     image.files.forEach((element) {
//       final tempImage = File(element.path ?? "");
//       setState(() {
//         // pickedImage = tempImage;
//         pickedFiles?.add(tempImage);
//       });
//     });
//   }
//
//   RxString selectedTab = "Image".obs;
//   RxBool agree = false.obs;
//   TextEditingController desStatusController = TextEditingController();
//   TextEditingController desImgController = TextEditingController();
//   TextEditingController urlYTController = TextEditingController();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     AppMethods().checkEULA();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add A New Post'),
//         backgroundColor: Colors.black,
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           SizedBox(
//             height: Get.mediaQuery.size.height * 0.02,
//           ),
//           StreamBuilder(
//               stream: selectedTab.stream,
//               builder: (context, snapshot) {
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         selectedTab.value = "Image";
//                       },
//                       child: Container(
//                           width: Get.mediaQuery.size.width * 0.5,
//                           alignment: Alignment.center,
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                               borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
//                               color: selectedTab.value == "Image" ? Colors.grey : Colors.white,
//                               border: Border.all(color: Colors.black)),
//                           child: const Text("Image/Video")),
//                     ),
//                     InkWell(
//                       onTap: () => selectedTab.value = "Status",
//                       child: Container(
//                           width: Get.mediaQuery.size.width * 0.5,
//                           alignment: Alignment.center,
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                               borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
//                               color: selectedTab.value == "Status" ? Colors.grey : Colors.white,
//                               border: Border.all(color: Colors.black)),
//                           child: const Text("Status")),
//                     )
//                   ],
//                 );
//               }),
//           Expanded(
//             child: StreamBuilder(
//                 stream: selectedTab.stream,
//                 builder: (context, snapshot) {
//                   if (selectedTab.value == "Status") {
//                     return SingleChildScrollView(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           const Text(
//                             'Youtube Video Link.',
//                             style: TextStyle(color: Colors.black),
//                           ),
//                           const SizedBox(
//                             height: 15,
//                           ),
//                           commonTextField(
//                             hint: 'Enter youtube video url here...',
//                             baseColor: Colors.grey,
//                             borderColor: Colors.blue,
//                             errorColor: Colors.black,
//                             maxLines: 1,
//                             isLastField: true,
//                             controller: urlYTController,
//
//                             // textStyle: gcolordarkGrey14w400.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
//                             // hintStyle: gcolordarkGrey14w400.copyWith(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.colorD6D9D8),
//                             // textEditingController: _link,
//                             // validationFunction: (String val) {
//                             //   if (val.isEmpty) {
//                             //     return "Please enter url";
//                             //   } else if (!isURL(val)) {
//                             //     return 'Please check url';
//                             //   }
//                             // },
//                           ),
//                           const SizedBox(
//                             height: 25,
//                           ),
//                           const Text(
//                             'Description',
//                             style: TextStyle(color: Colors.black),
//                           ),
//                           const SizedBox(height: 15),
//                           commonTextField(
//                             baseColor: Colors.grey,
//                             borderColor: Colors.blue,
//                             errorColor: Colors.black,
//                             isLastField: true,
//                             controller: desStatusController,
//
//                             // inputAction: TextInputAction.done,
//                             // maxLine: 6,
//                             // textStyle: gcolordarkGrey14w400.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
//                             // hintStyle: gcolordarkGrey14w400.copyWith(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.colorD6D9D8),
//                             hint: 'Say something about post...',
//                             // textEditingController: _dis,
//                           ),
//                         ],
//                       ).paddingSymmetric(horizontal: 10),
//                     );
//                   } else {
//                     return SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'Image/Video',
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               StreamBuilder(
//                                   stream: pickedFiles?.stream,
//                                   builder: (context, snapshot) {
//                                     if (pickedFiles?.isEmpty == true) {
//                                       return const SizedBox();
//                                     }
//                                     return const Text(
//                                       'Swipe to see images..',
//                                       style: TextStyle(color: Colors.grey),
//                                     );
//                                   }),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           StreamBuilder(
//                               stream: pickedFiles?.stream,
//                               builder: (context, snapshot) {
//                                 return Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Colors.black),
//                                   ),
//                                   height: 260,
//                                   width: double.maxFinite,
//                                   // child: pickedImage?.path == null && _video?.path == null || pickedImage?.path.isEmpty == true && _video?.path.isEmpty == true
//                                   child: pickedFiles?.isEmpty == true
//                                       ? Column(
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: [
//                                             // Image.asset(
//                                             //   'assets/images/icons/cloud_upload.png',
//                                             //   height: 70,
//                                             // ),
//                                             const Icon(
//                                               Icons.upload_file_outlined,
//                                               size: 70,
//                                             ),
//                                             const Text(
//                                               'Upload JPG, PNG, Video',
//                                               style: TextStyle(color: Colors.grey),
//                                             ),
//                                             const SizedBox(
//                                               height: 15,
//                                             ),
//                                           ],
//                                         )
//                                       : Stack(
//                                           // overflow: Overflow.visible,
//                                           clipBehavior: Clip.none,
//                                           children: [
//                                             Positioned.fill(
//                                               child: ClipRRect(
//                                                 borderRadius: BorderRadius.circular(12),
//                                                 child: SizedBox(
//                                                   height: 350,
//                                                   child: PageView.builder(
//                                                     // shrinkWrap: true,
//                                                     scrollDirection: Axis.horizontal,
//                                                     physics: const ClampingScrollPhysics(),
//                                                     itemCount: pickedFiles?.length ?? 0,
//                                                     itemBuilder: (context, index) {
//                                                       print("______ ITM ${pickedFiles?[index].path}");
//
//                                                       return Stack(
//                                                         children: [
//                                                           Container(
//                                                               width: Get.mediaQuery.size.width,
//                                                               height: 350,
//                                                               child: pickedFiles?[index].path.contains("jpg") == true ||
//                                                                       pickedFiles?[index].path.contains("jpeg") == true ||
//                                                                       pickedFiles?[index].path.contains("png") == true
//                                                                   ? Image.file(
//                                                                       File(pickedFiles?[index].path ?? ""),
//                                                                       fit: BoxFit.cover,
//                                                                     )
//                                                                   : Center(
//                                                                       child: FileVideoPlayer(
//                                                                       videoFile: File(pickedFiles?[index].path ?? ""),
//                                                                     ))),
//                                                           Positioned(
//                                                             top: 5,
//                                                             right: 5,
//                                                             child: GestureDetector(
//                                                               onTap: () {
//                                                                 setState(() {
//                                                                   _video = File("");
//                                                                   pickedImage = File('');
//                                                                   pickedFiles?.removeAt(index);
//                                                                   pickedFiles?.refresh();
//                                                                 });
//                                                               },
//                                                               child: const CircleAvatar(
//                                                                 radius: 12,
//                                                                 backgroundColor: Colors.black,
//                                                                 child: Icon(Icons.close, color: Colors.white),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       );
//                                                       return Container();
//                                                     },
//                                                   ),
//                                                 ),
//                                                 // child: _video?.path.isNotEmpty == true
//                                                 //     ? AspectRatio(
//                                                 //   aspectRatio: _videoPlayerController!.value.aspectRatio,
//                                                 //   child: VideoPlayer((_videoPlayerController!)),
//                                                 // )
//                                                 //     : pickedImage?.path.isNotEmpty == true
//                                                 //     ? Image.file(
//                                                 //   File(pickedImage?.path ?? ""),
//                                                 //   fit: BoxFit.cover,
//                                                 // )
//                                                 //     : Icon(Icons.upload_file,size: 70),
//                                               ),
//                                             ),
//
//                                             //
//
//                                             // Positioned(
//                                             //   top: -6,
//                                             //   right: -6,
//                                             //   child: GestureDetector(
//                                             //     onTap: () {
//                                             //       setState(() {
//                                             //         _video = File("");
//                                             //         pickedImage = File('');
//                                             //       });
//                                             //     },
//                                             //     child: const CircleAvatar(
//                                             //       radius: 12,
//                                             //       backgroundColor: Colors.black,
//                                             //       child: Icon(Icons.close, color: Colors.blue),
//                                             //     ),
//                                             //   ),
//                                             // )
//                                           ],
//                                         ),
//                                 );
//                               }),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               MaterialButton(
//                                 onPressed: () async {
//                                   // var status =
//                                   //     await Permission.storage.request();
//                                   // if (status.isDenied) {
//                                   //   if (status.isPermanentlyDenied) {
//                                   //     openAppSettings();
//                                   //   }
//                                   // }
//                                   // if (status.isGranted) {
//                                   //   getImage();
//                                   // }
//                                   if (await AppMethods().checkStoragePermission()) {
//                                     getImage();
//                                   }
//                                 },
//                                 elevation: 0,
//                                 color: Colors.grey,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                                 child: const Icon(Icons.perm_media),
//                                 // child: Text(
//                                 //   'Upload image or video',
//                                 //   style: TextStyle(color: Colors.black),
//                                 // ),
//                               ),
//                               const SizedBox(width: 10),
//                               MaterialButton(
//                                 onPressed: () async {
//                                   // var status = await Permission.storage.request();
//                                   // if (status.isDenied) {
//                                   //   if (status.isPermanentlyDenied) {
//                                   //     openAppSettings();
//                                   //   }
//                                   // }
//                                   // if (status.isGranted) {
//                                   //   takeImage();
//                                   // }
//                                   if (await AppMethods().checkPermission()) {
//                                     // takeImage();
//                                     addPhotoScreen();
//                                   }
//                                 },
//                                 elevation: 0,
//                                 color: Colors.grey,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                                 child: const Icon(Icons.camera_alt),
//                                 // child: Text(
//                                 //   'Take Pictures',
//                                 //   style: TextStyle(color: Colors.black),
//                                 // ),
//                               ),
//                               const SizedBox(width: 10),
//                               MaterialButton(
//                                 onPressed: () async {
//                                   // var status =
//                                   //     await Permission.storage.request();
//                                   // if (status.isDenied) {
//                                   //   if (status.isPermanentlyDenied) {
//                                   //     openAppSettings();
//                                   //   }
//                                   // }
//                                   // if (status.isGranted) {
//                                   //   takeVideo();
//                                   // }
//
//                                   if (await AppMethods().checkPermission()) {
//                                     // takeVideo();
//                                     addVideoScreen();
//                                   }
//                                 },
//                                 elevation: 0,
//                                 color: Colors.grey,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                                 child: const Icon(Icons.videocam),
//                                 // child: Text(
//                                 //   'Take Videos',
//                                 //   style: TextStyle(color: Colors.black),
//                                 // ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           const Text(
//                             'Description ',
//                             style: TextStyle(color: Colors.black),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           commonTextField(
//                             baseColor: Colors.grey,
//                             borderColor: Colors.blue,
//                             errorColor: Colors.black,
//                             isLastField: true,
//                             controller: desImgController,
//                             // inputAction: TextInputAction.done,
//                             maxLines: 5,
//                             // textStyle: gcolordarkGrey14w400.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
//                             // hintStyle: gcolordarkGrey14w400.copyWith(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.colorD6D9D8),
//                             hint: 'Say something about post...',
//                             // textEditingController: _dis,
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 }),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(15),
//             ),
//             color: Colors.grey.withOpacity(0.5)),
//         padding: EdgeInsets.only(bottom: Get.height * 0.02, left: 10.0, right: 10.0, top: 10.0),
//         child: StreamBuilder(
//           stream: AppMethods.eulaAccepted.stream,
//           builder: (context, snapshot) {
//             if (AppMethods.eulaAccepted.isTrue) {
//               agree.value = true;
//             }
//             return StreamBuilder(
//                 stream: agree.stream,
//                 builder: (context, snapshot) {
//                   return Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (AppMethods.eulaAccepted.isFalse)
//                         Row(
//                           children: [
//                             Checkbox(
//                               value: agree.value,
//                               onChanged: (value) {
//                                 agree.value = value ?? false;
//                               },
//                             ),
//                             RichText(
//                               text: TextSpan(style: const TextStyle(color: Colors.black), text: "By posting, I agree to the user", children: [
//                                 TextSpan(
//                                     text: " agreement",
//                                     style: const TextStyle(
//                                       color: Colors.blue,
//                                     ),
//                                     recognizer: new TapGestureRecognizer()
//                                       ..onTap = () {
//                                         launch(AppTexts.eulaLink);
//                                       }),
//                               ]),
//                             )
//                           ],
//                         ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           Expanded(
//                               child: ElevatedButton(
//                             onPressed: () {
//                               Get.back();
//                             },
//                             child: const Text("Cancel"),
//                             // borderRadius: 12,
//                             // backGroundColor: AppColors.colorE6E6E7,
//                             // textStyle: black16w600,
//                           )),
//                           if (agree.isTrue)
//                             const SizedBox(
//                               width: 20,
//                             ),
//                           if (agree.isTrue)
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                   AppMethods().acceptEULA();
//                                   if (selectedTab.value == "Image") {
//                                     if (pickedFiles?.isNotEmpty == true) {
//                                       snack(title: "Success", msg: "Your post is uploading in background..");
//                                       // Get.back();
//                                       Get.offAll(() => const DashBoardScreen());
//                                       await kDashboardController.uploadImage(
//                                           imageFilePaths: pickedFiles?.value ?? [],
//                                           description: desImgController.text,
//                                           showProngress: false,
//                                           callBack: () {
//                                             // Get.offAll(
//                                             //     () => const DashBoardScreen());
//                                           });
//                                     } else {
//                                       snack(title: "Ohh", msg: "Please upload photo or video");
//                                     }
//                                   } else {
//                                     if (urlYTController.text.isNotEmpty || desStatusController.text.isNotEmpty) {
//                                       postStatus(desStatusController.text, urlYTController.text, "", callBack: () {
//                                         Get.offAll(() => const DashBoardScreen());
//                                       });
//                                     } else {
//                                       snack(title: "Ohh", msg: "Please write description or YT Video Link.", iconColor: Colors.yellow, icon: Icons.warning);
//                                     }
//                                   }
//
//                                   // if (formKey.currentState?.validate() == true) {
//                                   //   if (pickedImage?.path != null && pickedImage?.path.isEmpty != true) {
//                                   //     final formData = dio.FormData.fromMap({"image": await dio.MultipartFile.fromFile(pickedImage?.path ?? "")});
//                                   //     commonControllers.addImageOrVideoApiCall(
//                                   //         formData: formData,
//                                   //         callBack: () async {
//                                   //           submitNewsSuggestionController.addshowNewTypeApi(() {
//                                   //             Get.off(() => const SubmitNewsTipScreen());
//                                   //             showSnackBar(message: "news suggestion created", title: ApiConfig.success);
//                                   //             submitNewsSuggestionController.showNewsSuggestionApi({});
//                                   //           }, {
//                                   //             "image": commonControllers.addNewsImageOrVideoModel.value.data?.image ?? "",
//                                   //             "thumnImg": commonControllers.addNewsImageOrVideoModel.value.data?.thumnImg ?? "",
//                                   //             "description": _dis.text,
//                                   //             "link": _link.text
//                                   //           }, isLoader: true);
//                                   //         });
//                                   //   } else if (_video?.path != null && _video?.path.isEmpty != true) {
//                                   //     final formData = dio.FormData.fromMap({"image": await dio.MultipartFile.fromFile(_video?.path ?? "")});
//                                   //     commonControllers.addImageOrVideoApiCall(
//                                   //         formData: formData,
//                                   //         callBack: () async {
//                                   //           submitNewsSuggestionController.addshowNewTypeApi(() {
//                                   //             Get.off(() => const SubmitNewsTipScreen());
//                                   //             showSnackBar(message: "news suggestion created", title: ApiConfig.success);
//                                   //             submitNewsSuggestionController.showNewsSuggestionApi({});
//                                   //           }, {
//                                   //             "image": commonControllers.addNewsImageOrVideoModel.value.data?.image ?? "",
//                                   //             "thumnImg": commonControllers.addNewsImageOrVideoModel.value.data?.thumnImg ?? "",
//                                   //             "description": _dis.text,
//                                   //             "link": _link.text
//                                   //           }, isLoader: true);
//                                   //         });
//                                   //   } else {
//                                   //     showSnackBar(message: 'Select Image or Video', title: ApiConfig.error);
//                                   //   }
//                                   // }
//                                 },
//                                 child: const Text("Post"),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//                   );
//                 });
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class FileVideoPlayer extends StatefulWidget {
//   final File videoFile;
//
//   const FileVideoPlayer({Key? key, required this.videoFile}) : super(key: key);
//
//   @override
//   State<FileVideoPlayer> createState() => _FileVideoPlayerState();
// }
//
// class _FileVideoPlayerState extends State<FileVideoPlayer> {
//   // VideoPlayerController videoPlayerController = VideoPlayerController.network("https://wghdfm.s3.amazonaws.com/videowires/1659596902_1.mp4");
//   // ChewieController chewieController = ChewieController(videoPlayerController: VideoPlayerController.network("https://wghdfm.s3.amazonaws.com/videowires/1659596902_1.mp4"));
//
//   @override
//   void initState() {
//     // videoPlayerController = VideoPlayerController.file(widget.videoFile);
//     // init().whenComplete(() {
//     //   if (mounted) {
//     //     setState(() {});
//     //   }
//     // });
//     // TODO: implement initState
//     // _controller = VideoPlayerController.network(widget.videoLink, videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: false, mixWithOthers: false))
//     //   ..initialize().then((_) {
//     //     // setState(() {});
//     //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//     //   });
//
//     super.initState();
//   }
//
//   Future init() async {
//     // await videoPlayerController.initialize();
//     // chewieController = ChewieController(
//     //   videoPlayerController: videoPlayerController,
//     //   autoPlay: false,
//     //   autoInitialize: true,
//     //   allowPlaybackSpeedChanging: false,
//     //   allowedScreenSleep: false,
//     //   allowMuting: false,
//     //   aspectRatio: videoPlayerController.value.aspectRatio,
//     //   fullScreenByDefault: false,
//     //   allowFullScreen: false,
//     //   showOptions: false,
//     //   // placeholder: Image.asset(AppImages.logoImage),
//     //   looping: false,
//     // );
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     // _controller.dispose();
//     // chewieController.dispose();
//     // videoPlayerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox();
//     // return StreamBuilder(
//     //   builder: (context, snapshot) {
//     //     RxBool loading = true.obs;
//     //     return StreamBuilder(
//     //       stream: loading.stream,
//     //       builder: (context, snapshot) {
//     //         Future.delayed(
//     //           const Duration(milliseconds: 500),
//     //           () => loading.value = false,
//     //         );
//     //         if (loading.value == true) {
//     //           return const Center(child: CupertinoActivityIndicator());
//     //         }
//     //         return videoPlayerController.value.isInitialized
//     //             ? Chewie(
//     //                 controller: chewieController,
//     //               )
//     //             : const Center(child: CupertinoActivityIndicator());
//     //       },
//     //     );
//     //   },
//     // );
//
//     // return _videoPlayerController!.value.isInitialized ?  AspectRatio(
//     //   aspectRatio: _videoPlayerController!.value.aspectRatio,
//     //   child: VideoPlayer((_videoPlayerController!)),
//     // ) : SizedBox(height: 35,width: 35,child: CupertinoActivityIndicator(),);
//   }
// }
