import 'package:flutter/material.dart';

/// Responsive utility widget that provides different layouts based on screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1920) {
          // Large Desktop (1920px+)
          return largeDesktop ?? desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 1200) {
          // Desktop (1200px - 1919px)
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 768) {
          // Tablet (768px - 1199px)
          return tablet ?? mobile;
        } else {
          // Mobile (< 768px)
          return mobile;
        }
      },
    );
  }
}

/// Responsive breakpoint utilities
class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1200;
  static const double desktop = 1920;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context)) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    } else if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsive(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
        largeDesktop: 48.0,
      ),
      vertical: responsive(
        context,
        mobile: 16.0,
        tablet: 20.0,
        desktop: 24.0,
        largeDesktop: 32.0,
      ),
    );
  }

  /// Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  /// Get responsive spacing
  static double responsiveSpacing(BuildContext context) {
    return responsive(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
      largeDesktop: 32.0,
    );
  }
}

/// Responsive grid widget for different screen sizes
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        
        if (constraints.maxWidth >= 1920) {
          // Large Desktop: 4 columns
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 1200) {
          // Desktop: 3 columns
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 768) {
          // Tablet: 2 columns
          crossAxisCount = 2;
        } else {
          // Mobile: 1 column
          crossAxisCount = 1;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.2,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Responsive container that adjusts its max width based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveBreakpoints.responsive(
            context,
            mobile: double.infinity,
            tablet: 768,
            desktop: 1200,
            largeDesktop: 1400,
          ),
        ),
        padding: padding ?? ResponsiveBreakpoints.responsivePadding(context),
        child: child,
      ),
    );
  }
}
