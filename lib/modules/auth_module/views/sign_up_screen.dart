import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wghdfm_java/common/background_widget.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/modules/auth_module/controller/auth_controller.dart';
import 'package:wghdfm_java/modules/auth_module/views/otp_screen.dart';
import 'package:wghdfm_java/utils/app_colors.dart';
import 'package:wghdfm_java/utils/button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  RxBool agree = false.obs;
  final authController = Get.put(AuthController());

  final firstNameTEC = TextEditingController(),
      lastNameTEC = TextEditingController(),
      emailTEC = TextEditingController(),
      passwordTEC = TextEditingController(),
      confirmPasswordTEC = TextEditingController(),
      genderTypeTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: backGroundWidget(
          widget: SingleChildScrollView(
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
                    hint: 'First Name',
                    isLabelFloating: false,
                    validator: (String? value) {
                      return (value != null && value.isEmpty)
                          ? "Please enter first name"
                          : null;
                    },
                    controller: firstNameTEC,
                    borderColor: Colors.white,
                    baseColor: AppColors.blackColor,
                    maxLines: 1,
                  ),
                  commonTextField(
                    readOnly: false,
                    hint: 'Last Name',
                    validator: (String? value) {
                      return (value != null && value.isEmpty)
                          ? "Please enter last name"
                          : null;
                    },
                    isLabelFloating: false,
                    controller: lastNameTEC,
                    borderColor: Colors.white,
                    baseColor: AppColors.blackColor,
                    maxLines: 1,
                  ),
                  commonTextField(
                    readOnly: false,
                    hint: 'Email',
                    validator: (String? value) {
                      return (value != null && !value.isEmail)
                          ? "Please enter valid email"
                          : null;
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
                    validator: (String? value) {
                      return (value != null && value.isEmpty)
                          ? "Please enter password"
                          : null;
                    },
                    isLabelFloating: false,
                    controller: passwordTEC,
                    borderColor: Colors.white,
                    baseColor: AppColors.blackColor,
                    obscureText: true,
                  ),
                  commonTextField(
                    readOnly: false,
                    hint: 'Confirm Password',
                    validator: (String? value) {
                      // return (value != null && value.isEmpty && passwordTEC.text != value) ? "Please enter valid password" : null;
                      return (value != null && value.isEmpty ||
                              (value != passwordTEC.text) == true)
                          ? "Please enter valid password"
                          : null;
                    },
                    isLabelFloating: false,
                    controller: confirmPasswordTEC,
                    borderColor: Colors.white,
                    baseColor: AppColors.blackColor,
                    isLastField: true,
                    obscureText: true,
                  ),
                  FittedBox(
                    child: StreamBuilder(
                        stream: agree.stream,
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              Checkbox(
                                value: agree.value,
                                onChanged: (value) {
                                  agree.value = value ?? false;
                                },
                                side: const BorderSide(color: AppColors.black),
                              ),
                              RichText(
                                text: TextSpan(
                                    style:
                                        TextStyle(color: AppColors.blackColor),
                                    text: "By signup, I agree to the ",
                                    children: [
                                      TextSpan(
                                          text: " Term and Conditon",
                                          style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w700),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                              launch(
                                                  "https://whatgodhasdoneforme.com/terms-condition");
                                            }),
                                    ]),
                              )
                            ],
                          );
                        }),
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     const Text(
                    //       "You are agreeing to all ",
                    //       style: TextStyle(color: Colors.orange, fontSize: 14),
                    //     ),
                    //     InkWell(
                    //         onTap: () async {
                    //           await launch(
                    //             "https://whatgodhasdoneforme.com/terms-condition",
                    //           );
                    //         },
                    //         child: const Text(
                    //           "terms & conditions",
                    //           style: TextStyle(color: Colors.orange, fontSize: 14, decoration: TextDecoration.underline),
                    //         )),
                    //   ],
                    // ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  customButton(
                      title: "Get OTP",
                      onTap: () {
                        firstNameTEC.text.trim();
                        lastNameTEC.text.trim();
                        emailTEC.text.trim();
                        passwordTEC.text.trim();
                        genderTypeTEC.text.trim();

                        if (formKey.currentState!.validate()) {
                          if (agree.isFalse) {
                            snack(
                                title: "Ohh",
                                msg: "Please agree with term and condition.");
                          } else {
                            authController.sendOpt(
                              firstName: firstNameTEC.text.trim(),
                              lastName: lastNameTEC.text.trim(),
                              email: emailTEC.text.trim(),
                              password: passwordTEC.text.trim(),
                              cPassword: confirmPasswordTEC.text.trim(),
                              gender: 'M',
                            );
                          }
                        }
                      }),
                ],
              ).paddingAll(15),
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
            style: GoogleFonts.montserrat(color: AppColors.black, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
