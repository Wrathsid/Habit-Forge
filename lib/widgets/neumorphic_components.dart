import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'neumorphic_box.dart';
import 'neumorphic_colors.dart';

/// Enhanced Neumorphic Button with multiple styles
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final NeumorphicEffect effect;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? textColor;
  final bool enableHaptic;
  final bool enableGlow;
  final bool enableFloating;
  final double depth;
  final Duration animationDuration;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.effect = NeumorphicEffect.convex,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.textColor,
    this.enableHaptic = true,
    this.enableGlow = false,
    this.enableFloating = false,
    this.depth = 1.0,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _isPressed = true;
      });
      _pressController.forward();
      
      if (widget.enableHaptic) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _isPressed = false;
      });
      _pressController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      setState(() {
        _isPressed = false;
      });
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    final textColor = widget.textColor ?? colors.textColor;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (context, child) {
          return NeumorphicBox(
            isPressed: _isPressed,
            effect: widget.effect,
            borderRadius: widget.borderRadius,
            padding: widget.padding,
            depth: widget.depth,
            enableGlow: widget.enableGlow,
            enableFloating: widget.enableFloating,
            animationDuration: widget.animationDuration,
            child: DefaultTextStyle(
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Enhanced Neumorphic Card with advanced effects
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final NeumorphicEffect effect;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool enableHover;
  final bool enableGlow;
  final bool enableFloating;
  final double depth;
  final Color? customAccent;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.effect = NeumorphicEffect.convex,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(8),
    this.onTap,
    this.enableHover = true,
    this.enableGlow = false,
    this.enableFloating = false,
    this.depth = 1.0,
    this.customAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: NeumorphicBox(
        effect: effect,
        borderRadius: borderRadius,
        padding: padding,
        onTap: onTap,
        enableHover: enableHover,
        enableGlow: enableGlow,
        enableFloating: enableFloating,
        depth: depth,
        customAccent: customAccent,
        child: child,
      ),
    );
  }
}

/// Enhanced Neumorphic Input Field
class NeumorphicTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final NeumorphicEffect effect;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool enableGlow;
  final double depth;

  const NeumorphicTextField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.effect = NeumorphicEffect.concave,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.enableGlow = false,
    this.depth = 0.8,
  });

  @override
  State<NeumorphicTextField> createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusController.forward();
      } else {
        _focusController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return NeumorphicBox(
          effect: widget.effect,
          borderRadius: widget.borderRadius,
          padding: widget.padding,
          depth: widget.depth,
          enableGlow: widget.enableGlow && _focusNode.hasFocus,
          customAccent: colors.accent,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            style: TextStyle(
              color: colors.textColor,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: colors.textColor.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        );
      },
    );
  }
}

/// Neumorphic Switch with smooth animations
class NeumorphicSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final NeumorphicEffect effect;
  final double borderRadius;
  final bool enableHaptic;
  final Color? activeColor;
  final Color? inactiveColor;

  const NeumorphicSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.effect = NeumorphicEffect.convex,
    this.borderRadius = 20.0,
    this.enableHaptic = true,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<NeumorphicSwitch> createState() => _NeumorphicSwitchState();
}

class _NeumorphicSwitchState extends State<NeumorphicSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NeumorphicSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    final activeColor = widget.activeColor ?? colors.accent;
    final inactiveColor = widget.inactiveColor ?? colors.depth1;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return NeumorphicBox(
            effect: widget.effect,
            borderRadius: widget.borderRadius,
            padding: const EdgeInsets.all(4),
            depth: 0.5,
            child: Container(
              width: 60,
              height: 32,
              decoration: BoxDecoration(
                color: Color.lerp(inactiveColor, activeColor, _animation.value),
                borderRadius: BorderRadius.circular(widget.borderRadius - 4),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: _animation.value * 28,
                    top: 0,
                    bottom: 0,
                    child: NeumorphicBox(
                      effect: NeumorphicEffect.convex,
                      borderRadius: 12,
                      padding: const EdgeInsets.all(0),
                      depth: 0.8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Neumorphic Slider with enhanced visuals
class NeumorphicSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final NeumorphicEffect effect;
  final double borderRadius;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enableHaptic;

  const NeumorphicSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.effect = NeumorphicEffect.concave,
    this.borderRadius = 20.0,
    this.activeColor,
    this.inactiveColor,
    this.enableHaptic = true,
  });

  @override
  State<NeumorphicSlider> createState() => _NeumorphicSliderState();
}

class _NeumorphicSliderState extends State<NeumorphicSlider> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    final activeColor = widget.activeColor ?? colors.accent;
    final inactiveColor = widget.inactiveColor ?? colors.depth1;
    final progress = (widget.value - widget.min) / (widget.max - widget.min);

    return NeumorphicBox(
      effect: widget.effect,
      borderRadius: widget.borderRadius,
      padding: const EdgeInsets.all(8),
      depth: 0.5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onPanUpdate: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              final newValue = (localPosition.dx / constraints.maxWidth)
                  .clamp(0.0, 1.0) * (widget.max - widget.min) + widget.min;
              
              if (widget.enableHaptic && (newValue - widget.value).abs() > 0.01) {
                HapticFeedback.selectionClick();
              }
              
              widget.onChanged(newValue);
            },
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: inactiveColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * progress - 8,
                    top: -4,
                    child: NeumorphicBox(
                      effect: NeumorphicEffect.convex,
                      borderRadius: 8,
                      padding: const EdgeInsets.all(0),
                      depth: 1.0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Neumorphic Progress Indicator
class NeumorphicProgressIndicator extends StatelessWidget {
  final double value;
  final double height;
  final NeumorphicEffect effect;
  final double borderRadius;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enableGlow;

  const NeumorphicProgressIndicator({
    super.key,
    required this.value,
    this.height = 8.0,
    this.effect = NeumorphicEffect.concave,
    this.borderRadius = 4.0,
    this.activeColor,
    this.inactiveColor,
    this.enableGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    final activeColor = this.activeColor ?? colors.accent;
    final inactiveColor = this.inactiveColor ?? colors.depth1;

    return NeumorphicBox(
      effect: effect,
      borderRadius: borderRadius,
      padding: const EdgeInsets.all(4),
      depth: 0.5,
      enableGlow: enableGlow,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: inactiveColor,
          borderRadius: BorderRadius.circular(borderRadius - 4),
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: inactiveColor,
                borderRadius: BorderRadius.circular(borderRadius - 4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: (MediaQuery.of(context).size.width - 32) * value.clamp(0.0, 1.0),
              height: height,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(borderRadius - 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
