import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wghdfm_java/common/background_widget.dart';
import 'package:wghdfm_java/modules/auth_module/controller/auth_controller.dart';
import 'package:wghdfm_java/modules/auth_module/views/sign_up_screen.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/page_res.dart';
import 'package:wghdfm_java/utils/scale_ui_utils.dart';

import '../../../common/commons.dart';
import '../../../utils/validation_utils.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final authController = Get.put(AuthController());
  final formKey = GlobalKey<FormState>();
  final emailTEC = TextEditingController();
  final passwordTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: backGroundWidget(
        widget: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
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
                                color: Colors.blue, fontSize: 16.0.sf),
                          ),
                          Text(
                            "God ",
                            style: GoogleFonts.montserrat(
                                color: Colors.red, fontSize: 16.0.sf),
                          ),
                          Text(
                            "Has ",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue, fontSize: 16.0.sf),
                          ),
                          Text(
                            "Done ",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue, fontSize: 16.0.sf),
                          ),
                          Text(
                            "For ",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue, fontSize: 16.0.sf),
                          ),
                          Text(
                            "Me",
                            style: GoogleFonts.montserrat(
                                color: Colors.blue, fontSize: 16.0.sf),
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
                      validator: (String? value) {
                        return (value != null && !value.isEmail)
                            ? "Please enter valid email"
                            : null;
                      },
                      onChanged: (String? value) {
                        if (value != null) {
                          AppMethods.showLog("?>>> VALUE $value");
                          value.removeAllWhitespace;
                          AppMethods.showLog("?>>> VALUE $value");
                        }
                      },
                      isLabelFloating: false,
                      controller: emailTEC,
                      borderColor: Colors.white,
                      baseColor: Colors.white,
                      maxLines: 1,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: commonTextField(
                      readOnly: false,
                      hint: 'Password',
                      isLabelFloating: false,
                      validator: (String? value) {
                        return (value != null &&
                                (!validateIsFieldFilled(value)))
                            ? "Please enter valid password"
                            : null;
                      },
                      controller: passwordTEC,
                      borderColor: Colors.white,
                      baseColor: Colors.white,
                      isLastField: true,
                      obscureText: true,
                    ),
                  ),
                  Container(
                    width: Get.width,
                    height: 50,
                    padding: const EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: () {
                        emailTEC.text.trim();
                        passwordTEC.text.trim();
                     
                        if (formKey.currentState!.validate()) {
                          authController.signIn(
                            email: emailTEC.text.trim(),
                            password: passwordTEC.text.trim(),
                          );
                        }
                      },
                      child: Text(
                        "Login".toUpperCase(),
                        style: GoogleFonts.openSans(
                            color: Colors.white, fontSize: 16.0.sf),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: Get.width,
                    height: 50,
                    padding: EdgeInsets.zero,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(PageRes.recoverPassword);
                      },
                      child: Text(
                        "Forgot Password? Click Here",
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 13.0.sf,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: Get.width,
                    height: 50,
                    padding: const EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => SignUpScreen());
                        // pushTransitionedOnlyTo(widget: SignUpScreen());
                      },
                      child: Text(
                        "Signup".toUpperCase(),
                        style: GoogleFonts.openSans(
                            color: Colors.white, fontSize: 16.0.sf),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // FittedBox(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       const Text(
                  //         "You are agreeing to all ",
                  //         style: TextStyle(color: Colors.orange, fontSize: 14),
                  //       ),
                  //       InkWell(
                  //           onTap: () async {
                  //             await launch(
                  //               "https://whatgodhasdoneforme.com/terms-condition",
                  //             );
                  //           },
                  //           child: const Text(
                  //             "terms & conditions",
                  //             style: TextStyle(color: Colors.orange, fontSize: 14, decoration: TextDecoration.underline),
                  //           )),
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
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
    );
  }
}
