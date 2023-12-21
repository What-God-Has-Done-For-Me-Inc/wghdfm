import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart' as dio;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/notification_module/notification_post_mode.dart';
import 'package:wghdfm_java/networking/api_service_class.dart';
import 'package:wghdfm_java/screen/groups/group_details_screen.dart';
import 'package:wghdfm_java/services/prefrence_services.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../view/messages_screen.dart';
import '../view/notification_post_details_screen.dart';

class NotificationHandler extends GetxController {
  static NotificationHandler get to => Get.put(NotificationHandler());

  static String serverKey =
      "AAAAho9Kasc:APA91bH53S8IsmkUfcBelTv99T_hNKHWfp-rjH_VLwyFHmvTW2v8_m7wK_4h9M72M1XYcQutd34ILKuJXtKBRYR9l9lNAhpODHHaP1HMwOFXeSvie7I4iCu9oVcrH9G45jozr9PBf6VI";

  getPermission() async {
    final messaging = FirebaseMessaging.instance;
    final fcmToken = await FirebaseMessaging.instance.getToken();

    print(" FCM :: ${fcmToken}");
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Permission granted: ${settings.authorizationStatus}');
  }

  setListener() {
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      print(":::: >>>>>>  get Initial Message ${value?.notification?.body}");
      print(":::: >>>>>>  get Initial Message ${value?.notification?.title}");
      print(":::: >>>>>>  get Initial Message ${value?.data}");
      if (value != null) {
        handleMessage(value);
      }

      // print(":::: >>>>>>  get Initial Message ${value?.notification?.body}");
    });

    FirebaseMessaging.onMessage.listen((event) {
      print(":::: >>>>>> ${event.notification?.body}");
      print(":::: >>>>>> ${event.notification?.title}");
      print(":::: >>>>>> apple ${event.notification?.apple?.toMap()}");
      print(":::: >>>>>> android ${event.notification?.android?.toMap()}");
      print(":::: >>>>>> data ${event.data}");
      if (!Platform.isIOS) {
        createNotification(event);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print(":::: >>>>>> onMessageOpenedApp ${event.notification?.body}");
      print(":::: >>>>>> onMessageOpenedApp ${event.notification?.title}");
      print(":::: >>>>>> onMessageOpenedApp ${event.data}");
      handleMessage(event);
    });
  }

  createNotification(RemoteMessage event) {
    int i = 1;
    Map<String, String> payLoadData = {};

    event.data.forEach((key, value) {
      payLoadData.addAll({key: value.toString()});
    });
    AwesomeNotifications()
        .createNotification(
            content: NotificationContent(
                id: i,
                channelKey: 'basic_channel',
                title: "${event.notification?.title}",
                body: "${event.notification?.body}",
                actionType: ActionType.Default,
                roundedBigPicture: true,
                notificationLayout: NotificationLayout.BigPicture,
                bigPicture: "${event.notification?.android?.imageUrl}",
                payload: payLoadData))
        .then((value) {
      handleLocalNotification();
      i++;
    });
  }

  handleLocalNotification() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) {
        if (receivedAction.payload != null) {
          print(" Local Notification Payload is ${receivedAction.payload}");
          if (receivedAction.payload?.containsKey("postId") == true) {
            Get.to(() => NotificationPostDetailsScreen(postId: "${receivedAction.payload?['postId']}"));
          }
          if (receivedAction.payload?.containsKey("notificationId") == true) {
            Get.to(() => MessageScreens());
          }
        }

        return Future.value(true);
      },
    );
  }

  handleMessage(RemoteMessage message) {
    print("Payload:::::${message.data}");
    if (message.data.keys.contains("GroupID")) {
      Get.to(() => GroupDetailsScreen(groupId: "${message.data["GroupID"]}"));
      return;
    }
    if (message.data.keys.contains("postId")) {
      Get.to(() => NotificationPostDetailsScreen(postId: "${message.data["postId"]}"));
      return;
    }
    if (message.data.keys.contains("notificationId")) {
      Get.to(() => const MessageScreens());
    }
  }

  static initializeHandler() {
    AwesomeNotifications().initialize(
        'resource://drawable/ic_launcher',
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              ledColor: Colors.white)
        ],
        // Channel groups are only visual and are not required
        channelGroups: [NotificationChannelGroup(channelGroupKey: 'basic_channel_group', channelGroupName: 'Basic group')],
        debug: true);
  }

  // static setListener() {
  //   AwesomeNotifications().setListeners(
  //     onActionReceivedMethod: (receivedAction) {
  //       print("receivedAction is ${receivedAction.title}");
  //       print("receivedAction is ${receivedAction.body}");
  //       print("receivedAction is ${receivedAction.buttonKeyPressed}");
  //       return Future.value(true);
  //     },
  //     onNotificationCreatedMethod: (receivedNotification) {
  //       print("receivedNotification onNotificationCreatedMethod ${receivedNotification.title}");
  //       print("receivedNotification onNotificationCreatedMethod ${receivedNotification.actionType}");
  //       print("receivedNotification onNotificationCreatedMethod ${receivedNotification.bigPicturePath}");
  //       print("receivedNotification onNotificationCreatedMethod ${receivedNotification.largeIcon}");
  //       return Future.value(true);
  //     },
  //     onNotificationDisplayedMethod: (receivedNotification) {
  //       print("receivedNotification onNotificationDisplayedMethod ${receivedNotification.title}");
  //       print("receivedNotification onNotificationDisplayedMethod ${receivedNotification.actionType}");
  //       print("receivedNotification onNotificationDisplayedMethod ${receivedNotification.bigPicturePath}");
  //       print("receivedNotification onNotificationDisplayedMethod ${receivedNotification.largeIcon}");
  //       return Future.value(true);
  //     },
  //     onDismissActionReceivedMethod: (receivedAction) {
  //       print("receivedAction is onDismissActionReceivedMethod ${receivedAction.title}");
  //       print("receivedAction is onDismissActionReceivedMethod ${receivedAction.body}");
  //       print("receivedAction is onDismissActionReceivedMethod ${receivedAction.buttonKeyPressed}");
  //       print("object");
  //       return Future.value(true);
  //     },
  //   );
  // }

  sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    required String postId,
    Map? data,
  }) async {
    await APIService().callAPI(
        params: {},
        formDataMap: jsonEncode({
          "to": fcmToken,
          "notification": {
            "title": title,
            "body": body,
            "mutable_content": true,
            "sound": "Tri-tone",
          },
          "data": data ?? {"postId": postId}
        }),
        serviceUrl: "https://fcm.googleapis.com/fcm/send",
        headers: {"Content-Type": "application/json", "Authorization": "key=$serverKey"},
        method: APIService.postMethod,
        success: (dio.Response response) {
          print(" ::: : Successfully sent notification");
        },
        error: (dio.Response response) {
          print(" ::: : error in while sent notification ${response.data}");
        },
        showProcess: false);
  }

  sendNotificationToUserID({required String userId, required String title, required String body, required String postId, Map? map}) async {
    await APIService().callAPI(
        params: {},
        serviceUrl: "${EndPoints.baseUrl}user/get_firebase_token",
        // headers: {"user_id": userId},
        formDatas: dio.FormData.fromMap({"user_id": userId}),
        method: APIService.postMethod,
        success: (dio.Response response) {
          Map<String, dynamic> dataMap = jsonDecode(response.data);
          if (dataMap['token'] != null) {
            sendNotification(
              fcmToken: dataMap['token'],
              title: title,
              body: body,
              postId: postId,
              data: map,
            );
          }
        },
        error: (dio.Response response) {},
        showProcess: false);
  }

  setFCMbyUserID() async {
    userId = await fetchStringValuesSF(SessionManagement.KEY_ID);
    FirebaseMessaging.instance.getToken().then((value) {
      print(" FCM Token is :::: ${value} ::::");
      if (value != null) {
        APIService().callAPI(
            params: {},
            serviceUrl: "${EndPoints.baseUrl}user/update_firebase_token",
            // headers: {},
            formDatas: dio.FormData.fromMap({"user_id": userId, "token": value}),
            method: APIService.postMethod,
            success: (dio.Response response) async {
              print(" Set Token Successfully");
            },
            error: (dio.Response response) {
              print(" Error while set token");
            },
            showProcess: false);
      }
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      APIService().callAPI(
          params: {},
          serviceUrl: "${EndPoints.baseUrl}user/update_firebase_token",
          // headers: {},
          formDatas: dio.FormData.fromMap({"user_id": userId, "token": fcmToken}),
          method: APIService.postMethod,
          success: (dio.Response response) async {
            await FirebaseMessaging.instance.subscribeToTopic("general");
            print(" Set Token Successfully");
          },
          error: (dio.Response response) {
            print(" Error while set token");
          },
          showProcess: false);
    }).onError((err) {
      // Error getting token.
    });
  }

  Rx<NotificationPostModel> notificationPostModel = NotificationPostModel().obs;

  getPostById({required String postID}) async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;
    await APIService().callAPI(
        params: {},
        serviceUrl: "${EndPoints.baseUrl}wire/get_single_wire/$postID/$userId",
        // headers: {},
        method: APIService.postMethod,
        success: (dio.Response response) {
          print(" >>>>>>> response.data >>>>>> ${response.data}");
          // print(" >>>>>>> JSON ${jsonDecode(response.data['feed'].first)}");
          notificationPostModel.value = NotificationPostModel.fromJson(jsonDecode(response.data));
          print(" >>>>>>> Model ${notificationPostModel.value.feed?.first?.name}");
        },
        error: (dio.Response response) {
          print(" Error while set token");
        },
        showProcess: true);
  }
}
