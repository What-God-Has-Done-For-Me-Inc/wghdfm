import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wghdfm_java/common/video_player.dart';
import 'package:wghdfm_java/screen/dashboard/post_details/post_details_controller.dart';

class PostDetailsScreen extends StatelessWidget {
  PostDetailsScreen({Key? key}) : super(key: key);
  final PostDetailsController p = PostDetailsController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   shadowColor: Colors.transparent,
        //   leading: IconButton(
        //     icon: const Icon(Icons.arrow_back, color: Colors.black),
        //     onPressed: () => Navigator.of(context).pop(),
        //   ),
        // ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    // separatorBuilder: (context, index) => SizedBox(height: 10),
                    // padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    // shrinkWrap: true,
                    // primary: false,

                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      p.media[index];
                      return ["mp4", "3gp"].contains(p.media[index].split(".").last)
                          ? Container(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.5),
                                  child: CommonVideoPlayer(videoLink: p.media[index]),
                                  // child: FlickVideoPlayer(
                                  //     flickManager: FlickManager(
                                  //   autoPlay: false,
                                  //   videoPlayerController: VideoPlayerController.network(p.media[index]),
                                  // )),
                                ),
                              ),
                            )
                          : ["jpg", "jpeg", "png", "gif"].contains(p.media[index].split(".").last)
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.5),
                                    child: ZoomableCachedNetworkImage(imageUrl: p.media[index]),
                                    // child: CachedNetworkImage(
                                    //     progressIndicatorBuilder: (BuildContext, String, DownloadProgress) {
                                    //       return const Center(child: CupertinoActivityIndicator());
                                    //     },
                                    //     errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                                    //     imageUrl: p.media[index]),
                                    // child: Image(
                                    //   image: NetworkImage(p.media[index]),
                                    //   fit: BoxFit.cover,
                                    // ),
                                  ),
                                )
                              : const Offstage();
                    },
                    // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //   crossAxisSpacing: 0,
                    //   childAspectRatio: 0.75,
                    //   mainAxisSpacing: 18,
                    //   crossAxisCount: 1,
                    // ),
                    itemCount: p.media.length ?? 0,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ZoomableCachedNetworkImage extends StatelessWidget {
  final String imageUrl;

  const ZoomableCachedNetworkImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => SizedBox(height: 30, width: 30, child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
