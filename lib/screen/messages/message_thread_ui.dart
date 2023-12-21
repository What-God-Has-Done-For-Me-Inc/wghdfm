import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/model/my_messages_res_obj.dart';
import 'package:wghdfm_java/screen/messages/apis.dart';
import 'package:wghdfm_java/screen/messages/message_controller.dart';
import 'package:wghdfm_java/utils/shimmer_utils.dart';

class MessageThreadUI extends StatelessWidget {
  final MessageObj msgObj;

  MessageThreadUI(this.msgObj);

  @override
  Widget build(BuildContext context) {
    //debugPrint("After: $id");
    //likeList(id);
    return GetBuilder<MessageController>(
      init: MessageController(),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Direct Message(s)',
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
        body: StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              fit: StackFit.expand,
              alignment: Alignment.bottomCenter,
              children: [
                FutureBuilder(
                  future: loadConversation(msgObj.id),
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return shimmerFeedLoading();
                    }

                    if (snapshot.hasError) {
                      return Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: customText(title: "${snapshot.error}"),
                      );
                    }

                    if (conversations!.isEmpty) {
                      return Align(
                        alignment: Alignment.center,
                        child: Container(
                          alignment: Alignment.center,
                          child: customText(title: "Be the first to start conversation"),
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 60),
                      child: CustomScrollView(
                        shrinkWrap: false,
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return listItem(index, setState);
                              },
                              childCount: conversations!.length, // 1000 list items
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    height: 60,
                    color: Theme.of(Get.context!).backgroundColor,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 9,
                          child: commonTextField(
                            readOnly: false,
                            hint: 'Type what\'s on your mind',
                            isLabelFloating: false,
                            controller: c.commentTEC,
                            borderColor: Theme.of(Get.context!).primaryColor,
                            baseColor: Theme.of(Get.context!).colorScheme.secondary,
                            isLastField: true,
                            obscureText: false,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (c.commentTEC.text.trim().isNotEmpty) {
                                addMessage(msgObj, c.commentTEC.text.trim()).then((_) {
                                  setState(() {
                                    c.commentTEC.text = "";
                                    loadConversation(msgObj.id);
                                  });
                                });
                              } else {
                                snack(icon: Icons.report_problem, iconColor: Colors.yellow, msg: "Type something first...", title: "Alert!");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
                    /*SizedBox(
                      width: 5,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: shimmerMeUp(
                        Icon(
                          FlutterIcons.report_problem_mdi,
                        ),
                      ),
                    ),*/
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
    return Card(
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
                    child: InkWell(
                      onTap: () {
                        Get.to(
                          () => InteractiveViewer(
                            child: CachedNetworkImage(
                              alignment: Alignment.center,
                              fit: BoxFit.fill,
                              imageUrl: conversations![index].profilePic!,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                      child: ClipOval(
                        child: CachedNetworkImage(
                          alignment: Alignment.center,
                          fit: BoxFit.fill,
                          imageUrl: conversations![index].profilePic!,
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
                Expanded(
                  flex: 8,
                  child: RichText(
                    text: TextSpan(
                      text: conversations![index].name!.toUpperCase().trim(),
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 15.0,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "\n" + conversations![index].timeStamp!,
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
          const Divider(),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                height: 40,
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Expanded(
                  child: Text(
                    conversations![index].message!.trim(),
                    style: GoogleFonts.montserrat(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
