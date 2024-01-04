import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wghdfm_java/common/background_widget.dart';
import 'package:wghdfm_java/modules/auth_module/controller/auth_controller.dart';
import 'package:wghdfm_java/modules/auth_module/views/sign_up_screen.dart';
import 'package:wghdfm_java/utils/app_colors.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/button.dart';
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
                    baseColor: AppColors.blackColor,
                    maxLines: 1,
                  ),
                  commonTextField(
                    readOnly: false,
                    hint: 'Password',
                    isLabelFloating: false,
                    validator: (String? value) {
                      return (value != null && (!validateIsFieldFilled(value)))
                          ? "Please enter valid password"
                          : null;
                    },
                    controller: passwordTEC,
                    borderColor: Colors.white,
                    baseColor: AppColors.blackColor,
                    isLastField: true,
                    obscureText: true,
                  ),
                  SizedBox(height: Get.height * 0.04),
                  customButton(
                      title: "Log In",
                      onTap: () {
                        emailTEC.text.trim();
                        passwordTEC.text.trim();

                        if (formKey.currentState!.validate()) {
                          authController.signIn(
                            email: emailTEC.text.trim(),
                            password: passwordTEC.text.trim(),
                          );
                        }
                      }),
                  SizedBox(height: Get.height * 0.02),
                  Row(
                    children: [
                      Text.rich(TextSpan(
                          text: 'Forgot Password?',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.primery,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed(PageRes.recoverPassword);
                            })),
                    ],
                  ),
                  SizedBox(height: Get.height * 0.04),
                  customButton(
                      title: "Sign Up",
                      onTap: () {
                        Get.to(() => const SignUpScreen());
                      }),
                  SizedBox(height: Get.height * 0.02),
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
