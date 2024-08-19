import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/utils/button.dart';

import '../../../services/sesssion.dart';
import '../../../utils/app_methods.dart';
import '../../auth_module/model/login_model.dart';
import '../controller/agora_controller.dart';

class CreateRoomDialog extends StatefulWidget {
  final String roomId;

  const CreateRoomDialog({super.key, required this.roomId});
  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final agora_controller = Get.put(AgoraController());

  TimeOfDay selectedTime = TimeOfDay.now();
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        });
    if (picked_s != null) {
      final now = new DateTime.now();
      final utc = DateTime(
          now.year, now.month, now.day, picked_s.hour, picked_s.minute);

      LoginModel userDetails = await SessionManagement.getUserDetails();
      String username = "${userDetails.fname} ${userDetails.lname}";
      AppMethods().share(
          string:
              "$username invites you to join a video meeting in MCSN at ${picked_s.format(context)} ${utc.timeZoneName}\nRoom ID: ${widget.roomId.toUpperCase()}",
          context: context);
    }
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Text(
                  "ID : " + widget.roomId.toUpperCase(),
                  style: const TextStyle(
                      color: Color(0xFF1A1E78),
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.roomId))
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Room id copied to clipboard")));
                      });
                    },
                    icon: const Icon(
                      Icons.copy_outlined,
                      color: Color(0xFF1A1E78),
                      size: 20,
                    ))
              ],
            ),
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
                            "$username invites you to join a video meeting in MCSN\nRoom ID: ${widget.roomId.toUpperCase()}",
                        context: context);
                  }),
              SizedBox(height: Get.height * 0.01),
              customButton(
                  title: "Schedule Meeting",
                  onTap: () {
                    _selectTime(context);
                  }),
              SizedBox(height: Get.height * 0.02),
              Divider(),
              SizedBox(height: Get.height * 0.02),
              customButton(
                title: "Join",
                onTap: () async {
                  bool isPermissionGranted = await AppMethods().getPermission();

                  if (isPermissionGranted == true) {
                    agora_controller.makeVideoCAll(channelName: widget.roomId);
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
