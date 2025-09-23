import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/social.dart';
import '../services/social_service.dart';
import '../services/achievement_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';

class UserProfileScreen extends StatefulWidget {
  final User? user;
  
  const UserProfileScreen({
    super.key,
    this.user,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _statusController = TextEditingController();
  bool _isEditingStatus = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user ?? SocialService.instance.currentUser;
    if (user != null) {
      _statusController.text = user.status ?? '';
    }
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;
    final user = widget.user ?? SocialService.instance.currentUser;
    final isCurrentUser = user?.id == SocialService.instance.currentUser?.id;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: colors.textColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Profile',
            style: TextStyle(color: colors.textColor),
          ),
        ),
        body: Center(
          child: Text(
            'No user profile found',
            style: TextStyle(color: colors.textColor),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isCurrentUser ? 'My Profile' : user.displayName,
          style: TextStyle(color: colors.textColor),
        ),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: Icon(LucideIcons.edit, color: colors.textColor),
              onPressed: _toggleStatusEdit,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(user, colors, isCurrentUser),
              const SizedBox(height: 24),
              _buildStats(user, colors),
              const SizedBox(height: 24),
              _buildAchievements(user, colors),
              if (!isCurrentUser) ...[
                const SizedBox(height: 24),
                _buildFriendActions(user, colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user, NeumorphicColors colors, bool isCurrentUser) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
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
                user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Name and username
          Text(
            user.displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            style: TextStyle(
              fontSize: 16,
              color: colors.textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Status
          if (_isEditingStatus && isCurrentUser)
            _buildStatusEditor(colors)
          else
            _buildStatus(user, colors),
          
          const SizedBox(height: 16),
          
          // Online status and level
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: user.isOnline ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Level ${user.level}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(User user, NeumorphicColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        user.status ?? 'No status set',
        style: TextStyle(
          fontSize: 16,
          color: colors.textColor,
          fontStyle: user.status == null ? FontStyle.italic : FontStyle.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatusEditor(NeumorphicColors colors) {
    return Column(
      children: [
        TextField(
          controller: _statusController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'What\'s on your mind?',
            hintStyle: TextStyle(color: colors.textColor.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: colors.textColor.withValues(alpha: 0.05),
          ),
          style: TextStyle(color: colors.textColor),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _cancelStatusEdit,
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.textColor.withValues(alpha: 0.7)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _saveStatus,
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(User user, NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total XP',
                  user.totalXP.toString(),
                  LucideIcons.star,
                  colors,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Current Streak',
                  '${user.currentStreak} days',
                  LucideIcons.flame,
                  colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Longest Streak',
                  '${user.longestStreak} days',
                  LucideIcons.trophy,
                  colors,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Member Since',
                  _formatDate(user.joinedAt),
                  LucideIcons.calendar,
                  colors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, NeumorphicColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.textColor, size: 24),
          const SizedBox(height: 8),
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
              color: colors.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(User user, NeumorphicColors colors) {
    final achievements = AchievementService.instance.getUnlockedAchievements();
    
    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          if (achievements.isEmpty)
            Text(
              'No achievements yet',
              style: TextStyle(
                fontSize: 14,
                color: colors.textColor.withValues(alpha: 0.7),
              ),
            )
          else
            ...achievements.take(3).map((achievement) => _buildAchievementItem(achievement, colors)),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(dynamic achievement, NeumorphicColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.rarityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: achievement.rarityColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.trophy,
            color: achievement.rarityColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendActions(User user, NeumorphicColors colors) {
    final isFriend = SocialService.instance.isFriend(user.id);
    final hasPendingRequest = SocialService.instance.hasPendingRequest(user.id);

    return NeumorphicBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          if (isFriend)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _removeFriend(user),
                icon: const Icon(LucideIcons.userMinus),
                label: const Text('Remove Friend'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          else if (hasPendingRequest)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _acceptFriendRequest(user),
                icon: const Icon(LucideIcons.userCheck),
                label: const Text('Accept Friend Request'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendFriendRequest(user),
                icon: const Icon(LucideIcons.userPlus),
                label: const Text('Add Friend'),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleStatusEdit() {
    setState(() {
      _isEditingStatus = !_isEditingStatus;
    });
  }

  void _cancelStatusEdit() {
    setState(() {
      _isEditingStatus = false;
      _statusController.text = SocialService.instance.currentUser?.status ?? '';
    });
  }

  void _saveStatus() async {
    await SocialService.instance.setUserStatus(_statusController.text);
    setState(() {
      _isEditingStatus = false;
    });
  }

  void _sendFriendRequest(User user) async {
    final success = await SocialService.instance.sendFriendRequest(user.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${user.displayName}')),
      );
    }
  }

  void _acceptFriendRequest(User user) async {
    // This would need to be implemented based on the specific friend request
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request accepted')),
    );
  }

  void _removeFriend(User user) async {
    // This would need to be implemented based on the specific friend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed ${user.displayName} from friends')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return 'Today';
    }
  }
}
