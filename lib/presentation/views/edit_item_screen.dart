import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koopon/data/services/item_services.dart';
import 'package:koopon/data/models/item_model.dart';

class EditItemPage extends StatefulWidget {
  final ItemModel item;

  const EditItemPage({Key? key, required this.item}) : super(key: key);

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCategory = 'Choose category';
  String _selectedStatus = 'available'; // Default to available
  File? _newImageFile;
  String? _currentImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final ItemService _itemService = ItemService();

  final List<String> _categories = [
    'Choose category',
    'Clothes',
    'Cosmetics',
    'Shoes',
    'Electronics',
    'Food'
  ];

  // FIXED: Updated status options to match what's actually used in the system
  final List<String> _statusOptions = [
    'available',    // Item is available for sale
    'Brand new',    // Condition: Brand new
    'Lightly used', // Condition: Lightly used
    'Well used',    // Condition: Well used
    'Heavily used', // Condition: Heavily used
  ];

  // Helper method to get display text for status
  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available for Sale';
      case 'brand new':
        return 'Brand New';
      case 'lightly used':
        return 'Lightly Used';
      case 'well used':
        return 'Well Used';
      case 'heavily used':
        return 'Heavily Used';
      case 'sold':
        return 'Sold (Cannot Edit)';
      case 'unavailable':
        return 'Unavailable';
      default:
        return status;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeWithItemData();
  }

  void _initializeWithItemData() {
    _nameController.text = widget.item.name;
    _priceController.text = widget.item.price.toString();
    _selectedCategory = widget.item.category;
    
    // FIXED: Handle status properly - if it's sold/unavailable, don't allow editing
    if (widget.item.status == 'sold' || widget.item.status == 'unavailable') {
      // Show info and prevent editing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showStatusWarning();
      });
      _selectedStatus = widget.item.status;
    } else {
      // For available items or condition statuses, set appropriately
      if (_statusOptions.contains(widget.item.status)) {
        _selectedStatus = widget.item.status;
      } else {
        // Default to available if status is not in our options
        _selectedStatus = 'available';
      }
    }
    
    _currentImageUrl = widget.item.imageUrl;
  }

  void _showStatusWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Item Status Notice'),
        content: Text(
          widget.item.status == 'sold' 
            ? 'This item has been sold and cannot be edited. You can only view the details.'
            : 'This item is currently unavailable and cannot be edited.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('Go Back'),
          ),
          if (widget.item.status == 'unavailable')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedStatus = 'available';
                });
              },
              child: const Text('Make Available'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Don't allow image changes for sold items
    if (widget.item.status == 'sold') {
      _showErrorSnackBar('Cannot edit sold items');
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _newImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if item is sold or unavailable
    final bool isEditable = widget.item.status != 'sold';
    
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
                  Expanded(
                    child: Center(
                      child: Text(
                        isEditable ? 'Edit Item' : 'View Item',
                        style: const TextStyle(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status warning banner for sold/unavailable items
              if (!isEditable) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: widget.item.status == 'sold' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.item.status == 'sold' ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.item.status == 'sold' ? Icons.check_circle : Icons.warning,
                        color: widget.item.status == 'sold' ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.item.status == 'sold' 
                            ? 'This item has been sold and cannot be modified'
                            : 'This item is unavailable and has limited editing options',
                          style: TextStyle(
                            color: widget.item.status == 'sold' ? Colors.green.shade700 : Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Category Dropdown
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: isEditable ? Colors.white : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    border: InputBorder.none,
                  ),
                  value: _selectedCategory,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8A56AC)),
                  isExpanded: true,
                  onChanged: isEditable ? (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  } : null,
                  items: _categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: isEditable ? const Color(0xFF8A56AC) : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              if (_selectedCategory != 'Choose category') ...[
                // Image Upload Section
                Center(
                  child: GestureDetector(
                    onTap: isEditable ? _pickImage : null,
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isEditable ? Colors.white : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_newImageFile != null)
                            ClipOval(
                              child: Image.file(
                                _newImageFile!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                          else if (_currentImageUrl != null)
                            ClipOval(
                              child: Image.network(
                                _currentImageUrl!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.add_photo_alternate,
                                    color: isEditable ? const Color(0xFF8A56AC) : Colors.grey,
                                    size: 40,
                                  );
                                },
                              ),
                            )
                          else
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  color: isEditable ? const Color(0xFF8A56AC) : Colors.grey,
                                  size: 40,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isEditable ? 'Optional' : 'View Only',
                                  style: TextStyle(
                                    color: isEditable ? const Color(0xFF8A56AC) : Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          if (isEditable)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8A56AC),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Item Name Field
                const Text(
                  "Item Name",
                  style: TextStyle(
                    color: Color(0xFF473173),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: isEditable ? const Color(0xFFF9E7FF) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextField(
                    controller: _nameController,
                    enabled: isEditable,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      border: InputBorder.none,
                      hintText: 'Enter item name',
                    ),
                  ),
                ),

                // Status Field
                const Text(
                  "Status",
                  style: TextStyle(
                    color: Color(0xFF473173),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: isEditable ? const Color(0xFFF9E7FF) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      border: InputBorder.none,
                    ),
                    value: _selectedStatus,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8A56AC)),
                    isExpanded: true,
                    onChanged: isEditable ? (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    } : null,
                    items: _statusOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          _getStatusDisplayText(value),
                          style: TextStyle(
                            color: isEditable ? const Color(0xFF8A56AC) : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Price Field
                const Text(
                  "Price (RM)",
                  style: TextStyle(
                    color: Color(0xFF473173),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: isEditable ? const Color(0xFFF9E7FF) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextField(
                    controller: _priceController,
                    enabled: isEditable,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      border: InputBorder.none,
                      hintText: 'Enter price',
                    ),
                  ),
                ),

                // Action Buttons
                Center(
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                    child: isEditable ? ElevatedButton(
                      onPressed: _isLoading ? null : _updateItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading ? Colors.grey : const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Update Item',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ) : ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _updateItem() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter item name');
      return;
    }

    if (_selectedCategory == 'Choose category') {
      _showErrorSnackBar('Please select a category');
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter price');
      return;
    }

    double? price;
    try {
      price = double.parse(_priceController.text.trim());
      if (price <= 0) {
        _showErrorSnackBar('Please enter a valid price');
        return;
      }
    } catch (e) {
      _showErrorSnackBar('Please enter a valid price');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use updateItemWithImage if there's a new image, otherwise use regular update
      if (_newImageFile != null) {
        await _itemService.updateItemWithImage(
          itemId: widget.item.id!,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          status: _selectedStatus,
          price: price,
          newImageFile: _newImageFile,
        );
      } else {
        final updateData = <String, dynamic>{
          'name': _nameController.text.trim(),
          'category': _selectedCategory,
          'status': _selectedStatus,
          'price': price,
        };

        await _itemService.updateItem(widget.item.id!, updateData);
      }

      _showSuccessSnackBar('Item updated successfully!');
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorSnackBar('Error updating item: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}