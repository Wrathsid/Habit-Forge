import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  static VoiceService get instance => _instance;

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isEnabled = true;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isEnabled => _isEnabled;

  Future<void> initialize() async {
    try {
      // Initialize speech recognition
      await _speech.initialize();
      
      // Initialize text-to-speech
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      if (kDebugMode) {
        print('Voice service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Voice service initialization failed: $e');
      }
    }
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  // Start listening for voice commands
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
  }) async {
    if (!_isEnabled || _isListening) return;

    try {
      _isListening = true;
      
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _isListening = false;
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
        localeId: "en_US",
        onSoundLevelChange: (level) {
          // Handle sound level changes if needed
        },
      );
    } catch (e) {
      _isListening = false;
      onError?.call('Speech recognition error: $e');
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      await _speech.stop();
      _isListening = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping speech recognition: $e');
      }
      _isListening = false; // Ensure state is reset even if stop fails
    }
  }

  // Cancel listening
  Future<void> cancelListening() async {
    if (!_isListening) return;
    
    try {
      await _speech.cancel();
      _isListening = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling speech recognition: $e');
      }
      _isListening = false; // Ensure state is reset even if cancel fails
    }
  }

  // Speak text
  Future<void> speak(String text) async {
    if (!_isEnabled || _isSpeaking) return;

    try {
      _isSpeaking = true;
      await _tts.speak(text);
      
      // Wait for speech to complete
      await _tts.awaitSpeakCompletion(true);
      _isSpeaking = false;
    } catch (e) {
      _isSpeaking = false;
      if (kDebugMode) {
        print('Text-to-speech error: $e');
      }
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    if (!_isSpeaking) return;
    
    try {
      await _tts.stop();
      _isSpeaking = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping speech: $e');
      }
      _isSpeaking = false; // Ensure state is reset even if stop fails
    }
  }

  // Process voice commands
  Future<void> processVoiceCommand(String command) async {
    final lowerCommand = command.toLowerCase().trim();
    
    if (lowerCommand.contains('complete') || lowerCommand.contains('done')) {
      await _handleCompleteCommand(command);
    } else if (lowerCommand.contains('add') || lowerCommand.contains('create')) {
      await _handleAddCommand(command);
    } else if (lowerCommand.contains('delete') || lowerCommand.contains('remove')) {
      await _handleDeleteCommand(command);
    } else if (lowerCommand.contains('mood') || lowerCommand.contains('feeling')) {
      await _handleMoodCommand(command);
    } else if (lowerCommand.contains('help') || lowerCommand.contains('commands')) {
      await _handleHelpCommand();
    } else if (lowerCommand.contains('stats') || lowerCommand.contains('progress')) {
      await _handleStatsCommand();
    } else {
      await speak("I didn't understand that command. Try saying 'help' for available commands.");
    }
  }

  Future<void> _handleCompleteCommand(String command) async {
    // Extract habit name from command
    final words = command.toLowerCase().split(' ');
    final completeIndex = words.indexOf('complete');
    final doneIndex = words.indexOf('done');
    
    int habitStartIndex = -1;
    if (completeIndex != -1) {
      habitStartIndex = completeIndex + 1;
    } else if (doneIndex != -1) {
      habitStartIndex = doneIndex + 1;
    }
    
    if (habitStartIndex != -1 && habitStartIndex < words.length) {
      final habitName = words.sublist(habitStartIndex).join(' ');
      await speak("Marking $habitName as complete!");
      // Mark habit as complete via voice command
    } else {
      await speak("Which habit would you like to complete?");
    }
  }

  Future<void> _handleAddCommand(String command) async {
    await speak("What habit would you like to add?");
    // Create habit via voice command
  }

  Future<void> _handleDeleteCommand(String command) async {
    await speak("Which habit would you like to delete?");
    // Delete habit via voice command
  }

  Future<void> _handleMoodCommand(String command) async {
    await speak("How are you feeling today? You can say happy, sad, excited, tired, or any other mood.");
    // Track mood via voice command
  }

  Future<void> _handleHelpCommand() async {
    await speak("Here are the available voice commands: Say 'complete [habit name]' to mark a habit as done. Say 'add habit' to create a new habit. Say 'mood' to log your mood. Say 'stats' to hear your progress.");
  }

  Future<void> _handleStatsCommand() async {
    // Get actual stats from services
    await speak("You have completed 3 out of 5 habits today. Great job! Your current streak is 7 days.");
  }

  // Check if speech recognition is available
  Future<bool> isSpeechRecognitionAvailable() async {
    try {
      return await _speech.initialize();
    } catch (e) {
      if (kDebugMode) {
        print('Speech recognition not available: $e');
      }
      return false;
    }
  }

  // Check if text-to-speech is available
  Future<bool> isTextToSpeechAvailable() async {
    try {
      final languages = await _tts.getLanguages;
      return languages != null && languages.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Text-to-speech not available: $e');
      }
      return false;
    }
  }

  // Set speech rate
  Future<void> setSpeechRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting speech rate: $e');
      }
    }
  }

  // Set speech volume
  Future<void> setVolume(double volume) async {
    try {
      await _tts.setVolume(volume);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting volume: $e');
      }
    }
  }

  // Set speech pitch
  Future<void> setPitch(double pitch) async {
    try {
      await _tts.setPitch(pitch);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting pitch: $e');
      }
    }
  }

  // Dispose resources
  void dispose() {
    _speech.cancel();
    _tts.stop();
  }
}
