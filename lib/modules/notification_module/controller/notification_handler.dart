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

import '../../../services/call_services.dart';
import '../../agora_module/views/meeting_screen.dart';
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
        // if (event.data.keys.contains("agora_token")) {
        //   createNotification(event);
        // Map<String, String> stringQueryParameters =
        //     event.data.map((key, value) => MapEntry(key, value.toString()));
        // makeCallInComing(
        //     title: event.notification!.title.toString(),
        //     body: event.notification!.body.toString(),
        //     data: stringQueryParameters);
        // } else {
        createNotification(event);
        //  }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print(":::: >>>>>> onMessageOpenedApp ${event.notification?.body}");
      print(":::: >>>>>> onMessageOpenedApp ${event.notification?.title}");
      print(":::: >>>>>> onMessageOpenedApp ${event.data}");
      handleMessage(event);
    });
  }

//   Video Call
// Mofijul is calling you..
// android {channelId: null, clickAction: null, color: null, count: null, imageUrl: null, link: null, priority: 0, smallIcon: https%3A%2F%2Fwhatgodhasdoneforme.com%2Fimages%2Ffavicon%2Ffavicon.png, sound: Tri-tone, ticker: null, tag: null, visibility: 0}
//  data {notify_type: video_call, agora_token: 006b244cfdf7c4f43d897eff4bd406b87b7IADIHXl2BUaD8jL+zE8KxLhXOs+IT2b5rq/plUqcdVAHfBW/NfEAAAAAIgDsKAAAx8JiZgQAAQBXf2FmAwBXf2FmAgBXf2FmBABXf2Fm, agora_channel: test_123, caller_firstname: Mofijul, caller_lastname: Hasan, caller_img: 1705479582.jpg}

  createNotification(RemoteMessage event) {
    int i = 1;
    Map<String, String> payLoadData = {};

    event.data.forEach((key, value) {
      payLoadData.addAll({key: value.toString()});
    });
    if (event.data.keys.contains("notify_type")) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: i,
            channelKey: 'firebase',
            title: "${event.notification?.title}",
            body: "${event.notification?.body}",
            wakeUpScreen: true,
            fullScreenIntent: true,
            locked: true,
            actionType: ActionType.Default,
            roundedBigPicture: true,
            notificationLayout: NotificationLayout.Default,
            // bigPicture: "${event.notification?.android?.imageUrl}",
            payload: payLoadData),
        actionButtons: [
          NotificationActionButton(
              key: 'decline', label: 'Decline', enabled: true),
          NotificationActionButton(
              key: 'answer', label: 'Answer', enabled: true),
        ],
      ).then((value) {
        i++;
      });
    } else {
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
        i++;
      });
    }
  }

  handleMessage(RemoteMessage message) {
    print("Payload:::::${message.data}");
    if (message.data.keys.contains("notify_type")) {
      Get.to(
        () => MeetingScreen(
          userName:
              "${message.data["caller_firstname"]} ${message.data["caller_lastname"]}",
          uid: userId,
          token: message.data["agora_token"],
          channelName: message.data["agora_channel"],
        ),
      );
    }
    if (message.data.keys.contains("GroupID")) {
      Get.to(() => GroupDetailsScreen(groupId: "${message.data["GroupID"]}"));
      return;
    }
    if (message.data.keys.contains("postId")) {
      Get.to(() =>
          NotificationPostDetailsScreen(postId: "${message.data["postId"]}"));
      return;
    }
    if (message.data.keys.contains("notificationId")) {
      Get.to(() => const MessageScreens());
    }
  }

  initializeHandler() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    AwesomeNotifications().initialize(
        'resource://drawable/ic_launcher',
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              ledColor: Colors.white),
          NotificationChannel(
            channelGroupKey: 'firebase',
            channelKey: 'firebase',
            channelName: 'firebase notifications',
            channelDescription: 'Notification channel for call services',
            ledColor: Colors.white,
            defaultRingtoneType: DefaultRingtoneType.Ringtone,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
            locked: true,
            importance: NotificationImportance.Max,
          ),
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true);
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) {
        return onActionReceivedMethod(receivedAction);
      },
    );
    //setListener();
  }

  sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    required String postId,
    Map? data,
  }) async {
    print(serverKey);
    await APIService().callAPI(
        params: {},
        formDataMap: jsonEncode(<String, dynamic>{
          "to": fcmToken,
          'priority': 'high',
          "notification": <String, dynamic>{
            "title": title,
            "body": body,
            "mutable_content": true,
            "sound": "Tri-tone",
          },
          "data": data ?? {"postId": postId}
        }),
        serviceUrl: "https://fcm.googleapis.com/fcm/send",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "key=$serverKey"
        },
        method: APIService.postMethod,
        success: (dio.Response response) {
          print(" ::: : Successfully sent notification");
        },
        error: (dio.Response response) {
          print(" ::: : error in while sent notification ${response.data}");
        },
        showProcess: false);
  }

  sendNotificationToUserID(
      {required String userId,
      required String title,
      required String body,
      required String postId,
      Map? map}) async {
    await APIService().callAPI(
        params: {},
        serviceUrl: "${EndPoints.baseUrl}user/get_firebase_token",
        // headers: {"user_id": userId},
        formDatas: dio.FormData.fromMap({"user_id": userId}),
        method: APIService.postMethod,
        success: (dio.Response response) {
          Map<String, dynamic> dataMap = jsonDecode(response.data);
          if (dataMap['token'] != null) {
            print(dataMap['token']);
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
            formDatas:
                dio.FormData.fromMap({"user_id": userId, "token": value}),
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
          formDatas:
              dio.FormData.fromMap({"user_id": userId, "token": fcmToken}),
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

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint(receivedAction.buttonKeyPressed.toString());
    if (receivedAction.payload != null) {
      print(" Local Notification Payload is ${receivedAction.payload}");
      if (receivedAction.channelKey == 'firebase' &&
          receivedAction.buttonKeyPressed == "answer") {
        Get.to(
          () => MeetingScreen(
            userName:
                "${receivedAction.payload!["caller_firstname"]} ${receivedAction.payload?["caller_lastname"]}",
            uid: userId,
            token: receivedAction.payload!["agora_token"].toString(),
            channelName: receivedAction.payload!["agora_channel"].toString(),
          ),
        );
      }
      if (receivedAction.payload?.containsKey("postId") == true) {
        Get.to(() => NotificationPostDetailsScreen(
            postId: "${receivedAction.payload?['postId']}"));
      }
      if (receivedAction.payload?.containsKey("notificationId") == true) {
        Get.to(() => MessageScreens());
      }
    }
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
          notificationPostModel.value =
              NotificationPostModel.fromJson(jsonDecode(response.data));
          print(
              " >>>>>>> Model ${notificationPostModel.value.feed?.first?.name}");
        },
        error: (dio.Response response) {
          print(" Error while set token");
        },
        showProcess: true);
  }
}
