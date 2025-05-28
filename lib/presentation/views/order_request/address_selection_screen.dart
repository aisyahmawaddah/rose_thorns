// views/order_request/address_selection_screen.dart
import 'package:flutter/material.dart';
import 'timeslot_selection_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  final Map<String, dynamic>? itemData;

  const AddressSelectionScreen({super.key, this.itemData});

  @override
  _AddressSelectionScreenState createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  String? selectedAddressId;

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
          'My addresses',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add address button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNewAddressScreen(),
                  ),
                );
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.add,
                    color: Color(0xFF6B46C1),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add address',
                    style: TextStyle(
                      color: Color(0xFF6B46C1),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Address list
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Number of addresses
                itemBuilder: (context, index) {
                  // Sample address data
                  List<Map<String, String>> addresses = [
                    {
                      'id': '1',
                      'name': 'Alicia Amin',
                      'phone': '011-19016774',
                      'address': 'MAJ, Kolej Tun Dr Ismail\nDepan medan air',
                    },
                    {
                      'id': '2',
                      'name': 'Alicia Amin',
                      'phone': '011-19016774',
                      'address': 'MAJ, KTDI\nDepan medan air',
                    },
                    {
                      'id': '3',
                      'name': 'Siti Zubaidah Aminah (SZA)',
                      'phone': '010-359-4323',
                      'address': 'L9, K9\nDepan kedai dessert',
                    },
                  ];

                  final address = addresses[index];
                  final isSelected = selectedAddressId == address['id'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6B46C1)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedAddressId = address['id'];
                        });
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address['name']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address['phone']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  address['address']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'view location picture',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B46C1),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6B46C1)
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Color(0xFF6B46C1),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAddressId != null
                    ? () {
                        // Create updated item data with selected address
                        Map<String, dynamic> updatedItemData = {
                          ...?widget.itemData,
                          'selectedAddressId': selectedAddressId,
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeslotSelectionScreen(
                              itemData: updatedItemData,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAddressId != null
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
                    color: selectedAddressId != null
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

// Add New Address Screen (simplified version for this fix)
class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

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
          'Add new address',
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
            const Text(
              'Add New Address Screen',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// Add this main function to run this screen directly
void main() {
  runApp(MaterialApp(
    home: AddressSelectionScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
