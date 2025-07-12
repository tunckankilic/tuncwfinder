import 'package:flutter/material.dart';
import 'package:tuncforwork/constants/app_strings.dart';

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
  // ${AppStrings.tabletAndLargeScreens}
  static const double tablet = 600.0;
  static const double largeTablet = 900.0;

  // ${AppStrings.phonesDifferentWidths}
  static const double smallPhone = 320.0;
  static const double mediumPhone = 375.0;
  static const double largePhone = 414.0;
}
