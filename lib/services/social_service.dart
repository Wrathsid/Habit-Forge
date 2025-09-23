import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/social.dart';
import '../services/achievement_service.dart';

class SocialService {
  static const String _usersKey = 'users';
  static const String _friendsKey = 'friends';
  static const String _currentUserKey = 'current_user';
  static SocialService? _instance;
  static SocialService get instance => _instance ??= SocialService._();
  
  SocialService._();

  List<User> _users = [];
  List<Friend> _friends = [];
  User? _currentUser;

  List<User> get users => List.unmodifiable(_users);
  List<Friend> get friends => List.unmodifiable(_friends);
  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    await _loadUsers();
    await _loadFriends();
    await _loadCurrentUser();
    await _createDefaultUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    
    _users = usersJson
        .map((json) => User.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _loadFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final friendsJson = prefs.getStringList(_friendsKey) ?? [];
    
    _friends = friendsJson
        .map((json) => Friend.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserJson = prefs.getString(_currentUserKey);
    
    if (currentUserJson != null) {
      _currentUser = User.fromJson(jsonDecode(currentUserJson));
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = _users
        .map((user) => jsonEncode(user.toJson()))
        .toList();
    
    await prefs.setStringList(_usersKey, usersJson);
  }

  Future<void> _saveFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final friendsJson = _friends
        .map((friend) => jsonEncode(friend.toJson()))
        .toList();
    
    await prefs.setStringList(_friendsKey, friendsJson);
  }

  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString(_currentUserKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  Future<void> _createDefaultUsers() async {
    if (_users.isNotEmpty) return;

    // Create demo users
    final demoUsers = [
      User(
        id: const Uuid().v4(),
        username: 'habit_master',
        displayName: 'Habit Master',
        level: 15,
        totalXP: 2500,
        currentStreak: 23,
        longestStreak: 45,
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        isOnline: true,
        status: 'Crushing my goals! 💪',
      ),
      User(
        id: const Uuid().v4(),
        username: 'wellness_warrior',
        displayName: 'Wellness Warrior',
        level: 12,
        totalXP: 1800,
        currentStreak: 15,
        longestStreak: 32,
        joinedAt: DateTime.now().subtract(const Duration(days: 45)),
        isOnline: false,
        status: 'Building healthy habits',
      ),
      User(
        id: const Uuid().v4(),
        username: 'fitness_fanatic',
        displayName: 'Fitness Fanatic',
        level: 18,
        totalXP: 3200,
        currentStreak: 8,
        longestStreak: 67,
        joinedAt: DateTime.now().subtract(const Duration(days: 60)),
        isOnline: true,
        status: 'Morning workout complete! 🏃‍♂️',
      ),
      User(
        id: const Uuid().v4(),
        username: 'mindful_meditator',
        displayName: 'Mindful Meditator',
        level: 10,
        totalXP: 1200,
        currentStreak: 31,
        longestStreak: 31,
        joinedAt: DateTime.now().subtract(const Duration(days: 20)),
        isOnline: true,
        status: 'Finding inner peace',
      ),
    ];

    _users = demoUsers;
    await _saveUsers();
  }

  Future<void> createUser({
    required String username,
    required String displayName,
    String? avatar,
  }) async {
    final user = User(
      id: const Uuid().v4(),
      username: username,
      displayName: displayName,
      avatar: avatar,
      level: 1,
      totalXP: 0,
      currentStreak: 0,
      longestStreak: 0,
      joinedAt: DateTime.now(),
      isOnline: true,
    );

    _users.add(user);
    _currentUser = user;
    await _saveUsers();
    await _saveCurrentUser();
  }

  Future<void> updateUser(User user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      if (_currentUser?.id == user.id) {
        _currentUser = user;
        await _saveCurrentUser();
      }
      await _saveUsers();
    }
  }

  Future<void> updateUserProgress() async {
    if (_currentUser == null) return;

    final userProgress = AchievementService.instance.userProgress;
    final updatedUser = _currentUser!.copyWith(
      level: userProgress.currentLevel,
      totalXP: userProgress.totalXP,
      longestStreak: userProgress.longestStreak,
    );

    await updateUser(updatedUser);
  }

  Future<bool> sendFriendRequest(String userId) async {
    if (_currentUser == null) return false;

    try {
      _friends.firstWhere(
        (f) => f.user.id == userId && f.user.id == _currentUser!.id,
      );
      return false; // Already friends or request sent
    } catch (e) {
      // No existing friend found, continue
    }

    final friend = Friend(
      id: const Uuid().v4(),
      user: _users.firstWhere((u) => u.id == userId, orElse: () => throw Exception('User not found')),
      status: FriendStatus.pending,
      createdAt: DateTime.now(),
    );

    _friends.add(friend);
    await _saveFriends();
    return true;
  }

  Future<bool> acceptFriendRequest(String friendId) async {
    final index = _friends.indexWhere((f) => f.id == friendId);
    if (index == -1) return false;

    _friends[index] = _friends[index].copyWith(
      status: FriendStatus.accepted,
      acceptedAt: DateTime.now(),
    );

    await _saveFriends();
    return true;
  }

  Future<bool> rejectFriendRequest(String friendId) async {
    _friends.removeWhere((f) => f.id == friendId);
    await _saveFriends();
    return true;
  }

  Future<bool> removeFriend(String friendId) async {
    _friends.removeWhere((f) => f.id == friendId);
    await _saveFriends();
    return true;
  }

  List<Friend> getPendingRequests() {
    return _friends.where((f) => f.status == FriendStatus.pending).toList();
  }

  List<Friend> getAcceptedFriends() {
    return _friends.where((f) => f.status == FriendStatus.accepted).toList();
  }

  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;
    
    final lowercaseQuery = query.toLowerCase();
    return _users.where((user) {
      return user.username.toLowerCase().contains(lowercaseQuery) ||
             user.displayName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  List<User> getOnlineFriends() {
    final acceptedFriends = getAcceptedFriends();
    return acceptedFriends
        .map((f) => f.user)
        .where((u) => u.isOnline)
        .toList();
  }

  List<User> getLeaderboard() {
    final allUsers = List<User>.from(_users);
    allUsers.sort((a, b) => b.totalXP.compareTo(a.totalXP));
    return allUsers.take(10).toList();
  }

  Future<void> setUserStatus(String status) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(status: status);
    await updateUser(updatedUser);
  }

  Future<void> setUserOnlineStatus(bool isOnline) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(isOnline: isOnline);
    await updateUser(updatedUser);
  }

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.id == userId, orElse: () => throw Exception('User not found'));
    } catch (e) {
      return null;
    }
  }

  bool isFriend(String userId) {
    return _friends.any((f) => 
        f.user.id == userId && f.status == FriendStatus.accepted);
  }

  bool hasPendingRequest(String userId) {
    return _friends.any((f) => 
        f.user.id == userId && f.status == FriendStatus.pending);
  }
}
