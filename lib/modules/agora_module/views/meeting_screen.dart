import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/utils/app_methods.dart';

import '../controller/agora_controller.dart';
import '../helper/count_down_timer.dart';

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
    print(widget.userName);
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
         uid:int.parse(widget.uid),
         // uid: DateTime.now().microsecond,
          // channelName: Get.arguments['channelName'],
          // username: Get.arguments['userName'],
          // tempToken: Get.arguments['token'],
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
            controller.setActiveUserName(uid:uid,currentUserId: widget.uid);

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
        ));

    controller.agoraGetData(channelName: widget.channelName);
    initAgora();
  }

@override
  void dispose() {
    // TODO: implement dispose
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

    return Scaffold(
      body: GetBuilder<AgoraController>(
        builder: (api) {
          print(api.activeUsers);
         // print(client.engine.getUserInfoByUid(int.parse(widget.uid)));
          return SafeArea(
            child: Stack(
              children: [
                AgoraVideoViewer(
                  client: client,
                  layoutType: Layout.floating,
                  enableHostControls: true, // Add this to enable host controls
                  showNumberOfUsers: true,
                  showAVState: true,
                ),
                AgoraVideoButtons(
                  client: client,
                  addScreenSharing: true, // Add this to enable screen sharing
                ),
                Positioned(
                    top: api.activeUsers.isEmpty
                        ? Get.height * 0.03
                        : Get.height * 0.21,
                    left: 10,
                    child: const CountDownTimer(startTimer: true)),
                Positioned(
                  top: api.activeUsers.isEmpty
                      ? Get.height * 0.05
                      : Get.height * 0.25,
                  left: 10,
                  child: Text(api.activeUserName ?? widget.userName.toString()),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
