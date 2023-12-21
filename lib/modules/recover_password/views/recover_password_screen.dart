import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/background_widget.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/modules/recover_password/controller/recover_password_controller.dart';

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
                                color: Colors.blue, fontSize: 16),
                          ),
                          Text(
                            "God ",
                            style: GoogleFonts.montserrat(
                                color: Colors.red, fontSize: 16),
                          ),
                          Text(
                            "Has ",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue, fontSize: 16),
                          ),
                          Text(
                            "Done ",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue, fontSize: 16),
                          ),
                          Text(
                            "For ",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue, fontSize: 16),
                          ),
                          Text(
                            "Me",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: commonTextField(
                      readOnly: false,
                      hint: 'Email',
                      isLabelFloating: false,
                      controller: r.emailTEC,
                      borderColor: Colors.white,
                      baseColor: Colors.white,
                      isLastField: true,
                      maxLines: 1,
                    ),
                  ),
                  Container(
                    width: Get.width,
                    height: 50,
                    padding: const EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: () {
                        //Get.to(DraftLoginUI());
                        if (r.areRecoveryFieldValid()) {
                          r.recovery(
                            userEmail: r.emailTEC.text.trim(),
                          );
                        }
                      },
                      child: Text(
                        "Recover Password".toUpperCase(),
                        style: GoogleFonts.openSans(
                            color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
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
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
