import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/background_widget.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/modules/recover_password/controller/recover_password_controller.dart';
import 'package:wghdfm_java/utils/app_colors.dart';
import 'package:wghdfm_java/utils/button.dart';

class RecoverPasswordScreen extends StatelessWidget {
  RecoverPasswordScreen({Key? key}) : super(key: key);
  final RecoverPasswordController r = Get.put(RecoverPasswordController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecoverPasswordController>(
      init: RecoverPasswordController(),
      global: false,
      builder: (c) => SafeArea(
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
          ),
          body: backGroundWidget(
            widget: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Image.asset("assets/drawable/logo.png", scale: 1.5),
                  SizedBox(height: Get.height * 0.04),
                  Container(
                    constraints: BoxConstraints(maxWidth: Get.width),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: FittedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "What ",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "God ",
                            style: GoogleFonts.montserrat(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Has ",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Done ",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "For ",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Me",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  commonTextField(
                    readOnly: false,
                    hint: 'Email',
                    isLabelFloating: false,
                    controller: r.emailTEC,
                    borderColor: Colors.white,
                    baseColor: AppColors.blackColor,
                    isLastField: true,
                    maxLines: 1,
                  ),
                  customButton(
                      title: "RECOVER PASSWORD",
                      onTap: () {
                        if (r.areRecoveryFieldValid()) {
                          r.recovery(
                            userEmail: r.emailTEC.text.trim(),
                          );
                        }
                      }),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            width: Get.width,
            color: Colors.transparent,
            height: 50,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(5),
            child: Text(
              "whatgodhasdoneforme@yahoo.com",
              style:
                  GoogleFonts.montserrat(color: AppColors.black, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
