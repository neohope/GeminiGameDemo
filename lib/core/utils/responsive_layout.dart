import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/constants/game_constants.dart';

enum ScreenSize {
  small,   // < 600
  medium,  // 600-1200
  large,   // > 1200
}

class ResponsiveLayout extends StatelessWidget {
  final Widget small;
  final Widget? medium;
  final Widget large;

  const ResponsiveLayout({
    super.key,
    required this.small,
    this.medium,
    required this.large,
  });

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < GameConstants.smallScreenBreakpoint) {
      return ScreenSize.small;
    } else if (width < GameConstants.mediumScreenBreakpoint) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  static bool isSmallScreen(BuildContext context) =>
      getScreenSize(context) == ScreenSize.small;

  static bool isMediumScreen(BuildContext context) =>
      getScreenSize(context) == ScreenSize.medium;

  static bool isLargeScreen(BuildContext context) =>
      getScreenSize(context) == ScreenSize.large;

  static double boardSize(BuildContext context, {double maxSize = 1000}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableSize = screenWidth < screenHeight ? screenWidth : screenHeight;
    return (availableSize * 0.98).clamp(200.0, maxSize);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium ?? large;
      case ScreenSize.large:
        return large;
    }
  }
}
