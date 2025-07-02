// lib/presentation/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koopon/presentation/views/add_item_screen.dart';
import 'package:koopon/presentation/views/edit_item_screen.dart';
import 'package:koopon/presentation/views/profile/edit_profile_screen.dart';
import 'package:koopon/presentation/viewmodels/profile_viewmodel.dart';
import 'package:koopon/data/models/item_model.dart';
import 'order_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/presentation/views/cart/cart_screen.dart';
import 'package:koopon/presentation/views/order_request/purchase_history_screen.dart';
import 'package:koopon/presentation/viewmodels/cart_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedNavIndex = 4; // Profile tab selected

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          // Initialize the view model when the Consumer is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!viewModel.isInitialized) {
              viewModel.initialize();
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFE8D4F1), // Same as home screen
            body: SafeArea(
              child: Column(
                children: [
                  // Header Section (Fixed at top)
                  _buildHeader(viewModel),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Profile Info Section
                          _buildProfileInfo(viewModel),

                          // My Products Section Header
                          _buildMyProductsHeader(viewModel),

                          // User's Products Grid (with fixed height)
                          _buildUserProductsGrid(viewModel),

                          // Extra padding at bottom for better UX
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Navigation (Fixed at bottom)
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

          // Refresh Icon instead of Settings
          Container(
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              onTap: () {
                viewModel.refreshProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile refreshed!')),
                );
              },
              child: const Icon(
                Icons.refresh,
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

          const SizedBox(height: 20),

          // ENHANCED: Real-time Stats Row with Seller Statistics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Products',
                viewModel.userItems.length.toString(),
                Icons.inventory,
                onTap: () {
                  // Could navigate to products management
                },
              ),
              _buildStatItem(
                'Sold',
                viewModel.totalSoldItems
                    .toString(), // UPDATED: Real-time sold count
                Icons.sell,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderHistoryScreen(),
                    ),
                  );
                  // Refresh when returning from order history
                  viewModel.refreshProfile();
                },
              ),
              _buildStatItem(
                'Revenue',
                'RM${viewModel.totalRevenue.toStringAsFixed(0)}', // UPDATED: Real revenue
                Icons.attach_money,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderHistoryScreen(),
                    ),
                  );
                  // Refresh when returning from order history
                  viewModel.refreshProfile();
                },
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

  Widget _buildStatItem(String label, String value, IconData icon,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: onTap != null
              ? const Color(0xFF9C27B0).withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Column(
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
            if (onTap != null) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.touch_app,
                size: 12,
                color: Colors.grey[400],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyProductsHeader(ProfileViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'My Products',
            style: TextStyle(
              color: Color(0xFF2D1B35),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Order History button
          TextButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderHistoryScreen(),
                ),
              );
              // Refresh profile when returning from order history
              viewModel.refreshProfile();
            },
            icon: const Icon(
              Icons.history,
              color: Color(0xFF9C27B0),
              size: 18,
            ),
            label: const Text(
              'Order History',
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
    if (viewModel.isLoading) {
      return Container(
        height: 200,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF9C27B0),
          ),
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Container(
        height: 200,
        child: Center(
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
                  viewModel.refreshUserItems();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                ),
                child:
                    const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.userItems.isEmpty) {
      return Container(
        height: 200,
        child: Center(
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
        ),
      );
    }

    // Calculate grid height based on number of items
    final int itemCount = viewModel.userItems.length;
    final int rows = (itemCount / 2).ceil();
    final double gridHeight = rows * 240.0; // Approximate height per row

    return Container(
      height: gridHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // Disable grid scroll
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: viewModel.userItems.length,
        itemBuilder: (context, index) {
          final item = viewModel.userItems[index];
          return _buildProductCard(item, viewModel);
        },
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
          // Item Image - Fixed Container with proper constraints
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    // Image Container with fixed dimensions
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(
                              item.imageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              headers: const {
                                'Cache-Control': 'no-cache',
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey[100],
                                  child: Center(
                                    child: CircularProgressIndicator(
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
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                    ),

                    // Status badge with proper positioning
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 80, // Prevent badge overflow
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusBadgeColor(item.status),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getStatusDisplayText(item.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Item Details - Fixed height container
          Container(
            height: 120, // Fixed height to prevent overflow
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Product Info Section
                Expanded(
                  child: Column(
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RM ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: item.status == 'sold'
                              ? Colors.grey
                              : const Color(0xFFE91E63),
                          decoration: item.status == 'sold'
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons section with fixed height
                Container(
                  height: 30, // Fixed height for buttons
                  child: item.status != 'sold'
                      ? Row(
                          children: [
                            // Edit Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditItemPage(item: item),
                                    ),
                                  );

                                  if (result == true) {
                                    viewModel.refreshUserItems();
                                  }
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9C27B0)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 12,
                                        color: Color(0xFF9C27B0),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF9C27B0),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            // Delete Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _showDeleteDialog(item, viewModel);
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 12,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontSize: 9,
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
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: Colors.green,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'SOLD',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ENHANCED: Helper method to get status badge color
  Color _getStatusBadgeColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'sold':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'unavailable':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // ENHANCED: Helper method to get status display text
  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'AVAILABLE';
      case 'sold':
        return 'SOLD';
      case 'pending':
        return 'PENDING';
      case 'unavailable':
        return 'UNAVAILABLE';
      default:
        return status.toUpperCase();
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
            if (item.status == 'sold')
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This item has been sold. Deleting it may affect order records.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
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
                    content: Text(
                        viewModel.errorMessage ?? 'Failed to delete product'),
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
          _buildNavItem(Icons.shopping_cart, 'Cart', 1), // Changed from bookmark to cart
          _buildSellButton(),
          _buildNavItem(Icons.receipt_long, 'History', 3), // Changed from notifications to receipt/history
          _buildNavItem(Icons.person, 'Profile', 4), // Selected profile
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
            // Home - Navigate back to home screen
            Navigator.of(context).pop();
            break;
          case 1:
            // Cart - Navigate to CartScreen
            if (FirebaseAuth.instance.currentUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              ).then((value) {
                // Reset navigation selection when returning from cart
                setState(() {
                  _selectedNavIndex = 4; // Keep profile selected
                });
              });
            } else {
              // Show login message for unauthenticated users
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please login to access your cart'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              // Reset selection to profile
              setState(() {
                _selectedNavIndex = 4;
              });
            }
            break;
          case 3:
            // Purchase History - Navigate to PurchaseHistoryScreen
            if (FirebaseAuth.instance.currentUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PurchaseHistoryScreen(),
                ),
              ).then((value) {
                // Reset navigation selection when returning from history
                setState(() {
                  _selectedNavIndex = 4; // Keep profile selected
                });
              });
            } else {
              // Show login message for unauthenticated users
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please login to view your purchase history'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              // Reset selection to profile
              setState(() {
                _selectedNavIndex = 4;
              });
            }
            break;
          case 4:
            // Profile - Already on profile screen, do nothing
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
            // Add cart badge for cart navigation item
            index == 1 ? // Cart navigation item
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Consumer<CartViewModel>(
                      builder: (context, cartViewModel, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              icon,
                              color: isSelected ? const Color(0xFF9C27B0) : Colors.grey[400],
                              size: 24,
                            ),
                            // Cart count badge (only show if items > 0 and user has token)
                            if (cartViewModel.itemCount > 0 && cartViewModel.userToken != null)
                              Positioned(
                                right: -8,
                                top: -8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE91E63),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white, width: 1),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${cartViewModel.itemCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Show cart icon without badge if user has no token
                    return Icon(
                      icon,
                      color: isSelected ? const Color(0xFF9C27B0) : Colors.grey[400],
                      size: 24,
                    );
                  }
                },
              )
            : // Regular navigation items
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

        // Refresh profile data when returning from add item page if needed
        if (result == true) {
          // You can add refresh logic here if needed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
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