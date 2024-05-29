import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/model/group_members_res_obj.dart';
import 'package:wghdfm_java/model/groups_res_obj.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/notification_module/controller/notification_handler.dart';
import 'package:wghdfm_java/screen/friends/friends_screen.dart';
import 'package:wghdfm_java/screen/groups/group_controller.dart';
import 'package:wghdfm_java/screen/groups/methods.dart';
import 'package:wghdfm_java/utils/shimmer_utils.dart';

class GroupMembersUI extends StatefulWidget {
  // Group group;
  String groupId;

  GroupMembersUI({super.key, required this.groupId});

  @override
  State<GroupMembersUI> createState() => _GroupMembersUIState();
}

class _GroupMembersUIState extends State<GroupMembersUI> {
  final List<GroupMemberModelData>? searchedMembers = [];
  final GroupController groupController = Get.put(GroupController());
  final RxBool isRemoveMember = false.obs;
  final RxBool makeAdmin = true.obs;

  @override
  void initState() {
    // TODO: implement initState
    loadMembers(groupId: widget.groupId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint("After: $id");
    //likeList(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Member(s)',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        actions: [
          if (groupDetailsModel.value.data?.ownerId ==
                  userId /*&&
                                                groupDetail!.sendReqButton !=
                                            "N"*/
              )
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              position: PopupMenuPosition.under,
              onSelected: (value) {
                print(" remove member api implement here");
                isRemoveMember.toggle();
                makeAdmin.toggle();
              },
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(value: 0, child: Text("Remove Member")),
                ];
              },
            ),
        ],
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                height: 60,
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: commonTextField(
                          readOnly: false,
                          hint: 'Search Member',
                          isLabelFloating: false,
                          controller: groupController.searchTEC,
                          borderColor: Theme.of(Get.context!).primaryColor,
                          baseColor:
                              Theme.of(Get.context!).colorScheme.secondary,
                          isLastField: true,
                          obscureText: false,
                          onChanged: (searchInput) {
                            setState(() {
                              isSearching = searchInput.isNotEmpty;
                            });
                          }),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          if (groupController.searchTEC.text
                              .trim()
                              .isNotEmpty) {
                            // setState(() {
                            //   groupController.searchTEC.text = '';
                            //   isSearching = false;
                            // });
                          } else {
                            snack(
                                icon: Icons.report_problem,
                                iconColor: Colors.yellow,
                                msg:
                                    "Type someone's name first... in order to search...",
                                title: "Alert!");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  // future: reloadGroupMembers(c),
                  stream: groupMembers?.stream,
                  builder: (BuildContext context, snapshot) {
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

                    // if ((isSearching ? searchedMembers : groupMembers)?.isEmpty == true) {
                    if (groupMembers?.isEmpty == true) {
                      return Align(
                        alignment: Alignment.center,
                        child: Container(
                          alignment: Alignment.center,
                          child: customText(
                              title: isSearching
                                  ? "No member(s) found by this name"
                                  : "You don't have any members"),
                        ),
                      );
                    }

                    // if (isSearching) {
                    //   return Align(
                    //     alignment: Alignment.center,
                    //     child: Container(
                    //       alignment: Alignment.center,
                    //       child: customText(title: isSearching ? "No member(s) found by this name" : "You don't have any members"),
                    //     ),
                    //   );
                    // }
                    return CustomScrollView(
                      shrinkWrap: false,
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              if (groupController.searchTEC.text.isNotEmpty) {
                                if (groupMembers?[index]
                                        .firstname
                                        ?.toLowerCase()
                                        .contains(groupController.searchTEC.text
                                            .toLowerCase()) ==
                                    true) {
                                  return listItem(index, setState);
                                } else {
                                  return const SizedBox();
                                }
                              } else {
                                return listItem(index, setState);
                              }
                            },
                            childCount: /* isSearching ? searchedMembers?.length : */
                                groupMembers?.length ?? 0, // 1000 list items
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          shimmerMeUp(Container(
                            height: 20,
                            width: Get.width,
                            color: Colors.grey,
                          )),
                          const SizedBox(
                            height: 5,
                          ),
                          shimmerMeUp(Container(
                            height: 20,
                            width: Get.width * 0.5,
                            color: Colors.grey,
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget listItem(int index, setState) {
    // String? memberUserId = (isSearching ? searchedMembers : groupMembers)![index].memberUserId;
    return InkWell(
      onTap: () {},
      child: Card(
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
                      child: ClipOval(
                        child: CachedNetworkImage(
                          alignment: Alignment.center,
                          fit: BoxFit.fill,
                          imageUrl:
                              "https://wghdfm.s3.amazonaws.com/thumb/${groupMembers?[index].img}",
                          placeholder: (context, url) => Container(
                            padding: const EdgeInsets.all(3),
                            child: shimmerMeUp(CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.secondary),
                            )),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
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
                        // text: (isSearching ? searchedMembers : groupMembers)![index].firstname!.toUpperCase().trim(),
                        text:
                            "${groupMembers?[index].firstname} ${groupMembers?[index].lastname}"
                                .toUpperCase()
                                .trim(),
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 15.0,
                          height: 1.8,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            // text: "\n${(isSearching ? searchedMembers : groupMembers)![index].isAdmin == "A" ? "Group Admin" : "Normal Member"}",
                            text:
                                "\n ${groupMembers?[index].isAdmin == "A" ? "Group Admin" : "Normal Member"}",
                            style: GoogleFonts.montserrat(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          // if ((isSearching ? searchedMembers : groupMembers)?[index].isActive == "P")
                          if (groupMembers?[index].isActive == "P")
                            TextSpan(
                              // text: "\n${(isSearching ? searchedMembers : groupMembers)![index].isActive == "P" ? "(Pending Request)" : ""}",
                              text:
                                  "\n${groupMembers?[index].isActive == "P" ? "(Pending Request)" : ""}",
                              style: GoogleFonts.montserrat(
                                color: Colors.grey,
                                fontSize: 12,
                                // fontWeight: FontWeight.w300,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // if (groupDetailsModel.value.data?.ownerId == userId)
                  //   StreamBuilder(
                  //     stream: isRemoveMember.stream,
                  //     builder: (context, snapshot) {
                  //       if (!isRemoveMember.value &&
                  //           groupMembers?[index].isActive == "P") {
                  //         return TextButton(
                  //             onPressed: () async {
                  //               if (widget.groupId != null) {
                  //                 groupController.acceptMember(
                  //                   grpMemberID:
                  //                       "${groupMembers?[index].groupMembersId}",
                  //                   grpID: "${widget.groupId}",
                  //                 );
                  //               }
                  //             },
                  //             child: const Text(
                  //               "Accept Member",
                  //               style: TextStyle(
                  //                 color: Colors.blue,
                  //               ),
                  //             ));
                  //       } else {
                  //         return SizedBox();
                  //       }
                  //     },
                  //   ),
                  // if (groupDetailsModel.value.data?.ownerId == userId)
                  //   StreamBuilder(
                  //     stream: isRemoveMember.stream,
                  //     builder: (context, snapshot) => StreamBuilder(
                  //       stream: makeAdmin.stream,
                  //       builder: (context, snapshot) {
                  //         if (makeAdmin.isTrue &&
                  //             groupMembers?[index].isAdmin != "A") {
                  //           return TextButton(
                  //               onPressed: () async {
                  //                 if (widget.groupId != null) {
                  //                   groupController.makeAdmin(
                  //                     grpMemberID:
                  //                         "${groupMembers?[index].groupMembersId}",
                  //                     grpID: "${widget.groupId}",
                  //                   );
                  //                 }
                  //               },
                  //               child: const Text(
                  //                 "Make Admin",
                  //                 style: TextStyle(
                  //                   color: Colors.blue,
                  //                 ),
                  //               ));
                  //         } else {
                  //           return const SizedBox();
                  //         }
                  //       },
                  //     ),
                  //   ),
                  StreamBuilder(
                    stream: isRemoveMember.stream,
                    builder: (context, snapshot) {
                      if (isRemoveMember.value) {
                        return TextButton(
                            onPressed: () async {
                              if (widget.groupId != null) {
                                groupController.removeMember(
                                  grpMemberID:
                                      "${groupMembers?[index].groupMembersId}",
                                  grpID: "${widget.groupId}",
                                );
                              }
                            },
                            child: const Text(
                              "Remove",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ));
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (groupDetailsModel.value.data?.ownerId == userId)
                  StreamBuilder(
                    stream: isRemoveMember.stream,
                    builder: (context, snapshot) {
                      if (!isRemoveMember.value &&
                          groupMembers?[index].isActive == "P") {
                        return TextButton(
                            onPressed: () async {
                              if (widget.groupId != null) {
                                groupController.acceptMember(
                                    grpMemberID:
                                        "${groupMembers?[index].groupMembersId}",
                                    grpID: "${widget.groupId}",
                                    callBack: () {
                                      NotificationHandler.to.sendNotificationToUserID(
                                          userId:
                                              "${groupMembers?[index].userId}",
                                          title:
                                              "Your request has been accepted",
                                          body:
                                              "Now you are member of ${groupDetailsModel.value.data?.name}",
                                          postId: "",
                                          map: {
                                            "GroupID":
                                                "${groupDetailsModel.value.data?.groupId}"
                                          });
                                    });
                              }
                            },
                            child: const Text(
                              "Accept Member",
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ));
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                if (groupDetailsModel.value.data?.ownerId == userId)
                  StreamBuilder(
                    stream: isRemoveMember.stream,
                    builder: (context, snapshot) => StreamBuilder(
                      stream: makeAdmin.stream,
                      builder: (context, snapshot) {
                        if (makeAdmin.isTrue &&
                            groupMembers?[index].isAdmin != "A") {
                          return TextButton(
                              onPressed: () async {
                                if (widget.groupId != null) {
                                  groupController.makeAdmin(
                                      grpMemberID:
                                          "${groupMembers?[index].groupMembersId}",
                                      grpID: "${widget.groupId}",
                                      callBack: () {
                                        NotificationHandler.to.sendNotificationToUserID(
                                            userId:
                                                "${groupMembers?[index].userId}",
                                            title: "You are now admin. ",
                                            body: "You are now admin of ${groupDetailsModel.value.data?.name}.",
                                            postId: "",
                                            map: {
                                              "GroupID":
                                                  "${groupDetailsModel.value.data?.groupId}"
                                            });
                                      });
                                }
                              },
                              child: const Text(
                                "Make Admin",
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ));
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future reloadGroupMembers(GroupController c) async {
    // groupMembers = await loadMembers(groupId: group.groupId!);
    // if (isSearching) {
    //   if (searchedMembers!.isNotEmpty) searchedMembers!.clear();
    //   for (int i = 0; i < groupMembers!.length; i++) {
    //     if (groupMembers![i].name!.toLowerCase().contains(c.searchTEC.text.trim().toLowerCase())) {
    //       searchedMembers!.add(groupMembers![i]);
    //     }
    //   }
    // } else {}
    //
    // return isSearching ? searchedMembers : groupMembers;
  }
}
