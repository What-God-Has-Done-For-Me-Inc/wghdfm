import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/model/groups_res_obj.dart';
import 'package:wghdfm_java/screen/friends/friends_screen.dart';
import 'package:wghdfm_java/screen/groups/group_controller.dart';
import 'package:wghdfm_java/screen/groups/group_details_screen.dart';
import 'package:wghdfm_java/screen/groups/methods.dart';
import 'package:wghdfm_java/utils/shimmer_utils.dart';

import '../../utils/app_images.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  GroupController groupController = Get.put(GroupController());
  RxList<Group>? searchedGroups = <Group>[].obs;

  @override
  void initState() {
    // TODO: implement initState
    // reloadGroups(groupController);
    getGroups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint("After: $id");
    //likeList(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group(s)',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
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
                          hint: 'Search a group',
                          isLabelFloating: false,
                          controller: groupController.searchTEC,
                          borderColor: Theme.of(Get.context!).primaryColor,
                          baseColor:
                              Theme.of(Get.context!).colorScheme.secondary,
                          isLastField: true,
                          obscureText: false,
                          onChanged: (searchInput) {
                            setState(() {
                              // isSearching = searchInput.isNotEmpty;
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
                            setState(() {
                              groupController.searchTEC.text = '';
                              isSearching = false;
                            });
                          } else {
                            snack(
                                icon: Icons.report_problem,
                                iconColor: Colors.yellow,
                                msg:
                                    "Type a group's name in order to search...",
                                title: "Alert!");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    getGroups();
                  },
                  child: StreamBuilder(
                    stream: groupList?.stream,
                    builder: (BuildContext context, snapshot) {
                      if (groupList?.value == null ||
                          groupList?.isEmpty == true) {
                        return shimmerFeedLoading();
                      }

                      // if (snapshot.hasError) {
                      //   return Container(
                      //     color: Colors.white,
                      //     alignment: Alignment.center,
                      //     child: customText(title: "${snapshot.error}"),
                      //   );
                      // }

                      if (isSearching
                          ? searchedGroups?.isEmpty == true
                          : groupList?.isEmpty == true) {
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                            alignment: Alignment.center,
                            child: customText(
                                title: isSearching
                                    ? "No group(s) found by this name"
                                    : "No groups found"),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: groupList?.length ?? 0,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (groupController.searchTEC.text.isNotEmpty ==
                              true) {
                            if (groupList?[index].name?.toLowerCase().contains(
                                    groupController.searchTEC.text
                                        .toLowerCase()) ==
                                true) {
                              return listItem(index, setState);
                            }
                            return SizedBox();
                          } else {
                            return listItem(index, setState);
                          }
                        },
                      );

                      // return CustomScrollView(
                      //   shrinkWrap: false,
                      //   slivers: [
                      //     SliverList(
                      //       delegate: SliverChildBuilderDelegate(
                      //         (BuildContext context, int index) {
                      //           if (groupController.searchTEC.text.isNotEmpty == true) {
                      //             if (groupList?[index].name?.toLowerCase().contains(groupController.searchTEC.text.toLowerCase()) == true) {
                      //               return listItem(index, setState);
                      //             }
                      //             return SizedBox();
                      //           } else {
                      //             return listItem(index, setState);
                      //           }
                      //         },
                      //         childCount: /*(isSearching ? searchedGroups?.length : */ groupList?.length ?? 0, // 1000 list items
                      //       ),
                      //     ),
                      //   ],
                      // );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            onAddGroup(groupController);
          },
          label: Text(
            "New Group",
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          )),
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
    String? ownerId =
        (isSearching ? searchedGroups : groupList)![index].ownerId;
    return InkWell(
      onTap: () {
        if ((isSearching ? searchedGroups : groupList)?[index] != null) {
          Get.to(() => GroupDetailsScreen(
              groupId:
                  (isSearching ? searchedGroups : groupList)?[index].groupId ??
                      ""));
        }
        // pushOnlyTo(widget: GroupDetailsScreen(group: (isSearching ? searchedGroups : groupList)![index]));
      },
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
                          imageUrl: "${groupList?[index].profilePic}",
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
                        text: groupList?[index].name?.trim(),
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 15.0,
                          height: 1.8,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "\n${groupList?[index].createdOn}",
                            style: GoogleFonts.montserrat(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Group>?> reloadGroups(GroupController c) async {
    // groupList?.value = groupList ?? [];
    // if (isSearching) {
    //   if (searchedGroups!.isNotEmpty) searchedGroups!.clear();
    //   for (int i = 0; i < groupList!.length; i++) {
    //     if (groupList![i].name!.toLowerCase().contains(
    //           c.searchTEC.text.trim().toLowerCase(),
    //         )) {
    //       searchedGroups!.add(groupList![i]);
    //     }
    //   }
    // } else {}
    //
    // return isSearching ? searchedGroups : groupList;
  }

  void onAddGroup(GroupController c) {
    c.groupTypeTEC.text = c.groupTypes[0].groupCode;
    RxString groupType = c.groupTypes[0].groupCode.obs;

    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          child: Container(
            // padding: EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Image.asset(
                  AppImages.logoImage,
                  height: 50,
                  width: 50,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Create Groups",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                commonTextField(
                  readOnly: false,
                  hint: 'Enter Group Name',
                  isLabelFloating: false,
                  inputType: TextInputType.text,
                  controller: c.groupNameTEC,
                  borderColor: Colors.black,
                  baseColor: Colors.black,
                  isLastField: true,
                  obscureText: false,
                ).paddingSymmetric(horizontal: 20),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                      right: 10,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Group Type",
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    )),
                StreamBuilder(
                    stream: groupType.stream,
                    builder: (context, snapshot) {
                      return Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                                value: "O",
                                groupValue: groupType.value,
                                onChanged: (value) {
                                  groupType.value = "O";
                                },
                                // contentPadding: EdgeInsets.zero,
                                title: Text("Public")),
                          ),
                          // Text("Public"),
                          Expanded(
                            child: RadioListTile(
                                value: "P",
                                groupValue: groupType.value,
                                onChanged: (value) {
                                  groupType.value = "P";
                                },
                                // contentPadding: EdgeInsets.zero,
                                title: Text("Private")),
                          ),
                          // Text("Private"),
                        ],
                      );
                    }),
                // StatefulBuilder(
                //   builder: (context, setState) {
                //     return Container(
                //       alignment: Alignment.centerLeft,
                //       margin: const EdgeInsets.only(
                //         bottom: 10,
                //       ),
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: List<Widget>.generate(c.genders.length,
                //             (int index) {
                //           return Container(
                //             width: MediaQuery.of(context).size.width / 2,
                //             padding: const EdgeInsets.only(
                //               top: 5,
                //               bottom: 5,
                //             ),
                //             child: buildSelectionTile(
                //                 isSelected: c.groupTypes[index].isSelected,
                //                 optionName: c.groupTypes[index].groupState,
                //                 onChange: (isSelected) {
                //                   debugPrint('index $index');
                //                   debugPrint('isSelected $isSelected');
                //
                //                   for (int i = 0;
                //                       i < c.groupTypes.length;
                //                       i++) {
                //                     c.groupTypes[i].isSelected = false;
                //                   }
                //                   c.groupTypes[index].isSelected = isSelected;
                //
                //                   for (int i = 0;
                //                       i < c.groupTypes.length;
                //                       i++) {
                //                     if (c.groupTypes[i].isSelected) {
                //                       c.groupTypeTEC.text =
                //                           c.groupTypes[i].groupCode;
                //                     }
                //                     debugPrint(
                //                         'index $i; c.groupTypes[index].isSelected ${c.groupTypes[i].isSelected}');
                //                   }
                //
                //                   //debugPrint('c.genders[index].isSelected ${c.genders[index].isSelected}');
                //
                //                   setState(() {});
                //                 },
                //                 isRadio: true),
                //           );
                //         }).toList(),
                //       ),
                //     );
                //   },
                // ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    // color: Colors.white,
                    color: Theme.of(Get.context!).primaryColor,
                  ),
                  // width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      if (c.groupNameTEC.text.trim().isNotEmpty) {
                        Get.back();
                        createNewGroup(
                                groupName: c.groupNameTEC.text.trim(),
                                groupType: groupType.value)
                            .then((value) => setState(() {}));
                      } else {
                        snack(
                            icon: Icons.report_problem,
                            iconColor: Colors.yellow,
                            msg:
                                "Please first enter the Name of the group you want to create",
                            title: "Alert!");
                      }
                    },
                    child: Text(
                      "Create".toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                /*SizedBox(
                  height: 3,
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  height: 40,
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      if (c.donationAmtTEC.text.trim().isNotEmpty) {
                        Get.back();
                        goToProcessTransaction(
                            price: c.donationAmtTEC.text.trim());
                      } else {
                        snack(
                            msg:
                                "Please first enter the intended amount you want to donate",
                            title: "Alert!");
                      }
                    },
                    child: Text(
                      "Monthly Payment",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),*/
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
