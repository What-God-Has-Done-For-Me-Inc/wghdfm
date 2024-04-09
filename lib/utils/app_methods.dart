import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

//import 'package:intent/action.dart' as android_action;
//import 'package:intent/intent.dart' as android_intent;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:wghdfm_java/modules/dashbord_module/views/ProfileSetupScreen.dart';
import 'package:wghdfm_java/utils/app_colors.dart';
import 'package:wghdfm_java/utils/app_texts.dart';

class AppMethods {
  static showLog(String text, {String? name}) {
    log(text, name: name ?? "Mavani", level: 5);
  }

  void share({required String string, required BuildContext context}) {
    // final box = context.findRenderObject() as RenderBox?;
    Share.share(string,
        subject: '#WGHDFM #WHATGODHASDONEFORME',
        sharePositionOrigin: Rect.fromLTWH(
            0,
            0,
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height / 2));
  }

  void onCall(String contactNumber) {
    debugPrint("contactNumber: +91$contactNumber");
    /*android_intent.Intent()
    ..setAction(android_action.Action.ACTION_VIEW)
    ..setData(Uri(scheme: "tel", path: contactNumber))
    ..startActivity().catchError((e) => print(e));*/

    //import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
    UrlLauncher.launch("tel://+91$contactNumber");
  }

  void onWhatsAppConnect(String customerMobile, {String msg = ''}) {
    /*String whatsAppCallUrl = "https://wa.me/$customerMobile?text=$msg";
  android_intent.Intent()
    ..setAction(android_action.Action.ACTION_VIEW)
    ..startActivityForResult().then(
      (data) => Uri.encodeFull(whatsAppCallUrl),
      onError: (e) => print(e.toString()),
    );*/
    String whatsAppCallUrl = "https://wa.me/$customerMobile?text=$msg";
    // FlutterWebBrowser.openWebPage(
    //   url: whatsAppCallUrl,
    //   customTabsOptions: CustomTabsOptions(
    //     colorScheme: CustomTabsColorScheme.dark,
    //     toolbarColor: Theme
    //         .of(Get.context!)
    //         .colorScheme.secondary,
    //     secondaryToolbarColor: Theme
    //         .of(Get.context!)
    //         .colorScheme.secondary,
    //     navigationBarColor: Colors.white,
    //     addDefaultShareMenuItem: false,
    //     instantAppsEnabled: false,
    //     showTitle: false,
    //     urlBarHidingEnabled: true,
    //   ),
    //   safariVCOptions: SafariViewControllerOptions(
    //     barCollapsingEnabled: true,
    //     preferredBarTintColor: Theme
    //         .of(Get.context!)
    //         .colorScheme.secondary,
    //     preferredControlTintColor: Colors.white,
    //     dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
    //     modalPresentationCapturesStatusBarAppearance: true,
    //   ),
    // );
  }

  void onNavigation(
    BuildContext context,
    String originLatitude,
    String originLongitude,
    String destinationLatitude,
    String destinationLongitude, {
    int zoomLvl = 18,
  }) async {
    //"StringAddress or lat,long"
    String origin =
        "$originLatitude,$originLongitude"; // lat,long like 123.34,68.56
    String destination = "$destinationLatitude,$destinationLongitude";

    ///https://www.google.com/maps/dir/?api=1&origin=22.5735602,88.4324186&destination=26.1859246,91.7442156&travelmode=driving&dir_action=navigate
    String navUrl = "";
    //navUrl = "https://www.google.com/maps/dir/?api=1&origin=" + origin + "&destination=" + destination + "&travelmode=driving&dir_action=navigate";

    ///https://www.google.com/maps/dir/22.5735602,88.4324186/26.1859246,91.7442156/@26.1856037,91.7445514,18z
    navUrl =
        "https://www.google.com/maps/dir/$origin/$destination/@$destination,${zoomLvl}z";
    debugPrint("navUrl: $navUrl");
    // FlutterWebBrowser.openWebPage(
    //   url: navUrl,
    //   customTabsOptions: CustomTabsOptions(
    //     colorScheme: CustomTabsColorScheme.dark,
    //     toolbarColor: Theme
    //         .of(Get.context!)
    //         .colorScheme.secondary,
    //     secondaryToolbarColor: Theme
    //         .of(Get.context!)
    //         .colorScheme.secondary,
    //     navigationBarColor: Colors.white,
    //     addDefaultShareMenuItem: false,
    //     instantAppsEnabled: false,
    //     showTitle: false,
    //     urlBarHidingEnabled: true,
    //   ),
    //   safariVCOptions: SafariViewControllerOptions(
    //     barCollapsingEnabled: true,
    //     preferredBarTintColor: Theme
    //         .of(Get.context!)
    //         .colorScheme.secondary,
    //     preferredControlTintColor: Colors.white,
    //     dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
    //     modalPresentationCapturesStatusBarAppearance: true,
    //   ),
    // );
  }

  void onLocation(
    BuildContext context,
    String latitude,
    String longitude, {
    int zoomLvl = 18,
  }) async {
    //"StringAddress or lat,long"
    String origin = "$latitude,$longitude"; // lat,long like 123.34,68.56

    ///https://www.google.com/maps/place/22.573536,88.3602028
    String navUrl = "";
    navUrl = "https://www.google.com/maps/place/$origin/$origin,${zoomLvl}z";
    debugPrint("navUrl: $navUrl");
    // FlutterWebBrowser.openWebPage(
    //   url: navUrl,
    //   customTabsOptions: CustomTabsOptions(
    //     colorScheme: CustomTabsColorScheme.dark,
    //     toolbarColor: Theme
    //         .of(Get.context!)
    //         .colorScheme.secondary,
    //     secondaryToolbarColor: Theme
    //         .of(Get.context!)
    //         .colorScheme.secondary,
    //     navigationBarColor: Colors.white,
    //     addDefaultShareMenuItem: false,
    //     instantAppsEnabled: false,
    //     showTitle: false,
    //     urlBarHidingEnabled: true,
    //   ),
    //   safariVCOptions: SafariViewControllerOptions(
    //     barCollapsingEnabled: true,
    //     preferredBarTintColor: Theme
    //         .of(Get.context!)
    //         .colorScheme.secondary,
    //     preferredControlTintColor: Colors.white,
    //     dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
    //     modalPresentationCapturesStatusBarAppearance: true,
    //   ),
    // );
  }

  void openUrl(String navUrl) async {
    if (await canLaunch(navUrl) != null) {
      await launch(navUrl);
    } else {
      throw 'Could not launch $navUrl';
    }
  }

/*void launchUrl(String mUrl, {bool isHttp = false}) async {
  android_intent.Intent()
    ..setAction(android_action.Action.ACTION_VIEW)
    ..setData(Uri(scheme: isHttp ? "http" : "https", host: mUrl))
    ..startActivity().catchError((e) => print(e));
}*/

  // void openInWeb(String navUrl,) async {
  //   FlutterWebBrowser.openWebPage(
  //     url: navUrl,
  //     customTabsOptions: CustomTabsOptions(
  //       colorScheme: CustomTabsColorScheme.dark,
  //       toolbarColor: Colors.black.withOpacity(0.3),
  //       secondaryToolbarColor: Colors.black.withOpacity(0.3),
  //       navigationBarColor: Colors.white,
  //       addDefaultShareMenuItem: false,
  //       instantAppsEnabled: false,
  //       showTitle: false,
  //       urlBarHidingEnabled: true,
  //     ),
  //     safariVCOptions: SafariViewControllerOptions(
  //       barCollapsingEnabled: true,
  //       preferredBarTintColor: Colors.black.withOpacity(0.3),
  //       preferredControlTintColor: Colors.white,
  //       dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
  //       modalPresentationCapturesStatusBarAppearance: true,
  //     ),
  //   );
  // }

  Future<bool> checkPermission({Permission? extraPermission}) async {
    // await Permission.locationWhenInUse.request();
    // await Permission.location.request();
    // await Permission.locationAlways.request();
    await Permission.camera.request();
    await Permission.microphone.request();
    showLog(" Permission of camera >> ${await Permission.camera.status}");
    showLog(
        " Permission of microphone >> ${await Permission.microphone.status}");

    ///For Location..
    if (Platform.isAndroid) {
      if (await Permission.camera.status != PermissionStatus.granted ||
          await Permission.microphone.status != PermissionStatus.granted) {
        await Get.dialog(CupertinoAlertDialog(
          title: const Text("Camera & Microphone permission"),
          content: const Text(
              "Camera & Microphone permission should be required to using this function, would you like to go to app settings to give Camera & Microphone permissions?"),
          actions: <Widget>[
            TextButton(
                child: const Text('No thanks'),
                onPressed: () {
                  Get.back();
                }),
            TextButton(
                child: const Text('Ok'),
                onPressed: () async {
                  Get.back();
                  await openAppSettings();
                })
          ],
        ));
        return false;
      } else {
        return true;
      }
    } else {
      await Permission.camera.request();
      await Permission.microphone.request();
      return true;
    }
  }

  Future<bool> getPermission() async {
    var cameraPermission = await Permission.camera.status;
    var microphonePermission = await Permission.microphone.status;

    if (cameraPermission == PermissionStatus.permanentlyDenied ||
        microphonePermission == PermissionStatus.permanentlyDenied) {
      // Handle permanently denied permissions
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: Text('Permissions Required'),
          content: Text(
              'Camera and microphone access are permanently denied. Please enable them in app settings.'),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
      return false;
    } else if (cameraPermission == PermissionStatus.denied ||
        microphonePermission == PermissionStatus.denied) {
      await Permission.camera.request();
      await Permission.microphone.request();
      return false;
    } else if (cameraPermission == PermissionStatus.granted ||
        microphonePermission == PermissionStatus.granted) {
      return true;
    }
    // Permissions are already granted, proceed with your logic
    print('Both camera and microphone permissions granted!');
    return true;
    // ...
  }

  Future<bool> checkStoragePermission() async {
    // await Permission.locationWhenInUse.request();
    // await Permission.location.request();
    // await Permission.locationAlways.request();
    await Permission.storage.request();
    await Permission.photos.request();

    // await Permission.manageExternalStorage.request();
    showLog(" Permission of camera >> ${await Permission.camera.status}");
    showLog(
        " Permission of microphone >> ${await Permission.microphone.status}");

    ///For Location..
    if (Platform.isAndroid) {
      if (await Permission.storage.status != PermissionStatus.granted &&
          await Permission.photos.status != PermissionStatus.granted) {
        await Get.dialog(CupertinoAlertDialog(
          title: const Text("Camera & Microphone permission"),
          content: const Text(
              "Camera & Microphone permission should be required to using this function, would you like to go to app settings to give Camera & Microphone permissions?"),
          actions: <Widget>[
            TextButton(
                child: const Text('No thanks'),
                onPressed: () {
                  Get.back();
                }),
            TextButton(
                child: const Text('Ok'),
                onPressed: () async {
                  Get.back();
                  await openAppSettings();
                })
          ],
        ));
        return false;
      } else {
        return true;
      }
    } else {
      await Permission.camera.request();
      await Permission.microphone.request();
      return true;
    }
  }

  Future<File?> pickImage() async {
    if (await checkStoragePermission() == true) {
      final pick = ImagePicker();
      final image = await pick.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
      );
      if (image != null) {
        return File(image.path);
      }
    } else {
      return null;
    }
  }

  static RxBool eulaAccepted = false.obs;
  static RxBool showTutorial = false.obs;
  static RxBool showTutorialForProfile = false.obs;

  hideTutorial() async {
    final instance = await SharedPreferences.getInstance();
    await instance.setBool("showTutorial", false);
  }

  hideTutorialForProfile() async {
    final instance = await SharedPreferences.getInstance();
    await instance.setBool("showTutorialForProfile", false);
  }

  checkTutorial({Function? callBack}) async {
    final instance = await SharedPreferences.getInstance();
    showTutorial.value = instance.getBool("showTutorial") ?? true;
    showTutorialForProfile.value =
        instance.getBool("showTutorialForProfile") ?? true;
    print("----- showTutorial.value${showTutorial.value}");
    print("----- showTutorialForProfile.value${showTutorialForProfile.value}");
    if (callBack != null) {
      callBack();
    }
  }

  static deleteDialog(
      {String? headingText,
      String? descriptionText,
      required Function onDelete}) {
    Get.dialog(CupertinoAlertDialog(
      title: Text(headingText ?? 'Are you sure you want to delete this?'),
      content: Text(descriptionText ?? 'This will delete the permanently'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back(); //close Dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
            onPressed: () {
              Get.back();
              onDelete();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            )),
      ],
    ));
  }

  static tutorialDialog() {
    Get.dialog(
        PopScope(
          canPop: false,
          child: CupertinoAlertDialog(
            title: Text("Profile Setup"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text("You haven't setup your profile, Please Let's do it "),
                SizedBox(
                  height: 10,
                ),
                Lottie.asset("assets/json/Profile.json",
                    height: 250, width: 250)
              ],
            ),
            actions: <Widget>[
              // TextButton(
              //   onPressed: () {
              //     Get.back(); //close Dialog
              //   },
              //   child: const Text('Skip'),
              // ),
              TextButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => ProfileSetupPage());
                  },
                  child: const Text(
                    "Let's do it",
                  )),
            ],
          ),
        ),
        barrierDismissible: false);
  }

  acceptEULA() async {
    final instance = await SharedPreferences.getInstance();
    await instance.setBool("eulaAccepted", true);
  }

  checkEULA() async {
    final instance = await SharedPreferences.getInstance();
    eulaAccepted.value = instance.getBool("eulaAccepted") ?? false;
    print("----- ${eulaAccepted.value}");
  }

  getEULA(context) async {
    await checkEULA();
    if (!eulaAccepted.value) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        builder: (context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icon/term_condition.png',
                      height: 50, width: 50),
                  const SizedBox(height: 15),
                  RichText(
                    text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        text:
                            "For use of What God Has Done For Me, you need to allow to the user",
                        children: [
                          TextSpan(
                              text: " agreement",
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                              recognizer: new TapGestureRecognizer()
                                ..onTap = () {
                                  launch(AppTexts.eulaLink);
                                }),
                        ]),
                  ),
                  // Text(
                  //   "Please read and allow our Privacy Policy to continue using our app.",
                  //   style: GoogleFonts.roboto(
                  //     color: Colors.black.withOpacity(0.7),
                  //     fontSize: 14,
                  //   ),
                  // ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () {
                      acceptEULA();
                      Get.back();
                    },
                    child: Text(
                      'Allow',
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
