import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/utils/button.dart';

import '../../../services/sesssion.dart';
import '../../../utils/app_methods.dart';
import '../../auth_module/model/login_model.dart';
import '../controller/agora_controller.dart';
import '../helper/utils.dart';
import 'meeting_screen.dart';

class CreateRoomDialog extends StatefulWidget {
  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final agora_controller = Get.put(AgoraController());
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
                  onTap: () async {
                    LoginModel userDetails =
                        await SessionManagement.getUserDetails();
                    String username =
                        "${userDetails.fname} ${userDetails.lname}";
                    AppMethods().share(
                        string:
                            "$username invite you to join video meeting\nRoom ID: $roomId",
                        context: context);
                  }),
              SizedBox(height: Get.height * 0.02),
              customButton(
                title: "Join",
                onTap: () async {
                  LoginModel userDetails =
                      await SessionManagement.getUserDetails();
                  var userId = userDetails.id;
                  bool isPermissionGranted = await AppMethods().getPermission();

                  if (isPermissionGranted == true) {
                    agora_controller.makeVideoCAll(channelName: roomId);
                  } else {
                    Get.snackbar(
                        "Failed", "Permissions Required for Video Call.",
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
