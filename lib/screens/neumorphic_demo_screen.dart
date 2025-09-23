import 'package:flutter/material.dart';
import '../widgets/neumorphic_components.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';

class NeumorphicDemoScreen extends StatefulWidget {
  const NeumorphicDemoScreen({super.key});

  @override
  State<NeumorphicDemoScreen> createState() => _NeumorphicDemoScreenState();
}

class _NeumorphicDemoScreenState extends State<NeumorphicDemoScreen> {
  bool _switchValue = false;
  double _sliderValue = 0.5;
  double _progressValue = 0.7;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          'Enhanced Neumorphic Theme',
          style: TextStyle(
            color: colors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: NeumorphicButton(
          effect: NeumorphicEffect.concave,
          borderRadius: 12,
          padding: const EdgeInsets.all(8),
          onPressed: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: colors.textColor,
            size: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            NeumorphicCard(
              effect: NeumorphicEffect.glass,
              enableGlow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enhanced Neumorphic Design',
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Experience the next level of neumorphic design with advanced effects, animations, and interactions.',
                    style: TextStyle(
                      color: colors.textColor.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Effect Showcase
            Text(
              'Effect Showcase',
              style: TextStyle(
                color: colors.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Effect Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildEffectCard('Convex', NeumorphicEffect.convex),
                _buildEffectCard('Concave', NeumorphicEffect.concave),
                _buildEffectCard('Floating', NeumorphicEffect.floating, enableFloating: true),
                _buildEffectCard('Glass', NeumorphicEffect.glass, enableGlow: true),
                _buildEffectCard('Gradient', NeumorphicEffect.gradient),
                _buildEffectCard('Embossed', NeumorphicEffect.embossed),
              ],
            ),

            const SizedBox(height: 24),

            // Interactive Components
            Text(
              'Interactive Components',
              style: TextStyle(
                color: colors.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Buttons
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buttons',
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: NeumorphicButton(
                          effect: NeumorphicEffect.convex,
                          onPressed: () {},
                          child: const Text('Convex'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeumorphicButton(
                          effect: NeumorphicEffect.concave,
                          onPressed: () {},
                          child: const Text('Concave'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: NeumorphicButton(
                          effect: NeumorphicEffect.floating,
                          enableFloating: true,
                          onPressed: () {},
                          child: const Text('Floating'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeumorphicButton(
                          effect: NeumorphicEffect.glass,
                          enableGlow: true,
                          onPressed: () {},
                          child: const Text('Glow'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Input Fields
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Input Fields',
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeumorphicTextField(
                    hintText: 'Enter your text here...',
                    controller: _textController,
                    effect: NeumorphicEffect.concave,
                    enableGlow: true,
                  ),
                  const SizedBox(height: 12),
                  NeumorphicTextField(
                    hintText: 'Password field',
                    obscureText: true,
                    effect: NeumorphicEffect.embossed,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Controls
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Controls',
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toggle Switch',
                        style: TextStyle(
                          color: colors.textColor,
                          fontSize: 16,
                        ),
                      ),
                      NeumorphicSwitch(
                        value: _switchValue,
                        onChanged: (value) {
                          setState(() {
                            _switchValue = value;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Slider
                  Text(
                    'Slider Control',
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeumorphicSlider(
                    value: _sliderValue,
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Progress Indicator
                  Text(
                    'Progress Indicator',
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeumorphicProgressIndicator(
                    value: _progressValue,
                    enableGlow: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Floating Action Button Demo
            NeumorphicCard(
              effect: NeumorphicEffect.floating,
              enableFloating: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Floating Elements',
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NeumorphicBox(
                        effect: NeumorphicEffect.floating,
                        enableFloating: true,
                        borderRadius: 25,
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.favorite,
                          color: colors.accent,
                          size: 24,
                        ),
                      ),
                      NeumorphicBox(
                        effect: NeumorphicEffect.floating,
                        enableFloating: true,
                        enableGlow: true,
                        borderRadius: 25,
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.star,
                          color: colors.accent,
                          size: 24,
                        ),
                      ),
                      NeumorphicBox(
                        effect: NeumorphicEffect.floating,
                        enableFloating: true,
                        borderRadius: 25,
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.thumb_up,
                          color: colors.accent,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectCard(String title, NeumorphicEffect effect, {bool enableFloating = false, bool enableGlow = false}) {
    return NeumorphicCard(
      effect: effect,
      enableFloating: enableFloating,
      enableGlow: enableGlow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForEffect(effect),
            size: 32,
            color: Theme.of(context).extension<NeumorphicColors>()!.accent,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).extension<NeumorphicColors>()!.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForEffect(NeumorphicEffect effect) {
    switch (effect) {
      case NeumorphicEffect.convex:
        return Icons.trending_up;
      case NeumorphicEffect.concave:
        return Icons.trending_down;
      case NeumorphicEffect.floating:
        return Icons.cloud;
      case NeumorphicEffect.glass:
        return Icons.diamond;
      case NeumorphicEffect.gradient:
        return Icons.gradient;
      case NeumorphicEffect.embossed:
        return Icons.texture;
      default:
        return Icons.circle;
    }
  }
}
