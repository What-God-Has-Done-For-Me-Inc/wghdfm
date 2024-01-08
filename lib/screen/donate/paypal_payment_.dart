import 'dart:collection';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wghdfm_java/screen/donate/paypal_services.dart';
import 'package:wghdfm_java/utils/app_colors.dart';
import 'package:wghdfm_java/utils/validation_utils.dart';

class PaypalPayment extends StatefulWidget {
  const PaypalPayment({super.key});

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  PaypalServices services = PaypalServices();

  var immediatePay = '';
  var instantFundingSource = 'INSTANT_FUNDING_SOURCE';
  var paymentMethod;

  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions settings = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(mediaPlaybackRequiresUserGesture: false),
    android: AndroidInAppWebViewOptions(),
  );

  PullToRefreshController? pullToRefreshController;

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

  @override
  void initState() {
    super.initState();
    paymentMethod = instantFundingSource;
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

    // Future.delayed(Duration.zero, () async {
    //   try {
    //     accessToken = await services.getAccessToken();

    //     // final transactions = getOrderParams();
    //     final transactions = getRecurringParams();
    //     // final res = await services.createPaypalPayment(transactions, accessToken);
    //     final res = await services.createRecurringPaypalPayment(
    //         transactions, accessToken);
    //     if (res != null) {
    //       setState(() {
    //         checkoutUrl = res['approvalUrl'];
    //         executeUrl = res['executeUrl'];
    //       });
    //     }
    //   } catch (e) {
    //     final snackBar = SnackBar(
    //       content: Text(e.toString()),
    //       duration: const Duration(seconds: 10),
    //       action: SnackBarAction(
    //         label: 'Close',
    //         onPressed: () {
    //           // Some code to undo the change.
    //           Get.back();
    //         },
    //       ),
    //     );

    //     // ignore: deprecated_member_use
    //     // _scaffoldKey.currentState!.showSnackBar(snackBar);
    //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //   }
    // });
  }

  String formatPrice(String price) {
    if (isNotBlank(price)) {
      final formatCurrency = NumberFormat('#,##0.00', 'en_US');
      return formatCurrency.format(double.parse(price));
    } else {
      return '0';
    }
  }

  // Map<String, dynamic> getOrderParams() {
  //   var temp = <String, dynamic>{
  //     'intent': 'sale',
  //     'payer': {'payment_method': 'paypal'},
  //     'transactions': [
  //       {
  //         'amount': {
  //           'total': formatPrice(widget.price),
  //           'currency': 'USD',
  //           'details': {
  //             'subtotal': '',
  //             'shipping': '',
  //             'shipping_discount': '',
  //             'tax': ''
  //           }
  //         },
  //         'description': 'The payment transaction description.',
  //         'payment_options': {
  //           'allowed_payment_method': 'INSTANT_FUNDING_SOURCE'
  //         },
  //         'item_list': {
  //           'items': [
  //             {'name': '', 'quantity': '', 'price': '', 'currency': ''}
  //           ],
  //           'shipping_address': {
  //             'recipient_name': '',
  //             'line1': '',
  //             'city': '',
  //             'country_code': '',
  //             'postal_code': '',
  //             'phone': '',
  //             'state': ''
  //           },
  //         }
  //       }
  //     ],
  //     'note_to_payer': 'Contact us for any questions on your order.',
  //     'redirect_urls': {
  //       'return_url': 'http://return.example.com',
  //       'cancel_url': 'http://cancel.example.com'
  //     }
  //   };

  //   var temp2 = <String, dynamic>{
  //     'intent': 'sale',
  //     'payer': {'payment_method': 'paypal'},
  //     'transactions': [
  //       {
  //         'amount': {
  //           'total': formatPrice(widget.price),
  //           'currency': 'USD',
  //         },
  //         'description': 'The payment transaction description.',
  //         'payment_options': {'allowed_payment_method': '$paymentMethod'},
  //       }
  //     ],
  //     'note_to_payer':
  //         'Contact us for any of your queries regarding the contribution you just made.',
  //     'redirect_urls': {
  //       'return_url': 'http://return.example.com',
  //       'cancel_url': 'http://cancel.example.com'
  //     }
  //   };

  //   return temp2;
  // }

  // Map<String, dynamic> getRecurringParams() {
  //   var temp = <String, dynamic>{
  //     'intent': 'sale',
  //     'payer': {'payment_method': 'paypal'},
  //     'transactions': [
  //       {
  //         'amount': {
  //           'total': formatPrice(widget.price),
  //           'currency': 'USD',
  //           'details': {
  //             'subtotal': '',
  //             'shipping': '',
  //             'shipping_discount': '',
  //             'tax': ''
  //           }
  //         },
  //         'description': 'The payment transaction description.',
  //         'payment_options': {
  //           'allowed_payment_method': 'INSTANT_FUNDING_SOURCE'
  //         },
  //         'item_list': {
  //           'items': [
  //             {'name': '', 'quantity': '', 'price': '', 'currency': ''}
  //           ],
  //           'shipping_address': {
  //             'recipient_name': '',
  //             'line1': '',
  //             'city': '',
  //             'country_code': '',
  //             'postal_code': '',
  //             'phone': '',
  //             'state': ''
  //           },
  //         }
  //       }
  //     ],
  //     'note_to_payer': 'Contact us for any questions on your order.',
  //     'redirect_urls': {
  //       'return_url': 'http://return.example.com',
  //       'cancel_url': 'http://cancel.example.com'
  //     }
  //   };

  //   var temp2 = <String, dynamic>{
  //     'intent': 'sale',
  //     'payer': {'payment_method': 'paypal'},
  //     'transactions': [
  //       {
  //         'amount': {
  //           'total': formatPrice(widget.price),
  //           'currency': 'USD',
  //         },
  //         'description': 'The payment transaction description.',
  //         'payment_options': {'allowed_payment_method': '$paymentMethod'},
  //       }
  //     ],
  //     'note_to_payer':
  //         'Contact us for any of your queries regarding the contribution you just made.',
  //     'redirect_urls': {
  //       'return_url': 'http://return.example.com',
  //       'cancel_url': 'http://cancel.example.com'
  //     }
  //   };

  //   return temp2;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: InAppWebView(
        key: webViewKey,
        //initialUrlRequest: URLRequest(url: Uri.parse(checkoutUrl!)),
        initialUrlRequest: URLRequest(
            url: WebUri.uri(Uri.parse(
                'https://www.paypal.com/donate?hosted_button_id=XJXBT4WC95LKU'))),
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
          // if (url.toString().startsWith('http://return.example.com')) {
          //   final uri = url;
          //   final payerID = uri!.queryParameters['PayerID'];
          //   if (payerID != null) {
          //     services
          //         .executePayment(executeUrl, payerID, accessToken)
          //         .then((id) {
          //       widget.onFinish(id);
          //     });
          //   }
          //   Navigator.of(context).pop();
          // }
          if (url.toString().startsWith('https://whatgodhasdoneforme.com/')) {
            Navigator.of(context).pop();
          }

          setState(() {
            this.url = url.toString();
          });
        },
        onLoadError: (controller, request, i, error) {
          pullToRefreshController?.endRefreshing();
        },
      ),
      // body: WebView(
      //   initialUrl: checkoutUrl,
      //   javascriptMode: JavascriptMode.unrestricted,
      //   navigationDelegate: (NavigationRequest request) {
      //     if (request.url.startsWith('http://return.example.com')) {
      //       final uri = Uri.parse(request.url);
      //       final payerID = uri.queryParameters['PayerID'];
      //       if (payerID != null) {
      //         services.executePayment(executeUrl, payerID, accessToken).then((id) {
      //           widget.onFinish(id);
      //         });
      //       }
      //       Navigator.of(context).pop();
      //     }
      //     if (request.url.startsWith('http://cancel.example.com')) {
      //       Navigator.of(context).pop();
      //     }
      //     return NavigationDecision.navigate;
      //   },
      // ),
    );
  }
}
