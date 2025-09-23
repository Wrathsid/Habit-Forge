import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/social.dart';
import '../services/challenge_service.dart';
import '../services/social_service.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          'Challenges',
          style: TextStyle(color: colors.textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.plus, color: colors.textColor),
            onPressed: _createChallenge,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.textColor,
          unselectedLabelColor: colors.textColor.withValues(alpha: 0.5),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'My Challenges'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveChallenges(colors),
          _buildMyChallenges(colors),
          _buildCompletedChallenges(colors),
        ],
      ),
    );
  }

  Widget _buildActiveChallenges(NeumorphicColors colors) {
    final activeChallenges = ChallengeService.instance.getActiveChallenges();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: activeChallenges.isEmpty
            ? _buildEmptyState('No Active Challenges', 'Create or join a challenge to get started!', LucideIcons.target, colors)
            : ListView.builder(
                itemCount: activeChallenges.length,
                itemBuilder: (context, index) {
                  final challenge = activeChallenges[index];
                  return _buildChallengeCard(challenge, colors);
                },
              ),
      ),
    );
  }

  Widget _buildMyChallenges(NeumorphicColors colors) {
    final currentUser = SocialService.instance.currentUser;
    if (currentUser == null) {
      return Center(
        child: Text(
          'Please log in to view your challenges',
          style: TextStyle(color: colors.textColor),
        ),
      );
    }

    final myChallenges = ChallengeService.instance.getUserChallenges(currentUser.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: myChallenges.isEmpty
            ? _buildEmptyState('No Challenges Yet', 'Create your first challenge or join one!', LucideIcons.plus, colors)
            : ListView.builder(
                itemCount: myChallenges.length,
                itemBuilder: (context, index) {
                  final challenge = myChallenges[index];
                  return _buildChallengeCard(challenge, colors);
                },
              ),
      ),
    );
  }

  Widget _buildCompletedChallenges(NeumorphicColors colors) {
    final completedChallenges = ChallengeService.instance.getCompletedChallenges();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: completedChallenges.isEmpty
            ? _buildEmptyState('No Completed Challenges', 'Complete some challenges to see them here!', LucideIcons.trophy, colors)
            : ListView.builder(
                itemCount: completedChallenges.length,
                itemBuilder: (context, index) {
                  final challenge = completedChallenges[index];
                  return _buildChallengeCard(challenge, colors);
                },
              ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, NeumorphicColors colors) {
    final stats = ChallengeService.instance.getChallengeStats(challenge.id);
    final currentUser = SocialService.instance.currentUser;
    final isParticipant = currentUser != null && 
        challenge.participants.any((p) => p.id == currentUser.id);
    final isCreator = currentUser != null && challenge.creator.id == currentUser.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeumorphicBox(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getChallengeTypeColor(challenge.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getChallengeTypeIcon(challenge.type),
                    color: _getChallengeTypeColor(challenge.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textColor,
                        ),
                      ),
                      Text(
                        'by ${challenge.creator.displayName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(challenge.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(challenge.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(challenge.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              challenge.description,
              style: TextStyle(
                fontSize: 14,
                color: colors.textColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),

            // Progress and Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Participants',
                    '${stats['totalParticipants']}',
                    LucideIcons.users,
                    colors,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Completion',
                    '${(stats['completionRate'] * 100).toInt()}%',
                    LucideIcons.target,
                    colors,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Days Left',
                    '${stats['daysRemaining']}',
                    LucideIcons.calendar,
                    colors,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            if (isParticipant) ...[
              LinearProgressIndicator(
                value: stats['completionRate'],
                backgroundColor: colors.textColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 6,
              ),
              const SizedBox(height: 16),
            ],

            // Actions
            Row(
              children: [
                if (!isParticipant && !isCreator)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _joinChallenge(challenge),
                      icon: const Icon(LucideIcons.userPlus, size: 16),
                      label: const Text('Join Challenge'),
                    ),
                  )
                else if (isParticipant && !isCreator)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _leaveChallenge(challenge),
                      icon: const Icon(LucideIcons.userMinus, size: 16),
                      label: const Text('Leave'),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewChallengeDetails(challenge),
                    icon: const Icon(LucideIcons.eye, size: 16),
                    label: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, NeumorphicColors colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.textColor, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: colors.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
            color: colors.textColor.withValues(alpha: 0.3),
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
              color: colors.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getChallengeTypeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.streak:
        return Colors.orange;
      case ChallengeType.completion:
        return Colors.blue;
      case ChallengeType.consistency:
        return Colors.green;
      case ChallengeType.custom:
        return Colors.purple;
    }
  }

  IconData _getChallengeTypeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.streak:
        return LucideIcons.flame;
      case ChallengeType.completion:
        return LucideIcons.checkCircle;
      case ChallengeType.consistency:
        return LucideIcons.target;
      case ChallengeType.custom:
        return LucideIcons.star;
    }
  }

  Color _getStatusColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.active:
        return Colors.green;
      case ChallengeStatus.completed:
        return Colors.blue;
      case ChallengeStatus.expired:
        return Colors.red;
      case ChallengeStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.active:
        return 'Active';
      case ChallengeStatus.completed:
        return 'Completed';
      case ChallengeStatus.expired:
        return 'Expired';
      case ChallengeStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _createChallenge() {
    // Implement challenge creation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Challenge'),
        content: const Text('Challenge creation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _joinChallenge(Challenge challenge) async {
    final success = await ChallengeService.instance.joinChallenge(challenge.id);
    if (success && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${challenge.title}')),
      );
    }
  }

  void _leaveChallenge(Challenge challenge) async {
    final success = await ChallengeService.instance.leaveChallenge(challenge.id);
    if (success && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Left ${challenge.title}')),
      );
    }
  }

  void _viewChallengeDetails(Challenge challenge) {
    // Implement challenge details screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(challenge.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(challenge.description),
            const SizedBox(height: 16),
            Text('Participants: ${challenge.participants.length}'),
            Text('Start Date: ${_formatDate(challenge.startDate)}'),
            Text('End Date: ${_formatDate(challenge.endDate)}'),
            Text('Rewards: ${challenge.rewards}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
