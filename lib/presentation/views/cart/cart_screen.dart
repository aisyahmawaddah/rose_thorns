import 'package:flutter/material.dart';
// Import the deal method screen
import '../order_request/deal_method_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [
    CartItem(
      id: '1',
      seller: 'shopwithmayauki',
      title: 'Zara Trenched Coat',
      condition: 'Lightly used',
      price: 30.00,
      quantity: 1,
      imageColor: const Color(0xFFDEB887),
      isSelected: true,
    ),
    CartItem(
      id: '2',
      seller: 'izzatiafrh',
      title: 'Astrid McStella Sweater',
      condition: 'Never used',
      price: 15.00,
      quantity: 1,
      imageColor: const Color(0xFF4682B4),
      isSelected: true,
    ),
    CartItem(
      id: '3',
      seller: 'izzatiafrh',
      title: 'Iphone 12',
      condition: 'Heavily used',
      price: 1500.00,
      quantity: 1,
      imageColor: const Color(0xFFF5F5DC),
      isSelected: true,
    ),
    CartItem(
      id: '4',
      seller: 'izzatiafrh',
      title: 'Ipad 9',
      condition: 'Heavily used',
      price: 1000.00,
      quantity: 1,
      imageColor: const Color(0xFF2F4F4F),
      isSelected: false,
    ),
    CartItem(
      id: '5',
      seller: 'izzatiafrh',
      title: 'Computational Intelligence Book',
      condition: 'Lightly used',
      price: 10.00,
      quantity: 1,
      imageColor: const Color(0xFF32CD32),
      isSelected: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedItems = cartItems.where((item) => item.isSelected).toList();
    final totalAmount = selectedItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8D4F1), // Changed to match app theme
      body: SafeArea(
        child: Column(
          children: [
            // Header with back arrow and cart title
            _buildHeader(),

            // Cart summary
            if (cartItems.isNotEmpty) _buildCartSummary(selectedItems.length, totalAmount),

            // Cart Items List
            Expanded(
              child: cartItems.isEmpty
                  ? _buildEmptyCart()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(cartItems[index], index);
                      },
                    ),
            ),

            // Bottom action buttons
            if (cartItems.isNotEmpty && selectedItems.isNotEmpty)
              _buildBottomActions(selectedItems, totalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          const Text(
            'My Cart',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B35),
            ),
          ),
          const Spacer(),
          if (cartItems.isNotEmpty)
            GestureDetector(
              onTap: () {
                _showClearCartDialog();
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

  Widget _buildCartSummary(int selectedCount, double totalAmount) {
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
          Icon(
            Icons.receipt_outlined,
            color: const Color(0xFF9C27B0),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$selectedCount items selected',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D1B35),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Total: RM ${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                final allSelected = cartItems.every((item) => item.isSelected);
                for (var item in cartItems) {
                  item.isSelected = !allSelected;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                cartItems.every((item) => item.isSelected) ? 'Deselect All' : 'Select All',
                style: const TextStyle(
                  color: Color(0xFF9C27B0),
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

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: item.isSelected
            ? Border.all(color: const Color(0xFF9C27B0), width: 2)
            : null,
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
            // Selection checkbox and seller info
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      item.isSelected = !item.isSelected;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.isSelected ? const Color(0xFF9C27B0) : Colors.transparent,
                      border: Border.all(
                        color: item.isSelected ? const Color(0xFF9C27B0) : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: item.isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
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
                  item.seller,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Item details row
            Row(
              children: [
                // Item image placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: item.imageColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getItemIcon(item.title),
                      size: 40,
                      color: Colors.white.withOpacity(0.8),
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
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D1B35),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.condition,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'RM ${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
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
                            if (item.quantity > 1) {
                              setState(() {
                                item.quantity--;
                              });
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.remove,
                              size: 16,
                              color: Color(0xFF2D1B35),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D1B35),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              item.quantity++;
                            });
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
                      _showRemoveItemDialog(item, index);
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
                      if (item.isSelected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DealMethodScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select the item first'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: item.isSelected 
                            ? const Color(0xFF9C27B0) 
                            : Colors.grey[400],
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

  Widget _buildBottomActions(List<CartItem> selectedItems, double totalAmount) {
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
                      '${selectedItems.length} items selected',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Total: RM ${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedItems.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DealMethodScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedItems.isNotEmpty
                        ? const Color(0xFF9C27B0)
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
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

  void _showRemoveItemDialog(CartItem item, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Remove Item'),
        content: Text('Are you sure you want to remove "${item.title}" from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                cartItems.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.title} removed from cart'),
                  backgroundColor: Colors.green,
                ),
              );
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

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                cartItems.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                  backgroundColor: Colors.green,
                ),
              );
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

  IconData _getItemIcon(String title) {
    if (title.toLowerCase().contains('coat') ||
        title.toLowerCase().contains('sweater')) {
      return Icons.checkroom;
    } else if (title.toLowerCase().contains('iphone')) {
      return Icons.phone_iphone;
    } else if (title.toLowerCase().contains('ipad')) {
      return Icons.tablet_mac;
    } else if (title.toLowerCase().contains('book')) {
      return Icons.book;
    }
    return Icons.shopping_bag;
  }
}

// Cart Item Model
class CartItem {
  final String id;
  final String seller;
  final String title;
  final String condition;
  final double price;
  int quantity;
  final Color imageColor;
  bool isSelected;

  CartItem({
    required this.id,
    required this.seller,
    required this.title,
    required this.condition,
    required this.price,
    required this.quantity,
    required this.imageColor,
    this.isSelected = true,
  });
}

// Add this to run the screen directly
void main() {
  runApp(const MaterialApp(
    home: CartScreen(),
    debugShowCheckedModeBanner: false,
  ));
}