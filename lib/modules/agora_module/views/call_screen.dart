import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/utils/button.dart';

import '../../../utils/app_methods.dart';
import '../helper/utils.dart';
import 'create_room.dart';
import 'join_room.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String roomId = "";
  @override
  void initState() {
    roomId = generateRandomString(8);
    AppMethods().getPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500)),
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButton(
                title: "Create Room",
                onTap: () async {
                  bool isPermissionGranted = await AppMethods().getPermission();
                  if (isPermissionGranted == true) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return CreateRoomDialog(roomId: roomId.toUpperCase());
                        });
                  }
                }),
            SizedBox(height: Get.height * 0.02),
            const Text(
              "create a unique agora room and ask others to join the same.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF1A1E78)),
            ),
            SizedBox(height: Get.height * 0.04),
            const Divider(),
            SizedBox(height: Get.height * 0.04),
            customButton(
                title: "Join Room",
                onTap: () async {
                  bool isPermissionGranted = await AppMethods().getPermission();
                  if (isPermissionGranted == true) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return JoinRoomDialog();
                        });
                  }
                }),
            SizedBox(height: Get.height * 0.02),
            const Text(
              "Join a agora room created by your friend.",
              style: TextStyle(color: Color(0xFF1A1E78)),
            ),
          ],
        ),
      ),
    );
  }
}
