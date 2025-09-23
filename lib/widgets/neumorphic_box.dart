import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'neumorphic_colors.dart';

/// Neumorphic effect types
enum NeumorphicEffect {
  convex,    // Raised effect (default)
  concave,   // Pressed/inset effect
  flat,      // No shadow effect
  floating,  // Floating effect with glow
  pressed,   // Deeply pressed effect
  embossed,  // Embossed/engraved effect
  gradient,  // Gradient neumorphic effect
  glass,     // Glass-like neumorphic effect
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
  final double depth;
  final double intensity;
  final bool enableGlow;
  final bool enableReflection;
  final Color? customAccent;
  final bool enableFloating;
  final double floatingHeight;

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
    this.depth = 1.0,
    this.intensity = 1.0,
    this.enableGlow = false,
    this.enableReflection = false,
    this.customAccent,
    this.enableFloating = false,
    this.floatingHeight = 8.0,
  });

  @override
  State<NeumorphicBox> createState() => _NeumorphicBoxState();
}

class _NeumorphicBoxState extends State<NeumorphicBox>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _isFocused = false;
  late AnimationController _hoverController;
  late AnimationController _floatingController;
  late AnimationController _glowController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.enableFloating) {
      _floatingController.repeat(reverse: true);
    }
    
    if (widget.enableGlow) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _floatingController.dispose();
    _glowController.dispose();
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
      animation: Listenable.merge([_hoverAnimation, _floatingAnimation, _glowAnimation]),
      builder: (context, child) {
        final floatingOffset = widget.enableFloating 
            ? _floatingAnimation.value * widget.floatingHeight 
            : 0.0;
        
        return Transform.translate(
          offset: Offset(0, -floatingOffset),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: _getBackgroundColor(colors),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: _getGradient(colors),
              boxShadow: _buildEnhancedBoxShadows(colors, context),
              border: _getBorder(colors),
            ),
            child: widget.child,
          ),
        );
      },
    );

    if (widget.onTap != null || widget.enableHover) {
      return Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: MouseRegion(
          onEnter: (_) => _onHoverEnter(),
          onExit: (_) => _onHoverExit(),
          child: GestureDetector(
            onTap: widget.onTap,
            child: box,
          ),
        ),
      );
    }

    return box;
  }

  Color _getBackgroundColor(NeumorphicColors colors) {
    switch (widget.effect) {
      case NeumorphicEffect.convex:
        return _isHovered ? colors.hover : colors.surface;
      case NeumorphicEffect.concave:
        return widget.isPressed ? colors.pressed : colors.depth1;
      case NeumorphicEffect.flat:
        return colors.surface;
      case NeumorphicEffect.floating:
        return colors.surface;
      case NeumorphicEffect.pressed:
        return colors.pressed;
      case NeumorphicEffect.embossed:
        return colors.depth2;
      case NeumorphicEffect.gradient:
        return colors.surface;
      case NeumorphicEffect.glass:
        return colors.surface.withValues(alpha: 0.8);
    }
  }

  Gradient? _getGradient(NeumorphicColors colors) {
    switch (widget.effect) {
      case NeumorphicEffect.gradient:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.highlight,
            colors.surface,
            colors.depth1,
          ],
        );
      case NeumorphicEffect.glass:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.reflection,
            colors.surface.withValues(alpha: 0.1),
            colors.ambient,
          ],
        );
      default:
        return null;
    }
  }

  Border? _getBorder(NeumorphicColors colors) {
    if (widget.effect == NeumorphicEffect.glass) {
      return Border.all(
        color: colors.highlight.withValues(alpha: 0.3),
        width: 1.0,
      );
    }
    return null;
  }

  List<BoxShadow> _buildEnhancedBoxShadows(NeumorphicColors colors, BuildContext context) {
    final isPressed = widget.isPressed;
    final isHovered = _isHovered && widget.enableHover && kIsWeb;
    final isFocused = _isFocused;
    final glowIntensity = widget.enableGlow ? _glowAnimation.value : 0.0;
    
    List<BoxShadow> shadows = [];
    
    // Base neumorphic shadows
    shadows.addAll(_buildBaseShadows(colors, isPressed, isHovered));
    
    // Glow effect
    if (widget.enableGlow) {
      shadows.addAll(_buildGlowShadows(colors, glowIntensity));
    }
    
    // Focus effect
    if (isFocused) {
      shadows.addAll(_buildFocusShadows(colors));
    }
    
    return shadows;
  }

  List<BoxShadow> _buildBaseShadows(NeumorphicColors colors, bool isPressed, bool isHovered) {
    final intensity = widget.intensity * widget.depth;
    final alpha = intensity.clamp(0.0, 1.0);
    
    switch (widget.effect) {
      case NeumorphicEffect.convex:
        return _buildConvexShadows(colors, alpha, isPressed, isHovered);
      case NeumorphicEffect.concave:
        return _buildConcaveShadows(colors, alpha, isPressed, isHovered);
      case NeumorphicEffect.flat:
        return [];
      case NeumorphicEffect.floating:
        return _buildFloatingShadows(colors, alpha, isPressed, isHovered);
      case NeumorphicEffect.pressed:
        return _buildPressedShadows(colors, alpha, isPressed, isHovered);
      case NeumorphicEffect.embossed:
        return _buildEmbossedShadows(colors, alpha, isPressed, isHovered);
      case NeumorphicEffect.gradient:
        return _buildGradientShadows(colors, alpha, isPressed, isHovered);
      case NeumorphicEffect.glass:
        return _buildGlassShadows(colors, alpha, isPressed, isHovered);
    }
  }

  List<BoxShadow> _buildConvexShadows(NeumorphicColors colors, double alpha, bool isPressed, bool isHovered) {
    final offset = isPressed ? 2.0 : (isHovered ? 4.0 : 3.0);
    final blur = isPressed ? 4.0 : (isHovered ? 8.0 : 6.0);
    
    return [
      BoxShadow(
        color: colors.shadowDark.withValues(alpha: alpha),
        offset: Offset(offset, offset),
        blurRadius: blur,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: colors.shadowLight.withValues(alpha: alpha),
        offset: Offset(-offset, -offset),
        blurRadius: blur,
        spreadRadius: 0,
      ),
    ];
  }

  List<BoxShadow> _buildConcaveShadows(NeumorphicColors colors, double alpha, bool isPressed, bool isHovered) {
    final offset = isPressed ? 1.0 : 2.0;
    final blur = isPressed ? 2.0 : 4.0;
    
    return [
      BoxShadow(
        color: colors.shadowLight.withValues(alpha: alpha),
        offset: Offset(offset, offset),
        blurRadius: blur,
        spreadRadius: 0.5,
      ),
      BoxShadow(
        color: colors.shadowDark.withValues(alpha: alpha),
        offset: Offset(-offset, -offset),
        blurRadius: blur,
        spreadRadius: 0.5,
      ),
    ];
  }

  List<BoxShadow> _buildFloatingShadows(NeumorphicColors colors, double alpha, bool isPressed, bool isHovered) {
    final baseOffset = isPressed ? 2.0 : 8.0;
    final hoverOffset = isHovered ? 4.0 : 0.0;
    final offset = baseOffset + hoverOffset;
    
    return [
      BoxShadow(
        color: colors.shadowDark.withValues(alpha: alpha * 0.8),
        offset: Offset(offset, offset + 4),
        blurRadius: 16,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: colors.shadowLight.withValues(alpha: alpha * 0.6),
        offset: Offset(-offset, -offset),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }

  List<BoxShadow> _buildPressedShadows(NeumorphicColors colors, double alpha, bool isPressed, bool isHovered) {
    return [
      BoxShadow(
        color: colors.shadowDark.withValues(alpha: alpha * 0.3),
        offset: const Offset(1, 1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: colors.shadowLight.withValues(alpha: alpha * 0.2),
        offset: const Offset(-1, -1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
    ];
  }

  List<BoxShadow> _buildEmbossedShadows(NeumorphicColors colors, double alpha, bool isPressed, bool isHovered) {
    return [
      BoxShadow(
        color: colors.highlight.withValues(alpha: alpha * 0.8),
        offset: const Offset(-2, -2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: colors.shadowDark.withValues(alpha: alpha * 0.6),
        offset: const Offset(2, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ];
  }

  List<BoxShadow> _buildGradientShadows(NeumorphicColors colors, double alpha, bool isPressed, bool isHovered) {
    return [
      BoxShadow(
        color: colors.accent.withValues(alpha: alpha * 0.3),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: colors.shadowDark.withValues(alpha: alpha * 0.4),
        offset: const Offset(3, 3),
        blurRadius: 6,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: colors.shadowLight.withValues(alpha: alpha * 0.4),
        offset: const Offset(-3, -3),
        blurRadius: 6,
        spreadRadius: 0,
      ),
    ];
  }

  List<BoxShadow> _buildGlassShadows(NeumorphicColors colors, double alpha, bool isPressed, bool isHovered) {
    return [
      BoxShadow(
        color: colors.glow.withValues(alpha: alpha * 0.5),
        offset: const Offset(0, 0),
        blurRadius: 20,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: colors.shadowDark.withValues(alpha: alpha * 0.2),
        offset: const Offset(2, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: colors.shadowLight.withValues(alpha: alpha * 0.2),
        offset: const Offset(-2, -2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ];
  }

  List<BoxShadow> _buildGlowShadows(NeumorphicColors colors, double intensity) {
    final accent = widget.customAccent ?? colors.accent;
    return [
      BoxShadow(
        color: accent.withValues(alpha: intensity * 0.6),
        offset: const Offset(0, 0),
        blurRadius: 20 + (intensity * 10),
        spreadRadius: intensity * 2,
      ),
      BoxShadow(
        color: accent.withValues(alpha: intensity * 0.3),
        offset: const Offset(0, 0),
        blurRadius: 40 + (intensity * 20),
        spreadRadius: intensity * 4,
      ),
    ];
  }

  List<BoxShadow> _buildFocusShadows(NeumorphicColors colors) {
    final accent = widget.customAccent ?? colors.accent;
    return [
      BoxShadow(
        color: accent.withValues(alpha: 0.4),
        offset: const Offset(0, 0),
        blurRadius: 8,
        spreadRadius: 2,
      ),
    ];
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
