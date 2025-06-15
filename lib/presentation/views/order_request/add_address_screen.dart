// lib/presentation/views/add_address_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/address_viewmodel.dart';

class AddAddressScreen extends StatefulWidget {
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _buildingController = TextEditingController();
  final _roomController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _buildingController.dispose();
    _roomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddressViewModel(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Add Address'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Address Title *',
                      hintText: 'e.g., Home, Dorm, Office',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an address title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Address field
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address *',
                      hintText: 'Street address, area, city',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Building field
                  TextFormField(
                    controller: _buildingController,
                    decoration: InputDecoration(
                      labelText: 'Building (Optional)',
                      hintText: 'Building name or number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Room field
                  TextFormField(
                    controller: _roomController,
                    decoration: InputDecoration(
                      labelText: 'Room/Unit (Optional)',
                      hintText: 'Room or unit number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Additional Notes (Optional)',
                      hintText: 'Delivery instructions, landmarks, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  
                  // Default checkbox
                  CheckboxListTile(
                    title: Text('Set as default address'),
                    subtitle: Text('Use this address as your default meetup location'),
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(height: 24),
                  
                  // Error message
                  Consumer<AddressViewModel>(
                    builder: (context, viewModel, _) {
                      if (viewModel.error != null) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(12),
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
                                  viewModel.error!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  
                  // Save button
                  Container(
                    width: double.infinity,
                    child: Consumer<AddressViewModel>(
                      builder: (context, viewModel, _) {
                        return ElevatedButton(
                          onPressed: viewModel.isLoading ? null : () => _saveAddress(context, viewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: viewModel.isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : Text(
                                  'Save Address',
                                  style: TextStyle(fontSize: 16),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveAddress(BuildContext context, AddressViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await viewModel.addAddress(
      title: _titleController.text.trim(),
      address: _addressController.text.trim(),
      building: _buildingController.text.trim().isEmpty 
          ? null 
          : _buildingController.text.trim(),
      room: _roomController.text.trim().isEmpty 
          ? null 
          : _roomController.text.trim(),
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
      isDefault: _isDefault,
    );

    if (success) {
      Navigator.pop(context, true);
    }
  }
}