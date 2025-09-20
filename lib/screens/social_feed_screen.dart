import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/social.dart';
import '../services/challenge_service.dart';
import '../services/social_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';
import 'user_profile_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final TextEditingController _postController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'achievement', 'motivation', 'fitness', 'wellness', 'learning',
    'morning', 'evening', 'streak', 'goal', 'progress', 'habit',
    'mindfulness', 'productivity', 'health', 'success', 'challenge'
  ];

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    final posts = ChallengeService.instance.getFeed();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Social Feed',
          style: TextStyle(color: colors.textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.plus, color: colors.textColor),
            onPressed: _showCreatePostDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick Stats
            _buildQuickStats(colors),
            
            // Posts Feed
            Expanded(
              child: posts.isEmpty
                  ? _buildEmptyState(colors)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return _buildPostCard(post, colors);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(NeumorphicColors colors) {
    final friends = SocialService.instance.getAcceptedFriends();
    final onlineFriends = SocialService.instance.getOnlineFriends();
    final activeChallenges = ChallengeService.instance.getActiveChallenges();

    return Container(
      padding: const EdgeInsets.all(16),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Friends',
                friends.length.toString(),
                LucideIcons.users,
                colors,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Online',
                onlineFriends.length.toString(),
                LucideIcons.wifi,
                colors,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Challenges',
                activeChallenges.length.toString(),
                LucideIcons.target,
                colors,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, NeumorphicColors colors) {
    return Column(
      children: [
        Icon(icon, color: colors.textColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colors.textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(SocialPost post, NeumorphicColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => _openUserProfile(post.author),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        post.author.displayName.isNotEmpty ? post.author.displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openUserProfile(post.author),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.textColor,
                          ),
                        ),
                        Text(
                          '@${post.author.username} • ${post.timeAgo}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(LucideIcons.moreVertical, color: colors.textColor),
                  onSelected: (value) => _handlePostAction(value, post),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report'),
                    ),
                    const PopupMenuItem(
                      value: 'hide',
                      child: Text('Hide'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Post Content
            Text(
              post.content,
              style: TextStyle(
                fontSize: 16,
                color: colors.textColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Tags
            if (post.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Image (if any)
            if (post.imageUrl != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colors.textColor.withOpacity(0.1),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 48),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Actions
            Row(
              children: [
                GestureDetector(
                  onTap: () => _likePost(post),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? LucideIcons.heart : LucideIcons.heart,
                        color: post.isLiked ? Colors.red : colors.textColor.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.likes.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    Icon(
                      LucideIcons.messageCircle,
                      color: colors.textColor.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.comments.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Icon(
                  LucideIcons.share,
                  color: colors.textColor.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(NeumorphicColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.messageSquare,
            size: 64,
            color: colors.textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Posts Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your progress!',
            style: TextStyle(
              fontSize: 14,
              color: colors.textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreatePostDialog,
            icon: const Icon(LucideIcons.plus),
            label: const Text('Create Post'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _postController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedTags.remove(tag);
                        } else {
                          _selectedTags.add(tag);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: Theme.of(context).colorScheme.primary)
                            : null,
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _postController.clear();
              _selectedTags.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _createPost,
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _createPost() async {
    if (_postController.text.trim().isEmpty) return;

    try {
      await ChallengeService.instance.createPost(
        content: _postController.text.trim(),
        tags: _selectedTags,
      );

      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _postController.clear();
          _selectedTags.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    }
  }

  void _likePost(SocialPost post) async {
    await ChallengeService.instance.likePost(post.id);
    setState(() {});
  }

  void _openUserProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(user: user),
      ),
    );
  }

  void _handlePostAction(String action, SocialPost post) {
    switch (action) {
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post reported')),
        );
        break;
      case 'hide':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post hidden')),
        );
        break;
    }
  }
}
