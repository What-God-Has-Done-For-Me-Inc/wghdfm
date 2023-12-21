import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/edit_post_screen.dart';
import 'package:wghdfm_java/screen/dashboard/dashboard_api/edit_post_api.dart';

void editStatusBottomSheet(
  PostModelFeed feed, {
  VoidCallback? onEdit,
}) {
  final DashBoardController c = Get.find<DashBoardController>();

  bool isMediaPost = (feed.media != null);

  bool areFieldsFilled() {
    bool isValid = true;
    List<String> errorList = [];
    if (c.statusTEC.text.trim().isEmpty) {
      isValid = false;
      errorList.add(
          "To post you atleast need to type in your status first. Please do so and try again.");
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

  c.statusTEC.text = feed.status!;
  c.ytUrlTEC.text = feed.url!;
  customModalBottomSheet(
      widget: isMediaPost == true
          ? feed.id != null
              ? MediaScreen(
                  postId: feed.id ?? "",
                  feed: feed,
                )
              : SizedBox()
          : ListView(shrinkWrap: false, children: [
              Container(
                padding: EdgeInsets.zero,
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).primaryColor,
                    // color: Colors.grey,

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
                        height: 3,
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
                            if (areFieldsFilled()) {
                              Get.back();
                              editPost(feed.id!, c.statusTEC.text.trim(),
                                      c.ytUrlTEC.text.trim())
                                  .then((_) {
                                onEdit!();
                              });
                            }
                          },
                          child: Text(
                            "UPDATE",
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
              )
            ])
      // widget: ListView(shrinkWrap: false, children: [
      //   Container(
      //     padding: EdgeInsets.zero,
      //     color: Colors.transparent,
      //     child: Container(
      //       decoration: BoxDecoration(
      //         color: Theme.of(Get.context!).primaryColor,
      //         borderRadius: BorderRadius.circular(10),
      //       ),
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         mainAxisSize: MainAxisSize.min,
      //         children: <Widget>[
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           Container(
      //             padding: const EdgeInsets.only(
      //               left: 5,
      //               right: 5,
      //             ),
      //             child: commonTextField(
      //               readOnly: false,
      //               hint: 'Enter Your Status Here',
      //               isLabelFloating: false,
      //               inputType: TextInputType.multiline,
      //               controller: c.statusTEC,
      //               borderColor: Theme.of(Get.context!).backgroundColor,
      //               baseColor: Theme.of(Get.context!).backgroundColor,
      //               isLastField: false,
      //               obscureText: false,
      //             ),
      //           ),
      //           const SizedBox(
      //             height: 3,
      //           ),
      //           Container(
      //             padding: const EdgeInsets.only(
      //               left: 5,
      //               right: 5,
      //             ),
      //             child: commonTextField(
      //               readOnly: false,
      //               hint: 'Paste your youtube url here (optional)',
      //               isLabelFloating: false,
      //               inputType: TextInputType.url,
      //               maxLines: null,
      //               controller: c.ytUrlTEC,
      //               borderColor: Theme.of(Get.context!).backgroundColor,
      //               baseColor: Theme.of(Get.context!).backgroundColor,
      //               isLastField: true,
      //               obscureText: false,
      //             ),
      //           ),
      //           const SizedBox(
      //             height: 3,
      //           ),
      //           Container(
      //             padding: const EdgeInsets.only(
      //               left: 10,
      //               right: 10,
      //             ),
      //             height: 40,
      //             width: Get.width,
      //             child: ElevatedButton(
      //               onPressed: () {
      //                 if (areFieldsFilled()) {
      //                   Get.back();
      //                   editPost(feed.id!, c.statusTEC.text.trim(), c.ytUrlTEC.text.trim()).then((_) {
      //                     onEdit!();
      //                   });
      //                 }
      //               },
      //               child: Text(
      //                 "UPDATE",
      //                 textAlign: TextAlign.center,
      //                 style: GoogleFonts.montserrat(
      //                   color: Colors.white,
      //                   fontSize: 18,
      //                 ),
      //               ),
      //             ),
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //         ],
      //       ),
      //     ),
      //   )
      // ]),
      );
}
