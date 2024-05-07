import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/post_status_api.dart';
import 'package:wghdfm_java/utils/app_binding.dart';
import 'package:wghdfm_java/utils/app_texts.dart';

void postStatusBottomSheet(
  DashBoardController c, {
  VoidCallback? onPost,
}) {
  if (c.statusTEC.text.trim().isNotEmpty) {
    c.statusTEC.text = "";
  }
  if (c.ytUrlTEC.text.trim().isNotEmpty) {
    c.ytUrlTEC.text = "";
  }
  bool areFieldsFilled() {
    bool isValid = true;
    List<String> errorList = [];
    if (c.statusTEC.text.trim().isEmpty) {
      isValid = false;
      errorList.add(
          "To post you at-least need to type in your status first. Please do so and try again.");
    }

    if (errorList.isNotEmpty) {
      snack(
        msg: errorList[0],
        title: "Alert!",
        icon: Icons.report_problem,
        iconColor: Colors.yellow,
      );
    }

    return isValid;
  }

  Get.dialog(Dialog(
    child: StreamBuilder(
        stream: null,
        builder: (context, snapshot) {
          RxBool isTagPost = false.obs;
          return StreamBuilder(
              stream: isTagPost.stream,
              builder: (context, snapshot) {
                return Container(
                  padding: EdgeInsets.zero,
                  color: Colors.transparent,
                  child: Container(
                    // height: Get.mediaQuery.size.height,
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: commonTextField(
                            readOnly: false,
                            hint: 'Enter Your Status Here',
                            isLabelFloating: false,
                            inputType: TextInputType.multiline,
                            controller: c.statusTEC,
                            borderColor: Theme.of(Get.context!).backgroundColor,
                            baseColor: Theme.of(Get.context!).backgroundColor,
                            isLastField: false,
                            obscureText: false,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: commonTextField(
                            readOnly: false,
                            hint: 'Paste your youtube url here (optional)',
                            isLabelFloating: false,
                            inputType: TextInputType.url,
                            maxLines: null,
                            controller: c.ytUrlTEC,
                            borderColor: Theme.of(Get.context!).backgroundColor,
                            baseColor: Theme.of(Get.context!).backgroundColor,
                            isLastField: true,
                            obscureText: false,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //   children: [
                        // Text("Tag users", style: TextStyle(color: Colors.white, fontSize: 18)),

                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "You posting something by agreeing",
                              style: TextStyle(color: Colors.red),
                            ),
                            InkWell(
                                onTap: () {
                                  launchUrlString(
                                      "https://whatgodhasdoneforme.com/eula");
                                },
                                child: const Text(
                                  " EULA",
                                  style: TextStyle(
                                      color: Colors.red,
                                      decoration: TextDecoration.underline),
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        InkWell(
                            onTap: () {
                              isTagPost.toggle();
                            },
                            child: Icon(Icons.sell_outlined,
                                color: Colors.white, size: 30)),
                        //   ],
                        // ),
                        if (isTagPost.value)
                          Container(
                            height: 200,
                            child: ListView.builder(
                              itemCount: kDashboardController
                                  .friendsModel.value.data?.length,
                              itemBuilder: (context, index) {
                                return StreamBuilder(
                                    stream: kDashboardController.friendsModel
                                        .value.data?[index]?.isSelected.stream,
                                    builder: (context, snapshot) {
                                      return CheckboxListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        tileColor: Colors.white,
                                        activeColor: Colors.white,
                                        checkColor: Colors.black,
                                        value: kDashboardController
                                            .friendsModel
                                            .value
                                            .data?[index]
                                            ?.isSelected
                                            .value,
                                        onChanged: (value) {
                                          kDashboardController.friendsModel
                                              .value.data?[index]?.isSelected
                                              .toggle();
                                        },
                                        title: Text(
                                            "${kDashboardController.friendsModel.value.data?[index]?.firstname} ${kDashboardController.friendsModel.value.data?[index]?.lastname}",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ).paddingOnly(bottom: 3);
                                    });
                              },
                            ),
                          ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          height: 40,
                          width: Get.width,
                          child: ElevatedButton(
                            onPressed: () {
                              String taggedUser = "";
                              kDashboardController.friendsModel.value.data
                                  ?.forEach((element) {
                                if (element?.isSelected.value == true) {
                                  taggedUser =
                                      "${taggedUser}|${element?.userId}";
                                }
                              });
                              print("------ ${taggedUser}");
                              if (areFieldsFilled()) {
                                Get.back();
                                postStatus(c.statusTEC.text.trim(),
                                        c.ytUrlTEC.text.trim(), taggedUser)
                                    .then((_) {
                                  onPost!();
                                });
                              }
                            },
                            child: Text(
                              "POST",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              });
        }),
  ));
}
