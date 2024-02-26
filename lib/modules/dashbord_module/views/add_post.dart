import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wghdfm_java/common/video_compressor.dart';
import 'package:wghdfm_java/common/video_player.dart';
import 'package:wghdfm_java/modules/dashbord_module/model/friends_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/tag_post_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/take_picture_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/take_video_screen.dart';
import 'package:wghdfm_java/utils/app_binding.dart';
import 'package:wghdfm_java/utils/app_colors.dart';

import '../../../common/commonYoutubePlayer.dart';
import '../../../common/common_snack.dart';
import '../../../common/commons.dart';
import '../../../screen/dashboard/dashboard_api/post_status_api.dart';
import '../../../utils/app_methods.dart';
import 'dash_board_screen.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  TextEditingController desImgController = TextEditingController();
  TextEditingController urlYTController = TextEditingController();
  VideoCompressor videoCompressor = VideoCompressor();
  RxBool isPost = false.obs;
  RxBool isLoading = false.obs;
  File? pickedImage;
  final formKey = GlobalKey<FormState>();
  RxList<File>? pickedFiles = <File>[].obs;
  File? _video;
  RxBool reLoad = false.obs;
  RxList<Map<String, String>> taggedUsers = <Map<String, String>>[].obs;

  @override
  void initState() {
    // TODO: implement initState.
    kDashboardController.friendsModel.value = FriendsModel();
    kDashboardController.getFriendList();
    VideoCompressor().subscribeVideo();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    VideoCompressor().unSubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // VideoCompressor().subscribe();
    return WillPopScope(
      onWillPop: () {
        videoCompressor.cancelCompressing();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Post'),
          titleSpacing: 0.0,
          elevation: 1,
          //backgroundColor: Colors.black,
          actions: [
            /*  StreamBuilder(
              stream: VideoCompressor.percentage.stream,
              builder: (context, snapshot) {
                if (VideoCompressor.percentage != null &&
                    VideoCompressor.percentage.value > 0 &&
                    VideoCompressor.percentage.value < 99) {
                  // --> use snapshot.data
                  return SizedBox();
                }
                return InkWell(
                  onTap: () async {
                    if (isPost.value) {
                      if (pickedFiles?.isNotEmpty == true) {
                        Get.back();
                        snack(
                            title: "Success",
                            msg: "Your post is uploading in background..");
                        // Get.back();
                        // Get.offAll(() => const DashBoardScreen());

                        ///----START--

                        String taggedUser = "";
                        try {
                          kDashboardController.friendsModel.value.data
                              ?.forEach((element) {
                            if (element?.isSelected.value == true) {
                              taggedUser = "${taggedUser}|${element?.userId}";
                            }
                          });
                        } catch (e) {
                          snack(
                              title:
                                  " Catch Error => kDashboardController.friendsModel.value.data",
                              msg: "Code:- 001",
                              icon: Icons.close,
                              textColor: Colors.red.withOpacity(0.5));
                        }

                        print("------ taggedUser ${taggedUser}");
                        try {
                          // final List<File> compressedFiles = [];
                          //
                          // ///Compressing Files.
                          // pickedFiles?.forEach((element) async {
                          //   ///Checking is Photo or Video.
                          //   if (isVideo(filePath: element.path)) {
                          //     final compressedFile = await videoCompressor.compressVideo(originalFile: element);
                          //     if (compressedFile != null) {
                          //       compressedFiles.add(compressedFile);
                          //     }
                          //   } else {
                          //     compressedFiles.add(element);
                          //   }
                          //
                          //   ///Compressing Videos..
                          // });

                          await kDashboardController.uploadImage(
                              imageFilePaths: pickedFiles?.value ?? [],
                              description: desImgController.text,
                              showProngress: false,
                              taggedUsers: taggedUser,
                              callBack: () {
                                kDashboardController.currentPage = 0;
                                // Get.offAll(
                                //     () => const DashBoardScreen());
                              });
                        } catch (e) {
                          snack(
                              title: "Catch Error => Upload Image",
                              msg: "Code:- 001",
                              icon: Icons.close,
                              textColor: Colors.red.withOpacity(0.5));
                        }
                        // await kDashboardController.uploadImage(
                        //     imageFilePaths: pickedFiles?.value ?? [],
                        //     description: desImgController.text,
                        //     showProngress: false,
                        //     taggedUsers: taggedUser,
                        //     callBack: () {
                        //       kDashboardController.currentPage = 0;
                        //       // Get.offAll(
                        //       //     () => const DashBoardScreen());
                        //     });

                        ///----END
                      } else {
                        snack(
                            title: "Ohh No.",
                            msg: "Please upload photo or video",
                            icon: Icons.close,
                            textColor: Colors.red.withOpacity(0.5));
                      }
                    } else {
                      String taggedUser = "";
                      kDashboardController.friendsModel.value.data
                          ?.forEach((element) {
                        if (element?.isSelected.value == true) {
                          taggedUser = "${taggedUser}|${element?.userId}";
                        }
                      });
                      print("------ taggedUser ${taggedUser}");
                      if (urlYTController.text.isNotEmpty ||
                          desImgController.text.isNotEmpty) {
                        postStatus(desImgController.text, urlYTController.text,
                            taggedUser, callBack: () {
                          Get.offAll(() => const DashBoardScreen());
                        });
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
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    // width: MediaQuery.of(context).size.width,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30)),
                    child: const Center(
                        child: Text(
                      "Post",
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                );
              },
            ),*/
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: InkWell(
                onTap: () async {
                  if (isPost.value) {
                    if (pickedFiles?.isNotEmpty == true) {
                      Get.back();
                      snack(
                          title: "Success",
                          msg: "Your post is uploading in background..");

                      ///----START--

                      String taggedUser = "";
                      try {
                        kDashboardController.friendsModel.value.data
                            ?.forEach((element) {
                          if (element?.isSelected.value == true) {
                            taggedUser = "${taggedUser}|${element?.userId}";
                          }
                        });
                      } catch (e) {
                        snack(
                            title:
                                " Catch Error => kDashboardController.friendsModel.value.data",
                            msg: "Code:- 001",
                            icon: Icons.close,
                            textColor: Colors.red.withOpacity(0.5));
                      }

                      print("------ taggedUser ${taggedUser}");
                      try {
                        // final List<File> compressedFiles = [];
                        //
                        // ///Compressing Files.
                        // pickedFiles?.forEach((element) async {
                        //   ///Checking is Photo or Video.
                        //   if (isVideo(filePath: element.path)) {
                        //     final compressedFile = await videoCompressor.compressVideo(originalFile: element);
                        //     if (compressedFile != null) {
                        //       compressedFiles.add(compressedFile);
                        //     }
                        //   } else {
                        //     compressedFiles.add(element);
                        //   }
                        //
                        //   ///Compressing Videos..
                        // });

                        await kDashboardController.uploadImage(
                            imageFilePaths: pickedFiles?.value ?? [],
                            description: desImgController.text,
                            showProngress: false,
                            taggedUsers: taggedUser,
                            callBack: () {
                              kDashboardController.currentPage = 0;
                              // Get.offAll(
                              //     () => const DashBoardScreen());
                            });
                      } catch (e) {
                        snack(
                            title: "Catch Error => Upload Image",
                            msg: "Code:- 001",
                            icon: Icons.close,
                            textColor: Colors.red.withOpacity(0.5));
                      }
                      // await kDashboardController.uploadImage(
                      //     imageFilePaths: pickedFiles?.value ?? [],
                      //     description: desImgController.text,
                      //     showProngress: false,
                      //     taggedUsers: taggedUser,
                      //     callBack: () {
                      //       kDashboardController.currentPage = 0;
                      //       // Get.offAll(
                      //       //     () => const DashBoardScreen());
                      //     });

                      ///----END
                    } else {
                      snack(
                          title: "Ohh No.",
                          msg: "Please upload photo or video",
                          icon: Icons.close,
                          textColor: Colors.red.withOpacity(0.5));
                    }
                  } else {
                    String taggedUser = "";
                    kDashboardController.friendsModel.value.data
                        ?.forEach((element) {
                      if (element?.isSelected.value == true) {
                        taggedUser = "${taggedUser}|${element?.userId}";
                      }
                    });
                    print("------ taggedUser ${taggedUser}");
                    if (urlYTController.text.isNotEmpty ||
                        desImgController.text.isNotEmpty) {
                      postStatus(desImgController.text, urlYTController.text,
                          taggedUser, callBack: () {
                        Get.offAll(() => const DashBoardScreen());
                      });
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
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)),
                  child: const Center(
                      child: Text(
                    "Post",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  )),
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: Obx(() {
          return ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: [
              SizedBox(
                height: Get.mediaQuery.size.height * 0.02,
              ),
              InkWell(
                onTap: () {
                  TextEditingController searchController =
                      TextEditingController();

                  Get.to(() => const TagUserScreen())?.then((value) {
                    setState(() {});
                  });
                },
                child: Row(
                  children: const [
                    Text(
                      'Tag Friends',
                      style: TextStyle(color: Colors.black),
                    ),
                    Icon(Icons.sell),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder(
                  stream: kDashboardController.friendsModel.stream ??
                      taggedUsers.stream,
                  builder: (context, snapshot) {
                    return Wrap(
                      spacing: 5,
                      children: kDashboardController.friendsModel.value.data
                              ?.map(
                                  (element) => element?.isSelected.value == true
                                      ? Chip(
                                          label: Text(
                                              "${element?.firstname} ${element?.lastname}"),
                                          deleteIcon:
                                              Icon(Icons.close_sharp, size: 18),
                                          onDeleted: () {
                                            element?.isSelected.value = false;
                                            setState(() {});
                                            // taggedUsers.remove(element);
                                          },
                                        )
                                      : SizedBox())
                              .toList() ??
                          [],
                    );
                  }),
              // const SizedBox(height: 10),
              // const Text(
              //   'Description',
              //   style: TextStyle(color: Colors.black),
              // ),
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
                      hint: "What's on your mind.",
                      // textEditingController: _dis,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    children: [],
                  )
                ],
              ),
              const SizedBox(height: 20),
              if (!isPost.value) ...[
                // const Text(
                //   'Youtube Video Link.',
                //   style: TextStyle(color: Colors.black),
                // ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Form(
                        key: formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors.blackColor)),
                          child: TextFormField(
                            controller: urlYTController,
                            textInputAction: TextInputAction.done,
                            maxLines: 2,
                            validator: (String? value) {
                              return value == null ||
                                      value == "" ||
                                      !value.isURL
                                  ? " Please enter valid link"
                                  : null;
                            },
                            onChanged: (text) {},
                            enabled: true,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1),
                              ),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: "OpenSans",
                                fontWeight: FontWeight.w300,
                              ),
                              border: InputBorder.none,
                              hintText: "Enter youtube video url here...",
                            ),
                          ),
                        ),
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
                        urlYTController.text
                                .contains("www.youtube.com/live/") ==
                            true) {
                      final String videoId = urlYTController.text
                                  .contains("youtube.com/watch?v") ==
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
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const CupertinoActivityIndicator(
                                    radius: 10),
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
                      // return Container(
                      //   height: 150,
                      //   alignment: Alignment.center,
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.grey, width: 0.5),
                      //     borderRadius: BorderRadius.circular(6),
                      //   ),
                      //   child: Text(
                      //       "Please paste youtube video Url to see videos."),
                      // );
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
              StreamBuilder(
                  stream: isLoading.stream,
                  builder: (context, snapshot) {
                    if (isLoading.value == false) {
                      return const SizedBox();
                    }
                    return Center(
                      child: const Text(
                        'Please wait file is loading..',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }),
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
                                          physics:
                                              const ClampingScrollPhysics(),
                                          itemCount: pickedFiles?.length ?? 0,
                                          itemBuilder: (context, index) {
                                            print(
                                                "______ ITM ${pickedFiles?[index].path}");

                                            return Stack(
                                              children: [
                                                SizedBox(
                                                    width: Get
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
            ],
          ).paddingSymmetric(horizontal: 10);
        }),
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: StreamBuilder<double>(
          stream: VideoCompressor.percentage.stream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            // print("===== VideoCompressor.lightCompressor.onProgressUpdated ${VideoCompressor.percentage.value}");
            // if (VideoCompressor.percentage != null && VideoCompressor.percentage.value > 0 && VideoCompressor.percentage.value < 99) {
            //   //   // --> use snapshot.data
            //   return Text("Compressing:-  ${VideoCompressor.percentage.toStringAsFixed(2)}");
            // }
            // else {
            //   // if (Get.isDialogOpen ?? false) {
            //   //   Get.back(result: true);
            //   // }
            // }

            return Row(
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
                                if (await AppMethods()
                                    .checkStoragePermission()) {
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
                            const SizedBox(height: 40),
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
            );
          },
        ),
      ),
    );
  }

  List<CameraDescription> cameras = [];

  addPhotoScreen() async {
    bool per = await AppMethods().getPermission();

    if (per == true) {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      Get.to(() => TakePictureScreen(
            camera: firstCamera,
          ))?.then((value) {
        pickedFiles?.add(value);
      });
    }
  }

  Future<void> addVideoScreen() async {
    bool per = await AppMethods().getPermission();
    if (per == true) {
      isLoading.value = true;
      cameras = await availableCameras();

      // Navigate to TakeVideoScreen with first camera
      final firstCamera = cameras.first;
      Get.to(() => TakeVideoScreen(camera: firstCamera))?.then((value) async {
        setState(() {
          pickedFiles?.add(value);
          isLoading.value = false;
        });
      });
    }
  }

  Future getImage() async {
    isLoading.value = true;
    Future<void> convartIosImage({required String filePath}) async {
      if (filePath.contains('.pvt')) {
        snack(
            title: "Failed",
            msg: "Some file format not supported",
            iconColor: Colors.red,
            icon: Icons.close);
      }
      if (!filePath.contains('.pvt')) {
        final tmpDir = (await getTemporaryDirectory()).path;
        final target = '$tmpDir/${DateTime.now().microsecondsSinceEpoch}.jpg';
        final result = await FlutterImageCompress.compressAndGetFile(
          filePath,
          target,
          format: CompressFormat.jpeg,
          quality: 90,
        );

        print(result!.path);
        //isLoading.value = false;
        setState(() {
          print('Loaded');
          pickedFiles?.add(File(result.path));
          isLoading.value = false;
        });
      }
      // error handling here
    }

    final image = await FilePicker.platform.pickFiles(
        allowCompression: false,
        withReadStream: false,
        allowMultiple: true,
        withData: false,
        dialogTitle: "Pick Photo or Video",
        type: FileType.media);
    if (image == null) {
      isLoading.value = false;
      return;
    }

    for (var element in image.files) {
      final tempImage = File(element.path ?? "");
      print("========= FILE PATH  ========${tempImage.path}");
      if (isVideo(filePath: tempImage.path)) {
        setState(() {
          // pickedImage = tempImage;
          pickedFiles?.add(tempImage);
          isLoading.value = false;
          // VideoCompressor.percentage.value = 0.0;
        });
      } else {
        if (isIosPhoto(filePath: tempImage.path)) {
          convartIosImage(filePath: tempImage.path);
        } else {
          setState(() {
            pickedFiles?.add(tempImage);
            isLoading.value = false;
          });
        }
      }
    }
  }
}
