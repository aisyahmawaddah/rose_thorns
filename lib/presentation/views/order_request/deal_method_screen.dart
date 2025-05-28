// Updated Deal Method Screen to accept item data
import 'package:flutter/material.dart';
import 'address_selection_screen.dart';

class DealMethodScreen extends StatefulWidget {
  // Accept item data
  final Map<String, dynamic>? itemData;

  // Constructor that accepts optional item data
  const DealMethodScreen({super.key, this.itemData});

  @override
  _DealMethodScreenState createState() => _DealMethodScreenState();
}

class _DealMethodScreenState extends State<DealMethodScreen> {
  String? selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  const Text(
                    'Order Request',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Display item information if available
                    if (widget.itemData != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Item image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: widget.itemData!['imageColor'] ??
                                    Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getItemIcon(widget.itemData!['title'] ?? ''),
                                color: Colors.white.withOpacity(0.8),
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.itemData!['title'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.itemData!['condition'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.itemData!['price'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Deal method section
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deal method',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              // Navigate to deal method selection
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DealMethodSelectionScreen(
                                    itemData: widget.itemData,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Choose deal method',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Row(
                                    children: [
                                      Text(
                                        'Add',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B46C1),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Color(0xFF6B46C1),
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
                  ],
                ),
              ),
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

// Create a separate deal method selection screen
class DealMethodSelectionScreen extends StatefulWidget {
  final Map<String, dynamic>? itemData;

  const DealMethodSelectionScreen({super.key, this.itemData});

  @override
  _DealMethodSelectionScreenState createState() =>
      _DealMethodSelectionScreenState();
}

class _DealMethodSelectionScreenState extends State<DealMethodSelectionScreen> {
  String? selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Deal Method',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // In Campus Meetup Option
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedMethod = 'campus';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedMethod == 'campus'
                          ? const Color(0xFF6B46C1)
                          : Colors.grey[300]!,
                      width: selectedMethod == 'campus' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'In Campus Meetup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'pay by cash when meetup',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'RM0.00',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedMethod == 'campus'
                                    ? const Color(0xFF6B46C1)
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: selectedMethod == 'campus'
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Color(0xFF6B46C1),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Delivery Option
            Container(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedMethod = 'delivery';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedMethod == 'delivery'
                          ? const Color(0xFF6B46C1)
                          : Colors.grey[300]!,
                      width: selectedMethod == 'delivery' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'RM 3.00',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedMethod == 'delivery'
                                    ? const Color(0xFF6B46C1)
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: selectedMethod == 'delivery'
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Color(0xFF6B46C1),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedMethod != null
                    ? () {
                        // Create updated item data with selected method
                        Map<String, dynamic> updatedItemData = {
                          ...?widget.itemData,
                          'selectedMethod': selectedMethod,
                          'deliveryFee':
                              selectedMethod == 'delivery' ? 3.0 : 0.0,
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressSelectionScreen(
                              itemData: updatedItemData,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMethod != null
                      ? const Color(0xFF6B46C1)
                      : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: selectedMethod != null
                        ? Colors.white
                        : Colors.grey[500],
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
}

// Add this main function to run this screen directly
void main() {
  final sampleItem = {
    'title': 'Zara Trenched Coat',
    'condition': 'Lightly used',
    'price': 'RM 30.00',
    'imageColor': const Color(0xFFDEB887),
    'seller': 'shopwithmayauki',
  };

  runApp(MaterialApp(
    home: DealMethodScreen(itemData: sampleItem),
    debugShowCheckedModeBanner: false,
  ));
}
