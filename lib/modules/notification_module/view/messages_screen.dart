import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/notification_module/models/messages_model.dart';
import 'package:wghdfm_java/utils/endpoints.dart';
import 'package:wghdfm_java/utils/shimmer_utils.dart';

import '../../../common/common_snack.dart';
import '../../../services/sesssion.dart';
import '../../auth_module/model/login_model.dart';
import '../../profile_module/controller/profile_controller.dart';
import '../controller/notification_handler.dart';

class MessageScreens extends StatefulWidget {
  const MessageScreens({Key? key}) : super(key: key);

  @override
  State<MessageScreens> createState() => _MessageScreensState();
}

class _MessageScreensState extends State<MessageScreens> {
  DashBoardController dashBoardController = Get.put(DashBoardController());
  final profileController = Get.put(ProfileController());
  RxString myId = "".obs;

  isOwn() async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    myId.value = userDetails.id ?? "";
  }

  @override
  void initState() {
    isOwn();
    dashBoardController.getMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: dashBoardController.messagesModel.stream,
              builder: (context, snapshot) => ListView.builder(
                itemCount: dashBoardController.messagesModel.value.messagesData?.length ?? 0,
                itemBuilder: (context, index) {
                  return listItem(messagesData: dashBoardController.messagesModel.value.messagesData?[index] ?? AllMessagesModelMessagesData());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listItem({required AllMessagesModelMessagesData messagesData}) {
    RxBool isReplyOpen = false.obs;
    final formKey = GlobalKey<FormState>();
    TextEditingController messageController = TextEditingController();

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ClipOval(
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).iconTheme.color,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Theme.of(Get.context!).iconTheme.color!,
                        width: 1,
                      ),
                    ),
                    margin: const EdgeInsets.all(5),
                    padding: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () {
                        // Get.to(
                        //   () => InteractiveViewer(
                        //     child: CachedNetworkImage(
                        //       alignment: Alignment.center,
                        //       fit: BoxFit.fill,
                        //       imageUrl: "${commentController.commentList?[index]?.img}",
                        //       placeholder: (context, url) => const CircularProgressIndicator(),
                        //       errorWidget: (context, url, error) => const Icon(Icons.error),
                        //     ),
                        //   ),
                        // );
                      },
                      child: ClipOval(
                        child: CachedNetworkImage(
                          alignment: Alignment.center,
                          fit: BoxFit.fill,
                          imageUrl: "${EndPoints.ImageURl}${messagesData.img}",
                          placeholder: (context, url) => Container(
                            padding: const EdgeInsets.all(3),
                            child: shimmerMeUp(CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                            )),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                RichText(
                  text: TextSpan(
                    text: "${messagesData.firstname} ${messagesData.lastname}",
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 15.0,
                      height: 1.8,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "\n${messagesData.date}",
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // if (userId == messagesData.userId) const Spacer(),
                // if (userId == messagesData.userId)
                //   IconButton(
                //       onPressed: () async {},
                //       icon: const Icon(
                //         Icons.delete_outline,
                //         color: Colors.red,
                //       ))
              ],
            ),
          ),
          const Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${messagesData.message}".trim(),
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Visibility(
                visible: messagesData.userId != myId.value,
                child: InkWell(
                  onTap: () {
                    isReplyOpen.value = true;
                  },
                  child: Text(
                    "Reply",
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              )
            ],
          ).paddingOnly(left: 10, right: 10, bottom: 10),
          StreamBuilder(
              stream: isReplyOpen.stream,
              builder: (context, snapshot) {
                return Visibility(
                    visible: isReplyOpen.value,
                    child: Form(
                      key: formKey,
                      child: Row(
                        children: [
                          Flexible(
                            child: TextFormField(
                              controller: messageController,
                              decoration: InputDecoration(
                                hintText: "Enter reply here...",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              validator: (value) {
                                return (value?.isNotEmpty ?? false) ? null : "Please enter a reply";
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  profileController.addMessage(
                                      userID: messagesData.id,
                                      message: messageController.text,
                                      callBack: () async {
                                        snack(title: "Success", msg: "Reply Sent Successfully");
                                        dashBoardController.getMessages();

                                        LoginModel userDetails = await SessionManagement.getUserDetails();

                                        NotificationHandler.to.sendNotificationToUserID(
                                            map: {'notificationId': messagesData.userId},
                                            postId: '',
                                            userId: messagesData.userId ?? "",
                                            title: "You have new message",
                                            body: "${userDetails.fname} ${userDetails.lname} messaged you");
                                      });
                                }
                              },
                              icon: Icon(Icons.send))
                        ],
                      ).paddingSymmetric(horizontal: 5),
                    ));
              }).paddingOnly(bottom: 10)
        ],
      ),
    );
  }
}
