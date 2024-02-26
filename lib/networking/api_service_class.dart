import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wghdfm_java/utils/app_images.dart';
import 'package:wghdfm_java/utils/app_methods.dart';

class APIService {
  static const String somethingWrong = "Something Went Wrong";
  static const String responseMessage = "NO RESPONSE DATA FOUND";
  static const String interNetMessage =
      "No internet connection, Please check your internet connection and try again later";
  static const String connectionTimeOutMessage =
      "Oops.. Server not working or might be in maintenance. Please Try Again Later";
  static const String authenticationMessage =
      "The session has been Expired. Please log in again.";
  static const String tryAgain = "Try Again";

  static const String getMethod = "getMethod";
  static const String postMethod = "postMethod";
  static const String putMethod = "putMethod";
  static const String deleteMethod = "deleteMethod";

  final d.Dio dio = d.Dio(d.BaseOptions(
    // baseUrl: "BaseURl ",
    // connectTimeout: 5000,
    // receiveTimeout: 5000,
    // sendTimeout: 5000,
    validateStatus: (code) {
      if (code == 200 || code == 201) {
        return true;
      } else {
        return false;
      }
    },
  ));

  Future<String> getToken() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("tokenKey") ?? "";
  }

  Future callAPI(
      {required Map<String, dynamic> params,
      Map<String, dynamic>? headers,
      required String serviceUrl,
      required String method,
      String? formDataMap,
      d.FormData? formDatas,
      required Function success,
      required Function error,
      RxString? percentage,
      required bool showProcess}) async {
    headers ??= {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${await getToken()}',
    };
    Map<String, dynamic> headersPassed = headers;
    d.FormData? formData = formDatas;
    String serviceUrlPassed = serviceUrl;
    String methodPassed = method;
    Map<String, dynamic> paramsPassed = params;

    AppMethods.showLog(" DIO API CALLING ", name: "API");
    AppMethods.showLog(" DIO API URL  >> $serviceUrlPassed", name: "API");
    AppMethods.showLog(" DIO API Method >> $methodPassed", name: "API");
    AppMethods.showLog(" DIO API Params >> $paramsPassed", name: "API");
    AppMethods.showLog(" DIO API formDataMap >> $formDataMap", name: "API");
    AppMethods.showLog(" DIO API FormData Fields >> ${formData?.fields}",
        name: "API");
    AppMethods.showLog(" DIO API Form Data Files >> ${formData?.files}",
        name: "API");

    if (await checkInternet()) {
      final timer = Stopwatch();
      timer.start();
      if (showProcess == true) {
        showProgressDialog();
      }
      // serviceUrlPassed = serviceUrl;
      // headersPassed = headers;
      // methodPassed = method;
      // paramsPassed = params;
      try {
        d.Response response;
        if (methodPassed == getMethod) {
          response = await dio.get(serviceUrlPassed,
              queryParameters: paramsPassed,
              options: d.Options(
                headers: headersPassed,
              ));
        } else if (methodPassed == postMethod) {
          response = await dio.post(
            serviceUrlPassed,
            queryParameters: paramsPassed,
            data: formDataMap ?? formData,
            onSendProgress: (int sent, total) {
              String uploadPercentage = (sent / total * 100).toStringAsFixed(2);
              AppMethods.showLog("percentage ===> $uploadPercentage");
              percentage?.value = uploadPercentage;
              AppMethods.showLog("percentagesss ===> ${percentage?.value}");
            },
            options: d.Options(
              headers: {'Content-Type': 'multipart/form-data'},
            ),
          );
        } else if (methodPassed == putMethod) {
          response = await dio.put(serviceUrlPassed,
              queryParameters: paramsPassed,
              data: formData,
              options: d.Options(headers: headersPassed));
        } else {
          response = await dio.delete(serviceUrlPassed,
              queryParameters: paramsPassed,
              data: formData,
              options: d.Options(headers: headersPassed));
        }
        AppMethods.showLog(":::: API RESPONSE >>  $response ::::", name: "API");
        if (response.statusCode == 200 || response.statusCode == 201) {
          AppMethods.showLog(":::: SUCCESS API CALL ::::", name: "API");
          AppMethods.showLog(
              "$serviceUrl is completed in ${timer.elapsedMilliseconds} ms",
              name: "API");
          timer.reset();
          if (showProcess == true) {
            hideProgressDialog();
          }
          print('Success Upload');
          await success(response);
        } else {
          if (showProcess == true) {
            hideProgressDialog();
          }
          AppMethods.showLog(":::: ERROR API CALL ::::");
          await error(response);
        }
      } on d.DioError catch (dioError) {
        AppMethods.showLog(" DIO ERROR >> TYPE >> ${dioError.type}");
        AppMethods.showLog(" DIO ERROR >> error >> ${dioError.error}");
        AppMethods.showLog(
            " DIO ERROR >> response >> ${dioError.response?.data}");
        AppMethods.showLog(" DIO ERROR >> message >> ${dioError.message}");
        if (showProcess == true) {
          hideProgressDialog();
        }
        await error(dioError.response);
        apiAlertDialog(
            message: connectionTimeOutMessage,
            buttonCallBack: () async {
              hideProgressDialog();
              await callAPI(
                  params: paramsPassed,
                  serviceUrl: serviceUrl,
                  method: methodPassed,
                  success: success,
                  error: error,
                  showProcess: showProcess);
            });
      } catch (e) {
        if (showProcess == true) {
          hideProgressDialog();
        }
        AppMethods.showLog("ERROR >> response >> ${e.toString()}");
        // apiAlertDialog(
        //   message: e.toString(),
        //   isBackOnly: true,
        // );
      }

      // if (showProcess == true) {
      //   hideProgressDialog();
      // }
    } else {
      apiAlertDialog(
          message: interNetMessage,
          buttonTitle: "Try again",
          isBackOnly: false,
          buttonCallBack: () async {
            hideProgressDialog();
            await callAPI(
                params: paramsPassed,
                serviceUrl: serviceUrl,
                method: methodPassed,
                success: success,
                error: error,
                showProcess: showProcess);
          });
    }
  }

  Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  apiAlertDialog({
    required String message,
    String? buttonTitle,
    Function? buttonCallBack,
    bool? isBackOnly,
  }) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    if (!Get.isDialogOpen!) {
      Get.dialog(
        WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: CupertinoAlertDialog(
              title: const Text("What God Has Done For Me..."),
              // content: Text(message),
              content: Column(
                children: [
                  Lottie.asset(AppImages.noInternetJson, height: 200),
                  Text(message),
                  const SizedBox(height: 10),
                ],
              ),
              actions: [
                if (isBackOnly == false)
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text(buttonTitle ?? "Try again"),
                    onPressed: () {
                      if (buttonCallBack != null) {
                        buttonCallBack();
                      }
                    },
                  ),
                if (isBackOnly == true)
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text("Go Back"),
                    onPressed: () {
                      Get.back();
                      // getX.Get.back();
                    },
                  )
              ]),
        ),
        barrierDismissible: false,
        transitionCurve: Curves.easeInCubic,
        transitionDuration: const Duration(milliseconds: 400),
      );
    }
  }
}

void showProgressDialog() {
  if (Get.isDialogOpen ?? false) {
    Get.back();
    // FeedListController.to.isFetching.value = true;
  }
  if (Get.isSnackbarOpen) {
    Get.closeCurrentSnackbar();
  }

  Get.dialog(
      WillPopScope(
        onWillPop: () => Future.value(false),
        child: Container(
          alignment: Alignment.center,
          color: Colors.black12.withOpacity(0.1),
          child: Lottie.asset(
            AppImages.loadingJson,
            height: 100,
            repeat: true,
          ),
        ),
      ),
      barrierDismissible: false);
}

void hideProgressDialog() {
  if (Get.isDialogOpen ?? false) {
    Get.back();
    // FeedListController.to.isFetching.value = false;
  }
}
