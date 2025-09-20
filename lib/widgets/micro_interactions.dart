import 'package:flutter/material.dart';
import '../services/haptic_service.dart';

class MicroInteractions {
  // Animated button with haptic feedback
  static Widget animatedButton({
    required Widget child,
    required VoidCallback onPressed,
    required BuildContext context,
    HapticType hapticType = HapticType.light,
    Duration animationDuration = const Duration(milliseconds: 150),
    double scaleFactor = 0.95,
    Color? splashColor,
  }) {
    return _AnimatedButton(
      onPressed: onPressed,
      hapticType: hapticType,
      animationDuration: animationDuration,
      scaleFactor: scaleFactor,
      splashColor: splashColor,
      child: child,
    );
  }

  // Animated card with hover effects
  static Widget animatedCard({
    required Widget child,
    VoidCallback? onTap,
    required BuildContext context,
    HapticType hapticType = HapticType.light,
    Duration animationDuration = const Duration(milliseconds: 200),
    double elevation = 4.0,
    double hoverElevation = 8.0,
  }) {
    return _AnimatedCard(
      onTap: onTap,
      hapticType: hapticType,
      animationDuration: animationDuration,
      elevation: elevation,
      hoverElevation: hoverElevation,
      child: child,
    );
  }

  // Animated switch with haptic feedback
  static Widget animatedSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required BuildContext context,
    HapticType hapticType = HapticType.selection,
    Color? activeColor,
    Color? inactiveColor,
    Duration animationDuration = const Duration(milliseconds: 200),
  }) {
    return _AnimatedSwitch(
      value: value,
      onChanged: onChanged,
      hapticType: hapticType,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      animationDuration: animationDuration,
    );
  }

  // Animated progress indicator
  static Widget animatedProgress({
    required double value,
    required BuildContext context,
    Duration animationDuration = const Duration(milliseconds: 500),
    Color? backgroundColor,
    Color? valueColor,
    double strokeWidth = 4.0,
  }) {
    return _AnimatedProgress(
      value: value,
      animationDuration: animationDuration,
      backgroundColor: backgroundColor,
      valueColor: valueColor,
      strokeWidth: strokeWidth,
    );
  }

  // Animated counter
  static Widget animatedCounter({
    required int value,
    required BuildContext context,
    Duration animationDuration = const Duration(milliseconds: 300),
    TextStyle? textStyle,
    Color? color,
  }) {
    return _AnimatedCounter(
      value: value,
      animationDuration: animationDuration,
      textStyle: textStyle,
      color: color,
    );
  }

  // Animated icon
  static Widget animatedIcon({
    required IconData icon,
    required BuildContext context,
    VoidCallback? onTap,
    HapticType hapticType = HapticType.light,
    Duration animationDuration = const Duration(milliseconds: 200),
    double size = 24.0,
    Color? color,
    double scaleFactor = 1.2,
  }) {
    return _AnimatedIcon(
      icon: icon,
      onTap: onTap,
      hapticType: hapticType,
      animationDuration: animationDuration,
      size: size,
      color: color,
      scaleFactor: scaleFactor,
    );
  }

  // Animated list item
  static Widget animatedListItem({
    required Widget child,
    required int index,
    Duration animationDuration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
  }) {
    return _AnimatedListItem(
      index: index,
      animationDuration: animationDuration,
      delay: delay,
      child: child,
    );
  }

  // Animated floating action button
  static Widget animatedFAB({
    required VoidCallback onPressed,
    required BuildContext context,
    required IconData icon,
    HapticType hapticType = HapticType.medium,
    Duration animationDuration = const Duration(milliseconds: 200),
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return _AnimatedFAB(
      onPressed: onPressed,
      hapticType: hapticType,
      animationDuration: animationDuration,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      icon: icon,
    );
  }
}

enum HapticType {
  light,
  medium,
  heavy,
  selection,
  success,
  error,
  celebration,
  streakMilestone,
  achievementUnlock,
  levelUp,
}

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final HapticType hapticType;
  final Duration animationDuration;
  final double scaleFactor;
  final Color? splashColor;

  const _AnimatedButton({
    required this.child,
    required this.onPressed,
    required this.hapticType,
    required this.animationDuration,
    required this.scaleFactor,
    this.splashColor,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    
    _triggerHaptic();
    widget.onPressed();
  }

  void _triggerHaptic() {
    switch (widget.hapticType) {
      case HapticType.light:
        HapticService.instance.light();
        break;
      case HapticType.medium:
        HapticService.instance.medium();
        break;
      case HapticType.heavy:
        HapticService.instance.heavy();
        break;
      case HapticType.selection:
        HapticService.instance.selection();
        break;
      case HapticType.success:
        HapticService.instance.success();
        break;
      case HapticType.error:
        HapticService.instance.error();
        break;
      case HapticType.celebration:
        HapticService.instance.celebration();
        break;
      case HapticType.streakMilestone:
        HapticService.instance.streakMilestone();
        break;
      case HapticType.achievementUnlock:
        HapticService.instance.achievementUnlock();
        break;
      case HapticType.levelUp:
        HapticService.instance.levelUp();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final HapticType hapticType;
  final Duration animationDuration;
  final double elevation;
  final double hoverElevation;

  const _AnimatedCard({
    required this.child,
    this.onTap,
    required this.hapticType,
    required this.animationDuration,
    required this.elevation,
    required this.hoverElevation,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.hoverElevation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      _triggerHaptic();
      widget.onTap!();
    }
  }

  void _triggerHaptic() {
    switch (widget.hapticType) {
      case HapticType.light:
        HapticService.instance.light();
        break;
      case HapticType.medium:
        HapticService.instance.medium();
        break;
      case HapticType.heavy:
        HapticService.instance.heavy();
        break;
      case HapticType.selection:
        HapticService.instance.selection();
        break;
      case HapticType.success:
        HapticService.instance.success();
        break;
      case HapticType.error:
        HapticService.instance.error();
        break;
      case HapticType.celebration:
        HapticService.instance.celebration();
        break;
      case HapticType.streakMilestone:
        HapticService.instance.streakMilestone();
        break;
      case HapticType.achievementUnlock:
        HapticService.instance.achievementUnlock();
        break;
      case HapticType.levelUp:
        HapticService.instance.levelUp();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) {
        setState(() {
          _isHovered = true;
        });
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() {
          _isHovered = false;
        });
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() {
          _isHovered = false;
        });
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Card(
            elevation: _elevationAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _AnimatedSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final HapticType hapticType;
  final Color? activeColor;
  final Color? inactiveColor;
  final Duration animationDuration;

  const _AnimatedSwitch({
    required this.value,
    required this.onChanged,
    required this.hapticType,
    this.activeColor,
    this.inactiveColor,
    required this.animationDuration,
  });

  @override
  State<_AnimatedSwitch> createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<_AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
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
  void didUpdateWidget(_AnimatedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      _triggerHaptic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    switch (widget.hapticType) {
      case HapticType.light:
        HapticService.instance.light();
        break;
      case HapticType.medium:
        HapticService.instance.medium();
        break;
      case HapticType.heavy:
        HapticService.instance.heavy();
        break;
      case HapticType.selection:
        HapticService.instance.selection();
        break;
      case HapticType.success:
        HapticService.instance.success();
        break;
      case HapticType.error:
        HapticService.instance.error();
        break;
      case HapticType.celebration:
        HapticService.instance.celebration();
        break;
      case HapticType.streakMilestone:
        HapticService.instance.streakMilestone();
        break;
      case HapticType.achievementUnlock:
        HapticService.instance.achievementUnlock();
        break;
      case HapticType.levelUp:
        HapticService.instance.levelUp();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color.lerp(
                widget.inactiveColor ?? Colors.grey,
                widget.activeColor ?? Theme.of(context).primaryColor,
                _animation.value,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: Curves.easeInOut,
                  left: _animation.value * 20,
                  top: 2,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedProgress extends StatefulWidget {
  final double value;
  final Duration animationDuration;
  final Color? backgroundColor;
  final Color? valueColor;
  final double strokeWidth;

  const _AnimatedProgress({
    required this.value,
    required this.animationDuration,
    this.backgroundColor,
    this.valueColor,
    required this.strokeWidth,
  });

  @override
  State<_AnimatedProgress> createState() => _AnimatedProgressState();
}

class _AnimatedProgressState extends State<_AnimatedProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _animation = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _animation.value,
          backgroundColor: widget.backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.valueColor ?? Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}

class _AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration animationDuration;
  final TextStyle? textStyle;
  final Color? color;

  const _AnimatedCounter({
    required this.value,
    required this.animationDuration,
    this.textStyle,
    this.color,
  });

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = IntTween(
      begin: _previousValue,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      _animation = IntTween(
        begin: _previousValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _animation.value.toString(),
          style: widget.textStyle?.copyWith(
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _AnimatedIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final HapticType hapticType;
  final Duration animationDuration;
  final double size;
  final Color? color;
  final double scaleFactor;

  const _AnimatedIcon({
    required this.icon,
    this.onTap,
    required this.hapticType,
    required this.animationDuration,
    required this.size,
    this.color,
    required this.scaleFactor,
  });

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
      _triggerHaptic();
      widget.onTap!();
    }
  }

  void _triggerHaptic() {
    switch (widget.hapticType) {
      case HapticType.light:
        HapticService.instance.light();
        break;
      case HapticType.medium:
        HapticService.instance.medium();
        break;
      case HapticType.heavy:
        HapticService.instance.heavy();
        break;
      case HapticType.selection:
        HapticService.instance.selection();
        break;
      case HapticType.success:
        HapticService.instance.success();
        break;
      case HapticType.error:
        HapticService.instance.error();
        break;
      case HapticType.celebration:
        HapticService.instance.celebration();
        break;
      case HapticType.streakMilestone:
        HapticService.instance.streakMilestone();
        break;
      case HapticType.achievementUnlock:
        HapticService.instance.achievementUnlock();
        break;
      case HapticType.levelUp:
        HapticService.instance.levelUp();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              widget.icon,
              size: widget.size,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration animationDuration;
  final Duration delay;

  const _AnimatedListItem({
    required this.child,
    required this.index,
    required this.animationDuration,
    required this.delay,
  });

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final HapticType hapticType;
  final Duration animationDuration;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData icon;

  const _AnimatedFAB({
    required this.onPressed,
    required this.hapticType,
    required this.animationDuration,
    this.backgroundColor,
    this.foregroundColor,
    required this.icon,
  });

  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    _triggerHaptic();
    widget.onPressed();
  }

  void _triggerHaptic() {
    switch (widget.hapticType) {
      case HapticType.light:
        HapticService.instance.light();
        break;
      case HapticType.medium:
        HapticService.instance.medium();
        break;
      case HapticType.heavy:
        HapticService.instance.heavy();
        break;
      case HapticType.selection:
        HapticService.instance.selection();
        break;
      case HapticType.success:
        HapticService.instance.success();
        break;
      case HapticType.error:
        HapticService.instance.error();
        break;
      case HapticType.celebration:
        HapticService.instance.celebration();
        break;
      case HapticType.streakMilestone:
        HapticService.instance.streakMilestone();
        break;
      case HapticType.achievementUnlock:
        HapticService.instance.achievementUnlock();
        break;
      case HapticType.levelUp:
        HapticService.instance.levelUp();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: FloatingActionButton(
                onPressed: null, // Handled by GestureDetector
                backgroundColor: widget.backgroundColor,
                foregroundColor: widget.foregroundColor,
                child: Icon(widget.icon),
              ),
            ),
          );
        },
      ),
    );
  }
}
