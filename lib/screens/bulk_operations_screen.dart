import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_colors.dart';
import '../widgets/micro_interactions.dart';
import '../services/haptic_service.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class BulkOperationsScreen extends StatefulWidget {
  const BulkOperationsScreen({super.key});

  @override
  State<BulkOperationsScreen> createState() => _BulkOperationsScreenState();
}

class _BulkOperationsScreenState extends State<BulkOperationsScreen> {
  final List<String> _selectedHabits = [];
  final List<Habit> _habits = [];
  
  // Filter options
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _selectedTimeframe = 'All';
  String _sortBy = 'Name';
  bool _sortAscending = true;
  
  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadHabits() {
    setState(() {
      _habits.clear();
      _habits.addAll(HabitService.instance.habits);
    });
  }

  List<Habit> get _filteredHabits {
    List<Habit> filtered = _habits.where((habit) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!habit.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !habit.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      
      // Category filter
      if (_selectedCategory != 'All' && habit.category != _selectedCategory) {
        return false;
      }
      
      // Status filter
      if (_selectedStatus != 'All') {
        bool isCompleted = HabitService.instance.isCompletedToday(habit.id);
        if (_selectedStatus == 'Completed' && !isCompleted) return false;
        if (_selectedStatus == 'Pending' && isCompleted) return false;
      }
      
      // Timeframe filter
      if (_selectedTimeframe != 'All') {
        DateTime now = DateTime.now();
        DateTime habitDate = DateTime.parse(habit.createdAt.toIso8601String());
        
        switch (_selectedTimeframe) {
          case 'Today':
            if (!_isSameDay(habitDate, now)) return false;
            break;
          case 'This Week':
            if (habitDate.isBefore(now.subtract(const Duration(days: 7)))) return false;
            break;
          case 'This Month':
            if (habitDate.month != now.month || habitDate.year != now.year) return false;
            break;
        }
      }
      
      return true;
    }).toList();
    
    // Sort
    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'Name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'Category':
          comparison = a.category.compareTo(b.category);
          break;
        case 'Created Date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'Streak':
          comparison = a.currentStreak.compareTo(b.currentStreak);
          break;
        case 'Priority':
          comparison = a.priority.compareTo(b.priority);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    return filtered;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
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
          'Bulk Operations',
          style: TextStyle(color: colors.textColor),
        ),
        leading: MicroInteractions.animatedIcon(
          icon: LucideIcons.arrowLeft,
          context: context,
          onTap: () => Navigator.pop(context),
          hapticType: HapticType.light,
        ),
        actions: [
          if (_selectedHabits.isNotEmpty)
            MicroInteractions.animatedIcon(
              icon: LucideIcons.x,
              context: context,
              onTap: () {
                setState(() => _selectedHabits.clear());
                HapticService.instance.light();
              },
              hapticType: HapticType.light,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(colors),
          _buildBulkActions(colors),
          Expanded(
            child: _buildHabitsList(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(NeumorphicColors colors) {
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: 'Search habits...',
              prefixIcon: Icon(LucideIcons.search, color: colors.textColor),
              suffixIcon: _searchQuery.isNotEmpty
                  ? MicroInteractions.animatedIcon(
                      icon: LucideIcons.x,
                      context: context,
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        HapticService.instance.light();
                      },
                      hapticType: HapticType.light,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colors.shadowDark.withValues(alpha: 0.1),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Category', _selectedCategory, [
                  'All', 'Health', 'Fitness', 'Learning', 'Work', 'Personal', 'Social'
                ], colors),
                const SizedBox(width: 8),
                _buildFilterChip('Status', _selectedStatus, [
                  'All', 'Completed', 'Pending'
                ], colors),
                const SizedBox(width: 8),
                _buildFilterChip('Timeframe', _selectedTimeframe, [
                  'All', 'Today', 'This Week', 'This Month'
                ], colors),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sort options
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  decoration: InputDecoration(
                    labelText: 'Sort by',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Name', 'Category', 'Created Date', 'Streak', 'Priority']
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _sortBy = value!);
                  },
                ),
              ),
              const SizedBox(width: 16),
              MicroInteractions.animatedButton(
                context: context,
                onPressed: () {
                  setState(() => _sortAscending = !_sortAscending);
                  HapticService.instance.selection();
                },
                hapticType: HapticType.selection,
                child: NeumorphicBox(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    _sortAscending ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                    color: colors.textColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String selected, List<String> options, NeumorphicColors colors) {
    return DropdownButton<String>(
      value: selected,
      underline: Container(),
      style: TextStyle(color: colors.textColor),
      items: options.map((option) => DropdownMenuItem(
        value: option,
        child: Text(option),
      )).toList(),
      onChanged: (value) {
        setState(() {
          switch (label) {
            case 'Category':
              _selectedCategory = value!;
              break;
            case 'Status':
              _selectedStatus = value!;
              break;
            case 'Timeframe':
              _selectedTimeframe = value!;
              break;
          }
        });
        HapticService.instance.selection();
      },
    );
  }

  Widget _buildBulkActions(NeumorphicColors colors) {
    if (_selectedHabits.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return NeumorphicBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '${_selectedHabits.length} habit${_selectedHabits.length == 1 ? '' : 's'} selected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MicroInteractions.animatedButton(
                  context: context,
                  onPressed: () => _bulkComplete(),
                  hapticType: HapticType.success,
                  child: NeumorphicBox(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.check, color: colors.textColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Complete',
                          style: TextStyle(color: colors.textColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MicroInteractions.animatedButton(
                  context: context,
                  onPressed: () => _bulkDelete(),
                  hapticType: HapticType.error,
                  child: NeumorphicBox(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.trash2, color: colors.textColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: colors.textColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MicroInteractions.animatedButton(
                  context: context,
                  onPressed: () => _bulkEdit(),
                  hapticType: HapticType.medium,
                  child: NeumorphicBox(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.edit, color: colors.textColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Edit',
                          style: TextStyle(color: colors.textColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(NeumorphicColors colors) {
    final filteredHabits = _filteredHabits;
    
    if (filteredHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.search,
              size: 64,
              color: colors.textColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No habits found',
              style: TextStyle(
                fontSize: 18,
                color: colors.textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredHabits.length,
      itemBuilder: (context, index) {
        final habit = filteredHabits[index];
        final isSelected = _selectedHabits.contains(habit.id);
        
        return MicroInteractions.animatedListItem(
          index: index,
          child: MicroInteractions.animatedCard(
            context: context,
            onTap: () => _toggleSelection(habit.id),
            hapticType: HapticType.selection,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Selection checkbox
                  MicroInteractions.animatedIcon(
                    icon: isSelected ? LucideIcons.checkSquare : LucideIcons.square,
                    context: context,
                    onTap: () => _toggleSelection(habit.id),
                    hapticType: HapticType.selection,
                    color: isSelected ? Theme.of(context).primaryColor : colors.textColor,
                  ),
                  const SizedBox(width: 16),
                  
                  // Habit icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.target,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Habit details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          habit.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textColor.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                habit.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              LucideIcons.flame,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${habit.currentStreak}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Completion status
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: HabitService.instance.isCompletedToday(habit.id)
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      HabitService.instance.isCompletedToday(habit.id)
                          ? LucideIcons.checkCircle
                          : LucideIcons.circle,
                      color: HabitService.instance.isCompletedToday(habit.id)
                          ? Colors.green
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleSelection(String habitId) {
    setState(() {
      if (_selectedHabits.contains(habitId)) {
        _selectedHabits.remove(habitId);
      } else {
        _selectedHabits.add(habitId);
      }
    });
    HapticService.instance.selection();
  }

  void _bulkComplete() {
    for (String habitId in _selectedHabits) {
      HabitService.instance.markComplete(habitId);
    }
    
    setState(() {
      _selectedHabits.clear();
    });
    
    HapticService.instance.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedHabits.length} habits marked as complete'),
      ),
    );
  }

  void _bulkDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habits'),
        content: Text('Are you sure you want to delete ${_selectedHabits.length} habits? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              for (String habitId in _selectedHabits) {
                HabitService.instance.deleteHabit(habitId);
              }
              
              setState(() {
                _selectedHabits.clear();
                _loadHabits();
              });
              
              HapticService.instance.error();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_selectedHabits.length} habits deleted'),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _bulkEdit() {
    if (_selectedHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select habits to edit'),
        ),
      );
      return;
    }
    
    HapticService.instance.medium();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bulk edit for ${_selectedHabits.length} habits - Feature in development'),
      ),
    );
  }
}
