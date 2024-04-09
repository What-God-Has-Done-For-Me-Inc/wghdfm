import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wghdfm_java/modules/profile_module/controller/profile_controller.dart';
import 'package:wghdfm_java/screen/donate/donate_ui.dart';
import 'package:wghdfm_java/services/prefrence_services.dart';
import 'package:wghdfm_java/utils/common-webview-screen.dart';
import 'package:wghdfm_java/utils/page_res.dart';
import 'package:wghdfm_java/utils/urls.dart';

import '../../../services/sesssion.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/shimmer_utils.dart';
import '../../auth_module/model/login_model.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.05),
            Row(
              children: [
                SizedBox(width: Get.width * 0.05),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 100,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).iconTheme.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: StreamBuilder(
                        stream: profilePic.stream,
                        builder: (context, snapshot) {
                          return Image.network(
                            profilePic.value,
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
                          );
                        }),
                  ),
                ),
                SizedBox(width: Get.width * 0.05),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder(
                        stream: userName.stream,
                        builder: (context, snapshot) {
                          return Text(
                            userName.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        }),
                    StreamBuilder(
                        stream: userEmail.stream,
                        builder: (context, snapshot) {
                          return Text(
                            userEmail.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }),
                  ],
                )
              ],
            ),
            SizedBox(height: Get.height * 0.05),
            setting_card(
              title: "My Profile",
              onTap: () async {
                LoginModel userDetails =
                    await SessionManagement.getUserDetails();
                var userId = userDetails.id;

                Get.toNamed(PageRes.profileScreen,
                    arguments: {"profileId": userId, "isSelf": true});
              },
              icon: MingCute.user_3_line,
              showarrow: true,
            ),
            setting_card(
              title: "Partner With Us",
              onTap: () {
                Get.to(() => DonateUI());
              },
              icon: FontAwesome.handshake,
              showarrow: true,
            ),
            setting_card(
              title: "Bible",
              onTap: () {
                Get.to(() => const CommonWebScreen(
                      url: bibleUrl,
                      title: "Bible",
                    ));
              },
              icon: MingCute.notebook_line,
              showarrow: true,
            ),
            setting_card(
              title: "Privacy & Security",
              onTap: () {
                launchUrlString(
                    "https://whatgodhasdoneforme.com/privacy-policy");
              },
              icon: MingCute.safety_certificate_line,
              showarrow: false,
            ),
            setting_card(
              title: "Logout",
              onTap: () {
                Get.dialog(CupertinoAlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout.? "),
                  actions: [
                    MaterialButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("No")),
                    MaterialButton(
                        onPressed: () {
                          SessionManagement.logoutUser();
                        },
                        child: const Text("Yes")),
                  ],
                ));
              },
              icon: MingCute.exit_line,
              showarrow: false,
            ),
          ],
        ),
      )),
    );
  }
}

class setting_card extends StatelessWidget {
  const setting_card({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.showarrow,
  });
  final String title;
  final IconData icon;
  final bool showarrow;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 15.0,
              )
            ],
            borderRadius: const BorderRadius.all(Radius.circular(15))),
        child: ListTile(
          leading: Icon(icon, color: AppColors.black.withOpacity(.80)),
          title: Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black.withOpacity(.80)),
          ),
          trailing: showarrow == true
              ? Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: AppColors.black.withOpacity(.80),
                  size: 30,
                )
              : null,
        ),
      ),
    );
  }
}
