import 'package:flutter/material.dart';
import 'package:get/get.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NavigatorService {
  static void pop() {
    navigatorKey.currentState!.pop();
  }

  static void pushScreen(Widget screen, {VoidCallback? whenComplete}) {
    navigatorKey.currentState!
        .push(MaterialPageRoute(
          builder: (context) => screen,
        ))
        .whenComplete(() => whenComplete == null ? null : whenComplete());
  }

  static void pushAndRemoveUntil(Widget screen) {
    navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => screen), (route) => false);
  }

  static void pushReplacement(Widget screen, {VoidCallback? whenComplete}) {
    navigatorKey.currentState!
        .pushReplacement(MaterialPageRoute(
          builder: (context) => screen,
        ))
        .whenComplete(() => whenComplete == null ? null : whenComplete());
  }
//  navigator.currentState.pushand(MaterialPageRoute(
//       builder: (context) => screen,
}

Future<dynamic> pushNamedToReplace({BuildContext? context, required String routeName}) async {
  return await Navigator.of(context ?? Get.context!).pushReplacementNamed(routeName);
}

Future<dynamic> pushNamedToAndRemoveUntil({BuildContext? context, required String routeName}) async {
  return await Navigator.of(context ?? Get.context!).pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false);
}

Future<dynamic> pushNamedOnlyTo({BuildContext? context, required String routeName}) async {
  return await Navigator.of(context ?? Get.context!).pushNamed(routeName);
}

Future<dynamic> pushReplaceTo({
  BuildContext? context,
  required Widget widget,
}) async {
  return await Navigator.of(context ?? Get.context!).pushReplacement(
    MaterialPageRoute(builder: (context) => widget),
  );
}

Future<double> pushToAndRemoveUntil({
  BuildContext? context,
  required Widget widget,
}) async {
  return await Navigator.of(context ?? Get.context!).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => widget), (Route<dynamic> route) => false);
}

Future<dynamic> pushOnlyTo({
  BuildContext? context,
  required Widget widget,
}) async {
  return await Navigator.of(context ?? Get.context!).push(
    MaterialPageRoute(builder: (context) => widget),
  );
}

Future<dynamic> pop({
  BuildContext? context,
  var result,
}) async {
  return Navigator.of(context ?? Get.context!).pop(result);
}

disableDefaultBackNavigation({bool canCancel = false}) async {
  // await showDialog or Show add banners or whatever
  // then
  //return true; // return true if the route to be popped
  return canCancel; // return true if the route not to be popped
}

Future<dynamic> pushTransitionedReplaceTo({BuildContext? context, required Widget widget}) async {
  return await Navigator.pushReplacement(
      context ?? Get.context!,
      PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
            return widget;
          },
          transitionsBuilder: (___, Animation<double> animation, ____, Widget child) {
            return FadeTransition(
              opacity: animation,
              child: RotationTransition(
                turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                child: child,
              ),
            );
          }));
}

Future<dynamic> pushTransitionedOnlyToOLD({BuildContext? context, required Widget widget}) async {
  // return await Navigator.push(
  //     context ?? Get.context!,
  //     PageRouteBuilder(
  //         opaque: false,
  //         pageBuilder: (BuildContext context, _, __) {
  //           return widget;
  //         },
  //         transitionsBuilder:
  //             (___, Animation<double> animation, ____, Widget child) {
  //           return FadeTransition(
  //             opacity: animation,
  //             child: RotationTransition(
  //               turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
  //               child: child,
  //             ),
  //           );
  //         }));
}
