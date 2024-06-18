import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/utils/button.dart';

import '../../../services/sesssion.dart';
import '../../../utils/app_methods.dart';
import '../../auth_module/model/login_model.dart';
import 'meeting_screen.dart';

class JoinRoomDialog extends StatelessWidget {
  final TextEditingController roomTxtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Join Room"),
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
          TextFormField(
            controller: roomTxtController,
            decoration: const InputDecoration(
                hintText: "Enter room id to join",
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1A1E78), width: 2)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF1A1E78), width: 2))),
            style: const TextStyle(
                color: Color(0xFF1A1E78), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          customButton(
              title: "Join Room",
              onTap: () async {
                LoginModel userDetails =
                    await SessionManagement.getUserDetails();
                var userId = userDetails.id;
                bool isPermissionGranted = await AppMethods().getPermission();

                if (isPermissionGranted == true) {
                  if (roomTxtController.text.isNotEmpty) {
                    Get.to(
                      MeetingScreen(
                        userName: "${userDetails.fname} ${userDetails.lname}",
                        token: "",
                        channelName: roomTxtController.text.trim(),
                      ),
                      // arguments: {
                      //   "userId": userId,
                      //   "userName": "${userDetails.fname} ${userDetails.lname}",
                      //   "channelName": roomTxtController.text.trim()
                      // },
                    );
                  } else {
                    Get.snackbar("Failed", "Enter Room-Id to Join.",
                        backgroundColor: Colors.white,
                        colorText: Color(0xFF1A1E78),
                        snackPosition: SnackPosition.BOTTOM);
                  }
                } else {
                  Get.snackbar("Failed", "Permissions Required for Video Call.",
                      backgroundColor: Colors.white,
                      colorText: Color(0xFF1A1E78),
                      snackPosition: SnackPosition.BOTTOM);
                }
              })
        ],
      ),
    );
  }
}
