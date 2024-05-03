import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/modules/ads_module/ads_controller.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/firebase_config.dart';
import 'package:wghdfm_java/utils/scale_ui_utils.dart';

import '../../../common/background_widget.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  AppConfigController appConfigController  = Get.put(AppConfigController());

  @override
  void initState() {
    // init();
    // TODO: implement initState
    AdsController.initGoogleMobileAds();
    appConfigController.getConfig();
    Future.delayed(
      const Duration(seconds: 5),
      () {
        SessionManagement.checkLogin();
        SessionManagement.checkLoginRedirect();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Scale.setup(context, MediaQuery.of(context).size);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: backGroundWidget(
          widget: Column(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: Get.width),
            child: FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShowUp(
                    delay: 250,
                    child: Text(
                      "My ",
                      style: GoogleFonts.montserrat(color: Colors.red, fontSize: 22.0.sf),
                    ),
                  ),
                  ShowUp(
                    delay: 500,
                    child: Text(
                      "Christian ",
                      style: GoogleFonts.montserrat(color: Colors.red, fontSize: 22.0.sf),
                    ),
                  ),
                  ShowUp(
                    delay: 1500,
                    child: Text(
                      "Social ",
                      style: GoogleFonts.montserrat(color: Colors.red, fontSize: 22.0.sf),
                    ),
                  ),
                  ShowUp(
                    delay: 2000,
                    child: Text(
                      "Network ",
                      style: GoogleFonts.montserrat(color: Colors.red, fontSize: 22.0.sf),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Image.asset("assets/drawable/logo.png"),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: Get.width),
                child: FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShowUp(
                        delay: 500,
                        child: Text(
                          "What ",
                          style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 22.0.sf),
                        ),
                      ),
                      ShowUp(
                        delay: 1500,
                        child: Text(
                          "God ",
                          style: GoogleFonts.montserrat(color: Colors.red, fontSize: 22.0.sf),
                        ),
                      ),
                      ShowUp(
                        delay: 2000,
                        child: Text(
                          "Has ",
                          style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 22.0.sf),
                        ),
                      ),
                      ShowUp(
                        delay: 2500,
                        child: Text(
                          "Done ",
                          style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 22.0.sf),
                        ),
                      ),
                      ShowUp(
                        delay: 3000,
                        child: Text(
                          "For ",
                          style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 22.0.sf),
                        ),
                      ),
                      ShowUp(
                        delay: 3500,
                        child: Text(
                          "Me",
                          style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 22.0.sf),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              Container(
                constraints: BoxConstraints(maxWidth: Get.width),
                child: FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShowUp(
                        delay: 500,
                        child: Text(
                          "Share ",
                          style: GoogleFonts.montserrat(color: Colors.red, fontSize: 22.0.sf),
                        ),
                      ),
                      ShowUp(
                        delay: 1000,
                        child: Text(
                          "Your ",
                          style: GoogleFonts.montserrat(color: Colors.red, fontSize: 22.0.sf),
                        ),
                      ),
                      ShowUp(
                        delay: 1500,
                        child: Text(
                          "Story ",
                          style: GoogleFonts.montserrat(color: Colors.red, fontSize: 22.0.sf),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(),
        ],
      )),
    );
  }
}

///ShowUp Widget
class ShowUp extends StatefulWidget {
  final Widget child;
  final int delay;

  const ShowUp({super.key, required this.child, required this.delay});

  @override
  // ignore: library_private_types_in_public_api
  _ShowUpState createState() => _ShowUpState();
}

class _ShowUpState extends State<ShowUp> with TickerProviderStateMixin {
  ///Try adding an initializer expression,
  ///or a generative constructor that initializes it,
  ///or mark it 'late'.
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    final curve = CurvedAnimation(curve: Curves.decelerate, parent: _animController);
    _animOffset = Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero).animate(curve);

/*
      ///The argument type 'int?' can't be assigned to the parameter type 'int'
      ///Try changing the type of the variable, or casting the right-hand type to 'int'.
      ///add e null check (!)*/
    Timer(Duration(milliseconds: widget.delay), () {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    ///The receiver can't be null,
    ///so the null-aware operator '?.' is unnecessary.
    ///Try replacing the operator '?.' with '.'.
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animController,
      child: SlideTransition(
        position: _animOffset,
        child: widget.child,
      ),
    );
  }
}

Widget fullView(Widget widget) {
  return SizedBox(
    width: Get.width,
    height: Get.height,
    child: FittedBox(
      fit: BoxFit.fill,
      child: widget,
    ),
  );
}
