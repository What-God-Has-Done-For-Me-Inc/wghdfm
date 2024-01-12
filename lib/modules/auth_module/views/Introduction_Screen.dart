import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/modules/auth_module/views/login_screen.dart';
import 'package:wghdfm_java/services/prefrence_services.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_colors.dart';

class IntroducationScreen extends StatefulWidget {
  @override
  _IntroducationScreenState createState() => _IntroducationScreenState();
}

class _IntroducationScreenState extends State<IntroducationScreen> {
  final int totalpages = 2;
  final PageController pagecontroller = PageController(initialPage: 0);
  int currentpage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            PageView(
              controller: pagecontroller,
              onPageChanged: (int page) {
                currentpage = page;
                setState(() {});
              },
              children: [
                buildPageContent(
                  image: "assets/drawable/intro1.jpg",
                  color: Color(0xffFFFFFF),
                  textColor: Colors.black,
                  title: "Let's Connect",
                  body:
                      'Share your Faith, Hope, and Love in a God-inspired, fun-filled environment,\n\nJoin this new home for the Faithful, the lost and the searching.',
                ),
                buildPageContent(
                  image: "assets/drawable/intro2.jpg",
                  color: Color(0xff88C5EC),
                  textColor: Colors.white,
                  title: 'Why Join Us?',
                  body:
                      'Access the Bible in over 1200 languages.\nMeet new christians with common interests.\nPost your thoughts on Video & Images.\nInvite your friends and create your own groups.',
                ),
                // buildPageContent(
                //   image: "assets/drawable/background.jpg",
                //   color: Color(0xffCEE5EB),
                //   textColor: Color(0xff301A31),
                //   title: 'Be Productive',
                //   body:
                //       'Easy tracking of daily tasks.\nSynergestic motivation through community',
                // ),
              ],
            ),
            Positioned(
              bottom: 24,
              left: Get.width * 0.01,
              right: Get.width * 0.01,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: Get.height * 0.08,
                    width: Get.width * 0.8,
                    child: Row(
                      children: <Widget>[
                        for (int i = 0; i < totalpages; i++)
                          i == currentpage
                              ? buildPageIndicator(true)
                              : buildPageIndicator(false),
                        Spacer(),
                        //if (currentpage != 2) Container(),
                        if (currentpage == 1)
                          FloatingActionButton(
                            backgroundColor: AppColors.primery,
                            elevation: 5,
                            onPressed: () {
                              pagecontroller.animateToPage(2,
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.linear);
                              setState(() {
                                storeBoolToSF(SessionManagement.IS_INTRO, true);
                                Get.off(LoginScreen());
                              });
                            },
                            child: Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageContent({
    String? image,
    Color? color,
    Color? textColor,
    String? title,
    String? body,
  }) {
    return Container(
      decoration: BoxDecoration(color: color),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              image!,
              height: Get.height * 0.45,
              width: Get.width,
            ),
          ),
          SizedBox(
            height: Get.height * 0.02,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  body!,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPageIndicator(bool isCurrentPage) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      margin: EdgeInsets.symmetric(
        horizontal: 5,
      ),
      height: isCurrentPage ? 18 : 10,
      width: isCurrentPage ? 18 : 10,
      decoration: BoxDecoration(
          color: isCurrentPage ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }
}
