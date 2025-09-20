import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'neumorphic_colors.dart';

/// Neumorphic effect types
enum NeumorphicEffect {
  convex,    // Raised effect (default)
  concave,   // Pressed/inset effect
  flat,      // No shadow effect
}

class NeumorphicBox extends StatefulWidget {
  final Widget child;
  final bool isPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final NeumorphicEffect effect;
  final bool enableHover;
  final Duration animationDuration;

  const NeumorphicBox({
    super.key,
    required this.child,
    this.isPressed = false,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(0),
    this.onTap,
    this.effect = NeumorphicEffect.convex,
    this.enableHover = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<NeumorphicBox> createState() => _NeumorphicBoxState();
}

class _NeumorphicBoxState extends State<NeumorphicBox>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    if (widget.enableHover && kIsWeb) {
      setState(() {
        _isHovered = true;
      });
      _hoverController.forward();
    }
  }

  void _onHoverExit() {
    if (widget.enableHover && kIsWeb) {
      setState(() {
        _isHovered = false;
      });
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;

    Widget box = AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: widget.animationDuration,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _buildBoxShadows(colors, context),
          ),
          child: widget.child,
        );
      },
    );

    if (widget.onTap != null || widget.enableHover) {
      return MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: GestureDetector(
          onTap: widget.onTap,
          child: box,
        ),
      );
    }

    return box;
  }

  List<BoxShadow> _buildBoxShadows(NeumorphicColors colors, BuildContext context) {
    final isPressed = widget.isPressed;
    final isHovered = _isHovered && widget.enableHover && kIsWeb;
    
    // Determine shadow intensity based on effect type
    double shadowIntensity;
    double hoverIntensity = 0.0;
    
    switch (widget.effect) {
      case NeumorphicEffect.convex:
        shadowIntensity = isPressed ? 0.3 : 0.2;
        hoverIntensity = 0.1;
        break;
      case NeumorphicEffect.concave:
        shadowIntensity = isPressed ? 0.1 : 0.3;
        hoverIntensity = -0.1;
        break;
      case NeumorphicEffect.flat:
        shadowIntensity = 0.0;
        hoverIntensity = 0.0;
        break;
    }

    // Add hover effect intensity
    if (isHovered) {
      shadowIntensity += hoverIntensity * _hoverAnimation.value;
    }

    // Web-specific optimizations for neumorphic shadows
    if (kIsWeb) {
      return _buildWebShadows(colors, shadowIntensity, isPressed);
    } else {
      return _buildMobileShadows(colors, shadowIntensity, isPressed);
    }
  }

  List<BoxShadow> _buildWebShadows(NeumorphicColors colors, double intensity, bool isPressed) {
    if (widget.effect == NeumorphicEffect.flat) {
      return [];
    }

    final alpha = intensity.clamp(0.0, 1.0);
    
    if (widget.effect == NeumorphicEffect.concave) {
      // Concave effect: inverted shadows
      return isPressed
          ? [
              BoxShadow(
                color: colors.shadowLight.withValues(alpha: alpha),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
              BoxShadow(
                color: colors.shadowDark.withValues(alpha: alpha),
                offset: const Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
            ]
          : [
              BoxShadow(
                color: colors.shadowLight.withValues(alpha: alpha),
                offset: const Offset(3, 3),
                blurRadius: 6,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: colors.shadowDark.withValues(alpha: alpha),
                offset: const Offset(-3, -3),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ];
    } else {
      // Convex effect: normal shadows
      return isPressed
          ? [
              BoxShadow(
                color: colors.shadowDark.withValues(alpha: alpha),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
              BoxShadow(
                color: colors.shadowLight.withValues(alpha: alpha),
                offset: const Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
            ]
          : [
              BoxShadow(
                color: colors.shadowDark.withValues(alpha: alpha),
                offset: const Offset(3, 3),
                blurRadius: 6,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: colors.shadowLight.withValues(alpha: alpha),
                offset: const Offset(-3, -3),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ];
    }
  }

  List<BoxShadow> _buildMobileShadows(NeumorphicColors colors, double intensity, bool isPressed) {
    if (widget.effect == NeumorphicEffect.flat) {
      return [];
    }

    final alpha = intensity.clamp(0.0, 1.0);
    
    if (widget.effect == NeumorphicEffect.concave) {
      // Concave effect: inverted shadows
      return isPressed
          ? [
              BoxShadow(
                color: colors.shadowLight.withValues(alpha: alpha),
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: colors.shadowDark.withValues(alpha: alpha),
                offset: const Offset(-4, -4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ]
          : [
              BoxShadow(
                color: colors.shadowLight.withValues(alpha: alpha),
                offset: const Offset(6, 6),
                blurRadius: 12,
              ),
              BoxShadow(
                color: colors.shadowDark.withValues(alpha: alpha),
                offset: const Offset(-6, -6),
                blurRadius: 12,
              ),
            ];
    } else {
      // Convex effect: normal shadows
      return isPressed
          ? [
              BoxShadow(
                color: colors.shadowDark.withValues(alpha: alpha),
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: colors.shadowLight.withValues(alpha: alpha),
                offset: const Offset(-4, -4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ]
          : [
              BoxShadow(
                color: colors.shadowDark.withValues(alpha: alpha),
                offset: const Offset(6, 6),
                blurRadius: 12,
              ),
              BoxShadow(
                color: colors.shadowLight.withValues(alpha: alpha),
                offset: const Offset(-6, -6),
                blurRadius: 12,
              ),
            ];
    }
  }
}
