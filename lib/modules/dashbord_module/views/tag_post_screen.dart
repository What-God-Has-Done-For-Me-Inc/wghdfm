import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/utils/app_binding.dart';
import 'package:wghdfm_java/utils/shimmer_utils.dart';

class TagUserScreen extends StatefulWidget {
  const TagUserScreen({Key? key}) : super(key: key);

  @override
  State<TagUserScreen> createState() => _TagUserScreenState();
}

class _TagUserScreenState extends State<TagUserScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Friends '),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: StatefulBuilder(
        builder: (context, StateSetter setStateSearch) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15),
              Container(
                color: Colors.white,
                child: commonTextField(
                    baseColor: Colors.black,
                    borderColor: Colors.black,
                    controller: searchController,
                    errorColor: Colors.white,
                    hint: "Search Friends",
                    onChanged: (String? value) {
                      setStateSearch(() {});
                    }),
              ),
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
              Expanded(
                child: StreamBuilder(
                  stream: kDashboardController.friendsModel.stream,
                  builder: (context, snapshot) => ListView.builder(
                    itemCount: kDashboardController.friendsModel.value.data?.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      String name = "${kDashboardController.friendsModel.value.data?[index]?.firstname}${kDashboardController.friendsModel.value.data?[index]?.lastname}";

                      if (searchController.text.isNotEmpty) {
                        print("::: NAME IS $name");
                        print("::: Contain IS ${name.toLowerCase().contains(searchController.text.toLowerCase())}");
                        // if (searchController.text.toLowerCase().contains(name.toLowerCase())) {
                        if (name.removeAllWhitespace.toLowerCase().contains(searchController.text.removeAllWhitespace.toLowerCase())) {
                          return StreamBuilder(
                              stream: kDashboardController.friendsModel.value.data?[index]?.isSelected.stream,
                              builder: (context, snapshot) {
                                return CheckboxListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  tileColor: Colors.white,
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                  value: kDashboardController.friendsModel.value.data?[index]?.isSelected.value,
                                  onChanged: (value) {
                                    kDashboardController.friendsModel.value.data?[index]?.isSelected.toggle();
                                    // if (value == true) {
                                    //   taggedUsers.add({
                                    //     'id': "${kDashboardController.friendsModel.value.data?[index]?.userId}",
                                    //     "name":
                                    //     "${kDashboardController.friendsModel.value.data?[index]?.firstname} ${kDashboardController.friendsModel.value.data?[index]?.lastname}"
                                    //   });
                                    // } else {
                                    //   Map usr = {
                                    //     "id": "${kDashboardController.friendsModel.value.data?[index]?.userId}",
                                    //     "name":
                                    //     "${kDashboardController.friendsModel.value.data?[index]?.firstname} ${kDashboardController.friendsModel.value.data?[index]?.lastname}"
                                    //   };
                                    //   taggedUsers.remove(usr);
                                    // }
                                  },
                                  title:
                                      Text("${kDashboardController.friendsModel.value.data?[index]?.firstname} ${kDashboardController.friendsModel.value.data?[index]?.lastname}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                  secondary: ClipOval(
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
                                                fit: BoxFit.contain,
                                                imageUrl: "https://wghdfm.s3.amazonaws.com/medium/${kDashboardController.friendsModel.value.data?[index]?.img}" ?? "",
                                                placeholder: (context, url) => const CircularProgressIndicator(),
                                                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            alignment: Alignment.center,
                                            fit: BoxFit.fill,
                                            imageUrl: "https://wghdfm.s3.amazonaws.com/medium/${kDashboardController.friendsModel.value.data?[index]?.img}" ?? "",
                                            placeholder: (context, url) => Container(
                                              padding: const EdgeInsets.all(3),
                                              child: shimmerMeUp(CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                                              )),
                                            ),
                                            errorWidget: (context, url, error) {
                                              print("--- URL Is ${url}");
                                              return const Icon(Icons.error, color: Colors.white);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ).paddingOnly(bottom: 3);
                              });
                        } else {
                          return SizedBox();
                        }
                      } else {
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
                                  // if (value == true) {
                                  //   taggedUsers.add({
                                  //     'id': "${kDashboardController.friendsModel.value.data?[index]?.userId}",
                                  //     "name":
                                  //     "${kDashboardController.friendsModel.value.data?[index]?.firstname} ${kDashboardController.friendsModel.value.data?[index]?.lastname}"
                                  //   });
                                  // } else {
                                  //   Map usr = {
                                  //     "id": "${kDashboardController.friendsModel.value.data?[index]?.userId}",
                                  //     "name":
                                  //     "${kDashboardController.friendsModel.value.data?[index]?.firstname} ${kDashboardController.friendsModel.value.data?[index]?.lastname}"
                                  //   };
                                  //   taggedUsers.remove(usr);
                                  // }
                                },
                                title: Text("${kDashboardController.friendsModel.value.data?[index]?.firstname} ${kDashboardController.friendsModel.value.data?[index]?.lastname}",
                                    style: TextStyle(color: Colors.black)),
                                secondary: ClipOval(
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
                                              fit: BoxFit.contain,
                                              imageUrl: "https://wghdfm.s3.amazonaws.com/medium/${kDashboardController.friendsModel.value.data?[index]?.img}" ?? "",
                                              placeholder: (context, url) => const CircularProgressIndicator(),
                                              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          alignment: Alignment.center,
                                          fit: BoxFit.fill,
                                          imageUrl: "https://wghdfm.s3.amazonaws.com/medium/${kDashboardController.friendsModel.value.data?[index]?.img}" ?? "",
                                          placeholder: (context, url) => Container(
                                            padding: const EdgeInsets.all(3),
                                            child: shimmerMeUp(CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                                            )),
                                          ),
                                          errorWidget: (context, url, error) {
                                            print("--- URL Is ${url}");
                                            return const Icon(Icons.error, color: Colors.white);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ).paddingOnly(bottom: 3);
                            });
                      }
                    },
                  ),
                ),
              ),

              /*Row(
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
              )*/
            ],
          );
        },
      ),
    );
  }
}
