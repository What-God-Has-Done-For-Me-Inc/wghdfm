import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/model/my_messages_res_obj.dart';
import 'package:wghdfm_java/screen/messages/apis.dart';
import 'package:wghdfm_java/screen/messages/message_controller.dart';
import 'package:wghdfm_java/screen/messages/message_thread_ui.dart';
import 'package:wghdfm_java/services/navigator_services.dart';
import 'package:wghdfm_java/utils/shimmer_utils.dart';

import '../../modules/dashbord_module/controller/dash_board_controller.dart';

class MessageThreadsUI extends StatefulWidget {
  MessageThreadsUI();

  @override
  _MessageThreadsUIState createState() => _MessageThreadsUIState();
}

class _MessageThreadsUIState extends State<MessageThreadsUI> {
  final messageController = Get.put(MessageController());

  @override
  void initState() {
    // TODO: implement initState
    messageController.loadMessageThreads();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint("After: $id");
    //likeList(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Message(s)',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: StatefulBuilder(
        builder: (context, setState) {
          return StreamBuilder(
            stream: messageController.messages?.stream,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerFeedLoading();
              }

              if (snapshot.hasError) {
                return Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  // child: customText(
                  //     title: "We are working on it :"), // ${snapshot.error}
                );
              }

              if (messageController.messages?.isEmpty == true) {
                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    alignment: Alignment.center,
                    child: customText(title: "You don't have any messages"),
                  ),
                );
              }
              return CustomScrollView(
                shrinkWrap: false,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return listItem(index, setState);
                        //return SizedBox();
                      },
                      childCount: messageController.messages?.length ??
                          0, // 1000 list items
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget shimmerFeedLoading() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    shimmerMeUp(
                      const CircleAvatar(
                        child: SizedBox(width: 70, height: 70),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          shimmerMeUp(Container(
                            height: 20,
                            width: Get.width,
                            color: Colors.grey,
                          )),
                          const SizedBox(
                            height: 5,
                          ),
                          shimmerMeUp(Container(
                            height: 20,
                            width: Get.width * 0.5,
                            color: Colors.grey,
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget listItem(int index, setState) {
    String? messageId = messageController.messages?[index].id;
    return Dismissible(
      // Each Dismissible must contain a Key. Keys allow Flutter to
      // uniquely identify widgets.
      key: Key(messageId!),
      // Provide a function that tells the app
      // what to do after an item has been swiped away.
      onDismissed: (direction) {
        // Remove the item from the data source.

        deleteMessageThread(messageController.messages?[index].id).then((_) {
          setState(() {});
        });

        // Then show a snackbar.
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$item dismissed')));
      },
      child: InkWell(
        onTap: () {
          pushOnlyTo(
              widget: MessageThreadUI(
                  messageController.messages?[index] ?? MessageObj()));
        },
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          //margin: EdgeInsets.all(10),
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
                        child: ClipOval(
                          child: CachedNetworkImage(
                            alignment: Alignment.center,
                            fit: BoxFit.fill,
                            imageUrl:
                                "${messageController.messages?[index].profilePic}",
                            placeholder: (context, url) => Container(
                              padding: const EdgeInsets.all(3),
                              child: shimmerMeUp(CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.secondary),
                              )),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      flex: 8,
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: (messageController.messages?[index].userId ==
                                  userId)
                              ? "ME"
                              : messageController.messages?[index].name!
                                  .toUpperCase()
                                  .trim(),
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 15.0,
                            height: 1.8,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "\n" +
                                  "${messageController.messages?[index].message}",
                              style: GoogleFonts.montserrat(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
