import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/dash_board_screen.dart';
import 'package:wghdfm_java/utils/firebase_config.dart';
import 'package:wghdfm_java/utils/lists.dart';

Widget buildDrawer() {
  final DashBoardController controller = Get.find<DashBoardController>();
  final appConfigController = Get.put(AppConfigController());

  return Container(
      height: Get.height,
      width: Get.width,
      // color: Colors.white.withOpacity(0.5),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                // padding: const EdgeInsets.only(left: 30, right: 30),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Image.asset(
                      "assets/logo.png",
                      height: 60,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "What God Has Done For Me",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                )),
            // const SizedBox(height: ),
            StreamBuilder(
                stream: appConfigController.changes.stream,
                builder: (context, snapshot) {
                  return ListView.builder(
                    key: itemsDrawerKey,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      ///For Hide Friends Tab..
                      if (index == 3) {
                        return SizedBox();
                      }
                      // if (index == 4 && !appConfigController.chatPage) {
                      //   return SizedBox();
                      // }
                      if (index == 5 && !appConfigController.biblePage) {
                        return SizedBox();
                      }
                      if (index == 6 && !appConfigController.newsPage) {
                        return SizedBox();
                      }
                      if (index == 7 && !appConfigController.dailyBreadPage) {
                        return SizedBox();
                      }
                      if (index == 8 && !appConfigController.bookPage) {
                        return SizedBox();
                      }
                      if (index == 9 && !appConfigController.donatePage) {
                        return SizedBox();
                      }

                      return buildDrawerTile(
                        title: drawerHeaderTitles[index],
                        icon: drawerHeaderIcons[index],
                        onClick: () {
                          controller.onDrawerTileClick(index);
                        },
                      );
                    },
                    itemCount: drawerHeaderTitles.length,
                  );
                }),
          ],
        ),
      ));
}
