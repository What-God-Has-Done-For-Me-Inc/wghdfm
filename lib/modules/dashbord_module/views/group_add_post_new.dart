import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/video_player.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/take_picture_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/take_video_screen.dart';

import '../../../common/commonYoutubePlayer.dart';
import '../../../common/common_snack.dart';
import '../../../common/commons.dart';
import '../../../screen/groups/group_controller.dart';
import '../../../utils/app_methods.dart';

class GroupAddPost extends StatefulWidget {
  final String groupId;

  const GroupAddPost({Key? key, required this.groupId}) : super(key: key);

  @override
  State<GroupAddPost> createState() => _GroupAddPostState();
}

class _GroupAddPostState extends State<GroupAddPost> {
  TextEditingController desImgController = TextEditingController();
  TextEditingController urlYTController = TextEditingController();
  RxBool isPost = false.obs;
  File? pickedImage;
  final formKey = GlobalKey<FormState>();
  RxList<File>? pickedFiles = <File>[].obs;
  File? _video;
  RxBool reLoad = false.obs;
  GroupController groupController = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Group Post'),
        backgroundColor: Colors.black,
        actions: [
          InkWell(
            onTap: () async {
              if (isPost.value) {
                if (pickedFiles?.isNotEmpty == true) {
                  snack(
                      title: "Success",
                      msg: "Your post is uploading in background..");
                  // Get.back();
                  groupController.uploadImage(
                      imageFilePaths: pickedFiles?.value ?? [],
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
                      title: "Ohh No.",
                      msg: "Please upload photo or video",
                      icon: Icons.close,
                      textColor: Colors.red.withOpacity(0.5));
                }
              } else {
                if (urlYTController.text.isNotEmpty ||
                    desImgController.text.isNotEmpty) {
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
                      textStatus: "${desImgController.text}");
                  // postStatus(desStatusController.text,
                  //     urlYTController.text, "", callBack: () {
                  //   Get.offAll(() => const DashBoardScreen());
                  // });
                  Get.close(1);
                } else {
                  snack(
                      title: "Ohh",
                      msg: "Please write description or YT Video Link.",
                      iconColor: Colors.yellow,
                      icon: Icons.warning);
                }
              }
            },
            child: Container(
              height: 25,
              margin: EdgeInsets.symmetric(vertical: 10),
              // width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(30)),
              child: const Center(
                  child: Text(
                "Post",
                style: TextStyle(color: Colors.white),
              )),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: Get.mediaQuery.size.height * 0.02,
            ),
            const Text(
              'Description',
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: commonTextField(
                    baseColor: Colors.grey,
                    borderColor: Colors.blue,
                    errorColor: Colors.black,
                    isLastField: true,
                    maxLines: 5,
                    controller: desImgController,

                    // inputAction: TextInputAction.done,
                    // maxLine: 6,
                    // textStyle: gcolordarkGrey14w400.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
                    // hintStyle: gcolordarkGrey14w400.copyWith(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.colorD6D9D8),
                    hint: 'Say something about post...',
                    // textEditingController: _dis,
                  ),
                ),
                const SizedBox(width: 15),
                // Column(
                //   children: [
                //     InkWell(
                //       onTap: () {
                //         isPost.value = true;
                //
                //         showModalBottomSheet(
                //           context: context,
                //           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                //           builder: (context) {
                //             return Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 MaterialButton(
                //                   onPressed: () async {
                //                     if (await AppMethods().checkStoragePermission()) {
                //                       getImage();
                //                       Get.back();
                //                     }
                //                   },
                //                   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                //                   child: Row(
                //                     mainAxisAlignment: MainAxisAlignment.start,
                //                     children: const [
                //                       Icon(Icons.perm_media),
                //                       SizedBox(width: 10),
                //                       Text(
                //                         'Pick from files or gallery',
                //                         style: TextStyle(color: Colors.black),
                //                       )
                //                     ],
                //                   ),
                //                 ),
                //                 const SizedBox(height: 5),
                //                 const Divider(color: Colors.grey, height: 2),
                //                 const SizedBox(height: 5),
                //                 MaterialButton(
                //                   onPressed: () async {
                //                     if (await AppMethods().checkPermission()) {
                //                       addPhotoScreen();
                //                       Get.back();
                //                     }
                //                   },
                //                   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                //                   child: Row(
                //                     mainAxisAlignment: MainAxisAlignment.start,
                //                     children: const [
                //                       Icon(Icons.camera_alt),
                //                       SizedBox(width: 10),
                //                       Text(
                //                         'Take Pictures',
                //                         style: TextStyle(color: Colors.black),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //                 const SizedBox(height: 5),
                //                 const Divider(color: Colors.grey, height: 2),
                //                 const SizedBox(height: 5),
                //                 MaterialButton(
                //                   onPressed: () async {
                //                     if (await AppMethods().checkPermission()) {
                //                       // takeVideo();
                //                       addVideoScreen();
                //                       Get.back();
                //                     }
                //                   },
                //                   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                //                   child: Row(
                //                     mainAxisAlignment: MainAxisAlignment.start,
                //                     children: const [
                //                       Icon(Icons.videocam),
                //                       SizedBox(width: 10),
                //                       Text(
                //                         'Take Videos',
                //                         style: TextStyle(color: Colors.black),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ],
                //             );
                //           },
                //         );
                //       },
                //       child: Image.asset(
                //         'assets/icon/image_upload_logo.png',
                //         height: 45,
                //         width: 45,
                //       ),
                //     ),
                //     const SizedBox(height: 15),
                //     InkWell(
                //       onTap: () {
                //         isPost.value = false;
                //       },
                //       child: Image.asset(
                //         'assets/icon/youtube_logo.png',
                //         height: 50,
                //         width: 50,
                //       ),
                //     ),
                //   ],
                // )
              ],
            ),
            const SizedBox(height: 20),
            if (!isPost.value) ...[
              const Text(
                'Youtube Video Link.',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: commonTextField(
                          hint: 'Enter youtube video url here...',
                          baseColor: Colors.grey,
                          borderColor: Colors.blue,
                          errorColor: Colors.black,
                          maxLines: 1,
                          isLastField: true,
                          controller: urlYTController,
                          onChanged: () {
                            formKey.currentState!.validate();
                            reLoad.toggle();
                          },
                          validator: (String? value) {
                            return value == null || value == "" || !value.isURL
                                ? " Please enter valid link"
                                : null;
                            // value.isEmail
                          }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // InkWell(
                  //   onTap: () async {
                  //     if (urlYTController.text.isEmail == true) {}
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.all(15),
                  //     // height: 50
                  //     // width: MediaQuery.of(context).size.width,
                  //     decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                  //     child: const Center(
                  //         child: Text(
                  //       "OK",
                  //       style: TextStyle(color: Colors.white),
                  //     )),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 30),
              StreamBuilder(
                stream: reLoad.stream,
                builder: (context, snapshot) {
                  if (urlYTController.text.contains("youtube.com/watch?v") ||
                      urlYTController.text.contains("youtu.be") ||
                      urlYTController.text.contains("www.youtube.com/live/") ==
                          true) {
                    final String videoId =
                        urlYTController.text.contains("youtube.com/watch?v") ==
                                true
                            ? urlYTController.text.split("=").last ?? ""
                            : urlYTController.text
                                        .contains("www.youtube.com/live/") ==
                                    true
                                ? urlYTController.text
                                    .split("/")
                                    .last
                                    .split('?')
                                    .first
                                : urlYTController.text.split("/").last ?? "";
                    RxBool reload = false.obs;
                    return StreamBuilder(
                        stream: reload.stream,
                        builder: (context, snapshot) {
                          if (reload.value == true) {
                            return Container(
                              height: 150,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child:
                                  const CupertinoActivityIndicator(radius: 10),
                            );
                          }
                          return Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              // child: YoutubeVideoScereen(
                              //   videoId: feed.url!.split("/").last,
                              // ),
                              child: CommonYTPlayer(videoId: videoId),
                            ),
                          );
                        });
                  } else {
                    return SizedBox();
                    return SizedBox();
                    return Container(
                      height: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child:
                          Text("Please paste youtube video Url to see videos."),
                    );
                  }
                },
              ),
            ],
            if (isPost.value && pickedFiles?.isNotEmpty == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Image/Video',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  StreamBuilder(
                      stream: pickedFiles?.stream,
                      builder: (context, snapshot) {
                        if (pickedFiles?.isEmpty == true) {
                          return const SizedBox();
                        }
                        return const Text(
                          'Swipe to see images..',
                          style: TextStyle(color: Colors.grey),
                        );
                      }),
                ],
              ),
            if (isPost.value) const SizedBox(height: 8),
            if (isPost.value)
              StreamBuilder(
                  stream: pickedFiles?.stream,
                  builder: (context, snapshot) {
                    if (pickedFiles?.isEmpty == true) {
                      return SizedBox();
                    }
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                // Image.asset(
                                //   'assets/images/icons/cloud_upload.png',
                                //   height: 70,
                                // ),
                                Icon(
                                  Icons.upload_file_outlined,
                                  size: 70,
                                ),
                                Text(
                                  'Preview of Media (Images and Videos)',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(
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
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      height: 350,
                                      child: PageView.builder(
                                        // shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        physics: const ClampingScrollPhysics(),
                                        itemCount: pickedFiles?.length ?? 0,
                                        itemBuilder: (context, index) {
                                          print(
                                              "______ ITM ${pickedFiles?[index].path}");

                                          return Stack(
                                            children: [
                                              SizedBox(
                                                  width:
                                                      Get.mediaQuery.size.width,
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
                                                          File(pickedFiles?[
                                                                      index]
                                                                  .path ??
                                                              ""),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Center(
                                                          child:
                                                              CommonVideoPlayer(
                                                          videoLink:
                                                              "${pickedFiles?[index].path}",
                                                          isFile: true,
                                                        ))),
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _video = File("");
                                                      pickedImage = File('');
                                                      pickedFiles
                                                          ?.removeAt(index);
                                                      pickedFiles?.refresh();
                                                    });
                                                  },
                                                  child: const CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor:
                                                        Colors.black,
                                                    child: Icon(Icons.close,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                          return Container();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    );
                  }),
            const SizedBox(height: 30),

            // const SizedBox(height: 30),
          ],
        ).paddingSymmetric(horizontal: 10);
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              isPost.value = true;

              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15))),
                builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MaterialButton(
                        onPressed: () async {
                          if (await AppMethods().checkStoragePermission()) {
                            getImage();
                            Get.back();
                          }
                        },
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.perm_media),
                            SizedBox(width: 10),
                            Text(
                              'Pick from files or gallery',
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Divider(color: Colors.grey, height: 2),
                      const SizedBox(height: 5),
                      MaterialButton(
                        onPressed: () async {
                          if (await AppMethods().checkPermission()) {
                            addPhotoScreen();
                            Get.back();
                          }
                        },
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.camera_alt),
                            SizedBox(width: 10),
                            Text(
                              'Take Pictures',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Divider(color: Colors.grey, height: 2),
                      const SizedBox(height: 5),
                      MaterialButton(
                        onPressed: () async {
                          if (await AppMethods().checkPermission()) {
                            // takeVideo();
                            addVideoScreen();
                            Get.back();
                          }
                        },
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.videocam),
                            SizedBox(width: 10),
                            Text(
                              'Take Videos',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      spreadRadius: 1,
                      blurRadius: 20)
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icon/image_upload_logo.png',
                    height: 40,
                    width: 40,
                  ),
                  Text("Photos and Videos"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: () {
              isPost.value = false;
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        spreadRadius: 1,
                        blurRadius: 20)
                  ],
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icon/youtube_logo.png',
                    height: 40,
                    width: 40,
                  ),
                  Text("Youtube Video"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Future getImage() async {
    final image = await FilePicker.platform.pickFiles(
        allowCompression: true,
        allowMultiple: true,
        withData: false,
        dialogTitle: "Pick Photo or Video",
        type: FileType.media);
    if (image == null) return;
    image.files.forEach((element) {
      final tempImage = File(element.path ?? "");
      setState(() {
        // pickedImage = tempImage;
        pickedFiles?.add(tempImage);
      });
    });
  }
}
