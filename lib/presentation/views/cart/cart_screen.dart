import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koopon/presentation/viewmodels/cart_viewmodel.dart';
import 'package:koopon/data/models/cart_model.dart';
import 'package:koopon/data/services/cart_service.dart'; // Add this import
import 'package:koopon/presentation/views/order_request/order_request_screen.dart'; // Add this import
import 'package:koopon/presentation/viewmodels/address_viewmodel.dart';
import 'package:koopon/presentation/viewmodels/order_request_viewmodel.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh cart when screen loads (with user token)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      print('CartScreen: Refreshing cart for user token: ${cartViewModel.userToken}');
      cartViewModel.refreshCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFE8D4F1),
          body: SafeArea(
            child: Column(
              children: [
                // Header with back arrow and cart title
                _buildHeader(cartViewModel),

                // Loading state
                if (cartViewModel.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                  )
                // Error state
                else if (cartViewModel.errorMessage != null)
                  Expanded(
                    child: _buildErrorState(cartViewModel),
                  )
                // No user token
                else if (cartViewModel.userToken == null)
                  Expanded(
                    child: _buildNoTokenState(),
                  )
                // Empty cart
                else if (cartViewModel.cartItems.isEmpty)
                  Expanded(
                    child: _buildEmptyCart(),
                  )
                // Cart Items List (no bottom actions needed)
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: cartViewModel.refreshCart,
                      color: const Color(0xFF9C27B0),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartViewModel.cartItems.length,
                        itemBuilder: (context, index) {
                          return _buildCartItem(cartViewModel.cartItems[index], cartViewModel);
                        },
                      ),
                    ),
                  ),

                // Removed bottom actions section completely
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(CartViewModel cartViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF2D1B35),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.shopping_cart_outlined,
            color: Color(0xFF2D1B35),
            size: 28,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Cart',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B35),
                ),
              ),
              if (cartViewModel.userToken != null && cartViewModel.cartItems.isNotEmpty)
                Text(
                  '${cartViewModel.itemCount} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (cartViewModel.cartItems.isNotEmpty && cartViewModel.userToken != null)
            GestureDetector(
              onTap: () {
                _showClearCartDialog(cartViewModel);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CartViewModel cartViewModel) {
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
            cartViewModel.errorMessage!,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D1B35),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              cartViewModel.refreshCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTokenState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_circle,
              size: 60,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Please Login',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B35),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You need to login to access your cart',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen or show login dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Go Back',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B35),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SIMPLIFIED: _buildCartItem method without quantity controls
  Widget _buildCartItem(CartModel cartItem, CartViewModel cartViewModel) {
    final item = cartItem.item;
    
    // Check if item is sold
    final bool isSold = item.status == 'sold';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Seller info and status
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.sellerName,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSold ? Colors.grey : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSold 
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isSold ? 'SOLD' : item.status,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSold ? Colors.red : const Color(0xFF9C27B0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // SOLD WARNING (if item is sold)
            if (isSold) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This item has been sold and is no longer available for checkout.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Item details row (simplified without quantity controls)
            Opacity(
              opacity: isSold ? 0.6 : 1.0,
              child: Row(
                children: [
                  // Item image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Image
                          item.imageUrl != null && item.imageUrl!.isNotEmpty
                              ? Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: _getItemColor(item.category),
                                      child: Icon(
                                        _getItemIcon(item.category),
                                        size: 40,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: _getItemColor(item.category),
                                  child: Icon(
                                    _getItemIcon(item.category),
                                    size: 40,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                          
                          // SOLD overlay on image
                          if (isSold)
                            Container(
                              width: 80,
                              height: 80,
                              color: Colors.black.withOpacity(0.7),
                              child: const Center(
                                child: Text(
                                  'SOLD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Item information (expanded to fill remaining space)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSold ? Colors.grey : const Color(0xFF2D1B35),
                            decoration: isSold ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'RM ${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSold ? Colors.grey : const Color(0xFFE91E63),
                            decoration: isSold ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Preloved badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Preloved Item',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSold ? Colors.grey : const Color(0xFF9C27B0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons - Individual checkout and remove
            Row(
              children: [
                // Remove button (always enabled)
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      _showRemoveItemDialog(cartItem, cartViewModel);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Individual checkout button (DISABLED if sold)
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: isSold ? null : () {
                      try {
                        print('CartScreen: Individual checkout clicked for ${item.name}, User token: ${cartViewModel.userToken}');
                        
                        // Convert single cart item to CartItem list for order
                        final cartItemForOrder = CartService.convertToCartItem(cartItem);
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider(create: (_) => OrderRequestViewModel()),
                                ChangeNotifierProvider(create: (_) => AddressViewModel()),
                              ],
                              child: OrderRequestScreen(cartItems: [cartItemForOrder]),
                            ),
                          ),
                        );
                      } catch (e) {
                        print('Error navigating to checkout: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSold 
                            ? Colors.grey[300] 
                            : const Color(0xFF9C27B0),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSold ? Icons.block : Icons.shopping_bag_outlined,
                              color: isSold ? Colors.grey[600] : Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isSold 
                                  ? 'Item Sold'
                                  : 'Checkout - RM ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isSold ? Colors.grey[600] : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveItemDialog(CartModel cartItem, CartViewModel cartViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Remove Item'),
        content: Text('Are you sure you want to remove "${cartItem.item.name}" from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              print('CartScreen: Removing item for user token: ${cartViewModel.userToken}');
              final success = await cartViewModel.removeFromCart(cartItem.id!);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${cartItem.item.name} removed from cart'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(cartViewModel.errorMessage ?? 'Failed to remove item'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(CartViewModel cartViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Clear Cart'),
        content: Text('Are you sure you want to remove all ${cartViewModel.itemCount} items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              print('CartScreen: Clearing cart for user token: ${cartViewModel.userToken}');
              final success = await cartViewModel.clearCart();
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(cartViewModel.errorMessage ?? 'Failed to clear cart'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for item icons and colors
  IconData _getItemIcon(String category) {
    switch (category.toLowerCase()) {
      case 'clothes':
        return Icons.checkroom;
      case 'electronics':
        return Icons.devices;
      case 'book':
        return Icons.menu_book;
      case 'shoes':
        return Icons.directions_walk;
      case 'cosmetics':
        return Icons.face;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getItemColor(String category) {
    switch (category.toLowerCase()) {
      case 'clothes':
        return const Color(0xFFDEB887);
      case 'electronics':
        return const Color(0xFF4682B4);
      case 'book':
        return const Color(0xFF32CD32);
      case 'shoes':
        return const Color(0xFF2F4F4F);
      case 'cosmetics':
        return const Color(0xFFF5F5DC);
      default:
        return const Color(0xFF9C27B0);
    }
  }
}