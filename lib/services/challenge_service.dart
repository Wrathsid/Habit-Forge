import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/social.dart';
import '../services/social_service.dart';

class ChallengeService {
  static const String _challengesKey = 'challenges';
  static const String _postsKey = 'social_posts';
  static ChallengeService? _instance;
  static ChallengeService get instance => _instance ??= ChallengeService._();
  
  ChallengeService._();

  List<Challenge> _challenges = [];
  List<SocialPost> _posts = [];

  List<Challenge> get challenges => List.unmodifiable(_challenges);
  List<SocialPost> get posts => List.unmodifiable(_posts);

  Future<void> initialize() async {
    await _loadChallenges();
    await _loadPosts();
    await _createDefaultChallenges();
    await _createDefaultPosts();
  }

  Future<void> _loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = prefs.getStringList(_challengesKey) ?? [];
    
    _challenges = challengesJson
        .map((json) => Challenge.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getStringList(_postsKey) ?? [];
    
    _posts = postsJson
        .map((json) => SocialPost.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = _challenges
        .map((challenge) => jsonEncode(challenge.toJson()))
        .toList();
    
    await prefs.setStringList(_challengesKey, challengesJson);
  }

  Future<void> _savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = _posts
        .map((post) => jsonEncode(post.toJson()))
        .toList();
    
    await prefs.setStringList(_postsKey, postsJson);
  }

  Future<void> _createDefaultChallenges() async {
    if (_challenges.isNotEmpty) return;

    final users = SocialService.instance.users;
    if (users.isEmpty) return;

    final demoChallenges = [
      Challenge(
        id: const Uuid().v4(),
        title: '30-Day Fitness Challenge',
        description: 'Complete a workout every day for 30 days!',
        type: ChallengeType.streak,
        status: ChallengeStatus.active,
        creator: users[0],
        participants: users.take(3).toList(),
        requirements: {'streak': 30, 'habit_type': 'fitness'},
        rewards: {'xp': 500, 'badge': 'fitness_master'},
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        progress: {
          users[0].id: {'streak': 5, 'completed': 5},
          users[1].id: {'streak': 3, 'completed': 3},
          users[2].id: {'streak': 7, 'completed': 7},
        },
      ),
      Challenge(
        id: const Uuid().v4(),
        title: 'Morning Routine Master',
        description: 'Build a consistent morning routine for 21 days',
        type: ChallengeType.consistency,
        status: ChallengeStatus.active,
        creator: users[1],
        participants: users.skip(1).take(2).toList(),
        requirements: {'perfect_days': 21, 'habit_type': 'morning'},
        rewards: {'xp': 300, 'badge': 'morning_master'},
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 11)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        progress: {
          users[1].id: {'perfect_days': 10, 'completed': 10},
          users[2].id: {'perfect_days': 8, 'completed': 8},
        },
      ),
      Challenge(
        id: const Uuid().v4(),
        title: 'Reading Marathon',
        description: 'Read for 30 minutes daily for 2 weeks',
        type: ChallengeType.completion,
        status: ChallengeStatus.completed,
        creator: users[2],
        participants: users.take(2).toList(),
        requirements: {'completions': 14, 'habit_type': 'reading'},
        rewards: {'xp': 200, 'badge': 'bookworm'},
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        endDate: DateTime.now().subtract(const Duration(days: 6)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        progress: {
          users[0].id: {'completions': 14, 'completed': 14},
          users[1].id: {'completions': 12, 'completed': 12},
        },
      ),
    ];

    _challenges = demoChallenges;
    await _saveChallenges();
  }

  Future<void> _createDefaultPosts() async {
    if (_posts.isNotEmpty) return;

    final users = SocialService.instance.users;
    if (users.isEmpty) return;

    final demoPosts = [
      SocialPost(
        id: const Uuid().v4(),
        author: users[0],
        content: 'Just completed my 30-day fitness challenge! 💪 Feeling stronger than ever!',
        tags: ['fitness', 'achievement', 'motivation'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 15,
        comments: 3,
      ),
      SocialPost(
        id: const Uuid().v4(),
        author: users[1],
        content: 'Morning meditation is changing my life. 21 days strong! 🧘‍♀️',
        tags: ['meditation', 'morning', 'wellness'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 8,
        comments: 2,
      ),
      SocialPost(
        id: const Uuid().v4(),
        author: users[2],
        content: 'Reading "Atomic Habits" - game changer for building better routines! 📚',
        tags: ['reading', 'habits', 'learning'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 12,
        comments: 5,
      ),
      SocialPost(
        id: const Uuid().v4(),
        author: users[0],
        content: 'New personal record: 7-day streak on my water intake habit! 🚰',
        tags: ['hydration', 'streak', 'health'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likes: 6,
        comments: 1,
      ),
    ];

    _posts = demoPosts;
    await _savePosts();
  }

  Future<Challenge> createChallenge({
    required String title,
    required String description,
    required ChallengeType type,
    required Map<String, dynamic> requirements,
    required Map<String, dynamic> rewards,
    required DateTime endDate,
  }) async {
    final currentUser = SocialService.instance.currentUser;
    if (currentUser == null) throw Exception('No current user');

    final challenge = Challenge(
      id: const Uuid().v4(),
      title: title,
      description: description,
      type: type,
      status: ChallengeStatus.active,
      creator: currentUser,
      participants: [currentUser],
      requirements: requirements,
      rewards: rewards,
      startDate: DateTime.now(),
      endDate: endDate,
      createdAt: DateTime.now(),
    );

    _challenges.add(challenge);
    await _saveChallenges();
    return challenge;
  }

  Future<bool> joinChallenge(String challengeId) async {
    final currentUser = SocialService.instance.currentUser;
    if (currentUser == null) return false;

    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) return false;

    final challenge = _challenges[index];
    if (challenge.participants.any((p) => p.id == currentUser.id)) return false;

    _challenges[index] = challenge.copyWith(
      participants: [...challenge.participants, currentUser],
    );

    await _saveChallenges();
    return true;
  }

  Future<bool> leaveChallenge(String challengeId) async {
    final currentUser = SocialService.instance.currentUser;
    if (currentUser == null) return false;

    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) return false;

    final challenge = _challenges[index];
    final updatedParticipants = challenge.participants
        .where((p) => p.id != currentUser.id)
        .toList();

    _challenges[index] = challenge.copyWith(
      participants: updatedParticipants,
    );

    await _saveChallenges();
    return true;
  }

  Future<void> updateChallengeProgress(String challengeId, Map<String, dynamic> progress) async {
    final currentUser = SocialService.instance.currentUser;
    if (currentUser == null) return;

    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) return;

    final challenge = _challenges[index];
    final updatedProgress = Map<String, dynamic>.from(challenge.progress);
    updatedProgress[currentUser.id] = progress;

    _challenges[index] = challenge.copyWith(progress: updatedProgress);
    await _saveChallenges();
  }

  Future<SocialPost> createPost({
    required String content,
    List<String> tags = const [],
    String? imageUrl,
  }) async {
    final currentUser = SocialService.instance.currentUser;
    if (currentUser == null) throw Exception('No current user');

    final post = SocialPost(
      id: const Uuid().v4(),
      author: currentUser,
      content: content,
      tags: tags,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    _posts.insert(0, post); // Add to beginning
    await _savePosts();
    return post;
  }

  Future<void> likePost(String postId) async {
    final currentUser = SocialService.instance.currentUser;
    if (currentUser == null) return;

    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final isLiked = post.isLiked;
    
    _posts[index] = post.copyWith(
      likes: isLiked ? post.likes - 1 : post.likes + 1,
      isLiked: !isLiked,
    );

    await _savePosts();
  }

  List<Challenge> getActiveChallenges() {
    return _challenges.where((c) => c.status == ChallengeStatus.active).toList();
  }

  List<Challenge> getCompletedChallenges() {
    return _challenges.where((c) => c.status == ChallengeStatus.completed).toList();
  }

  List<Challenge> getUserChallenges(String userId) {
    return _challenges.where((c) => 
        c.creator.id == userId || 
        c.participants.any((p) => p.id == userId)
    ).toList();
  }

  List<SocialPost> getFeed() {
    return List<SocialPost>.from(_posts)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<SocialPost> getPostsByUser(String userId) {
    return _posts.where((p) => p.author.id == userId).toList();
  }

  List<SocialPost> searchPosts(String query) {
    if (query.isEmpty) return _posts;
    
    final lowercaseQuery = query.toLowerCase();
    return _posts.where((post) {
      return post.content.toLowerCase().contains(lowercaseQuery) ||
             post.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  List<Challenge> searchChallenges(String query) {
    if (query.isEmpty) return _challenges;
    
    final lowercaseQuery = query.toLowerCase();
    return _challenges.where((challenge) {
      return challenge.title.toLowerCase().contains(lowercaseQuery) ||
             challenge.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Map<String, dynamic> getChallengeStats(String challengeId) {
    try {
      final challenge = _challenges.firstWhere((c) => c.id == challengeId);
      final totalParticipants = challenge.participants.length;
    final completedParticipants = challenge.progress.length;
    final completionRate = totalParticipants > 0 ? completedParticipants / totalParticipants : 0.0;

    return {
      'totalParticipants': totalParticipants,
      'completedParticipants': completedParticipants,
      'completionRate': completionRate,
      'daysRemaining': challenge.remainingTime.inDays,
      'isExpiringSoon': challenge.isExpiringSoon,
    };
  }
}
