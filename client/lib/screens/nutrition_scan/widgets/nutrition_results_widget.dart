import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NutritionResultsWidget extends StatefulWidget {
  final Map<String, dynamic> nutritionData;
  final VoidCallback onAddToDiary;
  final VoidCallback onShare;

  const NutritionResultsWidget({
    super.key,
    required this.nutritionData,
    required this.onAddToDiary,
    required this.onShare,
  });

  @override
  State<NutritionResultsWidget> createState() => _NutritionResultsWidgetState();
}

class _NutritionResultsWidgetState extends State<NutritionResultsWidget> {
  double _portionMultiplier = 1.0;
  String _selectedMealType = 'Breakfast';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  Widget build(BuildContext context) {
    final foodItem = widget.nutritionData;
    
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
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Nutrition Analysis',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onShare,
                    icon: CustomIconWidget(
                      iconName: 'share',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food item card
                    _buildFoodItemCard(foodItem),
                    
                    SizedBox(height: 3.h),
                    
                    // Portion size adjustment
                    _buildPortionAdjustment(),
                    
                    SizedBox(height: 3.h),
                    
                    // Nutrition breakdown
                    _buildNutritionBreakdown(foodItem),
                    
                    SizedBox(height: 3.h),
                    
                    // Health impact
                    _buildHealthImpact(foodItem),
                    
                    SizedBox(height: 3.h),
                    
                    // Alternative suggestions
                    _buildAlternativeSuggestions(),
                    
                    SizedBox(height: 3.h),
                    
                    // Meal type selection
                    _buildMealTypeSelection(),
                    
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemCard(Map<String, dynamic> foodItem) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(foodItem['image'] as String),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem['name'] as String,
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${((foodItem['confidence'] as double) * 100).toInt()}% confidence',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getHealthColor(foodItem['healthScore'] as double),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getHealthLabel(foodItem['healthScore'] as double),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortionAdjustment() {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portion Size',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'remove',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              Expanded(
                child: Slider(
                  value: _portionMultiplier,
                  min: 0.5,
                  max: 3.0,
                  divisions: 10,
                  activeColor: AppTheme.lightTheme.colorScheme.secondary,
                  onChanged: (value) {
                    setState(() {
                      _portionMultiplier = value;
                    });
                  },
                ),
              ),
              CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ],
          ),
          Text(
            '${(_portionMultiplier * 100).toInt()}% of standard portion',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBreakdown(Map<String, dynamic> foodItem) {
    final nutrition = foodItem['nutrition'] as Map<String, dynamic>;
    
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Breakdown',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  'Calories',
                  '${((nutrition['calories'] as double) * _portionMultiplier).toInt()}',
                  'kcal',
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  'Carbs',
                  '${((nutrition['carbs'] as double) * _portionMultiplier).toInt()}',
                  'g',
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  'Protein',
                  '${((nutrition['protein'] as double) * _portionMultiplier).toInt()}',
                  'g',
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  'Fat',
                  '${((nutrition['fat'] as double) * _portionMultiplier).toInt()}',
                  'g',
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  'Fiber',
                  '${((nutrition['fiber'] as double) * _portionMultiplier).toInt()}',
                  'g',
                  Colors.purple,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  'Sodium',
                  '${((nutrition['sodium'] as double) * _portionMultiplier).toInt()}',
                  'mg',
                  Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthImpact(Map<String, dynamic> foodItem) {
    final healthImpacts = foodItem['healthImpacts'] as List<dynamic>;
    
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Impact',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...healthImpacts.map((impact) => _buildHealthImpactItem(impact as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildHealthImpactItem(Map<String, dynamic> impact) {
    final isPositive = impact['isPositive'] as bool;
    
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isPositive 
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isPositive ? 'check_circle' : 'warning',
            color: isPositive ? Colors.green : Colors.orange,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              impact['message'] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeSuggestions() {
    final alternatives = [
      {
        'name': 'Brown Rice',
        'reason': 'Higher fiber, better for diabetes',
        'image': 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg',
      },
      {
        'name': 'Quinoa',
        'reason': 'Complete protein, lower glycemic index',
        'image': 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg',
      },
    ];

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Healthier Alternatives',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...alternatives.map((alt) => _buildAlternativeItem(alt)),
        ],
      ),
    );
  }

  Widget _buildAlternativeItem(Map<String, dynamic> alternative) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(alternative['image'] as String),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alternative['name'] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  alternative['reason'] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelection() {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add to Meal',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            children: _mealTypes.map((mealType) {
              final isSelected = _selectedMealType == mealType;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMealType = mealType;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? AppTheme.lightTheme.colorScheme.secondary
                      : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mealType,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/nutrition-scan'),
              child: Text('Scan Another'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: widget.onAddToDiary,
              child: Text('Add to Food Diary'),
            ),
          ),
        ],
      ),
    );
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