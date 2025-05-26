// views/order_request/order_summary_screen.dart
import 'package:flutter/material.dart';

class OrderSummaryScreen extends StatelessWidget {
  final Map<String, dynamic>? itemData;
  
  OrderSummaryScreen({this.itemData});

  @override
  Widget build(BuildContext context) {
    // Extract data from itemData or use defaults
    String title = itemData?['title'] ?? 'Zara Trenched Coat';
    String condition = itemData?['condition'] ?? 'Lightly used';
    String price = itemData?['price'] ?? 'RM 30.00';
    String total = itemData?['total'] ?? 'RM 30.00';
    Color imageColor = itemData?['imageColor'] ?? Color(0xFFDEB887);
    String selectedMethod = itemData?['selectedMethod'] ?? 'campus';
    double deliveryFee = itemData?['deliveryFee'] ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Request',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF6B46C1), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Product Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: imageColor,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        _getItemIcon(title),
                        color: Colors.white.withOpacity(0.8),
                        size: 40,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          condition,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Deal Method
            _buildInfoSection(
              title: 'Deal method',
              content: selectedMethod == 'campus' 
                  ? 'In Campus Meetup\nRM 0.00'
                  : 'Delivery\nRM ${deliveryFee.toStringAsFixed(2)}',
              actionText: 'Edit',
              onTap: () {
                // Navigate to deal method screen
              },
            ),

            SizedBox(height: 16),

            // Meetup Location
            _buildInfoSection(
              title: selectedMethod == 'campus' ? 'Meetup Location' : 'Delivery Address',
              content: 'Alicia Amin\n011-19016774\nMAJ, Kolej Tun Dr Ismail\nDepan medan air',
              actionText: 'Edit',
              showLocationTag: true,
              onTap: () {
                // Navigate to address selection screen
              },
            ),

            SizedBox(height: 16),

            // Date and Time
            _buildInfoSection(
              title: 'Date and Time',
              content: 'Monday, 4 May\n12:00 PM',
              actionText: 'Edit',
              onTap: () {
                // Navigate to timeslot selection screen
              },
            ),

            SizedBox(height: 24),

            // Payment Summary
            Text(
              'Payment summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),

            // Summary rows
            _buildSummaryRow('Subtotal (1 item)', price),
            _buildSummaryRow(
              selectedMethod == 'campus' ? 'In Campus Meetup' : 'Delivery Fee', 
              'RM ${deliveryFee.toStringAsFixed(2)}'
            ),
            
            Divider(height: 24, color: Colors.grey[300]),
            
            _buildSummaryRow(
              'Total',
              total,
              isTotal: true,
            ),

            SizedBox(height: 40),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle place order with all item data
                  _showOrderConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDDA0DD),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Place Order',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
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

  Widget _buildInfoSection({
    required String title,
    required String content,
    required String actionText,
    required VoidCallback onTap,
    bool showLocationTag = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  actionText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B46C1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          if (showLocationTag) ...[
            SizedBox(height: 8),
            Text(
              'view location picture',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B46C1),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Placed Successfully!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Your order request has been sent to the seller.',
                textAlign: TextAlign.center,
              ),
              if (itemData != null) ...[
                SizedBox(height: 12),
                Text(
                  'Item: ${itemData!['title']}',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Total: ${itemData!['total']}',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                // Navigate back to cart/home
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Add the _getItemIcon method inside the class
  IconData _getItemIcon(String title) {
    if (title.toLowerCase().contains('coat') || title.toLowerCase().contains('sweater')) {
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

// Add this main function to run this screen directly
void main() {
  runApp(MaterialApp(
    home: OrderSummaryScreen(),
    debugShowCheckedModeBanner: false,
  ));
}