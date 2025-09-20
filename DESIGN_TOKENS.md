# Design Tokens

This document defines the design system tokens used throughout HabitForge.

## Colors

### Dark Themes

| Token | Value | Usage |
|-------|-------|-------|
| `midnightBlack` | `#0A0A0A` | Primary background |
| `trueBlack` | `#000000` | Secondary background |
| `warmBlack` | `#1A1A1A` | Alternative background |

### Surface Colors

| Token | Value | Usage |
|-------|-------|-------|
| `surfaceDark` | `#1E1E1E` | Card backgrounds |
| `surfaceMedium` | `#2A2A2A` | Input fields |
| `surfaceLight` | `#3A3A3A` | Hover states |

### Neon Accents

| Token | Value | Usage |
|-------|-------|-------|
| `neonCyan` | `#00FFFF` | Primary accent |
| `neonMagenta` | `#FF00FF` | Secondary accent |
| `neonLime` | `#00FF00` | Success states |
| `neonOrange` | `#FF6600` | Warning states |
| `neonPurple` | `#9900FF` | Learning category |

### Text Colors

| Token | Value | Usage |
|-------|-------|-------|
| `textPrimary` | `#FFFFFF` | Headlines, important text |
| `textSecondary` | `#B0B0B0` | Body text |
| `textTertiary` | `#808080` | Labels, captions |

### Status Colors

| Token | Value | Usage |
|-------|-------|-------|
| `success` | `#00FF88` | Success states |
| `warning` | `#FFAA00` | Warning states |
| `error` | `#FF4444` | Error states |

## Typography

### Font Family

- **Primary**: Inter
- **Fallback**: system-ui, -apple-system, sans-serif

### Font Weights

| Weight | Value | Usage |
|--------|-------|-------|
| Regular | 400 | Body text |
| Medium | 500 | Labels, buttons |
| SemiBold | 600 | Subheadings |
| Bold | 700 | Headlines |

### Font Sizes

| Scale | Size | Usage |
|-------|------|-------|
| Display Large | 32px | Hero headlines |
| Display Medium | 28px | Page titles |
| Display Small | 24px | Section titles |
| Headline Large | 22px | Card titles |
| Headline Medium | 20px | App bar titles |
| Headline Small | 18px | Subsection titles |
| Title Large | 16px | List items |
| Title Medium | 14px | Labels |
| Title Small | 12px | Captions |
| Body Large | 16px | Body text |
| Body Medium | 14px | Secondary text |
| Body Small | 12px | Helper text |
| Label Large | 14px | Button text |
| Label Medium | 12px | Small buttons |
| Label Small | 10px | Micro text |

## Spacing

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `spaceXS` | 4px | Tight spacing |
| `spaceSM` | 8px | Small spacing |
| `spaceMD` | 16px | Medium spacing |
| `spaceLG` | 24px | Large spacing |
| `spaceXL` | 32px | Extra large spacing |
| `spaceXXL` | 48px | Section spacing |

### Component Spacing

| Component | Padding | Margin |
|-----------|---------|--------|
| Cards | 16px | 8px |
| Buttons | 16px vertical, 24px horizontal | 8px |
| Input fields | 16px | 0px |
| List items | 16px | 0px |

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radiusXS` | 4px | Small elements |
| `radiusSM` | 8px | Buttons, chips |
| `radiusMD` | 12px | Input fields |
| `radiusLG` | 16px | Cards |
| `radiusXL` | 24px | Large cards |
| `radiusXXL` | 32px | Hero elements |

## Elevation

| Token | Value | Usage |
|-------|-------|-------|
| `elevationLow` | 2px | Subtle shadows |
| `elevationMedium` | 4px | Standard shadows |
| `elevationHigh` | 8px | Prominent shadows |
| `elevationVeryHigh` | 16px | Modal shadows |

## Animation

### Durations

| Token | Value | Usage |
|-------|-------|-------|
| `durationFast` | 150ms | Micro interactions |
| `durationMedium` | 300ms | Standard animations |
| `durationSlow` | 500ms | Page transitions |
| `durationVerySlow` | 800ms | Complex animations |

### Reduced Motion Durations

| Token | Value | Usage |
|-------|-------|-------|
| `durationReducedFast` | 50ms | Micro interactions |
| `durationReducedMedium` | 100ms | Standard animations |
| `durationReducedSlow` | 200ms | Page transitions |

### Easing Curves

| Curve | Usage |
|-------|-------|
| `Curves.easeOut` | Standard animations |
| `Curves.easeInOut` | Page transitions |
| `Curves.elasticOut` | Bounce effects |
| `Curves.easeOutCubic` | Smooth animations |

## Neon Effects

### Glow Values

| Token | Value | Usage |
|-------|-------|-------|
| `glowRadius` | 20px | Standard glow |
| `glowOpacity` | 0.3 | Standard opacity |
| `glowIntensity` | 0.8 | Standard intensity |

### Glow Variations

| Variation | Radius | Opacity | Usage |
|-----------|--------|---------|-------|
| Subtle | 10px | 0.1 | Hover states |
| Standard | 20px | 0.3 | Active states |
| Prominent | 30px | 0.5 | Focus states |
| Intense | 40px | 0.7 | Celebrations |

## Component Tokens

### Buttons

| Variant | Background | Text | Border | Padding |
|---------|------------|------|--------|---------|
| Primary | `neonCyan` | `trueBlack` | None | 16px vertical, 24px horizontal |
| Secondary | Transparent | `neonCyan` | `neonCyan` | 16px vertical, 24px horizontal |
| Danger | `error` | `textPrimary` | None | 16px vertical, 24px horizontal |

### Cards

| Property | Value |
|----------|-------|
| Background | `surfaceDark` |
| Border | `surfaceMedium` |
| Border Radius | `radiusLG` |
| Padding | `spaceMD` |
| Shadow | `elevationMedium` |

### Input Fields

| Property | Value |
|----------|-------|
| Background | `surfaceMedium` |
| Border | None |
| Border Radius | `radiusMD` |
| Padding | `spaceMD` |
| Focus Border | `neonCyan` |

## Accessibility

### Color Contrast

| Combination | Ratio | Status |
|-------------|-------|--------|
| `textPrimary` on `midnightBlack` | 21:1 | AAA |
| `textSecondary` on `midnightBlack` | 4.5:1 | AA |
| `neonCyan` on `trueBlack` | 4.5:1 | AA |

### Touch Targets

| Component | Minimum Size |
|-----------|--------------|
| Buttons | 44px × 44px |
| Icons | 24px × 24px |
| Touch targets | 48px × 48px |

### Motion Preferences

- Respect `prefers-reduced-motion` system setting
- Provide alternative animations for reduced motion
- Use shorter durations for reduced motion mode

## Responsive Design

### Breakpoints

| Breakpoint | Width | Usage |
|------------|-------|-------|
| Mobile | < 768px | Default |
| Tablet | 768px - 1024px | Medium screens |
| Desktop | > 1024px | Large screens |

### Grid System

| Columns | Gutter | Margin |
|---------|--------|--------|
| 12 | 16px | 16px |

## Dark Mode Considerations

### Color Adjustments

- All colors optimized for dark backgrounds
- High contrast ratios maintained
- Neon accents provide sufficient contrast
- Text colors tested for readability

### Visual Hierarchy

- Use elevation and glow effects for depth
- Neon accents draw attention to important elements
- Subtle borders define component boundaries
- Consistent spacing creates visual rhythm

## Implementation Notes

### Flutter Implementation

```dart
// Color usage
Container(
  color: AppTheme.midnightBlack,
  child: Text(
    'Hello World',
    style: TextStyle(color: AppTheme.textPrimary),
  ),
)

// Spacing usage
Padding(
  padding: EdgeInsets.all(DesignTokens.spaceMD),
  child: Widget(),
)

// Animation usage
AnimatedContainer(
  duration: DesignTokens.durationMedium,
  curve: Curves.easeOut,
  child: Widget(),
)
```

### CSS Implementation

```css
/* Color usage */
.card {
  background-color: var(--color-surface-dark);
  color: var(--color-text-primary);
}

/* Spacing usage */
.button {
  padding: var(--space-md);
  margin: var(--space-sm);
}

/* Animation usage */
.transition {
  transition-duration: var(--duration-medium);
  transition-timing-function: ease-out;
}
```

## Maintenance

### Updating Tokens

1. Update token values in `app_theme.dart`
2. Update this documentation
3. Test across all components
4. Verify accessibility compliance
5. Update design system documentation

### Token Naming

- Use descriptive names
- Follow camelCase convention
- Group related tokens
- Use consistent prefixes
- Document usage examples
