
enum FriendStatus {
  pending,
  accepted,
  blocked,
}

enum ChallengeStatus {
  active,
  completed,
  expired,
  cancelled,
}

enum ChallengeType {
  streak,
  completion,
  consistency,
  custom,
}

class User {
  final String id;
  final String username;
  final String displayName;
  final String? avatar;
  final int level;
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final DateTime joinedAt;
  final bool isOnline;
  final String? status;

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatar,
    required this.level,
    required this.totalXP,
    required this.currentStreak,
    required this.longestStreak,
    required this.joinedAt,
    this.isOnline = false,
    this.status,
  });

  User copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatar,
    int? level,
    int? totalXP,
    int? currentStreak,
    int? longestStreak,
    DateTime? joinedAt,
    bool? isOnline,
    String? status,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      level: level ?? this.level,
      totalXP: totalXP ?? this.totalXP,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      joinedAt: joinedAt ?? this.joinedAt,
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatar': avatar,
      'level': level,
      'totalXP': totalXP,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'joinedAt': joinedAt.toIso8601String(),
      'isOnline': isOnline,
      'status': status,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      avatar: json['avatar'],
      level: json['level'],
      totalXP: json['totalXP'],
      currentStreak: json['currentStreak'],
      longestStreak: json['longestStreak'],
      joinedAt: DateTime.parse(json['joinedAt']),
      isOnline: json['isOnline'] ?? false,
      status: json['status'],
    );
  }
}

class Friend {
  final String id;
  final User user;
  final FriendStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  const Friend({
    required this.id,
    required this.user,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  Friend copyWith({
    String? id,
    User? user,
    FriendStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return Friend(
      id: id ?? this.id,
      user: user ?? this.user,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
    };
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      user: User.fromJson(json['user']),
      status: FriendStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeStatus status;
  final User creator;
  final List<User> participants;
  final Map<String, dynamic> requirements;
  final Map<String, dynamic> rewards;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final Map<String, dynamic> progress;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.creator,
    required this.participants,
    required this.requirements,
    required this.rewards,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.progress = const {},
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    ChallengeStatus? status,
    User? creator,
    List<User>? participants,
    Map<String, dynamic>? requirements,
    Map<String, dynamic>? rewards,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    Map<String, dynamic>? progress,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      creator: creator ?? this.creator,
      participants: participants ?? this.participants,
      requirements: requirements ?? this.requirements,
      rewards: rewards ?? this.rewards,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      progress: progress ?? this.progress,
    );
  }

  bool get isActive => status == ChallengeStatus.active;
  bool get isCompleted => status == ChallengeStatus.completed;
  bool get isExpired => status == ChallengeStatus.expired;

  Duration get remainingTime => endDate.difference(DateTime.now());
  bool get isExpiringSoon => remainingTime.inDays <= 3;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'creator': creator.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'requirements': requirements,
      'rewards': rewards,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'progress': progress,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.streak,
      ),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChallengeStatus.active,
      ),
      creator: User.fromJson(json['creator']),
      participants: (json['participants'] as List)
          .map((p) => User.fromJson(p))
          .toList(),
      requirements: Map<String, dynamic>.from(json['requirements']),
      rewards: Map<String, dynamic>.from(json['rewards']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
      progress: Map<String, dynamic>.from(json['progress'] ?? {}),
    );
  }
}

class SocialPost {
  final String id;
  final User author;
  final String content;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final bool isLiked;
  final Map<String, dynamic> metadata;

  const SocialPost({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    this.tags = const [],
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.metadata = const {},
  });

  SocialPost copyWith({
    String? id,
    User? author,
    String? content,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    int? likes,
    int? comments,
    bool? isLiked,
    Map<String, dynamic>? metadata,
  }) {
    return SocialPost(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      metadata: metadata ?? this.metadata,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'content': content,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
      'metadata': metadata,
    };
  }

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'],
      author: User.fromJson(json['author']),
      content: json['content'],
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
