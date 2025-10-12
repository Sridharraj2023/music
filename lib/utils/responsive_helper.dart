import 'package:flutter/material.dart';

/// Responsive Helper for handling different screen sizes
/// Optimized for Mobile, Tablet, and Desktop layouts
class ResponsiveHelper {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  
  /// Check if the current device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }
  
  /// Check if the current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }
  
  /// Check if the current device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }
  
  /// Get responsive width - limits max width on tablets/desktop
  static double getResponsiveWidth(BuildContext context, {double maxWidth = 500}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isTablet(context) || isDesktop(context)) {
      return maxWidth.clamp(0, screenWidth * 0.8);
    }
    return screenWidth;
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.2; // 20% larger on tablets
    } else {
      return baseFontSize * 1.4; // 40% larger on desktop
    }
  }
  
  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.07);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.15);
    } else {
      return EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.25);
    }
  }
  
  /// Get constrained box for forms (useful for login/signup screens on tablets)
  static BoxConstraints getFormConstraints(BuildContext context) {
    if (isMobile(context)) {
      return BoxConstraints(maxWidth: double.infinity);
    } else if (isTablet(context)) {
      return BoxConstraints(maxWidth: 500);
    } else {
      return BoxConstraints(maxWidth: 600);
    }
  }
  
  /// Get logo size based on screen
  static double getLogoSize(BuildContext context, double mobileSize) {
    if (isMobile(context)) {
      return mobileSize;
    } else if (isTablet(context)) {
      return mobileSize * 1.5;
    } else {
      return mobileSize * 2;
    }
  }
  
  /// Get button constraints
  static BoxConstraints getButtonConstraints(BuildContext context) {
    if (isMobile(context)) {
      return BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.8,
        minHeight: 50,
      );
    } else {
      return BoxConstraints(
        minWidth: 400,
        minHeight: 55,
      );
    }
  }
  
  /// Value based on screen type
  static T valueByScreen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;

  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isDesktop(context)) {
          return (desktop ?? tablet ?? mobile)(context, constraints);
        } else if (ResponsiveHelper.isTablet(context)) {
          return (tablet ?? mobile)(context, constraints);
        } else {
          return mobile(context, constraints);
        }
      },
    );
  }
}

/// Responsive Center - Centers content on large screens, full width on mobile
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const ResponsiveCenter({
    Key? key,
    required this.child,
    this.maxWidth = 500,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.isMobile(context) 
              ? double.infinity 
              : maxWidth,
        ),
        child: Padding(
          padding: padding ?? ResponsiveHelper.getResponsivePadding(context),
          child: child,
        ),
      ),
    );
  }
}

