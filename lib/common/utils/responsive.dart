import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getBreakpoint(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getAdaptivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 16;
    } else if (width < 900) {
      return 24;
    } else {
      return 32;
    }
  }

  static int getColumnsCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 1;
    } else if (width < 900) {
      return 2;
    } else {
      return 3;
    }
  }
}
