import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koopon/presentation/views/add_item_screen.dart';
import 'package:koopon/presentation/views/edit_item_screen.dart';
import 'package:koopon/presentation/views/profile/edit_profile_screen.dart';
import 'package:koopon/presentation/viewmodels/profile_viewmodel.dart';
import 'package:koopon/data/models/item_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedNavIndex = 4; // Profile tab selected
  late ProfileViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          _viewModel = viewModel;
          
          // Initialize the view model when the Consumer is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!viewModel.isInitialized) {
              print('🔄 Initializing ProfileViewModel...');
              viewModel.initialize();
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFE8D4F1), // Same as home screen
            body: SafeArea(
              child: Column(
                children: [
                  // Header Section
                  _buildHeader(viewModel),
                  
                  // Profile Info Section
                  _buildProfileInfo(viewModel),
                  
                  // My Products Section Header
                  _buildMyProductsHeader(viewModel),
                  
                  // User's Products Grid
                  Expanded(
                    child: _buildUserProductsGrid(viewModel),
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

  Widget _buildHeader(ProfileViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Back/Menu Icon
          Container(
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF2D1B35),
                size: 24,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Title
          const Text(
            'My Profile',
            style: TextStyle(
              color: Color(0xFF2D1B35),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const Spacer(),
          
          // Refresh Icon (Add this to help debug)
          Container(
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              onTap: () {
                print('🔄 Manual refresh triggered');
                viewModel.refreshUserItems();
              },
              child: const Icon(
                Icons.refresh,
                color: Color(0xFF2D1B35),
                size: 24,
              ),
            ),
          ),
          
          // Settings Icon
          Container(
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
              child: const Icon(
                Icons.settings,
                color: Color(0xFF2D1B35),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(ProfileViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF9C27B0), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: viewModel.currentUserPhotoUrl != null
                  ? Image.network(
                      viewModel.currentUserPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE8D4F1),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF9C27B0),
                            size: 50,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFFE8D4F1),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF9C27B0),
                        size: 50,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // User Name
          Text(
            viewModel.currentUserDisplayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B35),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // User Email
          Text(
            viewModel.currentUserEmail,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Debug info (Remove in production)
          Text(
            'User ID: ${viewModel.currentUserId}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Products',
                viewModel.userItems.length.toString(),
                Icons.inventory,
              ),
              _buildStatItem(
                'Active',
                viewModel.userItems.where((item) => item.status != 'Sold').length.toString(),
                Icons.visibility,
              ),
              _buildStatItem(
                'Sold',
                '0', // You can implement this later
                Icons.sell,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
                
                // Refresh profile if edit was successful
                if (result == true) {
                  viewModel.refreshProfile();
                }
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF9C27B0),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1B35),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMyProductsHeader(ProfileViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'My Products (${viewModel.userItems.length})',
            style: const TextStyle(
              color: Color(0xFF2D1B35),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () async {
              print('🚀 Navigating to Add Item screen');
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddItemPage(),
                ),
              );
              
              // Refresh products if new item was added
              if (result == true) {
                print('✅ Item added, refreshing user items');
                viewModel.refreshUserItems();
              }
            },
            icon: const Icon(
              Icons.add,
              color: Color(0xFF9C27B0),
              size: 18,
            ),
            label: const Text(
              'Add New',
              style: TextStyle(
                color: Color(0xFF9C27B0),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProductsGrid(ProfileViewModel viewModel) {
    // Debug prints
    print('🔍 Building products grid:');
    print('   - Is loading: ${viewModel.isLoading}');
    print('   - Error: ${viewModel.errorMessage}');
    print('   - Items count: ${viewModel.userItems.length}');
    print('   - User ID: ${viewModel.currentUserId}');
    
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF9C27B0),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your products...',
              style: TextStyle(
                color: Color(0xFF2D1B35),
                fontSize: 16,
              ),
            ),
          ],
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
                print('🔄 Retry button pressed');
                viewModel.refreshUserItems();
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

    if (viewModel.userItems.isEmpty) {
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
            const Text(
              'No products yet\nStart selling by adding your first product!',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2D1B35),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItemPage(),
                  ),
                );
                
                if (result == true) {
                  viewModel.refreshUserItems();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        print('🔄 Pull to refresh triggered');
        await viewModel.refreshUserItems();
      },
      color: const Color(0xFF9C27B0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(), // Enable pull to refresh
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75, // Make cards slightly taller
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: viewModel.userItems.length,
          itemBuilder: (context, index) {
            final item = viewModel.userItems[index];
            print('📦 Building product card for: ${item.name} (${item.id})');
            return _buildProductCard(item, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(ItemModel item, ProfileViewModel viewModel) {
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            headers: const {
                              'Cache-Control': 'no-cache',
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF9C27B0),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ Image load error for ${item.name}: $error');
                              return Container(
                                color: Colors.grey[200],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
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
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    
                    // Status badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.category,
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
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Edit Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            print('✏️ Editing item: ${item.name} (${item.id})');
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditItemPage(item: item),
                              ),
                            );
                            
                            // Refresh items if edit was successful
                            if (result == true) {
                              print('✅ Item edited, refreshing user items');
                              viewModel.refreshUserItems();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9C27B0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Color(0xFF9C27B0),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9C27B0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Delete Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            print('🗑️ Delete button pressed for: ${item.name}');
                            _showDeleteDialog(item, viewModel);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'brand new':
        return Colors.green;
      case 'lightly used':
        return Colors.blue;
      case 'well used':
        return Colors.orange;
      case 'heavily used':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(ItemModel item, ProfileViewModel viewModel) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Delete Product'),
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
            
            print('🗑️ Delete button pressed for: ${item.name}');
            
            // Show quick loading indicator (shorter duration)
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF9C27B0)),
                    SizedBox(width: 20),
                    Text('Deleting...'),
                  ],
                ),
              ),
            );
            
            // Perform deletion
            final success = await viewModel.deleteItem(item.id!);
            
            // Hide loading indicator
            Navigator.pop(context);
            
            // Show result
            if (success) {
              print('✅ Item deleted successfully');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('${item.name} deleted'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              print('❌ Failed to delete item');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(viewModel.errorMessage ?? 'Failed to delete product'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      _showDeleteDialog(item, viewModel); // Show dialog again
                    },
                  ),
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
          _buildNavItem(Icons.person, 'Profile', 4), // Selected profile
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Navigate to home
          Navigator.of(context).pop();
        } else {
          setState(() {
            _selectedNavIndex = index;
          });
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
          _viewModel.refreshUserItems();
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