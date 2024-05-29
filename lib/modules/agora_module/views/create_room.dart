import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/utils/button.dart';

import '../../../utils/app_methods.dart';
import '../helper/utils.dart';
import 'meeting_screen.dart';

class CreateRoomDialog extends StatefulWidget {
  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  String roomId = "";
  @override
  void initState() {
    roomId = generateRandomString(8);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Room Created"),
          IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(Icons.close))
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Room id : " + roomId,
            style: TextStyle(color: const Color(0xFF1A1E78)),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              customButton(
                  title: "Share",
                  onTap: () {
                    AppMethods().share(string: roomId, context: context);
                  }),
              SizedBox(height: Get.height * 0.02),
              customButton(
                title: "Join",
                onTap: () async {
                  bool isPermissionGranted = await AppMethods().getPermission();
                  if (isPermissionGranted == true) {
                    Get.to(const MeetingScreen(),
                        arguments: {"channelName": roomId});
                  } else {
                    Get.snackbar("Failed",
                        "Microphone Permission Required for Video Call.",
                        backgroundColor: Colors.white,
                        colorText: Color(0xFF1A1E78),
                        snackPosition: SnackPosition.BOTTOM);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
