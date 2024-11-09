import 'package:flutter/material.dart';

class DeviceHelper {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= DeviceBreakpoints.tablet;
  }

  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < DeviceBreakpoints.tablet;
  }

  static bool isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }
}

class DeviceBreakpoints {
  // Tablet ve büyük ekranlar için
  static const double tablet = 600.0;
  static const double largeTablet = 900.0;

  // Telefonlar için farklı genişlikler
  static const double smallPhone = 320.0;
  static const double mediumPhone = 375.0;
  static const double largePhone = 414.0;
}
