import 'package:flutter/material.dart';

@immutable
class NeumorphicColors extends ThemeExtension<NeumorphicColors> {
  final Color background;
  final Color shadowDark;
  final Color shadowLight;
  final Color textColor;

  const NeumorphicColors({
    required this.background,
    required this.shadowDark,
    required this.shadowLight,
    required this.textColor,
  });

  @override
  NeumorphicColors copyWith({
    Color? background,
    Color? shadowDark,
    Color? shadowLight,
    Color? textColor,
  }) {
    return NeumorphicColors(
      background: background ?? this.background,
      shadowDark: shadowDark ?? this.shadowDark,
      shadowLight: shadowLight ?? this.shadowLight,
      textColor: textColor ?? this.textColor,
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
    );
  }
}
