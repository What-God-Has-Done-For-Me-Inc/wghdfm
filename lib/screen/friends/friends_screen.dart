import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/screen/friends/friends_controller.dart';
import 'package:wghdfm_java/screen/friends/widgets/widgets.dart';

bool isSearching = false;

class FriendScreen extends StatelessWidget {
  FriendScreen({Key? key}) : super(key: key);
  final FriendsController f = Get.put(FriendsController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FriendsController>(
      init: FriendsController(),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text(
            'My Friend(s)',
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
            return Column(
              children: [
                Container(
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
                            hint: 'Search Friend',
                            isLabelFloating: false,
                            controller: f.searchTEC,
                            borderColor: Theme.of(Get.context!).primaryColor,
                            baseColor: Theme.of(Get.context!).colorScheme.secondary,
                            isLastField: true,
                            obscureText: false,
                            onChanged: (searchInput) {
                              setState(() {
                                isSearching = searchInput.isNotEmpty;
                              });
                            }),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            if (c.searchTEC.text.trim().isNotEmpty) {
                              setState(() {
                                c.searchTEC.text = '';
                                isSearching = false;
                              });
                            } else {
                              snack(icon: Icons.report_problem, iconColor: Colors.yellow, msg: "Type someone's name first... in order to search...", title: "Alert!");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    // future: reloadFriends(f),
                    initialData: f.friends?.value,
                    stream: f.friends?.stream,
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      // if (snapshot.connectionState == ConnectionState.waiting) {
                      //   return shimmerFeedLoading();
                      // }

                      if (snapshot.hasError) {
                        return Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          // child: customText(title: "We are working on it :}"), // ${snapshot.error
                        );
                      }

                      if (f.friends == null || f.friends == "null") {
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                            alignment: Alignment.center,
                            child: customText(title: isSearching ? "No friend(s) found by this name" : "You don't have any friends"),
                          ),
                        );
                      }

                      if ((isSearching ? f.searchedFriends : f.friends)!.isEmpty) {
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                            alignment: Alignment.center,
                            child: customText(title: isSearching ? "No friend(s) found by this name" : "You don't have any friends"),
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
                              },
                              childCount: isSearching
                                  ? f.searchedFriends!.length
                                  : f.friends == null
                                      ? 0
                                      : f.friends!.length,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
