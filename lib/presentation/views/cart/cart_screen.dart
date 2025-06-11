import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koopon/presentation/viewmodels/cart_viewmodel.dart'; // Updated import
import 'package:koopon/data/models/cart_model.dart';
// Import the deal method screen
import '../order_request/deal_method_screen.dart';

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

                // Cart summary (only show if user has token and items)
                if (cartViewModel.cartItems.isNotEmpty && cartViewModel.userToken != null) 
                  _buildCartSummary(cartViewModel),

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
                // Cart Items List
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

                // Bottom action buttons (only show if user has token and items)
                if (cartViewModel.cartItems.isNotEmpty && cartViewModel.userToken != null)
                  _buildBottomActions(cartViewModel),
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
              if (cartViewModel.userToken != null)
                Text(
                  'User: ${cartViewModel.userToken?.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 10,
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

  Widget _buildCartSummary(CartViewModel cartViewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_outlined,
            color: Color(0xFF9C27B0),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cartViewModel.itemCount} items (${cartViewModel.totalQuantity} total)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D1B35),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Total: RM ${cartViewModel.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Token: ${cartViewModel.userToken?.substring(0, 12)}...',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
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

  Widget _buildCartItem(CartModel cartItem, CartViewModel cartViewModel) {
    final item = cartItem.item;
    
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
            // Seller info and user token verification
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
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9C27B0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // User token info (for debugging/verification)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user,
                    size: 12,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Your Item (Token: ${cartItem.userId.substring(0, 8)}...)',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Item details row
            Row(
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
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
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
                  ),
                ),

                const SizedBox(width: 16),

                // Item information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D1B35),
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
                      Row(
                        children: [
                          Text(
                            'RM ${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                          if (cartItem.quantity > 1) ...[
                            const SizedBox(width: 8),
                            Text(
                              'x${cartItem.quantity}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (cartItem.quantity > 1)
                        Text(
                          'Total: RM ${cartItem.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                    ],
                  ),
                ),

                // Quantity controls
                Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (cartItem.quantity > 1) {
                              print('CartScreen: Decreasing quantity for user token: ${cartViewModel.userToken}');
                              cartViewModel.updateQuantity(
                                cartItem.id!,
                                cartItem.quantity - 1,
                              );
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: cartItem.quantity > 1 
                                  ? Colors.grey[200] 
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: cartItem.quantity > 1 
                                  ? const Color(0xFF2D1B35) 
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D1B35),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            print('CartScreen: Increasing quantity for user token: ${cartViewModel.userToken}');
                            cartViewModel.updateQuantity(
                              cartItem.id!,
                              cartItem.quantity + 1,
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9C27B0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // Remove button
                Expanded(
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
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Checkout button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      print('CartScreen: Checkout clicked for user token: ${cartViewModel.userToken}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DealMethodScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Checkout',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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

  Widget _buildBottomActions(CartViewModel cartViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cartViewModel.itemCount} items (${cartViewModel.totalQuantity} total)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Total: RM ${cartViewModel.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    Text(
                      'Token: ${cartViewModel.userToken?.substring(0, 12)}...',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: cartViewModel.isLoading ? null : () {
                    if (cartViewModel.cartItems.isNotEmpty && cartViewModel.userToken != null) {
                      print('CartScreen: Checkout all clicked for user token: ${cartViewModel.userToken}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DealMethodScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cartViewModel.cartItems.isNotEmpty && !cartViewModel.isLoading
                        ? const Color(0xFF9C27B0)
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: cartViewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Checkout All',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
        content: Text('Are you sure you want to remove all items from your cart?\n\nUser Token: ${cartViewModel.userToken?.substring(0, 12)}...'),
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