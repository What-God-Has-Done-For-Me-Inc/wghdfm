import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:wghdfm_java/common/background_widget.dart';
import 'package:wghdfm_java/modules/auth_module/controller/auth_controller.dart';
import 'package:wghdfm_java/utils/app_colors.dart';
import 'package:wghdfm_java/utils/button.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen(
      {Key? key,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.password,
      required this.cPasssword})
      : super(key: key);
  final String firstName, lastName, email, password, cPasssword;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool _isValid = false;
  final pinController = TextEditingController();
  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: backGroundWidget(
        widget: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(child: _buildForm()),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        //const CustomImage(path: KImages.forgotIcon),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Enter Code',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: Get.height * 0.02),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'We sent a code via Email to',
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.email,
            textAlign: TextAlign.left,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.black),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Note: Please check your email and spam  to activate your account.',
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor),
          ),
        ),
        const SizedBox(height: 22),
        Pinput(
          controller: pinController,
          defaultPinTheme: PinTheme(
            height: 52,
            width: 52,
            textStyle: const TextStyle(
                fontSize: 26,
                color: AppColors.black,
                fontWeight: FontWeight.w600),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.blackColor),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          autofocus: true,
          keyboardType: TextInputType.number,
          length: 6,
          validator: (String? s) {
            if (s == null || s.isEmpty) return 'Enter OTP';
            return null;
          },
          onChanged: (String s) {
            if (s.length == 6) {
              _isValid = true;
            } else {
              _isValid = false;
            }
            setState(() {});
          },
          onCompleted: (String s) {
            log('onComplete');
            // context.read<LoginBloc>().add(AccountActivateCodeSubmit(s));
          },
          onSubmitted: (String s) {
            log('onSUbmit');
          },
          androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
        ),
        const SizedBox(height: 28),
        customButton(
            title: "Continue",
            buttonColor: _isValid == false ? Colors.grey : null,
            onTap: () {
              authController.submitOpt(
                firstName: widget.firstName,
                lastName: widget.lastName,
                email: widget.email,
                passWord: widget.password,
                opt: pinController.text.trim(),
                cPassWord: widget.cPasssword,
                gender: 'M',
              );
            }),

        // Text.rich(
        //   TextSpan(
        //     text: '${Language.didNotReceived.capitalizeByWord()} ? ',
        //     style: const TextStyle(color: Color(0xff878D97)),
        //     children: [
        //       TextSpan(
        //         text: Language.resend.capitalizeByWord(),
        //         style: const TextStyle(color: Color(0xff000000)),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
