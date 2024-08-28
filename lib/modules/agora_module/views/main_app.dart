import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';

import '../../../custom_package/agora_ui_kit/agora_uikit.dart';
import '../../../utils/app_methods.dart';
import '../controller/agora_controller.dart';

class MainAppOne extends StatefulWidget {
  const MainAppOne({super.key});

  @override
  State<MainAppOne> createState() => _MainAppOneState();
}

class _MainAppOneState extends State<MainAppOne> {
  late AgoraClient client;
  final controller = Get.put(AgoraController());

// Initialize the Agora Engine
  @override
  void initState() {
    super.initState();

    controller.getData();

    Wakelock.enable();
    Future.delayed(const Duration(seconds: 5), () {
      controller.agoraSaveUser(
          channelName: controller.channelName.toString(),
          userId: controller.uid.toString(),
          uid: controller.uid.toString(),
          userName: controller.userName.toString(),
          userImage: "akash.jpg");
      client = AgoraClient(
          agoraConnectionData: AgoraConnectionData(
            appId: "2cd0fb4c3f5a4168b8e678a77ffdfd43",
            channelName: controller.channelName.toString(),
            username: controller.userName.toString(),
            tempToken: controller.token.toString(),
            screenSharingEnabled: true,
            rtmUid: controller.uid.toString(),
            uid: int.parse(controller.uid.toString()),
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

              controller.agoraGetData(
                  channelName: controller.channelName.toString());
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
              controller.agoraGetData(
                  channelName: controller.channelName.toString());
            },
          ),
          agoraRtmClientEventHandler: AgoraRtmClientEventHandler(
            onMessageReceived: (message, peerId) {
              print("Message ====>>>");
              print(message);
            },
          ),
          controller: controller);

      controller.agoraGetData(channelName: controller.channelName.toString());

      initAgora();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Wakelock.disable();
    controller.activeUsers.clear();
    controller.activeUserName = null;
    FlPiP().disable();
    AppMethods().deleteCacheDir();
    super.dispose();
  }

  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AgoraController>(builder: (api) {
        if (api.token == null || api.uid == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: client,
                controller: api,
                layoutType: Layout.floating,
                enableHostControls: false, // Add this to enable host controls
                showNumberOfUsers: true,
                showAVState: false,
              ),
              AgoraVideoButtons(
                client: client,
                autoHideButtons: true,
                addScreenSharing: false, // Add this to enable screen sharing
              ),
              Positioned(
                bottom: Get.height * 0.05,
                left: 10,
                child: Text(
                  api.activeUserName ?? controller.userName.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 10),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  onPressed: () {
                    FlPiP().disable();
                  },
                  icon: Icon(
                    Icons.fullscreen_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
