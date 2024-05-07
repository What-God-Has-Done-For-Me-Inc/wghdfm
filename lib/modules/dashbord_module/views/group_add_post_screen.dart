import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/common/video_player.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/take_picture_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/take_video_screen.dart';
import 'package:wghdfm_java/screen/groups/group_controller.dart';
import 'package:wghdfm_java/utils/app_methods.dart';

import '../../../utils/app_texts.dart';

class GroupAddNewPost extends StatefulWidget {
  // final Group group;
  final String groupId;

  const GroupAddNewPost({Key? key, required this.groupId}) : super(key: key);

  @override
  State<GroupAddNewPost> createState() => _GroupAddNewPostState();
}

class _GroupAddNewPostState extends State<GroupAddNewPost> {
  File? pickedImage;
  RxList<File>? pickedFiles = <File>[].obs;
  File? _video;
  final pick = ImagePicker();

  pickVideo() async {
    final video = await pick.pickVideo(source: ImageSource.camera);
    _video = File(video?.path ?? "");
  }

  addPhotoScreen() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    Get.to(() => TakePictureScreen(
          camera: firstCamera,
        ))?.then((value) {
      pickedFiles?.add(value);
    });
  }

  addVideoScreen() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    Get.to(() => TakeVideoScreen(
          camera: firstCamera,
        ))?.then((value) {
      pickedFiles?.add(value);
    });
  }

  takeImage() async {
    final image = await pick.pickImage(
      source: ImageSource.camera,
      imageQuality: 40,
    );
    if (image != null) {
      pickedFiles?.add(File(image.path));
    }
  }

  takeVideo() async {
    final image = await pick.pickVideo(source: ImageSource.camera);
    if (image != null) {
      pickedFiles?.add(File(image.path));
    }
  }

  Future getImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> image =
        await picker.pickMultipleMedia(requestFullMetadata: false);

    if (image.isEmpty) return;
    image.forEach((element) {
      final tempImage = File(element.path);
      setState(() {
        // pickedImage = tempImage;
        pickedFiles?.add(tempImage);
      });
    });
  }

  GroupController groupController = Get.put(GroupController());

  RxString selectedTab = "Status".obs;
  RxBool agree = false.obs;
  TextEditingController desStatusController = TextEditingController();
  TextEditingController desImgController = TextEditingController();
  TextEditingController urlYTController = TextEditingController();

  @override
  void initState() {
    AppMethods().checkEULA();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add A Group Post'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: Get.mediaQuery.size.height * 0.02,
          ),
          StreamBuilder(
              stream: selectedTab.stream,
              builder: (context, snapshot) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () => selectedTab.value = "Status",
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: selectedTab.value == "Status"
                                  ? Colors.grey
                                  : Colors.white,
                              border: Border.all(color: Colors.black)),
                          child: const Text("Status")),
                    ),
                    InkWell(
                      onTap: () {
                        selectedTab.value = "Image";
                      },
                      child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: selectedTab.value == "Image"
                                  ? Colors.grey
                                  : Colors.white,
                              border: Border.all(color: Colors.black)),
                          child: Text("Image/Video")),
                    ),
                  ],
                );
              }),
          Expanded(
            child: StreamBuilder(
                stream: selectedTab.stream,
                builder: (context, snapshot) {
                  if (selectedTab.value == "Status") {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Youtube Video Link.',
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          commonTextField(
                            hint: 'Enter youtube video url here...',
                            baseColor: Colors.grey,
                            borderColor: Colors.blue,
                            errorColor: Colors.black,
                            maxLines: 1,
                            isLastField: true,
                            controller: urlYTController,

                            // textStyle: gcolordarkGrey14w400.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
                            // hintStyle: gcolordarkGrey14w400.copyWith(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.colorD6D9D8),
                            // textEditingController: _link,
                            // validationFunction: (String val) {
                            //   if (val.isEmpty) {
                            //     return "Please enter url";
                            //   } else if (!isURL(val)) {
                            //     return 'Please check url';
                            //   }
                            // },
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Text(
                            'Description',
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          commonTextField(
                            baseColor: Colors.grey,
                            borderColor: Colors.blue,
                            errorColor: Colors.black,
                            isLastField: true,
                            controller: desStatusController,

                            // inputAction: TextInputAction.done,
                            // maxLine: 6,
                            // textStyle: gcolordarkGrey14w400.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
                            // hintStyle: gcolordarkGrey14w400.copyWith(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.colorD6D9D8),
                            hint: 'Say something about post...',
                            // textEditingController: _dis,
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 10),
                    );
                  } else {
                    return ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Image/Video',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            StreamBuilder(
                                stream: pickedFiles?.stream,
                                builder: (context, snapshot) {
                                  if (pickedFiles?.isEmpty == true) {
                                    return SizedBox();
                                  }
                                  return Text(
                                    'Swipe to see images..',
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        // DottedBorder(
                        //   borderType: BorderType.RRect,
                        //   dashPattern: const [6, 6],
                        //   color: Colors.black12,
                        //   radius: const Radius.circular(12),
                        //   child: SizedBox(
                        //     height: 260,
                        //     width: double.maxFinite,
                        //     child: pickedImage?.path == null && _video?.path == null || pickedImage?.path.isEmpty == true && _video?.path.isEmpty == true
                        //         ? Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Image.asset(
                        //           'assets/images/icons/cloud_upload.png',
                        //           height: 70,
                        //         ),
                        //         Text(
                        //           'Upload JPG, PNG, Video',
                        //           style: TextStyle(color: Colors.grey),
                        //         ),
                        //         const SizedBox(
                        //           height: 15,
                        //         ),
                        //         Row(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             MaterialButton(
                        //               onPressed: () async {
                        //                 var status = await Permission.storage.request();
                        //                 if (status.isDenied) {
                        //                   if (status.isPermanentlyDenied) {
                        //                     openAppSettings();
                        //                   }
                        //                 }
                        //                 if (status.isGranted) {
                        //                   getImage(ImageSource.gallery);
                        //                 }
                        //               },
                        //               elevation: 0,
                        //               color: Colors.grey,
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius: BorderRadius.circular(12),
                        //               ),
                        //               padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 35),
                        //               child: Text(
                        //                 'Choose image',
                        //                 style: TextStyle(color: Colors.black),
                        //               ),
                        //             ),
                        //             const SizedBox(width: 10),
                        //             MaterialButton(
                        //               onPressed: () async {
                        //                 var status = await Permission.storage.request();
                        //                 if (status.isDenied) {
                        //                   if (status.isPermanentlyDenied) {
                        //                     openAppSettings();
                        //                   }
                        //                 }
                        //                 if (status.isGranted) {
                        //                   pickVideo();
                        //                 }
                        //               },
                        //               elevation: 0,
                        //               color: Colors.black,
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius: BorderRadius.circular(12),
                        //               ),
                        //               padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 35),
                        //               child: Text(
                        //                 'Choose video',
                        //                 style: TextStyle(color: Colors.black),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     )
                        //         : Stack(
                        //       // overflow: Overflow.visible,
                        //       clipBehavior: Clip.none,
                        //       children: [
                        //         Positioned.fill(
                        //           child: ClipRRect(
                        //             borderRadius: BorderRadius.circular(12),
                        //             child: _video?.path.isNotEmpty == true
                        //                 ? AspectRatio(
                        //               aspectRatio: _videoPlayerController!.value.aspectRatio,
                        //               child: VideoPlayer((_videoPlayerController!)),
                        //             )
                        //                 : pickedImage?.path.isNotEmpty == true
                        //                 ? Image.file(
                        //               File(pickedImage?.path ?? ""),
                        //               fit: BoxFit.cover,
                        //             )
                        //                 : Image.asset("assets/images/placeholder.png", fit: BoxFit.contain),
                        //           ),
                        //         ),
                        //
                        //         //
                        //
                        //         Positioned(
                        //           top: -6,
                        //           right: -6,
                        //           child: GestureDetector(
                        //             onTap: () {
                        //               setState(() {
                        //                 _video = File("");
                        //                 pickedImage = File('');
                        //               });
                        //             },
                        //             child: const CircleAvatar(
                        //               radius: 12,
                        //               backgroundColor: Colors.black,
                        //               child: Icon(Icons.close, color: Colors.blue),
                        //             ),
                        //           ),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        StreamBuilder(
                            stream: pickedFiles?.stream,
                            builder: (context, snapshot) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black),
                                ),
                                height: 260,
                                width: double.maxFinite,
                                // child: pickedImage?.path == null && _video?.path == null || pickedImage?.path.isEmpty == true && _video?.path.isEmpty == true
                                child: pickedFiles?.isEmpty == true
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Image.asset(
                                          //   'assets/images/icons/cloud_upload.png',
                                          //   height: 70,
                                          // ),
                                          Icon(
                                            Icons.upload_file_outlined,
                                            size: 70,
                                          ),
                                          Text(
                                            'Upload JPG, PNG, Video',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                        ],
                                      )
                                    : Stack(
                                        // overflow: Overflow.visible,
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: SizedBox(
                                                height: 350,
                                                child: PageView.builder(
                                                  // shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  physics:
                                                      ClampingScrollPhysics(),
                                                  itemCount:
                                                      pickedFiles?.length ?? 0,
                                                  itemBuilder:
                                                      (context, index) {
                                                    print(
                                                        "______ ITM ${pickedFiles?[index].path}");

                                                    return Stack(
                                                      children: [
                                                        Container(
                                                            width:
                                                                Get
                                                                    .mediaQuery.size.width,
                                                            height: 350,
                                                            child: pickedFiles?[index]
                                                                            .path
                                                                            .contains(
                                                                                "jpg") ==
                                                                        true ||
                                                                    pickedFiles?[index]
                                                                            .path
                                                                            .contains(
                                                                                "jpeg") ==
                                                                        true ||
                                                                    pickedFiles?[index]
                                                                            .path
                                                                            .contains(
                                                                                "png") ==
                                                                        true
                                                                ? Image.file(
                                                                    File(pickedFiles?[index]
                                                                            .path ??
                                                                        ""),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : Center(
                                                                    child:
                                                                        CommonVideoPlayer(
                                                                    videoLink:
                                                                        "${pickedFiles?[index].path}",
                                                                    isFile:
                                                                        true,
                                                                  ))),
                                                        Positioned(
                                                          top: 5,
                                                          right: 5,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                _video =
                                                                    File("");
                                                                pickedImage =
                                                                    File('');
                                                                pickedFiles
                                                                    ?.removeAt(
                                                                        index);
                                                                pickedFiles
                                                                    ?.refresh();
                                                              });
                                                            },
                                                            child:
                                                                const CircleAvatar(
                                                              radius: 12,
                                                              backgroundColor:
                                                                  Colors.black,
                                                              child: Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                    return Container();
                                                  },
                                                ),
                                              ),
                                              // child: _video?.path.isNotEmpty == true
                                              //     ? AspectRatio(
                                              //   aspectRatio: _videoPlayerController!.value.aspectRatio,
                                              //   child: VideoPlayer((_videoPlayerController!)),
                                              // )
                                              //     : pickedImage?.path.isNotEmpty == true
                                              //     ? Image.file(
                                              //   File(pickedImage?.path ?? ""),
                                              //   fit: BoxFit.cover,
                                              // )
                                              //     : Icon(Icons.upload_file,size: 70),
                                            ),
                                          ),

                                          //

                                          // Positioned(
                                          //   top: -6,
                                          //   right: -6,
                                          //   child: GestureDetector(
                                          //     onTap: () {
                                          //       setState(() {
                                          //         _video = File("");
                                          //         pickedImage = File('');
                                          //       });
                                          //     },
                                          //     child: const CircleAvatar(
                                          //       radius: 12,
                                          //       backgroundColor: Colors.black,
                                          //       child: Icon(Icons.close, color: Colors.blue),
                                          //     ),
                                          //   ),
                                          // )
                                        ],
                                      ),
                              );
                            }),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            MaterialButton(
                              onPressed: () async {
                                var status = await Permission.storage.request();
                                if (status.isDenied) {
                                  if (status.isPermanentlyDenied) {
                                    openAppSettings();
                                  }
                                }
                                if (status.isGranted) {
                                  getImage();
                                }
                              },
                              elevation: 0,
                              color: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Icon(Icons.perm_media),
                              // child: Text(
                              //   'Upload image or video',
                              //   style: TextStyle(color: Colors.black),
                              // ),
                            ),
                            const SizedBox(width: 10),
                            MaterialButton(
                              onPressed: () async {
                                var status = await Permission.storage.request();
                                if (status.isDenied) {
                                  if (status.isPermanentlyDenied) {
                                    openAppSettings();
                                  }
                                }
                                if (status.isGranted) {
                                  // takeImage();
                                  addPhotoScreen();
                                }
                              },
                              elevation: 0,
                              color: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Icon(Icons.camera_alt),
                              // child: Text(
                              //   'Take Pictures',
                              //   style: TextStyle(color: Colors.black),
                              // ),
                            ),
                            const SizedBox(width: 10),
                            MaterialButton(
                              onPressed: () async {
                                var status = await Permission.storage.request();
                                if (status.isDenied) {
                                  if (status.isPermanentlyDenied) {
                                    openAppSettings();
                                  }
                                }
                                if (status.isGranted) {
                                  // takeVideo();
                                  addVideoScreen();
                                }
                              },
                              elevation: 0,
                              color: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Icon(Icons.videocam),
                              // child: Text(
                              //   'Take Videos',
                              //   style: TextStyle(color: Colors.black),
                              // ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Text(
                        //   'Link (Optional)',
                        //   style: TextStyle(color: Colors.black),
                        // ),
                        // const SizedBox(
                        //   height: 15,
                        // ),
                        // commonTextField(
                        //   hint: 'Enter url here...',
                        //   baseColor: Colors.grey ,
                        //   borderColor: Colors.blue,
                        //   errorColor: Colors.black
                        //   // textStyle: gcolordarkGrey14w400.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
                        //   // hintStyle: gcolordarkGrey14w400.copyWith(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.colorD6D9D8),
                        //   // textEditingController: _link,
                        //   // validationFunction: (String val) {
                        //   //   if (val.isEmpty) {
                        //   //     return "Please enter url";
                        //   //   } else if (!isURL(val)) {
                        //   //     return 'Please check url';
                        //   //   }
                        //   // },
                        // ),
                        Text(
                          'Description ',
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        commonTextField(
                          baseColor: Colors.grey,
                          borderColor: Colors.blue,
                          errorColor: Colors.black,
                          isLastField: true,
                          controller: desImgController,
                          // inputAction: TextInputAction.done,
                          maxLines: 5,
                          // textStyle: gcolordarkGrey14w400.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
                          // hintStyle: gcolordarkGrey14w400.copyWith(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.colorD6D9D8),
                          hint: 'Say something about post...',
                          // textEditingController: _dis,
                        ),
                      ],
                    );
                  }
                }),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15),
            ),
            color: Colors.grey.withOpacity(0.5)),
        padding: EdgeInsets.only(
            bottom: Get.height * 0.02, left: 10.0, right: 10.0, top: 10.0),
        child: StreamBuilder(
          stream: AppMethods.eulaAccepted.stream,
          builder: (context, snapshot) {
            if (AppMethods.eulaAccepted.isTrue) {
              agree.value = true;
            }
            return StreamBuilder(
                stream: agree.stream,
                builder: (context, snapshot) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (AppMethods.eulaAccepted.isFalse)
                        Row(
                          children: [
                            Checkbox(
                              value: agree.value,
                              onChanged: (value) {
                                agree.value = value ?? false;
                              },
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  text: "By posting, I agree to the user",
                                  children: [
                                    TextSpan(
                                        text: " agreement",
                                        style: TextStyle(
                                          color: Colors.blue,
                                        ),
                                        recognizer: new TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrlString(
                                                "https://whatgodhasdoneforme.com/eula");
                                          }),
                                  ]),
                            )
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                              child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text("Cancel"),
                            // borderRadius: 12,
                            // backGroundColor: AppColors.colorE6E6E7,
                            // textStyle: black16w600,
                          )),
                          if (agree.isTrue)
                            const SizedBox(
                              width: 20,
                            ),
                          if (agree.isTrue)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  AppMethods().acceptEULA();
                                  if (selectedTab.value == "Image") {
                                    if (pickedFiles?.isNotEmpty == true) {
                                      snack(
                                          title: "Success",
                                          msg:
                                              "Your post is uploading in background..");
                                      // Get.back();
                                      groupController.uploadImage(
                                          imageFilePaths:
                                              pickedFiles?.value ?? [],
                                          status: desImgController.text,
                                          groupID: "${widget.groupId}",
                                          callBack: () {
                                            // Get.close(1);
                                            groupController.getGrpFeed(
                                              groupId: widget.groupId,
                                              isFirstTimeLoading: true,
                                              page: 0,
                                              showProcess: false,
                                            );

                                            // Get.to(() => GroupScreen());

                                            // Get.off(() => GroupDetailsScreen(
                                            //     group: widget.group));
                                            // groupController.getGrpFeed(
                                            //     groupId: widget.group.groupId,
                                            //     isFirstTimeLoading: true,
                                            //     page: 0);
                                          });
                                      Get.close(1);

                                      // kDashboardController.uploadImage(
                                      //     imageFilePaths: pickedFiles?.value ?? [],
                                      //     description: desImgController.text,
                                      //     showProngress: true,
                                      //     callBack: () {
                                      //       // snack(title: "Success", msg: "Your post is uploading in background..");
                                      //       Get.offAll(
                                      //           () => const DashBoardScreen());
                                      //     });
                                    } else {
                                      snack(
                                          title: "Ohh",
                                          msg: "Please upload photo or video");
                                    }
                                  } else {
                                    if (urlYTController.text.isNotEmpty ||
                                        desStatusController.text.isNotEmpty) {
                                      groupController.uploadText(
                                          groupID: "${widget.groupId}",
                                          url: urlYTController.text,
                                          callBack: () {
                                            // Get.close(2);
                                            // Get.off(() => GroupScreen());

                                            // groupController.getGrpFeed(
                                            //     groupId: widget.groupId,
                                            //     isFirstTimeLoading: true,
                                            //     page: 0);
                                            if (widget.groupId != null) {
                                              // Get.back();
                                              // Get.close(2);
                                              // Get.off(() => GroupDetailsScreen(
                                              //       groupId: widget.groupId,
                                              //     ));
                                              // Get.back();
                                              groupController.getGrpFeed(
                                                groupId: widget.groupId,
                                                isFirstTimeLoading: true,
                                                page: 0,
                                                showProcess: false,
                                              );
                                            }
                                          },
                                          textStatus:
                                              "${desStatusController.text}");
                                      // postStatus(desStatusController.text,
                                      //     urlYTController.text, "", callBack: () {
                                      //   Get.offAll(() => const DashBoardScreen());
                                      // });
                                      Get.close(1);
                                    } else {
                                      snack(
                                          title: "Ohh",
                                          msg:
                                              "Please write description or YT Video Link.",
                                          iconColor: Colors.yellow,
                                          icon: Icons.warning);
                                    }
                                  }
                                },
                                child: Text("Post"),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }
}

class FileVideoPlayer extends StatefulWidget {
  final File videoFile;

  const FileVideoPlayer({Key? key, required this.videoFile}) : super(key: key);

  @override
  State<FileVideoPlayer> createState() => _FileVideoPlayerState();
}

class _FileVideoPlayerState extends State<FileVideoPlayer> {
  // VideoPlayerController videoPlayerController = VideoPlayerController.network(
  //     "https://wghdfm.s3.amazonaws.com/videowires/1659596902_1.mp4");
  // ChewieController chewieController = ChewieController(
  //     videoPlayerController: VideoPlayerController.network(
  //         "https://wghdfm.s3.amazonaws.com/videowires/1659596902_1.mp4"));

  @override
  void initState() {
    // videoPlayerController = VideoPlayerController.file(widget.videoFile);
    // init().whenComplete(() {
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
    // TODO: implement initState
    // _controller = VideoPlayerController.network(widget.videoLink, videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: false, mixWithOthers: false))
    //   ..initialize().then((_) {
    //     // setState(() {});
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //   });

    super.initState();
  }

  Future init() async {
    // await videoPlayerController.initialize();
    // chewieController = ChewieController(
    //   videoPlayerController: videoPlayerController,
    //   autoPlay: false,
    //   autoInitialize: true,
    //   allowPlaybackSpeedChanging: false,
    //   allowedScreenSleep: false,
    //   allowMuting: false,
    //   aspectRatio: videoPlayerController.value.aspectRatio,
    //   fullScreenByDefault: false,
    //   allowFullScreen: false,
    //   showOptions: false,
    //   // placeholder: Image.asset(AppImages.logoImage),
    //   looping: false,
    // );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // _controller.dispose();
    // chewieController.dispose();
    // videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text("=dsdfghjh");
    // return StreamBuilder(
    //   builder: (context, snapshot) {
    //     RxBool loading = true.obs;
    //     return StreamBuilder(
    //       stream: loading.stream,
    //       builder: (context, snapshot) {
    //         Future.delayed(
    //           const Duration(milliseconds: 500),
    //           () => loading.value = false,
    //         );
    //         if (loading.value == true) {
    //           return const Center(child: CupertinoActivityIndicator());
    //         }
    //         return videoPlayerController.value.isInitialized
    //             ? Chewie(
    //                 controller: chewieController,
    //               )
    //             : const Center(child: CupertinoActivityIndicator());
    //       },
    //     );
    //   },
    // );

    // return _videoPlayerController!.value.isInitialized ?  AspectRatio(
    //   aspectRatio: _videoPlayerController!.value.aspectRatio,
    //   child: VideoPlayer((_videoPlayerController!)),
    // ) : SizedBox(height: 35,width: 35,child: CupertinoActivityIndicator(),);
  }
}
