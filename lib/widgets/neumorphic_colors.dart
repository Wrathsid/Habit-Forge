import 'package:flutter/material.dart';

@immutable
class NeumorphicColors extends ThemeExtension<NeumorphicColors> {
  // Base colors
  final Color background;
  final Color shadowDark;
  final Color shadowLight;
  final Color textColor;
  
  // Enhanced neumorphic colors
  final Color surface;
  final Color highlight;
  final Color accent;
  final Color accentGlow;
  
  // Depth variations
  final Color depth1;
  final Color depth2;
  final Color depth3;
  
  // Interactive states
  final Color pressed;
  final Color hover;
  final Color focus;
  
  // Special effects
  final Color glow;
  final Color reflection;
  final Color ambient;

  const NeumorphicColors({
    required this.background,
    required this.shadowDark,
    required this.shadowLight,
    required this.textColor,
    required this.surface,
    required this.highlight,
    required this.accent,
    required this.accentGlow,
    required this.depth1,
    required this.depth2,
    required this.depth3,
    required this.pressed,
    required this.hover,
    required this.focus,
    required this.glow,
    required this.reflection,
    required this.ambient,
  });

  // Light theme
  static const NeumorphicColors light = NeumorphicColors(
    background: Color(0xFFE6E6E6),
    shadowDark: Color(0xFFB8B8B8),
    shadowLight: Color(0xFFFFFFFF),
    textColor: Color(0xFF2C2C2C),
    surface: Color(0xFFF0F0F0),
    highlight: Color(0xFFFFFFFF),
    accent: Color(0xFF007AFF),
    accentGlow: Color(0x40007AFF),
    depth1: Color(0xFFE0E0E0),
    depth2: Color(0xFFD8D8D8),
    depth3: Color(0xFFD0D0D0),
    pressed: Color(0xFFD4D4D4),
    hover: Color(0xFFECECEC),
    focus: Color(0xFFE8F4FD),
    glow: Color(0x20007AFF),
    reflection: Color(0x30FFFFFF),
    ambient: Color(0x10FFFFFF),
  );

  // Dark theme
  static const NeumorphicColors dark = NeumorphicColors(
    background: Color(0xFF1A1A1A),
    shadowDark: Color(0xFF0A0A0A),
    shadowLight: Color(0xFF2A2A2A),
    textColor: Color(0xFFE0E0E0),
    surface: Color(0xFF1E1E1E),
    highlight: Color(0xFF2A2A2A),
    accent: Color(0xFF00FFFF),
    accentGlow: Color(0x4000FFFF),
    depth1: Color(0xFF1C1C1C),
    depth2: Color(0xFF202020),
    depth3: Color(0xFF242424),
    pressed: Color(0xFF161616),
    hover: Color(0xFF1F1F1F),
    focus: Color(0xFF1A2A2A),
    glow: Color(0x2000FFFF),
    reflection: Color(0x10FFFFFF),
    ambient: Color(0x05FFFFFF),
  );

  // Cyberpunk theme
  static const NeumorphicColors cyberpunk = NeumorphicColors(
    background: Color(0xFF0A0A0A),
    shadowDark: Color(0xFF000000),
    shadowLight: Color(0xFF1A1A1A),
    textColor: Color(0xFF00FFFF),
    surface: Color(0xFF0E0E0E),
    highlight: Color(0xFF1A1A1A),
    accent: Color(0xFFFF00FF),
    accentGlow: Color(0x40FF00FF),
    depth1: Color(0xFF0C0C0C),
    depth2: Color(0xFF101010),
    depth3: Color(0xFF141414),
    pressed: Color(0xFF080808),
    hover: Color(0xFF0F0F0F),
    focus: Color(0xFF1A0A1A),
    glow: Color(0x30FF00FF),
    reflection: Color(0x20FF00FF),
    ambient: Color(0x10FF00FF),
  );

  @override
  NeumorphicColors copyWith({
    Color? background,
    Color? shadowDark,
    Color? shadowLight,
    Color? textColor,
    Color? surface,
    Color? highlight,
    Color? accent,
    Color? accentGlow,
    Color? depth1,
    Color? depth2,
    Color? depth3,
    Color? pressed,
    Color? hover,
    Color? focus,
    Color? glow,
    Color? reflection,
    Color? ambient,
  }) {
    return NeumorphicColors(
      background: background ?? this.background,
      shadowDark: shadowDark ?? this.shadowDark,
      shadowLight: shadowLight ?? this.shadowLight,
      textColor: textColor ?? this.textColor,
      surface: surface ?? this.surface,
      highlight: highlight ?? this.highlight,
      accent: accent ?? this.accent,
      accentGlow: accentGlow ?? this.accentGlow,
      depth1: depth1 ?? this.depth1,
      depth2: depth2 ?? this.depth2,
      depth3: depth3 ?? this.depth3,
      pressed: pressed ?? this.pressed,
      hover: hover ?? this.hover,
      focus: focus ?? this.focus,
      glow: glow ?? this.glow,
      reflection: reflection ?? this.reflection,
      ambient: ambient ?? this.ambient,
    );
  }

  @override
  NeumorphicColors lerp(ThemeExtension<NeumorphicColors>? other, double t) {
    if (other is! NeumorphicColors) return this;
    return NeumorphicColors(
      background: Color.lerp(background, other.background, t)!,
      shadowDark: Color.lerp(shadowDark, other.shadowDark, t)!,
      shadowLight: Color.lerp(shadowLight, other.shadowLight, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      depth1: Color.lerp(depth1, other.depth1, t)!,
      depth2: Color.lerp(depth2, other.depth2, t)!,
      depth3: Color.lerp(depth3, other.depth3, t)!,
      pressed: Color.lerp(pressed, other.pressed, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      reflection: Color.lerp(reflection, other.reflection, t)!,
      ambient: Color.lerp(ambient, other.ambient, t)!,
    );
  }
}
