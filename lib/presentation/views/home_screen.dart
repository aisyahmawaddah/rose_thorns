import 'package:flutter/material.dart';
import 'package:koopon/presentation/views/order_request/purchase_history_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/presentation/views/add_item_screen.dart';
import 'package:koopon/presentation/views/edit_item_screen.dart';
import 'package:koopon/presentation/views/product_detail_screen.dart';
import 'package:koopon/presentation/views/cart/cart_screen.dart';
import 'package:koopon/presentation/viewmodels/home_viewmodel.dart';
import 'package:koopon/presentation/viewmodels/cart_viewmodel.dart'; // Updated import
import 'package:koopon/data/models/item_model.dart';
import 'package:koopon/presentation/views/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize cart viewmodel's auth listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      cartViewModel.listenToAuthChanges();
      
      // Initialize cart if user is already authenticated
      if (FirebaseAuth.instance.currentUser != null && !cartViewModel.isInitialized) {
        cartViewModel.initializeCart();
        print('HomeScreen: Initializing cart for user token: ${cartViewModel.userToken}');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Add logout method
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
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

        // Sign out from Firebase
        // Note: We don't reset the cart here to allow cart persistence
        // The cart will be automatically handled by the CartViewModel's auth listener
        await FirebaseAuth.instance.signOut();

        // Hide loading indicator
        if (mounted) {
          Navigator.of(context).pop();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Hide loading indicator
        if (mounted) {
          Navigator.of(context).pop();
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use existing providers from main.dart - no new provider scope needed
    return Consumer<HomeViewModel>(
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
                  _buildHeader(viewModel),

                  // Search Section (conditionally visible)
                  if (_isSearchVisible) _buildSearchSection(viewModel),

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
        }
      );
  }

  Widget _buildHeader(HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Search Icon
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  viewModel.fetchAllItems(); // Reset to show all items
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                _isSearchVisible ? Icons.close : Icons.search,
                color: const Color(0xFF2D1B35),
                size: 24,
              ),
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

          // Cart Icon with Badge (only show if user has token)
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Consumer<CartViewModel>(
                  builder: (context, cartViewModel, child) {
                    print('HomeScreen: Cart badge - User token: ${cartViewModel.userToken}, Items: ${cartViewModel.itemCount}');
                    
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              color: Color(0xFF2D1B35),
                              size: 24,
                            ),
                            // Cart count badge (only show if items > 0 and user has token)
                            if (cartViewModel.itemCount > 0 && cartViewModel.userToken != null)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
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
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Show cart icon without badge if user has no token
                return GestureDetector(
                  onTap: () {
                    // Show login message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to access cart'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 8),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xFF2D1B35),
                      size: 24,
                    ),
                  ),
                );
              }
            },
          ),

          // Logout Icon (replaced profile avatar)
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                // User is logged in, show logout icon
                return GestureDetector(
                  onTap: _handleLogout,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2D1B35), width: 2),
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Color(0xFF2D1B35),
                      size: 20,
                    ),
                  ),
                );
              } else {
                // User is not logged in, show profile icon (inactive)
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to access your profile'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 2),
                      color: Colors.grey[100],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products or users...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9C27B0)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    viewModel.fetchAllItems();
                  },
                  icon: const Icon(Icons.clear, color: Color(0xFF9C27B0)),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {}); // Update UI to show/hide clear button
          // Implement search functionality
          if (value.isNotEmpty) {
            viewModel.searchItems(value);
          } else {
            viewModel.fetchAllItems();
          }
        },
      ),
    );
  }

  // UPDATED: _buildActionButtons method for HomeScreen
// Replace your existing _buildActionButtons method with this updated version

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

        // UPDATED: Purchase History Button
        Expanded(
          child: Container(
            height: 60,
            margin: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: () {
                // Check if user is authenticated
                if (FirebaseAuth.instance.currentUser != null) {
                  // Navigate to Order History Screen (you'll rename this to PurchaseHistoryScreen)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PurchaseHistoryScreen(), // You'll rename this to PurchaseHistoryScreen
                    ),
                  );
                } else {
                  // Show login prompt for unauthenticated users
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login to view your purchase history'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
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
                      Icons.receipt_long, // Changed icon from history to receipt
                      color: Color(0xFF9C27B0),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'View Purchase\nHistory', // UPDATED: Changed text
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
      'name': 'Book',
      'icon': Icons.menu_book,
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

  // ENHANCED: _buildItemCard method for HomeScreen
// Replace your existing _buildItemCard method with this enhanced version

Widget _buildItemCard(ItemModel item, HomeViewModel viewModel) {
  // Check if item is sold
  final bool isSold = item.status == 'sold';
  
  return GestureDetector(
    onTap: () {
      // Navigate to product detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(item: item),
        ),
      );
    },
    child: Container(
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
                    // Image with sold overlay
                    ColorFiltered(
                      colorFilter: isSold 
                          ? ColorFilter.mode(
                              Colors.grey.withOpacity(0.6),
                              BlendMode.srcATop,
                            )
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            ),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              headers: const {
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
                    ),
                    
                    // SOLD Overlay (prominent display)
                    if (isSold)
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'SOLD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Status badge (top left)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSold ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isSold ? 'SOLD' : item.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Cart icon (only show if user has token, not their own item, and item not sold)
                    if (!viewModel.isCurrentUserSeller(item.sellerId) && !isSold)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: StreamBuilder<User?>(
                          stream: FirebaseAuth.instance.authStateChanges(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              // User has token, show cart functionality
                              return Consumer<CartViewModel>(
                                builder: (context, cartViewModel, child) {
                                  final isInCart = cartViewModel.isItemInCart(item.id!);
                                  
                                  return GestureDetector(
                                    onTap: () async {
                                      print('HomeScreen: Add to cart clicked for item: ${item.name}, User token: ${cartViewModel.userToken}');
                                      
                                      if (isInCart) {
                                        // Navigate to cart if item already in cart
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const CartScreen(),
                                          ),
                                        );
                                      } else {
                                        // Add to cart (with user token)
                                        final success = await cartViewModel.addToCart(item);
                                        
                                        if (success && mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${item.name} added to cart'),
                                              backgroundColor: Colors.green,
                                              duration: const Duration(seconds: 2),
                                              action: SnackBarAction(
                                                label: 'View Cart',
                                                textColor: Colors.white,
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => const CartScreen(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        } else if (!success && mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(cartViewModel.errorMessage ?? 'Failed to add to cart'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isInCart 
                                            ? const Color(0xFF4CAF50).withOpacity(0.9)
                                            : Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isInCart 
                                            ? Icons.check_circle
                                            : Icons.shopping_cart_outlined,
                                        color: isInCart 
                                            ? Colors.white
                                            : const Color(0xFF9C27B0),
                                        size: 16,
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              // User has no token, show login prompt
                              return GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please login to add items to cart'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Color(0xFF9C27B0),
                                    size: 16,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                    // Show "SOLD" indicator for sold items
                    else if (!viewModel.isCurrentUserSeller(item.sellerId) && isSold)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.block,
                            color: Colors.white,
                            size: 16,
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: isSold ? Colors.grey : const Color(0xFF2D1B35),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isSold ? 'SOLD' : item.status,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSold ? Colors.red : Colors.grey[600],
                          fontWeight: isSold ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RM ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isSold ? Colors.grey : const Color(0xFFE91E63),
                          decoration: isSold ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),

                  // Seller info and action buttons
                  Row(
                    children: [
                      // Seller profile picture and info
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFFE8D4F1),
                                      child: const Icon(
                                        Icons.person,
                                        size: 10,
                                        color: Color(0xFF9C27B0),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.sellerName,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSold ? Colors.grey : Colors.grey[600],
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
                            // Only show edit/delete for non-sold items
                            if (!isSold) ...[
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
                            ]
                            // Show sold indicator for seller's sold items
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'SOLD',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        )
                      else
                        // Show item status for other users' items
                        StreamBuilder<User?>(
                          stream: FirebaseAuth.instance.authStateChanges(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              if (isSold) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'SOLD',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              } else {
                                return Consumer<CartViewModel>(
                                  builder: (context, cartViewModel, child) {
                                    final isInCart = cartViewModel.isItemInCart(item.id!);
                                    
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isInCart 
                                            ? Colors.blue.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isInCart ? 'In Cart' : 'Available',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: isInCart ? Colors.blue : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            } else {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSold 
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isSold ? 'SOLD' : 'Available',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: isSold ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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