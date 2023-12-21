import 'package:flutter/widgets.dart';

/// A class to help you scale your design on bigger or smaller screens to achieve the same design look.
class Scale {
  static late Size size;
  static late Size _deviceScreenSize;

  static num get _horizontallyScaleFactor {
    return _deviceScreenSize.width / size.width;
  }

  static num get _verticallyScaleFactor {
    return _deviceScreenSize.height / size.height;
  }

  static num get _fontScaleFactor {
    return _deviceScreenSize.width / size.width;
  }

  /// Setup the screen with a [context] and the [size] you will use.
  /// So, if you have a design with 1280 * 720. You will pass first the context
  /// then the design size.
  /// setup(context, Size(1280, 720))
  static void setup(BuildContext context, Size screenSize) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    _deviceScreenSize = mediaQuery.size;
    size = screenSize;
  }

  /// Setup the screen with the device screen [Size] and the [size] you will use.
  /// So, if you have a design with 1280 * 720. You will pass first the device
  /// screen size then the design size.
  /// setup(deviceScreenSize, Size(1280, 720))
  static void setupWith(Size deviceScreenSize, Size screenSize) {
    _deviceScreenSize = deviceScreenSize;
    size = screenSize;
  }

  /// Get the number scaled horizontally.
  static double scaleHorizontally(double number) {
    return double.parse((number * _horizontallyScaleFactor).toString());
  }

  /// Get the number scaled vertically.
  static double scaleVertically(double number) {
    return double.parse((number * _verticallyScaleFactor).toString());
  }

  /// Get the font scaled vertically.
  static double scaleFont(double number) {
    return double.parse((number * _fontScaleFactor).toString());
  }
}

/// An extension to make it easier to apply scale on number.
extension ScreenExtension on double {
  /// Get the number scaled horizontally.
  double get sh {
    return Scale.scaleHorizontally(this);
  }

  /// Get the number scaled vertically.
  double get sv {
    return Scale.scaleVertically(this);
  }

  /// Get the font scaled vertically.
  double get sf {
    return Scale.scaleFont(this);
  }
}
