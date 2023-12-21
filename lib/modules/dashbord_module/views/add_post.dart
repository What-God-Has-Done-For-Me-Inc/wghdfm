import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wghdfm_java/common/video_compressor.dart';
import 'package:wghdfm_java/common/video_player.dart';
import 'package:wghdfm_java/modules/dashbord_module/model/friends_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/add_post_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/tag_post_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/take_picture_screen.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/take_video_screen.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/utils/app_binding.dart';

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
          backgroundColor: Colors.black,
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
            InkWell(
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
                    postStatus(
                        desImgController.text, urlYTController.text, taggedUser,
                        callBack: () {
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
              InkWell(
                onTap: () {
                  TextEditingController searchController =
                      TextEditingController();

                  // taggedUsers.forEach((element) {
                  //   if(element['id'])
                  // });

                  // kDashboardController.friendsModel.value.data?.forEach((element) {
                  //   if (taggedUsers.every((elements) => elements['id'] == element?.userId)) {
                  //     element?.isSelected.value = true;
                  //   }
                  // });

                  Get.to(() => const TagUserScreen())?.then((value) {
                    setState(() {});
                  });

                  ///Add Post Dialogue
                  /*Get.dialog(Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 10,
                    child: StatefulBuilder(
                      builder: (context, StateSetter setStateSearch) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 15),
                            Text(
                              "Tag Friends",
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 20),
                            ),
                            SizedBox(height: 15),
                            // Container(
                            //   color: Colors.white,
                            //   child: commonTextField(
                            //       baseColor: Colors.black,
                            //       borderColor: Colors.black,
                            //       controller: searchController,
                            //       errorColor: Colors.white,
                            //       hint: "Search Friends",
                            //       onChanged: (String? value) {
                            //         setStateSearch(() {});
                            //       }),
                            // ),
                            SizedBox(
                              height: Get.height * 0.35,
                              width: Get.width * 0.8,
                              child: Container(
                                height: Get.height * 0.30,
                                child: ListView.builder(
                                  itemCount: kDashboardController.friendsModel.value.data?.length,
                                  itemBuilder: (context, index) {
                                    return StreamBuilder(
                                        stream: kDashboardController.friendsModel.value.data?[index]?.isSelected.stream,
                                        builder: (context, snapshot) {
                                          return CheckboxListTile(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            tileColor: Colors.white,
                                            activeColor: Colors.white,
                                            checkColor: Colors.black,
                                            value: kDashboardController.friendsModel.value.data?[index]?.isSelected.value,
                                            onChanged: (value) {
                                              kDashboardController.friendsModel.value.data?[index]?.isSelected.toggle();
                                              if (value == true) {
                                                taggedUsers.add({
                                                  'id': "${kDashboardController.friendsModel.value.data?[index]?.userId}",
                                                  "name":
                                                      "${kDashboardController.friendsModel.value.data?[index]?.firstname} ${kDashboardController.friendsModel.value.data?[index]?.lastname}"
                                                });
                                              } else {
                                                Map usr = {
                                                  "id": "${kDashboardController.friendsModel.value.data?[index]?.userId}",
                                                  "name":
                                                      "${kDashboardController.friendsModel.value.data?[index]?.firstname} ${kDashboardController.friendsModel.value.data?[index]?.lastname}"
                                                };
                                                taggedUsers.remove(usr);
                                              }
                                              setState(() {});
                                            },
                                            title: Text(
                                                "${kDashboardController.friendsModel.value.data?[index]?.firstname} ${kDashboardController.friendsModel.value.data?[index]?.lastname}",
                                                style: TextStyle(color: Colors.black)),
                                          ).paddingOnly(bottom: 3);
                                        });
                                  },
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // kDashboardController.friendsModel.value.data?.forEach((element) {
                                    //   element?.isSelected.value = false;
                                    // });
                                    setState(() {});
                                    Get.back();
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      Get.back();
                                    });
                                  },
                                  child: Text("Done"),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  ));*/
                },
                child: const Row(
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
                      // children: taggedUsers
                      //     .map((element) => Chip(
                      //           label: Text("${element['name']}"),
                      //           deleteIcon: Icon(Icons.close_sharp, size: 18),
                      //           onDeleted: () {
                      //             taggedUsers.remove(element);
                      //           },
                      //         ))
                      //     .toList(),

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
                      // children: [
                      //   Chip(
                      //     label: Text("Romil Mavani "),
                      //     deleteIcon: Icon(Icons.close_sharp, size: 18),
                      //     onDeleted: () {},
                      //   ),
                      //   Chip(
                      //     label: Text("Romil "),
                      //     deleteIcon: Icon(Icons.close_sharp, size: 18),
                      //     onDeleted: () {},
                      //   ),
                      //   Chip(
                      //     label: Text(" Mavani "),
                      //     deleteIcon: Icon(Icons.close_sharp, size: 18),
                      //     onDeleted: () {},
                      //   ),
                      //   Chip(
                      //     label: Text("Romil"),
                      //     deleteIcon: Icon(Icons.close_sharp, size: 18),
                      //     onDeleted: () {},
                      //   ),
                      //   Chip(
                      //     label: Text("Romil Mavani "),
                      //     deleteIcon: Icon(Icons.close_sharp, size: 18),
                      //     onDeleted: () {},
                      //   ),
                      // ],
                    );
                  }),
              const SizedBox(height: 10),
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
                              return value == null ||
                                      value == "" ||
                                      !value.isURL
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
                      return Container(
                        height: 150,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                            "Please paste youtube video Url to see videos."),
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
                                                                true ||
                                                            pickedFiles?[index]
                                                                    .path
                                                                    .contains(
                                                                        "heif") ==
                                                                true ||
                                                            pickedFiles?[index]
                                                                    .path
                                                                    .contains(
                                                                        "heic") ==
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

  Future<bool> getPermission() async {
    var cameraPermission = await Permission.camera.status;
    var microphonePermission = await Permission.microphone.status;

    if (cameraPermission == PermissionStatus.permanentlyDenied ||
        microphonePermission == PermissionStatus.permanentlyDenied) {
      // Handle permanently denied permissions
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: Text('Permissions Required'),
          content: Text(
              'Camera and microphone access are permanently denied. Please enable them in app settings.'),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
      return false;
    } else if (cameraPermission == PermissionStatus.denied ||
        microphonePermission == PermissionStatus.denied) {
      await Permission.camera.request();
      await Permission.microphone.request();
      return false;
    } else if (cameraPermission == PermissionStatus.granted ||
        microphonePermission == PermissionStatus.granted) {
      return true;
    }
    // Permissions are already granted, proceed with your logic
    print('Both camera and microphone permissions granted!');
    return true;
    // ...
  }

  addPhotoScreen() async {
    bool per = await getPermission();
    print(per);
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
    // Check camera and microphone permissions
    bool per = await getPermission();
    if (per == true) {
      cameras = await availableCameras();

      // Navigate to TakeVideoScreen with first camera
      final firstCamera = cameras.first;
      Get.to(() => TakeVideoScreen(camera: firstCamera))?.then((value) async {
        // Handle captured video file
        // ... (your existing logic for processing captured video)

        // Update picked files (adapt based on your implementation)
        setState(() => pickedFiles?.add(value));
      });
    }
  }

  Future getImage() async {
    // ImagePicker imagePicker = ImagePicker();
    // imagePicker.pickMedia().then((value) => null);
    // final imageFiles = await imagePicker.pickMultipleMedia(
    //   imageQuality: 5,
    //   requestFullMetadata: false,
    // );
    // if (imageFiles == null) return;
    //
    // imageFiles.forEach((element) {
    //   final tempImage = File(element.path ?? "");
    //   setState(() {
    //     // pickedImage = tempImage;
    //     pickedFiles?.add(tempImage);
    //   });
    // });

    final image = await FilePicker.platform.pickFiles(
        allowCompression: false,
        allowMultiple: true,
        withData: false,
        dialogTitle: "Pick Photo or Video",
        type: FileType.media);
    if (image == null) return;
    showProgressDialog();
    image.files.forEach((element) {
      final tempImage = File(element.path ?? "");
      print("========= FILE PATH  ========${tempImage.path}");
      if (isVideo(filePath: tempImage.path)) {
        setState(() {
          // pickedImage = tempImage;
          pickedFiles?.add(tempImage);
          VideoCompressor.percentage.value = 0.0;
          hideProgressDialog();
        });
      } else {
        if (tempImage != null) {
          setState(() {
            // pickedImage = tempImage;
            pickedFiles?.add(tempImage);
            hideProgressDialog();
          });
        }
      }
    });
  }
}
