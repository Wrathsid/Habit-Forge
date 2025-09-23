import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  static HapticService get instance => _instance;

  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  // Check if haptic feedback is available on current platform
  bool get _isHapticAvailable {
    if (kIsWeb) {
      // Web doesn't support haptic feedback
      return false;
    }
    return true;
  }

  // Light haptic feedback for subtle interactions
  Future<void> light() async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  // Medium haptic feedback for regular interactions
  Future<void> medium() async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  // Heavy haptic feedback for important interactions
  Future<void> heavy() async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  // Selection haptic feedback for UI selections
  Future<void> selection() async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  // Success haptic pattern
  Future<void> success() async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      // Custom success pattern: light-medium-light
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback error: $e');
      }
      // Disable haptic feedback if it fails
      _isHapticAvailable = false;
    }
  }

  // Error haptic pattern
  Future<void> error() async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      // Custom error pattern: heavy-heavy
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback error: $e');
      }
      // Disable haptic feedback if it fails
      _isHapticAvailable = false;
    }
  }

  // Celebration haptic pattern
  Future<void> celebration() async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      // Custom celebration pattern: light-medium-heavy-medium-light
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback error: $e');
      }
      // Disable haptic feedback if it fails
      _isHapticAvailable = false;
    }
  }

  // Streak milestone haptic pattern
  Future<void> streakMilestone() async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      // Custom streak pattern: medium-light-medium-light-medium
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  // Achievement unlock haptic pattern
  Future<void> achievementUnlock() async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      // Custom achievement pattern: heavy-light-heavy-light-heavy
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  // Level up haptic pattern
  Future<void> levelUp() async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      // Custom level up pattern: medium-heavy-medium-heavy-medium-heavy
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 90));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 90));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 90));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 90));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 90));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  // Check if device supports haptic feedback
  Future<bool> isAvailable() async {
    if (kIsWeb) {
      return false; // Web doesn't support haptic feedback
    }
    
    try {
      return await Vibration.hasVibrator();
    } catch (e) {
      print('Error checking haptic availability: $e');
      return false;
    }
  }

  // Custom vibration pattern
  Future<void> customPattern(List<int> pattern) async {
    if (!_isEnabled || !_isHapticAvailable) return;
    
    try {
      await Vibration.vibrate(pattern: pattern);
    } catch (e) {
      if (kDebugMode) {
        print('Custom vibration pattern failed: $e');
      }
    }
  }
}
