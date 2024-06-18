import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/utils/endpoints.dart';
import '../modules/agora_module/views/meeting_screen.dart';

Future<void> callbackTask() async {
  // Register call event listener
  print('Callback task executed');
  ConnectycubeFlutterCallKit.provideFullScreenIntentAccess();
  ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);
  callBackground();
  ConnectycubeFlutterCallKit.instance.init(
    onCallAccepted: _onCallAccepted,
    onCallRejected: _onCallRejected,
    onCallIncoming: _onCallIncoming,
  );
}

Future<void> callBackground() async {
  ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated =
      onCallRejectedWhenTerminated;
  ConnectycubeFlutterCallKit.onCallAcceptedWhenTerminated =
      onCallAcceptedWhenTerminated;
  ConnectycubeFlutterCallKit.onCallIncomingWhenTerminated =
      onCallIncomingWhenTerminated;
}

Future<void> _onCallAccepted(CallEvent callEvent) async {
  print("Answare Call");
  print(callEvent.toJson());
  print(callEvent.userInfo!["profile_id"]);
  print(callEvent.userInfo!["caller_firstname"]);
  print(callEvent.userInfo!["caller_lastname"]);
  print(callEvent.userInfo!["agora_channel"]);
  print(callEvent.userInfo!["agora_token"]);
  Get.to(
    () => MeetingScreen(
      userName:
          "${callEvent.userInfo!["caller_firstname"]} ${callEvent.userInfo!["caller_lastname"]}",
      token: callEvent.userInfo!["agora_token"].toString(),
      channelName: callEvent.userInfo!["agora_channel"].toString(),
    ),
    // arguments: {
    //   "userId": callEvent.userInfo!["profile_id"],
    //   "userName":
    //       "${callEvent.userInfo!["caller_firstname"]} ${callEvent.userInfo!["caller_lastname"]}",
    //   "channelName": callEvent.userInfo!["agora_channel"],
    //   "token": callEvent.userInfo!["agora_token"]
    // },
  );
  // the call was accepted
}

Future<void> _onCallRejected(CallEvent callEvent) async {
  print("Reject Call");
  // the call was rejected
}

Future<void> _onCallIncoming(CallEvent callEvent) async {
  print("Call Incoming");
  // the Incoming call screen/notification was shown for user
}

@pragma('vm:entry-point')
Future<void> onCallRejectedWhenTerminated(CallEvent callEventHandler) async {
  print("Background Call Reject");
}

@pragma('vm:entry-point')
Future<void> onCallAcceptedWhenTerminated(CallEvent callEventHandler) async {
  print(callEventHandler.toJson());
  //PageRes.videoCallScreen

  Get.to(
    () => MeetingScreen(
      userName:
          "${callEventHandler.userInfo!["caller_firstname"]} ${callEventHandler.userInfo!["caller_lastname"]}",
      token: callEventHandler.userInfo!["agora_token"].toString(),
      channelName: callEventHandler.userInfo!["agora_channel"].toString(),
    ),
    // arguments: {
    //   "userId": callEventHandler.userInfo!["profile_id"],
    //   "userName":
    //       "${callEventHandler.userInfo!["caller_firstname"]} ${callEventHandler.userInfo!["caller_lastname"]}",
    //   "channelName": callEventHandler.userInfo!["agora_channel"],
    //   "token": callEventHandler.userInfo!["agora_token"]
    // },
  );
  print("Background Call Accepted");
}

@pragma('vm:entry-point')
Future<void> onCallIncomingWhenTerminated(CallEvent callEventHandler) async {}

Future<void> makeCallInComing(
    {required String title,
    required String body,
    required Map<String, String> data}) async {
  List<int> opponentsIdsList = [2]; // Assuming opponent's ID is 2
  Set<int> opponentsIds = opponentsIdsList.toSet(); // Convert list to set

  CallEvent callEvent = CallEvent(
      sessionId: data["agora_channel"].toString(),
      callType: 1,
      callerId: int.parse(data["caller_id"].toString()),
      callerName: data["caller_firstname"].toString(),
      opponentsIds: opponentsIds,
      callPhoto: EndPoints.ImageURl + data["caller_img"].toString(),
      userInfo: data);
  ConnectycubeFlutterCallKit.showCallNotification(callEvent);
}
