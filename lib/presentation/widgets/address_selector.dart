// lib/presentation/widgets/address_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/order_request_viewmodel.dart';
import '../viewmodels/address_viewmodel.dart';
import '../../data/models/address_model.dart';
import '../../data/models/order_model.dart';

class AddressSelector extends StatefulWidget {
  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressViewModel>().loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OrderRequestViewModel, AddressViewModel>(
      builder: (context, orderViewModel, addressViewModel, _) {
        if (addressViewModel.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (addressViewModel.error != null) {
          return _buildErrorWidget(addressViewModel.error!);
        }

        // Determine which address is currently selected based on deal method
        Address? currentlySelectedAddress;
        if (orderViewModel.selectedDealMethod == DealMethod.inCampusMeetup) {
          currentlySelectedAddress = orderViewModel.selectedMeetupLocation;
        } else {
          currentlySelectedAddress = orderViewModel.selectedAddress;
        }

        return Column(
          children: [
            // Add new address button
            Container(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAddAddressDialog(context, addressViewModel),
                icon: Icon(Icons.add),
                label: Text('Add New Address'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Address list
            if (addressViewModel.addresses.isEmpty)
              _buildEmptyState()
            else
              Column(
                children: addressViewModel.addresses.map((address) {
                  final isSelected = currentlySelectedAddress?.id == address.id;
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: _buildAddressCard(
                      address: address,
                      isSelected: isSelected,
                      onTap: () => _selectAddress(orderViewModel, address),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  // Handle address selection based on deal method
  void _selectAddress(OrderRequestViewModel orderViewModel, Address address) {
    if (orderViewModel.selectedDealMethod == DealMethod.inCampusMeetup) {
      orderViewModel.setMeetupLocation(address);
    } else {
      orderViewModel.selectAddress(address);
    }
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: () => context.read<AddressViewModel>().loadAddresses(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No addresses yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add an address to continue with your order',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard({
    required Address address,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: isSelected ? Colors.blue : Colors.grey.shade600,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.blue.shade700 : Colors.black,
                        ),
                      ),
                      if (address.isDefault) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (address.notes != null && address.notes!.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      'Note: ${address.notes}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context, AddressViewModel addressViewModel) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    final buildingController = TextEditingController();
    final roomController = TextEditingController();
    final notesController = TextEditingController();
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add New Address'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Address Title *',
                    hintText: 'e.g., Home, Office, Dorm',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Full Address *',
                    hintText: 'Enter complete address',
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: buildingController,
                  decoration: InputDecoration(
                    labelText: 'Building (Optional)',
                    hintText: 'Building name or number',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: roomController,
                  decoration: InputDecoration(
                    labelText: 'Room (Optional)',
                    hintText: 'Room number',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Additional instructions',
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                CheckboxListTile(
                  value: isDefault,
                  onChanged: (value) {
                    setState(() {
                      isDefault = value ?? false;
                    });
                  },
                  title: Text('Set as default address'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final success = await addressViewModel.addAddress(
                  title: titleController.text.trim(),
                  address: addressController.text.trim(),
                  building: buildingController.text.trim().isNotEmpty
                      ? buildingController.text.trim()
                      : null,
                  room: roomController.text.trim().isNotEmpty
                      ? roomController.text.trim()
                      : null,
                  notes: notesController.text.trim().isNotEmpty
                      ? notesController.text.trim()
                      : null,
                  isDefault: isDefault,
                );

                if (success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Address added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(addressViewModel.error ?? 'Failed to add address'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}