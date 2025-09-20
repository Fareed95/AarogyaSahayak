import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScanHistoryWidget extends StatefulWidget {
  final VoidCallback onClose;

  const ScanHistoryWidget({
    super.key,
    required this.onClose,
  });

  @override
  State<ScanHistoryWidget> createState() => _ScanHistoryWidgetState();
}

class _ScanHistoryWidgetState extends State<ScanHistoryWidget> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Today',
    'This Week',
    'This Month'
  ];

  final List<Map<String, dynamic>> _scanHistory = [
    {
      'id': 1,
      'name': 'Dal Tadka',
      'image':
          'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'calories': 180,
      'healthScore': 0.8,
      'mealType': 'Lunch',
    },
    {
      'id': 2,
      'name': 'Chapati',
      'image':
          'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'calories': 120,
      'healthScore': 0.7,
      'mealType': 'Lunch',
    },
    {
      'id': 3,
      'name': 'Mixed Vegetable Curry',
      'image':
          'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'calories': 150,
      'healthScore': 0.9,
      'mealType': 'Dinner',
    },
    {
      'id': 4,
      'name': 'White Rice',
      'image':
          'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'calories': 200,
      'healthScore': 0.5,
      'mealType': 'Dinner',
    },
    {
      'id': 5,
      'name': 'Samosa',
      'image':
          'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'calories': 250,
      'healthScore': 0.3,
      'mealType': 'Snack',
    },
  ];

  List<Map<String, dynamic>> get _filteredHistory {
    List<Map<String, dynamic>> filtered = _scanHistory;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return (item['name'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply date filter
    if (_selectedFilter != 'All') {
      final now = DateTime.now();
      filtered = filtered.where((item) {
        final itemDate = item['date'] as DateTime;
        switch (_selectedFilter) {
          case 'Today':
            return itemDate.day == now.day &&
                itemDate.month == now.month &&
                itemDate.year == now.year;
          case 'This Week':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return itemDate.isAfter(weekStart);
          case 'This Month':
            return itemDate.month == now.month && itemDate.year == now.year;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onClose,
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Scan History',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _showFilterOptions,
                    icon: CustomIconWidget(
                      iconName: 'filter_list',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Container(
              margin: EdgeInsets.all(4.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search food items...',
                  border: InputBorder.none,
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: Colors.grey[400]!,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            color: Colors.grey[400]!,
                            size: 20,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            // Filter chips
            Container(
              height: 6.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = _filterOptions[index];
                  final isSelected = _selectedFilter == filter;

                  return Container(
                    margin: EdgeInsets.only(right: 2.w),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: AppTheme.lightTheme.colorScheme.secondary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 2.h),

            // History list
            Expanded(
              child: _filteredHistory.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: _filteredHistory.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(_filteredHistory[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food image
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(item['image'] as String),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 4.w),

          // Food details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      '${item['calories']} kcal',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      item['mealType'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatDate(item['date'] as DateTime),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Health score and actions
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getHealthColor(item['healthScore'] as double),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getHealthLabel(item['healthScore'] as double),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _rescanItem(item),
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'refresh',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () => _deleteItem(item),
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'delete_outline',
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: Colors.grey[400]!,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No scan history found',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start scanning food items to see your history here',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: widget.onClose,
            child: Text('Start Scanning'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Date',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ..._filterOptions.map((filter) {
              return ListTile(
                title: Text(filter),
                leading: Radio<String>(
                  value: filter,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _rescanItem(Map<String, dynamic> item) {
    // Navigate back to camera for rescanning
    widget.onClose();
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content:
            Text('Are you sure you want to delete this scan from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _scanHistory.removeWhere(
                    (historyItem) => historyItem['id'] == item['id']);
              });
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getHealthColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getHealthLabel(double score) {
    if (score >= 0.8) return 'Healthy';
    if (score >= 0.6) return 'Moderate';
    return 'Caution';
  }
}
