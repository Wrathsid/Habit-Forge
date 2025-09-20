import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/social.dart';
import '../services/social_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';
import 'user_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NeumorphicColors>()!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Friends',
          style: TextStyle(color: colors.textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.search, color: colors.textColor),
            onPressed: _showSearchDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.textColor,
          unselectedLabelColor: colors.textColor.withOpacity(0.5),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsTab(colors),
          _buildRequestsTab(colors),
          _buildDiscoverTab(colors),
        ],
      ),
    );
  }

  Widget _buildFriendsTab(NeumorphicColors colors) {
    final friends = SocialService.instance.getAcceptedFriends();
    final onlineFriends = SocialService.instance.getOnlineFriends();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onlineFriends.isNotEmpty) ...[
              Text(
                'Online Now (${onlineFriends.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: onlineFriends.length,
                  itemBuilder: (context, index) {
                    final friend = onlineFriends[index];
                    return _buildOnlineFriendItem(friend, colors);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'All Friends (${friends.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: friends.isEmpty
                  ? _buildEmptyState('No friends yet', 'Start adding friends to see their progress!', LucideIcons.users, colors)
                  : ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return _buildFriendItem(friend, colors);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab(NeumorphicColors colors) {
    final requests = SocialService.instance.getPendingRequests();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Friend Requests (${requests.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: requests.isEmpty
                  ? _buildEmptyState('No pending requests', 'Friend requests will appear here', LucideIcons.userPlus, colors)
                  : ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return _buildRequestItem(request, colors);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverTab(NeumorphicColors colors) {
    final allUsers = SocialService.instance.users;
    final currentUser = SocialService.instance.currentUser;
    final discoverableUsers = allUsers.where((user) => 
        user.id != currentUser?.id && 
        !SocialService.instance.isFriend(user.id) &&
        !SocialService.instance.hasPendingRequest(user.id)
    ).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover People (${discoverableUsers.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: discoverableUsers.isEmpty
                  ? _buildEmptyState('No one to discover', 'All users are already your friends!', LucideIcons.search, colors)
                  : ListView.builder(
                      itemCount: discoverableUsers.length,
                      itemBuilder: (context, index) {
                        final user = discoverableUsers[index];
                        return _buildDiscoverItem(user, colors);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineFriendItem(User friend, NeumorphicColors colors) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _openUserProfile(friend),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                      friend.displayName.isNotEmpty ? friend.displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              friend.displayName,
              style: TextStyle(
                fontSize: 12,
                color: colors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendItem(Friend friend, NeumorphicColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _openUserProfile(friend.user),
              child: Container(
                width: 50,
                height: 50,
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
                    friend.user.displayName.isNotEmpty ? friend.user.displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => _openUserProfile(friend.user),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.user.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${friend.user.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: friend.user.isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          friend.user.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textColor.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Level ${friend.user.level}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(LucideIcons.moreVertical, color: colors.textColor),
              onSelected: (value) => _handleFriendAction(value, friend),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove Friend'),
                ),
                const PopupMenuItem(
                  value: 'block',
                  child: Text('Block User'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(Friend request, NeumorphicColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
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
                  request.user.displayName.isNotEmpty ? request.user.displayName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.user.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${request.user.username}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${request.user.level} • ${request.user.totalXP} XP',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(LucideIcons.check, color: Colors.green),
                  onPressed: () => _acceptRequest(request),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: Colors.red),
                  onPressed: () => _rejectRequest(request),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverItem(User user, NeumorphicColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Level ${user.level}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${user.totalXP} XP',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: user.isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _sendFriendRequest(user),
              icon: const Icon(LucideIcons.userPlus, size: 16),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, NeumorphicColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: colors.textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: colors.textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openUserProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(user: user),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Users'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by username or display name',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement search functionality
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _handleFriendAction(String action, Friend friend) {
    switch (action) {
      case 'remove':
        _removeFriend(friend);
        break;
      case 'block':
        _blockUser(friend.user);
        break;
    }
  }

  void _acceptRequest(Friend request) async {
    final success = await SocialService.instance.acceptFriendRequest(request.id);
    if (success && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${request.user.displayName} as a friend')),
      );
    }
  }

  void _rejectRequest(Friend request) async {
    final success = await SocialService.instance.rejectFriendRequest(request.id);
    if (success && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejected ${request.user.displayName}\'s friend request')),
      );
    }
  }

  void _sendFriendRequest(User user) async {
    final success = await SocialService.instance.sendFriendRequest(user.id);
    if (success && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${user.displayName}')),
      );
    }
  }

  void _removeFriend(Friend friend) async {
    final success = await SocialService.instance.removeFriend(friend.id);
    if (success && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${friend.user.displayName} from friends')),
      );
    }
  }

  void _blockUser(User user) {
    // Implement block functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Blocked ${user.displayName}')),
    );
  }
}
