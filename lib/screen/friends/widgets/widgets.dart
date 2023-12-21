import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/screen/friends/friends_controller.dart';
import 'package:wghdfm_java/screen/friends/friends_screen.dart';
import 'package:wghdfm_java/utils/page_res.dart';
import 'package:wghdfm_java/utils/shimmer_utils.dart';

Widget listItem(int index, setState) {
  final FriendsController f = Get.find<FriendsController>();
  String? ownerId = (isSearching ? f.searchedFriends : f.friends)![index].ownerId;
  return Dismissible(
    // Each Dismissible must contain a Key. Keys allow Flutter to
    // uniquely identify widgets.
    key: Key(ownerId!),
    // Provide a function that tells the app
    // what to do after an item has been swiped away.
    onDismissed: (direction) {
      // Remove the item from the data source.
      setState(() {});
      // Then show a snackbar.
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$item dismissed')));
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
                InkWell(
                  onTap: () {
                    Get.toNamed(PageRes.profileScreen, arguments: {"profileId": (isSearching ? f.searchedFriends : f.friends)![index].ownerId, "isSelf": false});
                    // pushOnlyTo(
                    //   widget: ProfileUI(
                    //     profileId:
                    //     (isSearching ? searchedFriends : friends)![index]
                    //         .ownerId,
                    //     isSelf: false,
                    //   ),
                    // );
                  },
                  child: ClipOval(
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
                          imageUrl: (isSearching ? f.searchedFriends : f.friends)![index].profilePic!,
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
                      text: (isSearching ? f.searchedFriends : f.friends)![index].name!.toUpperCase().trim(),
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 15.0,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "\n" + (isSearching ? f.searchedFriends : f.friends)![index].address!,
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
  );
}
