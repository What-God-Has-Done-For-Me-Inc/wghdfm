import 'dart:convert';

import 'package:get/get.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/dash_board_screen.dart';
import 'package:wghdfm_java/services/prefrence_services.dart';
import 'package:wghdfm_java/utils/page_res.dart';

import '../networking/api_service_class.dart';

RxString userName = 'Guest'.obs;
RxString profilePic = ''.obs;
RxString coverPic = ''.obs;

class SessionManagement {
  static String IS_LOGIN = "IsLoggedIn";
  static String ACTIVE_USER_DETAILS = "ActiveUserDetails";
  static String KEY_EMAIL = "email";
  static String KEY_ID = "id";
  static String POST_ID = "post_id";

  static void createLoginSession(String email, String id) {
    // Storing login value as TRUE
    storeBoolToSF(IS_LOGIN, true);

    // Storing email in pref
    storeStringToSF(KEY_EMAIL, email);

    // Storing id in pref
    storeStringToSF(KEY_ID, id);
  }

  static void createPostSession(String postID) {
    storeStringToSF(POST_ID, postID);
  }

  static Future<void> checkLogin() async {
    // Check login status
    if (!await isLoggedIn()) {
      // user is not logged in redirect him to Login Activity
      Get.toNamed(PageRes.loginScreen);
    }
  }

  static Future<void> checkLoginRedirect() async {
    // Check login status
    if (await isLoggedIn()) {
      // user is not logged in redirect him to Login Activity
      // Get.offNamed(PageRes.dashBoardScreen);
      Get.offAll(() => DashBoardScreen());
      // Get.offAll(() => DrawerScreen(screenName: AppTexts.dashBoard));
    }
  }

  static Future<LoginModel> getUserDetails() async {
    var jsonDecoded = jsonDecode(await fetchStringValuesSF(ACTIVE_USER_DETAILS));
    LoginModel details = LoginModel.fromJson(jsonDecoded);
    userName.value = ("${details.fname!} ${details.lname!}").trim();
    profilePic.value = details.img!;
    return details;
  }

  static void logoutUser() {
    showProgressDialog();

    Future.delayed(const Duration(seconds: 3), () {
      // Clearing all data from Shared Preferences
      clearValueFromSF(IS_LOGIN);
      clearValueFromSF(KEY_EMAIL);
      clearValueFromSF(KEY_ID);
      clearValueFromSF(ACTIVE_USER_DETAILS);
      clearAllStorage();
      // After logout redirect user to Loing Activity
      Get.offAllNamed(PageRes.loginScreen);
      // pushToAndRemoveUntil(
      //   widget: LoginUI(),
      // );
    });
  }

  static Future<bool> isLoggedIn() async {
    return await fetchBoolValuesSF(IS_LOGIN);
  }
}
