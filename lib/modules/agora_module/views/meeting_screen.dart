import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen(
      {super.key,
      required this.channelName,
      required this.token,
      required this.userName});
  final String channelName;
  final String token;
  final String userName;

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late AgoraClient client;
// Initialize the Agora Engine
  @override
  void initState() {
    super.initState();
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: "2cd0fb4c3f5a4168b8e678a77ffdfd43",
        channelName: widget.channelName,
        username: widget.userName,
        tempToken: widget.token,
        // channelName: Get.arguments['channelName'],
        // username: Get.arguments['userName'],
        // tempToken: Get.arguments['token'],
      ),
      enabledPermission: [
        Permission.camera,
        Permission.microphone,
      ],
    );
    initAgora();
  }

  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(
              client: client,
              layoutType: Layout.floating,
              enableHostControls: true, // Add this to enable host controls
            ),
            AgoraVideoButtons(
              client: client,
              addScreenSharing: true, // Add this to enable screen sharing
            ),
          ],
        ),
      ),
    );
  }
}
