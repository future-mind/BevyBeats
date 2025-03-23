import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';

/// A widget that renders different widgets based on the current platform.
/// This allows for platform-specific UI patterns while maintaining a single codebase.
class PlatformWidget extends StatelessWidget {
  /// Widget to display on iOS/macOS
  final Widget Function(BuildContext) cupertino;

  /// Widget to display on Android/Linux/Windows
  final Widget Function(BuildContext) material;

  /// Optional widget to display specifically on web
  final Widget Function(BuildContext)? web;

  /// Optional widget to display specifically on desktop platforms (macOS, Windows, Linux)
  final Widget Function(BuildContext)? desktop;

  const PlatformWidget({
    Key? key,
    required this.cupertino,
    required this.material,
    this.web,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Web platform takes precedence if specified
    if (kIsWeb && web != null) {
      return web!(context);
    }

    // Check for desktop platforms if desktop builder is provided
    if (desktop != null) {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return desktop!(context);
      }
    }

    // Default to platform-specific mobile builders
    if (Platform.isIOS || Platform.isMacOS) {
      return cupertino(context);
    }

    // Default to material design for Android and other platforms
    return material(context);
  }
}

/// Utility class to check the current platform
class PlatformHelper {
  static bool get isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  static bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  static bool get isWeb => kIsWeb;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
}

/// Platform-aware button that displays a Material button on Android/other platforms
/// and a Cupertino button on iOS/macOS.
class PlatformButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final bool isPrimary;

  const PlatformButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material:
          (context) => ElevatedButton(
            onPressed: onPressed,
            style:
                isPrimary
                    ? ElevatedButton.styleFrom(
                      backgroundColor:
                          backgroundColor ??
                          Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    )
                    : null,
            child: child,
          ),
      cupertino:
          (context) => CupertinoButton(
            onPressed: onPressed,
            color:
                isPrimary
                    ? backgroundColor ?? CupertinoColors.activeBlue
                    : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: child,
          ),
    );
  }
}

/// Platform-aware icon button that displays a Material icon button on Android/other platforms
/// and a Cupertino icon button on iOS/macOS.
class PlatformIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final String? tooltip;
  final Color? color;
  final double size;

  const PlatformIconButton({
    Key? key,
    required this.onPressed,
    required this.materialIcon,
    required this.cupertinoIcon,
    this.tooltip,
    this.color,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material:
          (context) => IconButton(
            icon: Icon(materialIcon, color: color, size: size),
            onPressed: onPressed,
            tooltip: tooltip,
          ),
      cupertino:
          (context) => CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            child: Icon(cupertinoIcon, color: color, size: size),
          ),
    );
  }
}
