import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
 HeadlessInAppWebView? headlessWebView;
  String url = "";

// void openInWeb(
//   String navUrl,
// ) async {
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

void openInBrowser({required String url}) async {
  var urllaunchable = await canLaunch(url); //canLaunch is from url_launcher package
  if (urllaunchable) {
    await launch(url); //launch is from url_launcher package to launch URL
  } else {
    print("URL can't be launched.");
  }
}
