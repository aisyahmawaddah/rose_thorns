import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koopon/presentation/views/add_item_screen.dart';
import 'package:koopon/presentation/views/edit_item_screen.dart';
import 'package:koopon/presentation/viewmodels/home_viewmodel.dart';
import 'package:koopon/data/models/item_model.dart';
import 'package:koopon/presentation/views/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          // Initialize the view model when the Consumer is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!viewModel.isInitialized) {
              viewModel.initialize();
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFE8D4F1), // Light purple background
            body: SafeArea(
              child: Column(
                children: [
                  // Header Section
                  _buildHeader(),

                  // Action Buttons Section
                  _buildActionButtons(viewModel),

                  // Category Section
                  _buildCategorySection(viewModel),

                  // Items Grid
                  Expanded(
                    child: _buildItemsGrid(viewModel),
                  ),

                  // Bottom Navigation
                  _buildBottomNavigation(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Menu Icon
          Container(
            padding: const EdgeInsets.all(4),
            child: const Icon(
              Icons.menu,
              color: Color(0xFF2D1B35),
              size: 24,
            ),
          ),

          const Spacer(),

          // Title
          const Text(
            'Graduate Marketplace',
            style: TextStyle(
              color: Color(0xFF2D1B35),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Profile Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1494790108755-2616b612b550?w=100&h=100&fit=crop&crop=face',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Add Item Button
          Expanded(
            child: Container(
              height: 60,
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddItemPage()),
                  );

                  // Refresh items when returning from add item page
                  if (result == true) {
                    viewModel.refreshItems();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63), // Pink color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFFE91E63),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Click here\nto add item',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Order History Button
          Expanded(
            child: Container(
              height: 60,
              margin: const EdgeInsets.only(left: 8),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Order history functionality coming soon')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0), // Purple color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history,
                        color: Color(0xFF9C27B0),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'View Order\nHistory',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(HomeViewModel viewModel) {
  final categories = [
    {
      'name': 'Clothes',
      'icon': Icons.checkroom,
      'color': const Color(0xFF9C27B0)
    },
    {
      'name': 'Cosmetics',
      'icon': Icons.face,
      'color': const Color(0xFF9C27B0)
    },
    {
      'name': 'Shoes',
      'icon': Icons.directions_walk,
      'color': const Color(0xFF9C27B0)
    },
    {
      'name': 'Electronics',
      'icon': Icons.devices,
      'color': const Color(0xFF9C27B0)
    },
    {
      'name': 'Book', // Changed from 'Food' to 'Book'
      'icon': Icons.menu_book, // Changed from Icons.restaurant to Icons.menu_book
      'color': const Color(0xFF9C27B0)
    },
  ];

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Category',
              style: TextStyle(
                color: Color(0xFF2D1B35),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (viewModel.selectedCategory.isNotEmpty)
              TextButton(
                onPressed: () {
                  viewModel.fetchAllItems();
                },
                child: const Text(
                  'Show All',
                  style: TextStyle(
                    color: Color(0xFF9C27B0),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: categories.map((category) {
            final isSelected = viewModel.selectedCategory == category['name'];
            return GestureDetector(
              onTap: () {
                viewModel.fetchItemsByCategory(category['name'] as String);
              },
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6A1B9A)
                          : category['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? const Color(0xFF6A1B9A)
                          : const Color(0xFF2D1B35),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

  Widget _buildItemsGrid(HomeViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF9C27B0),
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFF9C27B0),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2D1B35),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                viewModel.refreshItems();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (viewModel.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Color(0xFF9C27B0),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.selectedCategory.isEmpty
                  ? 'No items available\nStart by adding your first item!'
                  : 'No items found in ${viewModel.selectedCategory}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2D1B35),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemPage()),
                );

                if (result == true) {
                  viewModel.refreshItems();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
              ),
              child:
                  const Text('Add Item', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshItems,
      color: const Color(0xFF9C27B0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: viewModel.items.length,
          itemBuilder: (context, index) {
            final item = viewModel.items[index];
            return _buildItemCard(item, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildItemCard(ItemModel item, HomeViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            headers: {
                              'Cache-Control': 'no-cache', // Force fresh load
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: const Color(0xFF9C27B0),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                          fontSize: 8, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ Error loading image: $error');
                              print('🔗 Image URL: ${item.imageUrl}');
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Image failed to load',
                                      style: TextStyle(
                                          fontSize: 8, color: Colors.grey[600]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No image',
                                  style: TextStyle(
                                      fontSize: 8, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                    // Status badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Item Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Color(0xFF2D1B35),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.status,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RM ${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ),

                  // Seller info and action buttons
                  Row(
                    children: [
                      // Seller info
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8D4F1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 10,
                                color: Color(0xFF9C27B0),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.sellerName,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action buttons (only show for current user's items)
                      if (viewModel.isCurrentUserSeller(item.sellerId))
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                // Navigate to edit item screen
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditItemPage(item: item),
                                  ),
                                );

                                // Refresh items if edit was successful
                                if (result == true) {
                                  viewModel.refreshItems();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Color(0xFF9C27B0),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showDeleteDialog(item, viewModel);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.delete,
                                  size: 14,
                                  color: Color(0xFF9C27B0),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        // Show a small indicator that this is someone else's item
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ItemModel item, HomeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${item.name}"?'),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF9C27B0),
                  ),
                ),
              );

              final success = await viewModel.deleteItem(item.id!);

              // Hide loading indicator
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(viewModel.errorMessage ?? 'Failed to delete item'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.bookmark_border, 'Wishlist', 1),
          _buildSellButton(),
          _buildNavItem(Icons.notifications_none, 'Updates', 3),
          _buildNavItem(Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
  final isSelected = _selectedNavIndex == index;
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedNavIndex = index;
      });
      
      // Handle navigation based on index
      switch (index) {
        case 0:
          // Home - already on home screen, do nothing
          break;
        case 1:
          // Wishlist
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wishlist functionality coming soon')),
          );
          break;
        case 3:
          // Updates/Notifications
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Updates functionality coming soon')),
          );
          break;
        case 4:
          // Profile - Navigate to ProfileScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          ).then((value) {
            // Reset navigation selection when returning from profile
            setState(() {
              _selectedNavIndex = 0;
            });
          });
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label selected')),
          );
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF9C27B0) : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? const Color(0xFF9C27B0) : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSellButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddItemPage()),
        );

        // Refresh items when returning from add item page
        if (result == true) {
          Provider.of<HomeViewModel>(context, listen: false).refreshItems();
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF9C27B0),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C27B0).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
