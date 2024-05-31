import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  // String roomId = "";
  // String userId = "";
  // String userName = "";
  // Instantiate the client
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
        appId: "2cd0fb4c3f5a4168b8e678a77ffdfd43",
        channelName: Get.arguments['channelName'],
        username: Get.arguments['userName'],
        tempToken:
            "007eJxTYChu8v4T4xdw9/LHdQ49vXu/zU5Ndb3FMtWjxfP36bbVc9MUGIySUwzSkkySjdNME00MzSySLFLNzC0Szc3T0lLSUkyM2Wwi0xoCGRlm/vzIysgAgSA+G0N5ekZKWi4DAwBaxiMQ"),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );
// Initialize the Agora Engine
  @override
  void initState() {
    super.initState();
    // roomId = Get.arguments['channelName'] as String;
    // print(roomId);
    initAgora();
  }

  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Video Call'),
      //   centerTitle: true,
      // ),
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
