import 'package:flutter/material.dart';
// Import the deal method screen
import '../order_request/deal_method_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // Light blue background
      body: SafeArea(
        child: Column(
          children: [
            // Header with back arrow and cart title
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'My Cart',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Cart Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Item 1 - Zara Trenched Coat
                  _buildCartItem(
                    context: context,
                    seller: 'shopwithmayauki',
                    title: 'Zara Trenched Coat',
                    condition: 'Lightly used',
                    price: 'RM 30.00',
                    itemCount: '1 item',
                    total: 'RM 30.00',
                    imageColor: const Color(0xFFDEB887), // Beige color for coat
                  ),

                  // Item 2 - Astrid McStella Sweater
                  _buildCartItem(
                    context: context,
                    seller: 'izzatiafrh',
                    title: 'Astrid McStella Sweater',
                    condition: 'Never used',
                    price: 'RM 15.00',
                    itemCount: '1 item',
                    total: 'RM 15.00',
                    imageColor:
                        const Color(0xFF4682B4), // Blue color for sweater
                  ),

                  // Item 3 - iPhone 12
                  _buildCartItem(
                    context: context,
                    seller: 'izzatiafrh',
                    title: 'Iphone 12',
                    condition: 'Heavily used',
                    price: 'RM 1,500.00',
                    itemCount: '1 item',
                    total: 'RM 1,500.00',
                    imageColor:
                        const Color(0xFFF5F5DC), // Light color for phone
                  ),

                  // Item 4 - iPad 9 (with Remove button)
                  _buildCartItem(
                    context: context,
                    seller: 'izzatiafrh',
                    title: 'Ipad 9',
                    condition: 'Heavily used',
                    price: 'RM 1,000.00',
                    itemCount: '1 item',
                    total: 'RM 1,000.00',
                    imageColor: const Color(0xFF2F4F4F), // Dark color for iPad
                    showRemoveButton: true,
                  ),

                  // Item 5 - AI Book
                  _buildCartItem(
                    context: context,
                    seller: 'izzatiafrh',
                    title: 'Computational Intelligence Book',
                    condition: 'Lightly used',
                    price: 'RM 10.00',
                    itemCount: '1 item',
                    total: 'RM 10.00',
                    imageColor: const Color(0xFF32CD32), // Green color for book
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required BuildContext context,
    required String seller,
    required String title,
    required String condition,
    required String price,
    required String itemCount,
    required String total,
    required Color imageColor,
    bool showRemoveButton = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Seller info with avatar
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
                  seller,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Item details row
            Row(
              children: [
                // Item image placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: imageColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getItemIcon(title),
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
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        condition,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quantity and total row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  itemCount,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  total,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // Remove button (only for iPad)
                if (showRemoveButton) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Handle remove item
                        print('Remove item: $title');
                        // You can add remove functionality here
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: Text(
                            'Remove',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],

                // Checkout button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Deal Method Screen
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
                        color: const Color(0xFF9C27B0), // Purple color
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          'Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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

// Add this to run the screen directly
void main() {
  runApp(const MaterialApp(
    home: CartScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
