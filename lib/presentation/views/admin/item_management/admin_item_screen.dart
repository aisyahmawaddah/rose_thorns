// lib/presentation/views/admin/item_management/admin_item_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koopon/presentation/viewmodels/admin_item_viewmodel.dart';
import 'package:koopon/presentation/views/admin/item_management/admin_edit item_screen.dart';
import 'package:koopon/data/models/item_model.dart';

class AdminItemManagementScreen extends StatefulWidget {
  const AdminItemManagementScreen({Key? key}) : super(key: key);

  @override
  _AdminItemManagementScreenState createState() => _AdminItemManagementScreenState();
}

class _AdminItemManagementScreenState extends State<AdminItemManagementScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isSearchVisible = false;
  final List<String> _statusFilters = ['All', 'Available', 'Sold'];
  String _selectedStatusFilter = 'All';
  String _selectedCategoryFilter = 'All'; // Add this to track category selection

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize animations
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
    _searchController.dispose();
    _tabController.dispose();
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
                    _buildTabBar(),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildItemsTab(viewModel),
                              _buildStatisticsTab(viewModel),
                            ],
                          ),
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
            'Item Management',
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
              icon: Icon(
                _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
                color: const Color.fromARGB(255, 185, 144, 242),
              ),
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) {
                    _searchController.clear();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: const Color.fromARGB(255, 185, 144, 242),
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_rounded, size: 18),
                SizedBox(width: 8),
                Text('Items'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_rounded, size: 18),
                SizedBox(width: 8),
                Text('Analytics'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTab(AdminItemViewModel viewModel) {
    return Column(
      children: [
        // Search Section
        if (_isSearchVisible) _buildSearchSection(viewModel),
        
        // Filter Section
        _buildFilterSection(viewModel),
        
        // Items List
        Expanded(
          child: _buildItemsList(viewModel),
        ),
      ],
    );
  }

  Widget _buildSearchSection(AdminItemViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search items, sellers, or categories...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search_rounded, color: Color.fromARGB(255, 185, 144, 242)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    viewModel.searchItems('');
                  },
                  icon: const Icon(Icons.clear_rounded, color: Color.fromARGB(255, 185, 144, 242)),
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (value) {
          setState(() {}); // Update UI to show/hide clear button
          viewModel.searchItems(value);
        },
      ),
    );
  }

  Widget _buildFilterSection(AdminItemViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filter
          _buildFilterTitle('Filter by Category'),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: viewModel.availableCategories.map((category) {
                final isSelected = _selectedCategoryFilter == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildFilterChip(
                    category,
                    isSelected,
                    () {
                      setState(() {
                        _selectedCategoryFilter = category;
                      });
                      
                      // Apply filter logic
                      if (category == 'All') {
                        viewModel.filterByCategory(''); // Empty string shows all
                      } else {
                        viewModel.filterByCategory(category);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status Filter
          _buildFilterTitle('Filter by Status'),
          const SizedBox(height: 12),
          Row(
            children: _statusFilters.map((status) {
              final isSelected = _selectedStatusFilter == status;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildFilterChip(
                  status,
                  isSelected,
                  () {
                    setState(() {
                      _selectedStatusFilter = status;
                    });
                    viewModel.filterByStatus(status);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 185, 144, 242),
                    Color.fromARGB(255, 165, 129, 195),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color.fromARGB(255, 185, 144, 242).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(AdminItemViewModel viewModel) {
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
              'Loading items...',
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

    if (viewModel.items.isEmpty) {
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
                Icons.inventory_2_outlined,
                size: 64,
                color: Color.fromARGB(255, 185, 144, 242),
              ),
              const SizedBox(height: 16),
              Text(
                'No items found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or search terms',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (viewModel.selectedCategory.isNotEmpty || viewModel.searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton(
                    onPressed: () {
                      viewModel.clearFilters();
                      _searchController.clear();
                      setState(() {
                        _selectedStatusFilter = 'All';
                        _selectedCategoryFilter = 'All';
                      });
                    },
                    child: const Text(
                      'Clear all filters',
                      style: TextStyle(
                        color: Color.fromARGB(255, 185, 144, 242),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshItems,
      color: const Color.fromARGB(255, 185, 144, 242),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.items.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            child: _buildItemCard(viewModel.items[index], viewModel),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(ItemModel item, AdminItemViewModel viewModel) {
    final bool isSold = item.status == 'sold';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[200]!,
                        Colors.grey[100]!,
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image_rounded,
                                color: Color.fromARGB(255, 185, 144, 242),
                                size: 32,
                              );
                            },
                          )
                        : const Icon(
                            Icons.image_rounded,
                            color: Color.fromARGB(255, 185, 144, 242),
                            size: 32,
                          ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSold ? Colors.grey : Colors.grey[800],
                          decoration: isSold ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          _buildStatusChip(item.status),
                          const SizedBox(width: 8),
                          _buildCategoryChip(item.category),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'RM ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSold ? Colors.grey : const Color.fromARGB(255, 103, 246, 103),
                          decoration: isSold ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        'Seller: ${item.sellerName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      Text(
                        'Added: ${_formatDate(item.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action Menu
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 185, 144, 242).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Color.fromARGB(255, 185, 144, 242),
                    ),
                    onSelected: (value) {
                      _handleMenuAction(value, item, viewModel);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view_details',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_rounded, size: 18, color: Color.fromARGB(255, 149, 195, 255)),
                            SizedBox(width: 12),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit_item',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18, color: Color.fromARGB(255, 255, 189, 139)),
                            SizedBox(width: 12),
                            Text('Edit Item'),
                          ],
                        ),
                      ),
                      if (!isSold)
                        const PopupMenuItem(
                          value: 'mark_sold',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, size: 18, color: Color.fromARGB(255, 180, 229, 180)),
                              SizedBox(width: 12),
                              Text('Mark as Sold'),
                            ],
                          ),
                        ),
                      if (isSold)
                        const PopupMenuItem(
                          value: 'mark_available',
                          child: Row(
                            children: [
                              Icon(Icons.restore_rounded, size: 18, color: Color.fromARGB(255, 180, 229, 180)),
                              SizedBox(width: 12),
                              Text('Mark as Available'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, size: 18, color: Color.fromARGB(255, 255, 180, 180)),
                            SizedBox(width: 12),
                            Text('Delete Item'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Additional info if item has dynamic fields
            if (item.additionalFields.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 185, 144, 242).withOpacity(0.1),
                        const Color.fromARGB(255, 165, 129, 195).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Details:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...item.additionalFields.entries.map((entry) {
                        return Text(
                          '${entry.key}: ${entry.value}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 185, 144, 242).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 185, 144, 242),
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(AdminItemViewModel viewModel) {
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
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Category Breakdown
            _buildStatisticsCard(
              'Items by Category',
              Icons.category_rounded,
              viewModel.itemsByCategory.entries.map((entry) {
                return StatItem(
                  entry.key,
                  entry.value.toString(),
                  _getCategoryIcon(entry.key),
                  const Color.fromARGB(255, 185, 144, 242),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Seller Statistics
            _buildStatisticsCard(
              'Top Sellers',
              Icons.people_rounded,
              viewModel.sellerStats.entries.take(5).map((entry) {
                return StatItem(
                  'Seller ${entry.key.substring(0, 8)}...',
                  '${entry.value} items',
                  Icons.person_rounded,
                  const Color.fromARGB(255, 149, 195, 255),
                );
              }).toList(),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return const Color.fromARGB(255, 255, 180, 180);
      case 'available':
      case 'brand new':
      case 'lightly used':
        return const Color.fromARGB(255, 180, 229, 180);
      case 'heavily used':
      case 'well used':
        return const Color.fromARGB(255, 255, 189, 139);
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action, ItemModel item, AdminItemViewModel viewModel) {
    switch (action) {
      case 'view_details':
        _showItemDetails(item);
        break;
      case 'edit_item':
        _navigateToEditItem(item, viewModel);
        break;
      case 'mark_sold':
        _confirmStatusChange(item, 'sold', viewModel);
        break;
      case 'mark_available':
        _confirmStatusChange(item, 'available', viewModel);
        break;
      case 'delete':
        _confirmDelete(item, viewModel);
        break;
    }
  }

  void _navigateToEditItem(ItemModel item, AdminItemViewModel viewModel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEditItemScreen(item: item),
      ),
    );

    // Refresh items if edit was successful
    if (result == true) {
      viewModel.refreshItems();
      _showSuccessSnackBar('Item updated successfully');
    }
  }

  void _showItemDetails(ItemModel item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 153, 167, 226),
                Color.fromARGB(255, 165, 129, 195),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Item Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                          Container(
                            width: double.infinity,
                            height: 200,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      size: 50,
                                      color: Color.fromARGB(255, 185, 144, 242),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        
                        _buildDetailRow('Item Name', item.name),
                        _buildDetailRow('Category', item.category),
                        _buildDetailRow('Status', item.status.toUpperCase()),
                        _buildDetailRow('Price', 'RM ${item.price.toStringAsFixed(2)}'),
                        _buildDetailRow('Seller', item.sellerName),
                        _buildDetailRow('Seller ID', item.sellerId),
                        _buildDetailRow('Created', _formatDate(item.createdAt)),
                        
                        if (item.description.isNotEmpty)
                          _buildDetailRow('Description', item.description),
                        
                        if (item.additionalFields.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Additional Details:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...item.additionalFields.entries.map((entry) {
                            return _buildDetailRow(entry.key, entry.value.toString());
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmStatusChange(ItemModel item, String newStatus, AdminItemViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.swap_horiz_rounded,
              color: const Color.fromARGB(255, 185, 144, 242),
            ),
            const SizedBox(width: 12),
            const Text('Update Status'),
          ],
        ),
        content: Text('Mark "${item.name}" as ${newStatus.toUpperCase()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await viewModel.updateItemStatus(item.id!, newStatus);
              
              if (mounted) {
                if (success) {
                  _showSuccessSnackBar('Item status updated successfully');
                } else {
                  _showErrorSnackBar('Failed to update item status');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 185, 144, 242),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ItemModel item, AdminItemViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.delete_rounded,
              color: const Color.fromARGB(255, 255, 180, 180),
            ),
            const SizedBox(width: 12),
            const Text('Delete Item'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${item.name}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 180, 180).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Color.fromARGB(255, 255, 180, 180),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 255, 180, 180),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 185, 144, 242),
                  ),
                ),
              );
              
              final success = await viewModel.deleteItem(item.id!);
              
              // Hide loading
              if (mounted) Navigator.pop(context);
              
              if (mounted) {
                if (success) {
                  _showSuccessSnackBar('Item deleted successfully');
                } else {
                  _showErrorSnackBar('Failed to delete item');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 180, 180),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 180, 229, 180),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 255, 180, 180),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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