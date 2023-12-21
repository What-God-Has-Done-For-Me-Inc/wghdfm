import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/services/sesssion.dart';

class PaypalWebRecurringScreen extends StatefulWidget {
  final int price;
  const PaypalWebRecurringScreen({Key? key, required this.price})
      : super(key: key);

  @override
  State<PaypalWebRecurringScreen> createState() =>
      _PaypalWebRecurringScreenState();
}

class _PaypalWebRecurringScreenState extends State<PaypalWebRecurringScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions settings = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(mediaPlaybackRequiresUserGesture: false),
    android: AndroidInAppWebViewOptions(),
  );

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;

  List<String> links = [
    "http",
    "https",
    "file",
    "chrome",
    "data",
    "javascript",
    "about"
  ];

  String? userId;
  @override
  void initState() {
    // TODO: implement initState
    getUserId();
    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            options: PullToRefreshOptions(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
    super.initState();
  }

  getUserId() async {
    LoginModel userDetails = await SessionManagement.getUserDetails();
    userId = userDetails.id;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: userId != null
          ? InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      'https://whatgodhasdoneforme.com/mobile/donate?user_id=$userId&amount=${widget.price}')),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              initialOptions: settings,
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
              onLoadStart: (controller, url) async {
                setState(() {
                  this.url = url.toString();
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;

                if (!links.contains(uri.scheme)) {
                  if (await canLaunchUrl(uri)) {
                    // Launch the App
                    await launchUrl(
                      uri,
                    );
                    // and cancel the request
                    return NavigationActionPolicy.CANCEL;
                  }
                }

                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                pullToRefreshController?.endRefreshing();
                print(" _____  REQUEST URL ${url.toString()}");

                if (url
                    .toString()
                    .startsWith("https://whatgodhasdoneforme.com/?token")) {
                  Navigator.of(context).pop();
                }
                // if (request.url.startsWith('http://return.example.com')) {
                //   final uri = Uri.parse(request.url);
                //   final payerID = uri.queryParameters['PayerID'];
                //   if (payerID != null) {
                //     services.executePayment(executeUrl, payerID, accessToken).then((id) {
                //       widget.onFinish(id);
                //     });
                //   }
                //   Navigator.of(context).pop();
                // }
                if (url.toString().startsWith('http://cancel.example.com')) {
                  Navigator.of(context).pop();
                }

                setState(() {
                  this.url = url.toString();
                });
                //return NavigationDecision.navigate;
              },
              onLoadError: (controller, request, i, error) {
                pullToRefreshController?.endRefreshing();
              },
            )
          : Center(child: CircularProgressIndicator()),
      // body: userId != null ? WebView(
      //   initialUrl: "https://whatgodhasdoneforme.com/mobile/donate?user_id=$userId&amount=${widget.price}",
      //   javascriptMode: JavascriptMode.unrestricted,
      //   navigationDelegate: (NavigationRequest request) {
      //     print(" _____  REQUEST URL ${request.url}");

      //     if(request.url.startsWith("https://whatgodhasdoneforme.com/?token")){
      //       Navigator.of(context).pop();
      //     }
      //     // if (request.url.startsWith('http://return.example.com')) {
      //     //   final uri = Uri.parse(request.url);
      //     //   final payerID = uri.queryParameters['PayerID'];
      //     //   if (payerID != null) {
      //     //     services.executePayment(executeUrl, payerID, accessToken).then((id) {
      //     //       widget.onFinish(id);
      //     //     });
      //     //   }
      //     //   Navigator.of(context).pop();
      //     // }
      //     if (request.url.startsWith('http://cancel.example.com')) {
      //       Navigator.of(context).pop();
      //     }
      //     return NavigationDecision.navigate;
      //   },
      // ) : Center(child: CircularProgressIndicator()),
    );
  }
}
