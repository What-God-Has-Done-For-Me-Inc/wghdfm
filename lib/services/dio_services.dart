// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart' as d;
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:whatgodhasdoneforme/utils/endpoints.dart';
// import 'package:whatgodhasdoneforme/utils/toast_me_not.dart';

//
// class DioServices {
//   static Future<dynamic> dioPostApi({required String endPoints, Map<String, dynamic>? body, Map<String, dynamic>? header}) async {
//     try {
//       d.BaseOptions options = d.BaseOptions(
//         baseUrl: EndPoints.baseUrl,
//         connectTimeout: 10000,
//         receiveTimeout: 10000,
//       );
//
//       d.Response response;
//       var dio = d.Dio(options);
//       header ??= {"Content-Type": "application/json"};
//
//       if (kDebugMode) {
//         print("Url => ${EndPoints.baseUrl}$endPoints");
//         print("Header => $header");
//         print("Body => $body");
//       }
//       dio.options.headers = header;
//
//       response = await dio.post(endPoints, data: jsonEncode(body ?? {}));
//
//       if (kDebugMode) {
//         print("\n\nAPI STATUS CODE : ${response.statusCode}\nRESPONSE DATA : ${response.data}");
//       }
//       if (response.statusCode == 200) {
//         return response;
//       } else {
//         return null;
//       }
//     } on SocketException catch (_) {
//       ToastMeNot.show("Network connectivity not found. Try again.", Get.context!);
//       //To handle Socket Exception in case network connection is not available during initiating your network call
//     } catch (e) {
//       debugPrint("====================>$e");
//       return null;
//     }
//   }
//
//   // static Future<dynamic> dioGetApi({required String endPoints, Map<String, dynamic>? header}) async {
//   //   try {
//   //     d.BaseOptions options = d.BaseOptions(
//   //       baseUrl: EndPoints.baseUrl,
//   //       connectTimeout: 10000,
//   //       receiveTimeout: 10000,
//   //     );
//   //     d.Response response;
//   //     var dio = d.Dio(options);
//   //     header ??= {"Content-Type": "application/json"};
//   //     if (kDebugMode) {
//   //       print("Url => ${EndPoints.baseUrl}$endPoints");
//   //       print("Header => $header");
//   //     }
//   //     dio.options.headers = header;
//   //
//   //     response = await dio.get(endPoints);
//   //
//   //     if (kDebugMode) {
//   //       print("API RESPONSE DATA : ${response.data}");
//   //     }
//   //     if (response.statusCode == 200) {
//   //       return response;
//   //     } else {
//   //       return null;
//   //     }
//   //   } on SocketException catch (_) {
//   //     ToastMeNot.show("Network connectivity not found. Try again.", Get.context!);
//   //     //To handle Socket Exception in case network connection is not available during initiating your network call
//   //   } catch (e) {
//   //     e.toString();
//   //   }
//   // }
// }
