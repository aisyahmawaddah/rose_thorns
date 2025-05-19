import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: OrderHistoryScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // Sample order data - in a real app, this would come from a database
  final List<Map<String, dynamic>> _orders = [
    {
      'itemName': 'Astrid McStella Sweater',
      'status': 'Lightly used',
      'price': 'RM 10.00',
      'date': '17 Apr, 2024',
      'buyer': 'IzzatiGirL',
      'orderStatus': 'Delivered',
      'icon': Icons.style,
      'iconBgColor': Color(0xFF6B94B3),
    },
    {
      'itemName': 'iPad 9',
      'status': 'Lightly used',
      'price': 'RM 1,250.00',
      'date': '17 Apr, 2024',
      'buyer': 'IzzieMeh',
      'orderStatus': 'Bought',
      'icon': Icons.tablet,
      'iconBgColor': Color(0xFF808080),
    },
  ];

  // Available order statuses for dropdown
  final List<String> _availableStatuses = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Bought',
    'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F6FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFD4E8FF),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF473173)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Order History',
                        style: TextStyle(
                          color: Color(0xFF473173),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF8A56AC),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order, index);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    // Determine the background color based on the order status
    Color bgColor;
    if (order['orderStatus'] == 'Delivered') {
      bgColor = const Color(0xFFF9E7FF);
    } else if (order['orderStatus'] == 'Bought') {
      bgColor = const Color(0xFFD4E8FF);
    } else if (order['orderStatus'] == 'Pending') {
      bgColor = const Color(0xFFFFF9E0);
    } else if (order['orderStatus'] == 'Cancelled') {
      bgColor = const Color(0xFFFFE0E0);
    } else {
      bgColor = const Color(0xFFE0FFE0);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item image or icon
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: order['iconBgColor'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                order['icon'],
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          // Order details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order['itemName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF473173),
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        order['date'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['status'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['price'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF80AB),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Buyer info and order status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0xFFF9E7FF),
                            child: Icon(
                              Icons.person,
                              size: 12,
                              color: Color(0xFF8A56AC),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order['buyer'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order['orderStatus']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _buildStatusDropdown(order, index),
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

  // Create a dropdown to update the order status
  Widget _buildStatusDropdown(Map<String, dynamic> order, int index) {
    return DropdownButton<String>(
      value: order['orderStatus'],
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      underline: Container(),
      isDense: true,
      dropdownColor: _getStatusColor(order['orderStatus']),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _orders[index]['orderStatus'] = newValue;
          });
          // In a real app, you would update this status in your database
          // showUpdateConfirmation(order['itemName'], newValue);
        }
      },
      items: _availableStatuses.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  // Get appropriate color for different order statuses
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF8BC34A);
      case 'Bought':
        return const Color(0xFF8A56AC);
      case 'Pending':
        return const Color(0xFFFF9800);
      case 'Processing':
        return const Color(0xFF2196F3);
      case 'Shipped':
        return const Color(0xFF03A9F4);
      case 'Cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // Show confirmation dialog when updating status
  void showUpdateConfirmation(String itemName, String newStatus) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status for $itemName updated to $newStatus'),
        backgroundColor: const Color(0xFF8A56AC),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}