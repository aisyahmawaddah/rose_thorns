// lib/presentation/views/admin/analytics/admin_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koopon/presentation/viewmodels/admin_item_viewmodel.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AdminAnalyticsScreenState createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AdminItemViewModel()..initialize(),
      child: Consumer<AdminItemViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 153, 167, 226), // Pastel blue
                    Color.fromARGB(255, 165, 129, 195), // Pastel purple
                    Color.fromARGB(255, 212, 146, 189), // Pastel pink
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildAnalyticsContent(viewModel),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color.fromARGB(255, 185, 144, 242)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Spacer(),
          const Text(
            'Analytics Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 251, 251, 251),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.analytics_rounded,
                  color: Color.fromARGB(255, 185, 144, 242)),
              onPressed: () {}, // Analytics indicator
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(AdminItemViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading analytics...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color.fromARGB(255, 255, 180, 180),
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: viewModel.refreshItems,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 185, 144, 242),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshItems,
      color: const Color.fromARGB(255, 185, 144, 242),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Statistics
            _buildStatisticsCard(
              'Overall Statistics',
              Icons.assessment_rounded,
              [
                StatItem('Total Items', viewModel.totalItems.toString(), Icons.inventory_2_rounded),
                StatItem('Available Items', viewModel.availableItems.toString(), Icons.check_circle_rounded, const Color.fromARGB(255, 180, 229, 180)),
                StatItem('Sold Items', viewModel.soldItems.toString(), Icons.shopping_bag_rounded, const Color.fromARGB(255, 255, 189, 139)),
                StatItem('Sales Rate', '${_calculateSalesRate(viewModel)}%', Icons.trending_up_rounded, const Color.fromARGB(255, 149, 195, 255)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Category Analytics
            _buildStatisticsCard(
              'Category Analytics',
              Icons.category_rounded,
              viewModel.itemsByCategory.entries.map((entry) {
                final percentage = _calculateCategoryPercentage(entry.value, viewModel.totalItems);
                return StatItem(
                  entry.key,
                  '${entry.value} items ($percentage%)',
                  _getCategoryIcon(entry.key),
                  _getCategoryColor(entry.key),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Seller Analytics
            _buildStatisticsCard(
              'Top Sellers (Most Active)',
              Icons.people_rounded,
              viewModel.sellerStats.entries.take(10).map((entry) {
                return StatItem(
                  'Seller ${entry.key.substring(0, 8)}...',
                  '${entry.value} items',
                  Icons.person_rounded,
                  const Color.fromARGB(255, 149, 195, 255),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Platform Health Metrics
            _buildStatisticsCard(
              'Platform Health',
              Icons.health_and_safety_rounded,
              [
                StatItem('Active Sellers', viewModel.sellerStats.length.toString(), Icons.group_rounded, const Color.fromARGB(255, 180, 229, 180)),
                StatItem('Avg Items/Seller', _calculateAverageItemsPerSeller(viewModel).toString(), Icons.person_add_rounded, const Color.fromARGB(255, 255, 189, 139)),
                StatItem('Platform Activity', _getPlatformActivityStatus(viewModel), Icons.trending_up_rounded, const Color.fromARGB(255, 149, 195, 255)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Recent Activity Summary
            _buildStatisticsCard(
              'Recent Activity Summary',
              Icons.history_rounded,
              [
                StatItem('New Listings Today', _getNewListingsToday(viewModel).toString(), Icons.new_releases_rounded, const Color.fromARGB(255, 180, 229, 180)),
                StatItem('Most Popular Category', _getMostPopularCategory(viewModel), Icons.star_rounded, const Color.fromARGB(255, 255, 189, 139)),
                StatItem('Platform Growth', 'Growing', Icons.trending_up_rounded, const Color.fromARGB(255, 149, 195, 255)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(String title, IconData titleIcon, List<StatItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 185, 144, 242),
                        Color.fromARGB(255, 165, 129, 195),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    titleIcon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        size: 18,
                        color: item.color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item.color.withOpacity(0.2),
                            item.color.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: item.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Helper methods for analytics calculations
  String _calculateSalesRate(AdminItemViewModel viewModel) {
    if (viewModel.totalItems == 0) return '0';
    final rate = (viewModel.soldItems / viewModel.totalItems * 100).round();
    return rate.toString();
  }

  String _calculateCategoryPercentage(int categoryCount, int totalItems) {
    if (totalItems == 0) return '0';
    final percentage = (categoryCount / totalItems * 100).round();
    return percentage.toString();
  }

  int _calculateAverageItemsPerSeller(AdminItemViewModel viewModel) {
    if (viewModel.sellerStats.isEmpty) return 0;
    final totalSellerItems = viewModel.sellerStats.values.reduce((a, b) => a + b);
    return (totalSellerItems / viewModel.sellerStats.length).round();
  }

  String _getPlatformActivityStatus(AdminItemViewModel viewModel) {
    if (viewModel.totalItems > 50) return 'Very Active';
    if (viewModel.totalItems > 20) return 'Active';
    if (viewModel.totalItems > 5) return 'Growing';
    return 'Starting';
  }

  int _getNewListingsToday(AdminItemViewModel viewModel) {
    final today = DateTime.now();
    return viewModel.items.where((item) {
      return item.createdAt.year == today.year &&
             item.createdAt.month == today.month &&
             item.createdAt.day == today.day;
    }).length;
  }

  String _getMostPopularCategory(AdminItemViewModel viewModel) {
    if (viewModel.itemsByCategory.isEmpty) return 'None';
    
    var mostPopular = viewModel.itemsByCategory.entries.reduce((a, b) => 
        a.value > b.value ? a : b);
    return mostPopular.key;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'clothes':
        return const Color.fromARGB(255, 255, 189, 139);
      case 'cosmetics':
        return const Color.fromARGB(255, 255, 180, 180);
      case 'shoes':
        return const Color.fromARGB(255, 149, 195, 255);
      case 'electronics':
        return const Color.fromARGB(255, 180, 229, 180);
      case 'book':
        return const Color.fromARGB(255, 185, 144, 242);
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'clothes':
        return Icons.checkroom_rounded;
      case 'cosmetics':
        return Icons.face_rounded;
      case 'shoes':
        return Icons.directions_walk_rounded;
      case 'electronics':
        return Icons.devices_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

// Helper class for statistics
class StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  StatItem(this.label, this.value, this.icon, [this.color = const Color.fromARGB(255, 185, 144, 242)]);
}