import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wghdfm_java/services/prefrence_services.dart';
import 'package:wghdfm_java/utils/app_methods.dart';

import '../../../custom_package/agora_ui_kit/agora_uikit.dart';
import '../controller/agora_controller.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen(
      {super.key,
      required this.channelName,
      required this.token,
      required this.userName,
      required this.uid});
  final String channelName;
  final String token;
  final String uid;
  final String userName;

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late AgoraClient client;
  final controller = Get.put(AgoraController());

// Initialize the Agora Engine
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    storeStringToSF("channelName", widget.channelName);
    storeStringToSF("token", widget.token);
    storeStringToSF("uid", widget.uid);
    storeStringToSF("userName", widget.userName);
    controller.startTimer();
    controller.agoraSaveUser(
        channelName: widget.channelName,
        userId: widget.uid,
        uid: widget.uid,
        userName: widget.userName,
        userImage: "akash.jpg");
    client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          appId: "2cd0fb4c3f5a4168b8e678a77ffdfd43",
          channelName: widget.channelName,
          username: widget.userName,
          tempToken: widget.token,
          screenSharingEnabled: true,
          rtmUid: widget.uid,
          uid: int.parse(widget.uid),
        ),
        enabledPermission: [
          Permission.camera,
          Permission.microphone,
        ],
        agoraChannelData: AgoraChannelData(
          channelProfileType: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleAudience,
        ),
        agoraEventHandlers: AgoraRtcEventHandlers(
          onUserJoined: (connection, remoteUid, elapsed) {
            print("Remote Id >>>>>>");
            print(remoteUid);

            // controller.userNames[remoteUid] = 'User $remoteUid';

            controller.agoraGetData(channelName: widget.channelName);
          },
          onActiveSpeaker: (connection, uid) {
            print("active speaker");
            controller.setActiveUserName(uid: uid, change_name: true);
          },
          onVideoSubscribeStateChanged:
              (channel, uid, oldState, newState, elapseSinceLastState) {
            print(uid);
            controller.setActiveUserName(uid: uid, change_name: true);
          },
        ),
        agoraRtmChannelEventHandler: AgoraRtmChannelEventHandler(
          onMemberJoined: (member) {
            print("Member ====>>>>");
            print(member.userId);
            controller.agoraGetData(channelName: widget.channelName);
          },
        ),
        agoraRtmClientEventHandler: AgoraRtmClientEventHandler(
          onMessageReceived: (message, peerId) {
            print("Message ====>>>");
            print(message);
          },
        ),
        controller: controller);

    controller.agoraGetData(channelName: widget.channelName);

    initAgora();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Wakelock.disable();
    controller.stopTimer();
    FlPiP().disable();
    controller.activeUsers.clear();
    controller.activeUserName = null;

    AppMethods().deleteCacheDir();
    super.dispose();
  }

  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop == false) {
          FlPiP().toggle(AppState.background);
          FlPiP().enable(
              ios: const FlPiPiOSConfig(packageName: "com.wghdfmapp"),
              android: const FlPiPAndroidConfig(
                  aspectRatio: Rational.vertical(),
                  packageName: "com.wghdfmapp"));
        }
      },
      child: Scaffold(
        body: GetBuilder<AgoraController>(builder: (api) {
          return PiPBuilder(builder: (PiPStatusInfo? statusInfo) {
            return SafeArea(
              child: Stack(
                children: [
                  AgoraVideoViewer(
                    client: client,
                    controller: api,
                    layoutType: Layout.floating,
                    enableHostControls:
                        statusInfo!.status == PiPStatus.disabled ? true : false,
                    showNumberOfUsers:
                        statusInfo.status == PiPStatus.disabled ? true : false,
                    showAVState:
                        statusInfo.status == PiPStatus.disabled ? true : false,
                    showPin:
                        statusInfo.status == PiPStatus.disabled ? true : false,
                  ),
                  if (statusInfo.status == PiPStatus.disabled)
                    AgoraVideoButtons(
                      client: client,
                      autoHideButtons: true,
                      extraButtons: [
                        RawMaterialButton(
                          onPressed: () {
                            FlPiP().toggle(AppState.background);
                            FlPiP().enable(
                                ios: const FlPiPiOSConfig(
                                  
                                    packageName: "com.wghdfmapp"),
                                android: const FlPiPAndroidConfig(
                                    aspectRatio: Rational.vertical(),
                                    packageName: "com.wghdfmapp"));
                          },
                          child: Icon(
                            MingCute.expand_player_line,
                            color: Colors.blueAccent,
                            size: 20.0,
                          ),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          fillColor: Colors.white,
                          padding: const EdgeInsets.all(12.0),
                        )
                      ],
                      addScreenSharing:
                          true, // Add this to enable screen sharing
                    ),
                  if (statusInfo.status == PiPStatus.disabled)
                    Positioned(
                        top: api.activeUsers.isEmpty
                            ? Get.height * 0.03
                            : Get.height * 0.21,
                        left: 10,
                        child: Text(api.formatTime(api.duration.value),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white))),
                  if (statusInfo.status == PiPStatus.disabled)
                    Positioned(
                      top: api.activeUsers.isEmpty
                          ? Get.height * 0.05
                          : Get.height * 0.25,
                      left: 10,
                      child: Text(
                        api.activeUserName ?? widget.userName.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  if (statusInfo.status == PiPStatus.enabled)
                    Positioned(
                      bottom: Get.height * 0.02,
                      left: 10,
                      child: Text(
                        api.activeUserName ?? widget.userName.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 10),
                      ),
                    ),
                ],
              ),
            );
          });
        }),
      ),
    );
  }
}
