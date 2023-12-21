import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/group_add_post_new.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/screen/comment/comment_screen.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/add_fav_post_api.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/report_post_api.dart';
import 'package:wghdfm_java/screen/dashboard/widgets/feed_with_load_more.dart';
import 'package:wghdfm_java/screen/groups/group_controller.dart';
import 'package:wghdfm_java/screen/groups/methods.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/app_texts.dart';
import 'package:wghdfm_java/utils/emoji_keybord_custom.dart';
import 'package:wghdfm_java/utils/get_links_text.dart';
import 'package:wghdfm_java/utils/shimmer_utils.dart';

import '../../utils/endpoints.dart';
import 'group_members_ui.dart';

// ignore: must_be_immutable
class GroupDetailsScreen extends StatefulWidget {
  // final Group group;
  final String? groupId;

  const GroupDetailsScreen({super.key, /*required this.group,*/ this.groupId});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  bool isFirstTime = true;

  int currentPage = 0;

  int itemCount = 0;
  ScrollController grpScrollController = ScrollController();
  GroupController groupController = Get.put(GroupController());

  @override
  void initState() {
    // TODO: implement initState
    groupController.isPostUploading.value = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      groupFeeds?.clear();
      fetchGroupDetails(groupId: widget.groupId);
      groupController.getGrpFeed(groupId: widget.groupId, isFirstTimeLoading: true, page: currentPage);
      pagination();
    });
    super.initState();
  }

  pagination() {
    grpScrollController.addListener(() async {
      if (grpScrollController.position.pixels >= grpScrollController.position.maxScrollExtent * 0.70 && groupController.isLoading.value == false) {
        groupController.isLoading.value = true;
        isFirstTime = false;
        currentPage = currentPage + 1;
        groupController.getGrpFeed(groupId: widget.groupId, isFirstTimeLoading: false, page: currentPage, showProcess: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: groupDetailsModel.stream,
      builder: (context, snapshot) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey,
          // extendBody: true,
          // extendBodyBehindAppBar: false,
          appBar: AppBar(
            title: Text(
              groupDetailsModel.value.data?.name ?? "",
              style: GoogleFonts.montserrat(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            actions: [
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                onSelected: (value) {
                  if (value == 0) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text('Are you sure you want to delete this group?'),
                            content: const Text('This will delete the Group permanently'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); //close Dialog
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    groupController.removeGroup(grpID: '${widget.groupId}');
                                    Get.back();
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  )),
                            ],
                          );
                        });
                  }
                  if (value == 1) {
                    if (groupDetailsModel.value.data?.name != null && widget.groupId != null) {
                      groupController.promoteGroups(groupName: groupDetailsModel.value.data?.name ?? "", groupId: groupDetailsModel.value.data?.groupId ?? "");
                    }
                  }
                  if (value == 2) {
                    if (widget.groupId != null) {
                      Get.to(() => GroupMembersUI(groupId: widget.groupId ?? ""));
                    }
                  }
                },
                itemBuilder: (context) {
                  return [
                    if (groupDetailsModel.value.data?.ownerId ==
                        userId /*&&
                                                  groupDetail!.sendReqButton !=
                                              "N"*/
                    )
                      PopupMenuItem(value: 0, child: Text("Delete Group")),
                    PopupMenuItem(value: 1, child: Text("Promote Group")),
                    PopupMenuItem(value: 2, child: Text("Group Members")),
                  ];
                },
              ),
              // IconButton(onPressed: (){}, icon: I)
            ],
            elevation: 0,
            centerTitle: true,
            iconTheme: Theme.of(context).iconTheme,
            backgroundColor: Theme.of(context).backgroundColor,
          ),
          body: Column(
            children: [
              StreamBuilder(
                stream: groupController.isPostUploading.stream,
                builder: (context, snapshot) {
                  if (groupController.isPostUploading.isTrue) {
                    return Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text("Your Post is Uploading.. \nPlease don't close app."),
                          Container(
                            // width: Get.width,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const CupertinoActivityIndicator(radius: 10),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (groupController.isPostUploading.isFalse) {
                      groupFeeds?.clear();
                      fetchGroupDetails(groupId: widget.groupId);
                      currentPage = 0;
                      groupController.getGrpFeed(groupId: widget.groupId, isFirstTimeLoading: true, page: currentPage);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    controller: grpScrollController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: Get.width,
                          height: 200,
                          child: StreamBuilder(
                            stream: groupDetailsModel.stream,
                            builder: (context, snapshot) {
                              // if (snapshot.connectionState == ConnectionState.waiting) {
                              //   return shimmerProfileLoading();
                              // }

                              if (snapshot.hasError) {
                                return Container(
                                  color: Colors.white,
                                  child: customText(title: "${snapshot.error}"),
                                );
                              }

                              return Stack(
                                // fit: StackFit.loose,
                                children: [
                                  ///Cover Photo
                                  Positioned(
                                    top: 0,
                                    child: Container(
                                      width: Get.width,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        // RoundedRectangleBorder(
                                        //     side: const BorderSide(color: Colors.grey, width: 0.5),
                                        //     borderRadius: BorderRadius.circular(5))
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.grey, width: 0.5),
                                      ),
                                      child: CachedNetworkImage(
                                        alignment: Alignment.center,
                                        fit: BoxFit.cover,
                                        imageUrl: "${groupDetailsModel.value.data?.coverPic}",
                                        placeholder: (context, url) => Container(
                                          width: 20,
                                          height: 20,
                                          padding: const EdgeInsets.all(3),
                                          child: shimmerMeUp(CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                                          )),
                                        ),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    ),
                                  ),

                                  ///Edit button
                                  if (groupDetailsModel.value.data?.ownerId == userId)
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        // padding: const EdgeInsets.all(5),
                                        decoration:
                                            BoxDecoration(color: Colors.white.withOpacity(0.7), border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(5)),
                                        child: IconButton(
                                            onPressed: () async {
                                              final image = await AppMethods().pickImage();
                                              if (image != null && groupDetailsModel.value.data?.groupId != null) {
                                                groupController.editGroupCover(
                                                    imagePath: image,
                                                    groupID: groupDetailsModel.value.data?.groupId ?? "",
                                                    callBack: () {
                                                      fetchGroupDetails(groupId: groupDetailsModel.value.data?.groupId);
                                                    });
                                              }
                                            },
                                            icon: const Icon(Icons.edit)),
                                      ),
                                    ),

                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      // width: Get.width,
                                      // height: 150,
                                      // color: Colors.black.withOpacity(0.5),
                                      padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                                      // padding: const EdgeInsets.all(10),
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Row(
                                          //   mainAxisSize: MainAxisSize.min,
                                          //   mainAxisAlignment: MainAxisAlignment.center,
                                          //   children: [
                                          //     Container(
                                          //         height: 70,
                                          //         width: 70,
                                          //         decoration: BoxDecoration(
                                          //           color: Theme.of(Get.context!)
                                          //               .iconTheme
                                          //               .color,
                                          //           borderRadius:
                                          //               BorderRadius.circular(100),
                                          //           border: Border.all(
                                          //             color: Theme.of(Get.context!)
                                          //                 .iconTheme
                                          //                 .color!,
                                          //             width: 1,
                                          //           ),
                                          //         ),
                                          //         margin: const EdgeInsets.all(5),
                                          //         padding: EdgeInsets.zero,
                                          //         child: ClipOval(
                                          //           child: CachedNetworkImage(
                                          //             alignment: Alignment.center,
                                          //             fit: BoxFit.fill,
                                          //             imageUrl: groupDetailsModel
                                          //                     .value.data?.profilePic ??
                                          //                 "",
                                          //             placeholder: (context, url) =>
                                          //                 Container(
                                          //               padding:
                                          //                   const EdgeInsets.all(3),
                                          //               child: shimmerMeUp(
                                          //                   CircularProgressIndicator(
                                          //                 valueColor:
                                          //                     AlwaysStoppedAnimation<
                                          //                             Color>(
                                          //                         Theme.of(context)
                                          //                             .accentColor),
                                          //               )),
                                          //             ),
                                          //             errorWidget:
                                          //                 (context, url, error) =>
                                          //                     const Icon(Icons.error),
                                          //           ),
                                          //         )),
                                          //     const SizedBox(
                                          //       width: 5,
                                          //     ),
                                          //     Container(
                                          //       padding: EdgeInsets.all(5),
                                          //       decoration: BoxDecoration(
                                          //         borderRadius:
                                          //             BorderRadius.circular(12),
                                          //         color: Colors.white.withOpacity(0.5),
                                          //       ),
                                          //       child: Column(
                                          //           mainAxisSize: MainAxisSize.min,
                                          //           mainAxisAlignment:
                                          //               MainAxisAlignment.center,
                                          //           children: [
                                          //             RichText(
                                          //               text: TextSpan(
                                          //                   text:
                                          //                       "${groupDetailsModel.value.data?.name.toString().capitalize}" ??
                                          //                           "",
                                          //                   style: const TextStyle(
                                          //                     color: Colors.black,
                                          //                     fontSize: 15.0,
                                          //                     height: 1.8,
                                          //                     fontWeight:
                                          //                         FontWeight.bold,
                                          //                     decoration:
                                          //                         TextDecoration.none,
                                          //                   ),
                                          //                   children: [
                                          //                     TextSpan(
                                          //                       text: "\n" +
                                          //                           "${groupDetailsModel.value.data?.ownerName.toString().capitalize}",
                                          //                       style: const TextStyle(
                                          //                         color: Colors.black,
                                          //                         fontSize: 15.0,
                                          //                         height: 1.8,
                                          //                         fontWeight:
                                          //                             FontWeight.w300,
                                          //                         decoration:
                                          //                             TextDecoration
                                          //                                 .none,
                                          //                       ),
                                          //                     ),
                                          //                     if (groupDetailsModel
                                          //                             .value
                                          //                             .data
                                          //                             ?.groupDescription !=
                                          //                         null)
                                          //                       TextSpan(
                                          //                         text: "\n" +
                                          //                             "${groupDetailsModel.value.data?.groupDescription.toString().capitalize}",
                                          //                         style:
                                          //                             const TextStyle(
                                          //                           color: Colors.black,
                                          //                           fontSize: 15.0,
                                          //                           height: 1.8,
                                          //                           fontWeight:
                                          //                               FontWeight.w300,
                                          //                           decoration:
                                          //                               TextDecoration
                                          //                                   .none,
                                          //                         ),
                                          //                       )
                                          //                   ]),
                                          //             ),
                                          //             // if (groupDetailsModel.value.data
                                          //             //         ?.groupDescription !=
                                          //             //     null)
                                          //             //   Text(
                                          //             //       "${groupDetailsModel.value.data?.groupDescription.toString().capitalize}"),
                                          //             Row(
                                          //               mainAxisAlignment:
                                          //                   MainAxisAlignment
                                          //                       .spaceEvenly,
                                          //               children: [
                                          //                 if (groupDetailsModel.value
                                          //                             .data?.ownerId !=
                                          //                         userId &&
                                          //                     groupDetailsModel
                                          //                             .value
                                          //                             .data
                                          //                             ?.sendReqButton !=
                                          //                         "N")
                                          //                   ElevatedButton(
                                          //                     onPressed: () {
                                          //                       sendJoinRequest();
                                          //                     },
                                          //                     child: groupDetailsModel
                                          //                                 .value
                                          //                                 .data
                                          //                                 ?.sendReqButton ==
                                          //                             "N"
                                          //                         ? const Text(
                                          //                             "Requested")
                                          //                         : const Text("Join"),
                                          //                   ),
                                          //                 // const SizedBox(width: 2),
                                          //                 // Expanded(
                                          //                 //   child: ElevatedButton(
                                          //                 //     onPressed: () {
                                          //                 //       if (widget.groupId !=
                                          //                 //           null) {
                                          //                 //         Get.to(() =>
                                          //                 //             GroupMembersUI(
                                          //                 //                 groupId: widget
                                          //                 //                         .groupId ??
                                          //                 //                     ""));
                                          //                 //       }
                                          //                 //     },
                                          //                 //     child:
                                          //                 //         const Text("Member(s)"),
                                          //                 //   ),
                                          //                 // ),
                                          //               ],
                                          //             )
                                          //           ]),
                                          //     ),
                                          //     // Expanded(
                                          //     //   flex: 8,
                                          //     //   child: Column(
                                          //     //       mainAxisAlignment:
                                          //     //           MainAxisAlignment.center,
                                          //     //       children: [
                                          //     //         RichText(
                                          //     //           text: TextSpan(
                                          //     //               text:
                                          //     //                   "${groupDetailsModel.value.data?.name}" ??
                                          //     //                       "",
                                          //     //               style: const TextStyle(
                                          //     //                 color: Colors.black,
                                          //     //                 fontSize: 15.0,
                                          //     //                 height: 1.8,
                                          //     //                 fontWeight:
                                          //     //                     FontWeight.bold,
                                          //     //                 decoration:
                                          //     //                     TextDecoration.none,
                                          //     //               ),
                                          //     //               children: [
                                          //     //                 TextSpan(
                                          //     //                   text: "\n" +
                                          //     //                       "${groupDetailsModel.value.data?.ownerName}",
                                          //     //                   style: const TextStyle(
                                          //     //                     color: Colors.black,
                                          //     //                     fontSize: 15.0,
                                          //     //                     height: 1.8,
                                          //     //                     fontWeight:
                                          //     //                         FontWeight.w300,
                                          //     //                     decoration:
                                          //     //                         TextDecoration
                                          //     //                             .none,
                                          //     //                   ),
                                          //     //                 )
                                          //     //               ]),
                                          //     //         ),
                                          //     //         Row(
                                          //     //           mainAxisAlignment:
                                          //     //               MainAxisAlignment
                                          //     //                   .spaceEvenly,
                                          //     //           children: [
                                          //     //             if (groupDetailsModel.value
                                          //     //                         .data?.ownerId !=
                                          //     //                     userId &&
                                          //     //                 groupDetailsModel
                                          //     //                         .value
                                          //     //                         .data
                                          //     //                         ?.sendReqButton !=
                                          //     //                     "N")
                                          //     //               ElevatedButton(
                                          //     //                 onPressed: () {
                                          //     //                   sendJoinRequest();
                                          //     //                 },
                                          //     //                 child: groupDetailsModel
                                          //     //                             .value
                                          //     //                             .data
                                          //     //                             ?.sendReqButton ==
                                          //     //                         "N"
                                          //     //                     ? const Text(
                                          //     //                         "Requested")
                                          //     //                     : const Text("Join"),
                                          //     //               ),
                                          //     //             // const SizedBox(width: 2),
                                          //     //             // Expanded(
                                          //     //             //   child: ElevatedButton(
                                          //     //             //     onPressed: () {
                                          //     //             //       if (widget.groupId !=
                                          //     //             //           null) {
                                          //     //             //         Get.to(() =>
                                          //     //             //             GroupMembersUI(
                                          //     //             //                 groupId: widget
                                          //     //             //                         .groupId ??
                                          //     //             //                     ""));
                                          //     //             //       }
                                          //     //             //     },
                                          //     //             //     child:
                                          //     //             //         const Text("Member(s)"),
                                          //     //             //   ),
                                          //     //             // ),
                                          //     //           ],
                                          //     //         )
                                          //     //       ]),
                                          //     // ),
                                          //   ],
                                          // ),
                                          Container(
                                              height: 90,
                                              width: 90,
                                              decoration: BoxDecoration(
                                                color: Theme.of(Get.context!).iconTheme.color,
                                                borderRadius: BorderRadius.circular(100),
                                                border: Border.all(
                                                  color: Theme.of(Get.context!).iconTheme.color!,
                                                  width: 1,
                                                ),
                                              ),
                                              margin: const EdgeInsets.all(5),
                                              padding: EdgeInsets.zero,
                                              child: ClipOval(
                                                child: CachedNetworkImage(
                                                  alignment: Alignment.center,
                                                  fit: BoxFit.fill,
                                                  imageUrl: groupDetailsModel.value.data?.profilePic ?? "",
                                                  placeholder: (context, url) => Container(
                                                    padding: const EdgeInsets.all(3),
                                                    child: shimmerMeUp(CircularProgressIndicator(
                                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                                                    )),
                                                  ),
                                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                                ),
                                              )),
                                          // Container(
                                          //   padding: const EdgeInsets.only(
                                          //       bottom: 5, left: 5, right: 5),
                                          //   decoration: BoxDecoration(
                                          //     borderRadius: BorderRadius.circular(12),
                                          //     color: Colors.white.withOpacity(0.5),
                                          //   ),
                                          //   child: Row(
                                          //       mainAxisSize: MainAxisSize.min,
                                          //       mainAxisAlignment:
                                          //           MainAxisAlignment.center,
                                          //       children: [
                                          //         RichText(
                                          //           text: TextSpan(
                                          //               text:
                                          //                   "${groupDetailsModel.value.data?.name.toString().capitalize}" ??
                                          //                       "",
                                          //               style: const TextStyle(
                                          //                 color: Colors.black,
                                          //                 fontSize: 15.0,
                                          //                 height: 1.8,
                                          //                 fontWeight: FontWeight.bold,
                                          //                 decoration:
                                          //                     TextDecoration.none,
                                          //               ),
                                          //               children: [
                                          //                 TextSpan(
                                          //                   text: "\n" +
                                          //                       "${groupDetailsModel.value.data?.ownerName.toString().capitalize}",
                                          //                   style: const TextStyle(
                                          //                     color: Colors.black,
                                          //                     fontSize: 15.0,
                                          //                     height: 1.8,
                                          //                     fontWeight:
                                          //                         FontWeight.w300,
                                          //                     decoration:
                                          //                         TextDecoration.none,
                                          //                   ),
                                          //                 ),
                                          //                 if (groupDetailsModel
                                          //                         .value
                                          //                         .data
                                          //                         ?.groupDescription !=
                                          //                     null)
                                          //                   TextSpan(
                                          //                     text: "\n" +
                                          //                         "${groupDetailsModel.value.data?.groupDescription.toString().capitalize}",
                                          //                     style: const TextStyle(
                                          //                       color: Colors.black,
                                          //                       fontSize: 15.0,
                                          //                       height: 1.8,
                                          //                       fontWeight:
                                          //                           FontWeight.w300,
                                          //                       decoration:
                                          //                           TextDecoration.none,
                                          //                     ),
                                          //                   )
                                          //               ]),
                                          //         ),
                                          //         // if (groupDetailsModel.value.data
                                          //         //         ?.groupDescription !=
                                          //         //     null)
                                          //         //   Text(
                                          //         //       "${groupDetailsModel.value.data?.groupDescription.toString().capitalize}"),
                                          //         Row(
                                          //           mainAxisAlignment:
                                          //               MainAxisAlignment.spaceEvenly,
                                          //           children: [
                                          //             if (groupDetailsModel.value.data
                                          //                         ?.ownerId !=
                                          //                     userId &&
                                          //                 groupDetailsModel.value.data
                                          //                         ?.sendReqButton !=
                                          //                     "N")
                                          //               ElevatedButton(
                                          //                 onPressed: () {
                                          //                   sendJoinRequest();
                                          //                 },
                                          //                 child: groupDetailsModel
                                          //                             .value
                                          //                             .data
                                          //                             ?.sendReqButton ==
                                          //                         "N"
                                          //                     ? const Text("Requested")
                                          //                     : const Text("Join"),
                                          //               ),
                                          //             // const SizedBox(width: 2),
                                          //             // Expanded(
                                          //             //   child: ElevatedButton(
                                          //             //     onPressed: () {
                                          //             //       if (widget.groupId !=
                                          //             //           null) {
                                          //             //         Get.to(() =>
                                          //             //             GroupMembersUI(
                                          //             //                 groupId: widget
                                          //             //                         .groupId ??
                                          //             //                     ""));
                                          //             //       }
                                          //             //     },
                                          //             //     child:
                                          //             //         const Text("Member(s)"),
                                          //             //   ),
                                          //             // ),
                                          //           ],
                                          //         )
                                          //       ]),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          // alignment: Alignment.center,
                          child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                    text: "${groupDetailsModel.value.data?.name.toString().capitalize}" ?? "",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                      height: 1.5,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "\n" + "${groupDetailsModel.value.data?.ownerName.toString().capitalize}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          height: 1.8,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      if (groupDetailsModel.value.data?.groupDescription != null)
                                        TextSpan(
                                          text: "\n" + "${groupDetailsModel.value.data?.groupDescription.toString().capitalize}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                            height: 1.8,
                                            fontWeight: FontWeight.w300,
                                            decoration: TextDecoration.none,
                                          ),
                                        )
                                    ]),
                              ),
                            ),

                            if (groupDetailsModel.value.data?.ownerId == userId)
                              IconButton(
                                  onPressed: () {
                                    if (groupDetailsModel.value.data?.groupId != null) {
                                      editGroupDetails(
                                          name: groupDetailsModel.value.data?.name,
                                          description: groupDetailsModel.value.data?.groupDescription,
                                          groupId: groupDetailsModel.value.data?.groupId ?? '');
                                    }
                                  },
                                  icon: Icon(Icons.edit)),
                            // if (groupDetailsModel.value.data
                            //         ?.groupDescription !=
                            //     null)
                            //   Text(
                            //       "${groupDetailsModel.value.data?.groupDescription.toString().capitalize}"),
                            if (groupDetailsModel.value.data?.ownerId != userId && groupDetailsModel.value.data?.sendReqButton != "N")
                              ElevatedButton(
                                onPressed: () {
                                  if (groupDetailsModel.value.data?.sendReqButton != "N") {
                                    sendJoinRequest();
                                  }
                                },
                                child: groupDetailsModel.value.data?.sendReqButton == "N" ? const Text("Requested") : const Text("Join"),
                              )
                          ]),
                        ),

                        // Column(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       RichText(
                        //         text: TextSpan(
                        //             text:
                        //                 "Group Name: ${groupDetailsModel.value.data?.name.toString().capitalize}" ??
                        //                     "",
                        //             style: const TextStyle(
                        //               color: Colors.black,
                        //               fontSize: 15.0,
                        //               height: 1.8,
                        //               fontWeight: FontWeight.bold,
                        //               decoration: TextDecoration.none,
                        //             ),
                        //             children: [
                        //               TextSpan(
                        //                 text: "\n" +
                        //                     "Admin: ${groupDetailsModel.value.data?.ownerName.toString().capitalize}",
                        //                 style: const TextStyle(
                        //                   color: Colors.black,
                        //                   fontSize: 15.0,
                        //                   height: 1.8,
                        //                   fontWeight: FontWeight.w300,
                        //                   decoration: TextDecoration.none,
                        //                 ),
                        //               )
                        //             ]),
                        //       ),
                        //       Row(
                        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //         children: [
                        //           if (groupDetailsModel.value.data?.ownerId !=
                        //                   userId &&
                        //               groupDetailsModel.value.data?.sendReqButton !=
                        //                   "N")
                        //             ElevatedButton(
                        //               onPressed: () {
                        //                 sendJoinRequest();
                        //               },
                        //               child: groupDetailsModel
                        //                           .value.data?.sendReqButton ==
                        //                       "N"
                        //                   ? const Text("Requested")
                        //                   : const Text("Join"),
                        //             ),
                        //           // const SizedBox(width: 2),
                        //           // Expanded(
                        //           //   child: ElevatedButton(
                        //           //     onPressed: () {
                        //           //       if (widget.groupId !=
                        //           //           null) {
                        //           //         Get.to(() =>
                        //           //             GroupMembersUI(
                        //           //                 groupId: widget
                        //           //                         .groupId ??
                        //           //                     ""));
                        //           //       }
                        //           //     },
                        //           //     child:
                        //           //         const Text("Member(s)"),
                        //           //   ),
                        //           // ),
                        //         ],
                        //       )
                        //     ]),
                        StatefulBuilder(
                          builder: (context, setStateCustom) {
                            return StreamBuilder(
                              stream: groupFeeds?.stream,
                              builder: (context, snapshot) {
                                print("----- ${groupFeeds?.length}");

                                // if (snapshot.connectionState == ConnectionState.waiting) {
                                //   return shimmerFeedLoading();
                                // }

                                if (snapshot.hasError) {
                                  return Container(
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    child: customText(title: "${snapshot.error}"),
                                  );
                                }
                                // if (groupFeeds?.isEmpty == true) {
                                //   return Container(
                                //     height: Get.height * 0.4,
                                //     // color: Colors.white,
                                //     alignment: Alignment.center,
                                //     child: customText(title: 'No Feeds', txtColor: Colors.white),
                                //   );
                                // }

                                return groupFeeds?.isNotEmpty == true
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: groupFeeds?.length ?? 0,
                                        itemBuilder: (BuildContext context, int index) {
                                          //return SizedBox();
                                          return listItem(index, onFavClick: () {
                                            setStateCustom(() {});
                                          }, onLikeClick: () {
                                            setStateCustom(() {});
                                          });
                                        },
                                      )
                                    : Center(child: customText(title: 'No Feeds', txtColor: Colors.white));
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          resizeToAvoidBottomInset: false,
          floatingActionButton: StreamBuilder(
            stream: groupController.isPostUploading.stream,
            builder: (context, snapshot) {
              return groupController.isPostUploading.value == false
                  ? StreamBuilder(
                      stream: groupDetailsModel.stream,
                      builder: (context, snapshot) {
                        return groupDetailsModel.value.data?.postAbility == "Y"
                            ? FloatingActionButton(
                                backgroundColor: Colors.black,
                                onPressed: () {
                                  if (widget.groupId != null) {
                                    // Get.to(() => GroupAddNewPost(
                                    //       groupId: widget.groupId ?? "",
                                    //     ));
                                    Get.to(() => GroupAddPost(
                                          groupId: widget.groupId ?? "",
                                        ));
                                  }
                                },
                                child: const Icon(Icons.add),
                              )
                            : SizedBox();
                      },
                    )
                  : SizedBox();
            },
          ),

          // floatingActionButton: ExpandableFab(
          //   fabIcon: Icons.add,
          //   initialOpen: false,
          //   distance: 80,
          //   children: [
          //     ActionButton(
          //       icon: Icon(Icons.image),
          //       onPressed: () async {
          //         RxList<File> fileList = <File>[].obs;
          //         final filePickerResult = await FilePicker.platform.pickFiles(
          //           allowMultiple: true,
          //         );
          //         filePickerResult?.files.forEach((element) {
          //           fileList.add(File("${element.path}"));
          //         });
          //         if (fileList.isNotEmpty) {
          //           groupController.uploadImage(
          //               imageFilePaths: fileList,
          //               groupID: "${widget.group.groupId}",
          //               callBack: () {
          //                 groupController.getGrpFeed(groupId: widget.group.groupId, isFirstTimeLoading: true, page: currentPage);
          //               });
          //         }
          //       },
          //     ),
          //     ActionButton(
          //       icon: Icon(Icons.text_fields_sharp),
          //       onPressed: () {
          //         TextEditingController statusController = TextEditingController();
          //         TextEditingController urlController = TextEditingController();
          //         final formKey = GlobalKey<FormState>().obs;
          //         Get.dialog(AlertDialog(
          //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          //           title: Text("Post Status"),
          //           content: StreamBuilder(
          //               stream: formKey.stream,
          //               builder: (context, snapshot) {
          //                 return Form(
          //                   key: formKey.value,
          //                   child: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     mainAxisSize: MainAxisSize.min,
          //                     children: [
          //                       Text("Write Status here..", style: GoogleFonts.inter(color: Colors.black)),
          //                       commonTextField(
          //                           baseColor: Colors.black,
          //                           borderColor: Colors.black,
          //                           controller: statusController,
          //                           maxLines: 2,
          //                           validator: (String? value) {
          //                             return value?.isEmpty == true ? 'Please enter status' : null;
          //                           }),
          //                       Text("Write Url here..", style: GoogleFonts.inter(color: Colors.black)),
          //                       commonTextField(
          //                         baseColor: Colors.black,
          //                         borderColor: Colors.black,
          //                         controller: urlController,
          //                         maxLines: 1,
          //                       ),
          //                     ],
          //                   ),
          //                 );
          //               }),
          //           actions: [
          //             TextButton(
          //                 onPressed: () {
          //                   Get.back();
          //                 },
          //                 child: Text("Cancel")),
          //             TextButton(
          //                 onPressed: () {
          //                   if (formKey.value.currentState?.validate() == true) {
          //                     groupController.uploadText(
          //                         groupID: "${widget.group.groupId}",
          //                         url: urlController.text,
          //                         callBack: () {
          //                           groupController.getGrpFeed(groupId: widget.group.groupId, isFirstTimeLoading: true, page: currentPage);
          //                         },
          //                         textStatus: "${statusController.text}");
          //                   }
          //                 },
          //                 child: Text("Post")),
          //           ],
          //         ));
          //       },
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }

  Widget listItem(int index, {VoidCallback? onFavClick, VoidCallback? onLikeClick}) {
    TextEditingController commentTextController = TextEditingController();
    RxBool emojiShowing = false.obs;
    return StatefulBuilder(
      builder: (context, StateSetter setStateCard) => Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        //margin: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ClipOval(
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).iconTheme.color,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Theme.of(Get.context!).iconTheme.color!,
                          width: 1,
                        ),
                      ),
                      margin: const EdgeInsets.all(5),
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          Get.to(
                            () => InteractiveViewer(
                              child: CachedNetworkImage(
                                alignment: Alignment.center,
                                fit: BoxFit.fill,
                                imageUrl: groupFeeds?[index].profilePic ?? "",
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          );
                        },
                        child: ClipOval(
                          child: CachedNetworkImage(
                            alignment: Alignment.center,
                            fit: BoxFit.fill,
                            imageUrl: groupFeeds?[index].profilePic ?? "",
                            placeholder: (context, url) => Container(
                              padding: const EdgeInsets.all(3),
                              child: shimmerMeUp(CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                              )),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 8,
                    child: RichText(
                      text: TextSpan(
                        text: groupFeeds?[index].name ?? "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          height: 1.8,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                        children: const <TextSpan>[
                          TextSpan(
                            text: "",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 15.0,
                              height: 1.8,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    // position: PopupMenuPosition.under,
                    onSelected: (value) {
                      if (value == "Report" && groupFeeds?[index].id != null) {
                        reportPost(groupFeeds?[index].id ?? "");
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text("Report"),
                          value: "Report",
                        ),
                      ];
                    },
                  )
                ],
              ),
            ),
            customImageView(groupFeeds?[index]),
            if (groupFeeds?[index].status != null && groupFeeds?[index].status != '')
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 8,
                      child: getLinkText(text: groupFeeds![index].status ?? ""),
                      // child: RichText(
                      //   text: TextSpan(
                      //     text: groupFeeds![index].status!,
                      //     style: const TextStyle(
                      //       color: Colors.black45,
                      //       fontSize: 15.0,
                      //       height: 1.8,
                      //       fontWeight: FontWeight.normal,
                      //       decoration: TextDecoration.none,
                      //     ),
                      //   ),
                      // ),
                    ),
                  ],
                ),
              ),
            Container(
              margin: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  StatefulBuilder(
                    builder: (context, StateSetter setStateFav) {
                      bool isLoved = groupFeeds?[index].isFav == 1;
                      return Expanded(
                        flex: 1,
                        child: IconButton(
                            onPressed: () {
                              // groupFeeds?[index].isFav == 1
                              //     ? setAsFav(
                              //         "${groupFeeds?[index].id}",
                              //       ).then((value) {
                              //         onFavClick!();
                              //         groupFeeds?[index].isFav = 1;
                              //       })
                              //     : setAsUnFav("${groupFeeds?[index].id}").then((value) {
                              //         groupFeeds?[index].isFav = 0;
                              //         onFavClick!();
                              //       });

                              if (!isLoved) {
                                setAsFav(postId: "${groupFeeds?[index].id}", isFrmGrp: true).then((value) {
                                  if (groupFeeds?[index].isFav == 0) {
                                    groupFeeds?[index].isFav = 1;
                                  } else {
                                    groupFeeds?[index].isFav = 0;
                                  }
                                  setStateFav(() {});
                                });
                              } else {
                                setAsUnFav("${groupFeeds?[index].id}").then((value) {
                                  if (groupFeeds?[index].isFav == 0) {
                                    groupFeeds?[index].isFav = 1;
                                  } else {
                                    groupFeeds?[index].isFav = 0;
                                  }
                                  setStateFav(() {});
                                });
                              }
                            },
                            icon: Icon(
                              isLoved ? Icons.favorite : Icons.favorite_border,
                              color: isLoved ? Colors.red : Theme.of(Get.context!).iconTheme.color,
                            )),
                      );
                    },
                  ),
                  StatefulBuilder(
                    builder: (context, StateSetter setStateLike) {
                      bool isLiked = groupFeeds?[index].isLike == 1;
                      return Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () async {
                              await setAsLiked(
                                  postId: "${groupFeeds?[index].id}",
                                  isInsertLike: groupFeeds?[index].isLike == 0,
                                  postOwnerId: groupFeeds?[index].ownerId,
                                  isGrpPost: true,
                                  callBack: (commentCount) {
                                    if (groupFeeds?[index].isLike == 0) {
                                      groupFeeds?[index].isLike = 1;
                                    } else {
                                      groupFeeds?[index].isLike = 0;
                                    }
                                    groupFeeds?[index].countLike = "${commentCount}";
                                    setStateLike(() {});
                                  });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              height: 20,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    isLiked ? "assets/icon/liked_image.png" : "assets/icon/like_img.png",
                                    color: isLiked ? Colors.blue : Theme.of(Get.context!).iconTheme.color,
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    "${groupFeeds?[index].countLike}",
                                  ),
                                ],
                              ),
                            )),
                      );
                    },
                  ),
                  // Expanded(
                  //   flex: 1,
                  //   child: IconButton(
                  //       onPressed: () {
                  //         debugPrint("Before: ${groupFeeds![index].id!}");
                  //         String postId = "${groupFeeds?[index].id}";
                  //         Get.to(() => CommentScreen(
                  //               isFrom: AppTexts.group,
                  //               index: index,
                  //               postId: postId,
                  //             ));
                  //         // pushOnlyTo(widget: CommentUI(AppData.selectedPostId));
                  //       },
                  //       icon: const Icon(Icons.messenger_outline)),
                  // ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () async {
                        LoginModel userDetails = await SessionManagement.getUserDetails();
                        if (kDebugMode) {
                          print("user id: ${userDetails.id}");
                          print("post id: ${groupFeeds?[index].id}");
                          print(">> > Before Comment Count ${groupFeeds?[index].countComment}");
                          print(":: CURRENT INDEX IS ${index}");
                          print("Before: ${groupFeeds?[index].id!}");
                        }
                        String postId = "${groupFeeds?[index].id}";
                        Get.to(() => CommentScreen(
                              index: index,
                              isFrom: AppTexts.group,
                              postId: postId,
                              postOwnerId: groupFeeds?[index].ownerId,
                              grpId: widget.groupId,
                            ))?.then((value) {
                          groupFeeds?.refresh();
                          print(">> >> > After Comment Count ${groupFeeds?[index].countComment}");
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: 20,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              // color: isLiked ? Colors.blue : Theme.of(Get.context!).iconTheme.color,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              "${groupFeeds?[index].countComment}",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Expanded(
                  //   flex: 1,
                  //   child: IconButton(
                  //       onPressed: () async {
                  //         LoginModel userDetails = await SessionManagement.getUserDetails();
                  //         userId = userDetails.id;
                  //         groupController.sharePostToTimeline(
                  //             postOwnerId: "${groupFeeds?[index].ownerId}", ownerId: "${userId}", wireId: "${widget.group.groupId}");
                  //       },
                  //       icon: const Icon(Icons.add_box)),
                  // ),
                  PopupMenuButton(
                    onSelected: (value) async {
                      LoginModel userDetails = await SessionManagement.getUserDetails();
                      userId = userDetails.id;
                      if (value == "Timeline") {
                        groupController.sharePostToTimeline(postOwnerId: "${groupFeeds?[index].ownerId}", ownerId: "${userId}", wireId: "${groupFeeds?[index].id}");
                      }
                      if (value == "Other") {
                        AppMethods().share("https://whatgodhasdoneforme.com/profile/post/group/${groupDetailsModel.value.data?.groupId}/${groupFeeds?[index].id}");
                      }
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    position: PopupMenuPosition.under,
                    icon: Icon(Icons.share),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                            value: "Timeline",
                            child: Row(
                              children: [
                                const Icon(Icons.add_box).paddingOnly(right: 7),
                                Text("Timeline"),
                              ],
                            )),
                        PopupMenuItem(
                            value: "Other",
                            child: Row(
                              children: [
                                Icon(Icons.ios_share).paddingOnly(right: 7),
                                Text("Share"),
                              ],
                            )),
                      ];
                    },
                  ),
                  // Expanded(
                  //   flex: 1,
                  //   child: IconButton(
                  //       onPressed: () {
                  //
                  //
                  //
                  //         AppMethods().share(EndPoints.socialSharePostUrl + groupFeeds![index].id!);
                  //       },
                  //       icon: const Icon(Icons.share)),
                  // ),
                  // Expanded(
                  //   flex: 1,
                  //   child: IconButton(
                  //       onPressed: () {
                  //         reportPost(groupFeeds![index].id!);
                  //       },
                  //       icon: const Icon(Icons.report_problem)),
                  // ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: customText(title: groupFeeds?[index].timeStamp!, fs: 10),
                )),
            if (groupFeeds?[index].latestComments?.isNotEmpty == true)
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Comments",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).paddingOnly(left: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    // reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (groupFeeds?[index].latestComments?.length ?? 0) > 3 ? 3 : groupFeeds?[index].latestComments?.length ?? 0,
                    itemBuilder: (context, indexOfComment) {
                      int listLength = groupFeeds?[index].latestComments?.length ?? 0;
                      return Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(Get.context!).iconTheme.color,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Theme.of(Get.context!).iconTheme.color!,
                                width: 1,
                              ),
                            ),
                            margin: const EdgeInsets.all(5),
                            padding: EdgeInsets.zero,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                alignment: Alignment.center,
                                fit: BoxFit.fill,
                                imageUrl:
                                    "https://wghdfm.s3.amazonaws.com/thumb/${groupFeeds?[index].latestComments?[listLength - (listLength >= 3 ? 3 : listLength >= 2 ? 2 : 1) + indexOfComment]?.img}",
                                // "https://wghdfm.s3.amazonaws.com/thumb/${dashBoardController.dashboardFeeds[index].latestComments?.last.img}",
                                progressIndicatorBuilder: (BuildContext, String, DownloadProgress) {
                                  return const Center(child: CupertinoActivityIndicator());
                                },
                                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    "${groupFeeds?[index].latestComments?[listLength - (listLength >= 3 ? 3 : listLength >= 2 ? 2 : 1) + indexOfComment]?.firstname} ${groupFeeds?[index].latestComments?[listLength - (listLength >= 3 ? 3 : listLength >= 2 ? 2 : 1) + indexOfComment]?.lastname}",
                                    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500)),
                                Text(
                                    "${groupFeeds?[index].latestComments?[listLength - (listLength >= 3 ? 3 : listLength >= 2 ? 2 : 1) + indexOfComment]?.comment}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          // Text("${listLength - (listLength >= 3 ? 3 : listLength >= 2 ? 2 : 0) + indexOfComment}"),
                        ],
                      );
                    },
                  ),
                ],
              ),
            Container(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              height: 60,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 9,
                    child: commonTextField(
                      readOnly: false,
                      leading: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined, size: 25),
                        onPressed: () async {
                          emojiShowing.toggle();
                          // setState(() {});
                        },
                      ),
                      hint: 'Write Comment',
                      isLabelFloating: false,
                      controller: commentTextController,
                      borderColor: Theme.of(Get.context!).primaryColor,
                      baseColor: Theme.of(Get.context!).colorScheme.secondary,
                      isLastField: true,
                      obscureText: false,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      print(":: ${groupFeeds?[index].latestComments?.length}");
                      FocusScope.of(context).requestFocus(FocusNode());
                      LoginModel userDetailss = await SessionManagement.getUserDetails();
                      String postId = "${groupFeeds?[index].id}";

                      if (commentTextController.text.trim().isNotEmpty) {
                        LoginModel userDetails = await SessionManagement.getUserDetails();

                        Map<String, String> bodyData = {"post_id": postId, "user_id": "${userDetailss.id}", "comment": commentTextController.text};

                        await APIService().callAPI(
                            params: {},
                            serviceUrl: "${EndPoints.baseUrl}${EndPoints.insertCommentForGrpUrl}/${postId}/${userDetails.id}/G",
                            method: APIService.postMethod,
                            formDatas: dio.FormData.fromMap(bodyData),
                            success: (dio.Response response) async {
                              // Get.back();
                              print(":: RESPONSE : ${response.data}");
                              // print(":: RESPONSE Comment Id  : ${jsonDecode(response.data)["comment_id"]}");
                              print(":: INDEX IS ${index}");
                              setStateCard(() {
                                // print(":: commentController.commentList?.length IS ${commentController.commentList?.length}");
                                // groupFeeds?[index].latestComments?.add(PostModelFeedLatestComments(
                                //       comment: commentTextController.text,
                                //       commentId: "${jsonDecode(response.data)["comment_id"]}",
                                //       firstname: userDetails.fname ?? "",
                                //       lastname: userDetails.lname ?? "",
                                //       img: userDetails.img ?? "",
                                //       date: DateTime.now().toString(),
                                //       userId: userDetails.id ?? "",
                                //     ));

                                final decodedesponse = jsonDecode(response.data);
                                // print()
                                groupFeeds?[index].latestComments?.clear();
                                decodedesponse.forEach((element) {
                                  print(":: element $element");
                                  print(":: element[comment] ${element["comment"]}");
                                  groupFeeds?[index].latestComments?.add(PostModelFeedLatestComments(
                                      comment: element["comment"] ?? "",
                                      commentId: element["comment_id"] ?? "",
                                      lastname: element["lastname"] ?? "",
                                      firstname: element["firstname"] ?? "",
                                      img: element["img"] ?? "",
                                      userId: element["user_id"] ?? "",
                                      date: ""));
                                });

                                groupFeeds?[index].countComment = (groupFeeds?[index].countComment ?? 0) + 1;
                                commentTextController.clear();
                                groupFeeds?.refresh();
                              });
                              print(">> < COMMENT COUNT ? ${groupFeeds?[index].countComment}");
                              print(">> ::  COMMENT COUNT ? ${groupFeeds?[index].latestComments?.length}");
                              if (groupFeeds?[index].ownerId != userDetails.id && groupFeeds?[index].ownerId != null) {
                                NotificationHandler.to.sendNotificationToUserID(
                                    postId: groupFeeds?[index].id ?? "0",
                                    userId: groupFeeds?[index].ownerId ?? "0",
                                    title: "New Comments on Your Post",
                                    body: "${userDetails.fname} ${userDetails.lname} Commented your post");
                              }
                            },
                            error: (dio.Response response) {
                              snack(icon: Icons.report_problem, iconColor: Colors.yellow, msg: "Type something first...", title: "Alert!");
                            },
                            showProcess: true);
                      }
                    },
                  ),
                ],
              ),
            ),
            StreamBuilder(
                stream: emojiShowing.stream,
                builder: (context, snapshot) {
                  return Offstage(
                    offstage: emojiShowing.isFalse,
                    child: SizedBox(
                      height: Get.height * 0.4,
                      child: EmojiKeybord(
                        textController: commentTextController,
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  ///For group ui
  // Widget customImageView(PostModelFeed? feed) {
  //   var feedImg = (feed?.image!.trim() == '' || feed.image == null)
  //       ? ((feed.youtubeId!.trim() != '') ? feed.vimg! : "${EndPoints.VIDEO_THUMB_URL}${feed.videoThumb!}")
  //       : feed.image;
  //   var feedUrl = (feed.image!.trim() == '' || feed.image == null)
  //       ? ((feed.youtubeId!.trim() != '') ? feed.url! : "${EndPoints.VIDEO_URL}${feed.video}")
  //       : feed.image;
  //   //debugPrint("feedImg: $feedImg");
  //   return ((feed.image!.trim() == '' || feed.image == null) &&
  //           (feed.vimg!.trim() == '' || feed.vimg == null) &&
  //           (feed.videoThumb!.trim() == '' || feed.videoThumb == null))
  //       ? const SizedBox()
  //       : InkWell(
  //           onTap: () {
  //             if (feed.image!.trim() == '' || feed.image == null) {
  //               if (feed.youtubeId!.trim() != '') {
  //                 //Is Youtube Video
  //                 openInWeb(feedUrl!);
  //               } else {}
  //             } else {
  //               //Is Post Image
  //               Get.to(
  //                 () => InteractiveViewer(
  //                   child: CachedNetworkImage(
  //                     alignment: Alignment.center,
  //                     fit: BoxFit.fill,
  //                     imageUrl: feedImg,
  //                     placeholder: (context, url) => const CircularProgressIndicator(),
  //                     errorWidget: (context, url, error) => const Icon(Icons.error_outline),
  //                   ),
  //                 ),
  //               );
  //             }
  //           },
  //           child: AspectRatio(
  //             aspectRatio: 4 / 3,
  //             child: Stack(fit: StackFit.expand, alignment: Alignment.center, children: [
  //               CachedNetworkImage(
  //                 alignment: Alignment.center,
  //                 fit: BoxFit.fill,
  //                 imageUrl: feedImg!,
  //                 placeholder: (context, url) => Container(
  //                   padding: const EdgeInsets.all(3),
  //                   child: shimmerMeUp(CircularProgressIndicator(
  //                     valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
  //                   )),
  //                 ),
  //                 errorWidget: (context, url, error) => const Icon(Icons.error),
  //               ),
  //               if (feed.image!.trim() == '' || feed.image == null)
  //                 Container(
  //                   height: double.maxFinite,
  //                   width: double.maxFinite,
  //                   color: Colors.black.withOpacity(0.7),
  //                 ),
  //               if (feed.image!.trim() == '' || feed.image == null)
  //                 const Align(
  //                   alignment: Alignment.center,
  //                   child: Icon(
  //                     Icons.play_arrow,
  //                     size: 40,
  //                     color: Colors.red,
  //                   ),
  //                 ),
  //             ]),
  //           ),
  //         );
  // }

  Widget shimmerFeedLoading() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    shimmerMeUp(
                      const CircleAvatar(
                        child: SizedBox(width: 70, height: 70),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: shimmerMeUp(Container(
                        height: 20,
                        color: Colors.grey,
                      )),
                    ),
                    /*SizedBox(
                      width: 5,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: shimmerMeUp(
                        Icon(
                          FlutterIcons.report_problem_mdi,
                        ),
                      ),
                    ),*/
                  ],
                ),
              ),
              shimmerMeUp(
                AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      width: Get.width,
                      color: Colors.grey,
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.favorite_border)),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: 20,
                        child: Image.asset(
                          "assets/icon/like_img.png",
                          color: Theme.of(Get.context!).iconTheme.color,
                        ),
                      )),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.messenger_outline)),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.add_box)),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.share)),
                    ),
                    const Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(
                        const Icon(
                          Icons.report_problem,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: shimmerMeUp(Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  height: 20,
                  color: Colors.grey,
                )),
              ),
            ],
          ),
        ),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    shimmerMeUp(
                      const CircleAvatar(
                        child: SizedBox(width: 70, height: 70),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: shimmerMeUp(Container(
                        height: 20,
                        color: Colors.grey,
                      )),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: shimmerMeUp(
                        const Icon(
                          Icons.more_horiz,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              shimmerMeUp(
                AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      width: Get.width,
                      color: Colors.grey,
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        height: 20,
                        child: Image.asset(
                          "assets/icon/like_img.png",
                          color: Theme.of(Get.context!).iconTheme.color,
                        ),
                      )),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.messenger_outline)),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.share)),
                    ),
                    const Expanded(
                      flex: 4,
                      child: SizedBox(),
                    ),
                    Expanded(
                      flex: 1,
                      child: shimmerMeUp(const Icon(Icons.favorite_border)),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: shimmerMeUp(Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  height: 20,
                  color: Colors.grey,
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget shimmerProfileLoading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        shimmerMeUp(
          ClipOval(
            child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).iconTheme.color,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Theme.of(Get.context!).iconTheme.color!,
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.all(5),
                padding: EdgeInsets.zero,
                child: const ClipOval(
                  child: SizedBox(),
                )),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        shimmerMeUp(Container(
          width: 200,
          height: 60,
          color: Colors.grey,
        )),
      ],
    );
  }

  List<VoidCallback> postOptionOnClicks() {
    var callBacks = <VoidCallback>[
      () {
        debugPrint("Status");
      },
      () {
        debugPrint("Photo");
      },
      () {
        debugPrint("Video");
      },
    ];

    return callBacks;
  }

  void sendJoinRequest() {
    Get.dialog(Dialog(
        child: Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Want to send member request?"),
          Row(
            children: [
              Expanded(
                child: MaterialButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text("No".toUpperCase()),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    sendGroupJoinRequest(
                        groupId: widget.groupId ?? "",
                        groupType: groupDetailsModel.value.data?.type ?? "",
                        callBaack: () {
                          if (groupDetailsModel.value.data?.type == "P") {
                            NotificationHandler.to.sendNotificationToUserID(
                                userId: groupDetailsModel.value.data?.ownerId ?? "",
                                title: "New Request Pending.. ",
                                body: "Someone requested in ${groupDetailsModel.value.data?.name}",
                                postId: "",
                                map: {"GroupID": "${groupDetailsModel.value.data?.groupId}"});
                          }
                        });
                  },
                  child: Text("Yes".toUpperCase()),
                ),
              ),
            ],
          )
        ],
      ),
    )));
  }

  void editGroupDetails({String? name, String? description, required String groupId}) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    nameController.text = name ?? "";
    descriptionController.text = description ?? "";
    final formKey = GlobalKey<FormState>();
    Get.dialog(Dialog(
        child: Container(
      padding: const EdgeInsets.all(10),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Edit Group Details",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                )),
            SizedBox(
              height: 10,
            ),
            commonTextField(
              readOnly: false,
              hint: 'Group Name',
              validator: (String? value) {
                return (value == null || value.isEmpty) ? "Please enter valid name" : null;
              },
              isLabelFloating: false,
              controller: nameController,
              borderColor: Colors.black,
              baseColor: Colors.black,
              maxLines: 1,
            ),
            commonTextField(
              readOnly: false,
              hint: 'Group Description',
              isLastField: true,
              charLimit: 60,
              validator: (String? value) {
                return (value == null || value.isEmpty) ? "Please enter valid description" : null;
              },
              isLabelFloating: false,
              controller: descriptionController,
              borderColor: Colors.black,
              baseColor: Colors.black,
              maxLines: 3,
            ),
            Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text("No".toUpperCase()),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Get.back();
                        groupController.editGroupDetails(
                            groupName: nameController.text,
                            groupDescription: descriptionController.text,
                            groupId: groupId,
                            callBack: () {
                              fetchGroupDetails(groupId: groupId);
                              getGroups();
                            });
                      }
                    },
                    child: Text("Yes".toUpperCase()),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    )));
  }

  // void openInWeb(
  //   String navUrl,
  // ) async {
  //   FlutterWebBrowser.openWebPage(
  //     url: navUrl,
  //     customTabsOptions: CustomTabsOptions(
  //       colorScheme: CustomTabsColorScheme.dark,
  //       toolbarColor: Colors.black.withOpacity(0.3),
  //       secondaryToolbarColor: Colors.black.withOpacity(0.3),
  //       navigationBarColor: Colors.white,
  //       addDefaultShareMenuItem: false,
  //       instantAppsEnabled: false,
  //       showTitle: false,
  //       urlBarHidingEnabled: true,
  //     ),
  //     safariVCOptions: SafariViewControllerOptions(
  //       barCollapsingEnabled: true,
  //       preferredBarTintColor: Colors.black.withOpacity(0.3),
  //       preferredControlTintColor: Colors.white,
  //       dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
  //       modalPresentationCapturesStatusBarAppearance: true,
  //     ),
  //   );
  // }
}
