import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/profile_module/view/profile_screen.dart';
import 'package:wghdfm_java/utils/app_binding.dart';
import 'package:wghdfm_java/utils/app_images.dart';

import '../../../common/commons.dart';
import '../../profile_module/view/someones_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final dashBoardController = Get.put(DashBoardController());

  final nameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    dashBoardController.searchUsers(name: "", isShowProcess: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        appBar: AppBar(
          title: Text(
            'Search Users',
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              // color: Colors.white,
              child: commonTextField(
                borderColor: Colors.black,
                baseColor: Colors.black,
                hint: "Enter user's name here",
                controller: nameController,
                maxLines: 1,
                onChanged: (String? value) async {
                  print(">> VALUE IS ${value}");
                  if (value != null) {
                    await dashBoardController.searchUsers(name: value);
                  }
                },
                leading: Icon(Icons.search_outlined, size: 26),
              ),
            ),
            StreamBuilder(
                stream: dashBoardController.usersList.stream,
                builder: (context, snapshot) {
                  if (dashBoardController.usersList.isNotEmpty) {
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        cacheExtent: 5000,
                        itemCount: dashBoardController.usersList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if ("${dashBoardController.usersList[index].userId}" != userId) {
                                Get.to(() => SomeoneProfileScreen(profileID: "${dashBoardController.usersList[index].userId}"));
                              } else {
                                Get.to(() => const ProfileScreen());
                              }
                            },
                            child: Card(
                              child: Container(
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
                                            imageUrl: "${dashBoardController.usersList[index].profileImg}",
                                            // placeholder: (context, url) {
                                            //   return Image.asset(
                                            //     "assets/logo.png",
                                            //     scale: 5.0,
                                            //   );
                                            // },
                                            progressIndicatorBuilder: (BuildContext, String, DownloadProgress) {
                                              return const Center(child: CupertinoActivityIndicator());
                                            },
                                            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
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
                                          text: "${dashBoardController.usersList[index].firstname}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                            height: 1.8,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: " ${dashBoardController.usersList[index].lastname} ",
                                              style: const TextStyle(
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
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Expanded(
                      child: Center(
                        child: Lottie.asset(
                          AppImages.searchJson,
                          repeat: true,
                        ),
                      ),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}
