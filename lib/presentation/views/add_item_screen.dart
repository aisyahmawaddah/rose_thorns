import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koopon/data/services/item_services.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCategory = 'Choose category';
  final String _selectedStatus = 'Lightly used';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Instance of ItemService
  final ItemService _itemService = ItemService();

  // List of categories
  final List<String> _categories = [
    'Choose category',
    'Clothes',
    'Cosmetics',
    'Shoes',
    'Electronics',
    'Food'
  ];

  // Map to store dynamic fields for each category
  final Map<String, List<String>> _categoryFields = {
    'Clothes': ['Brand', 'Size', 'Condition', 'Material', 'Color'],
    'Cosmetics': ['Brand', 'Type', 'Volume', 'Expiry Date'],
    'Shoes': ['Brand', 'Size', 'Condition', 'Color', 'Material'],
    'Electronics': ['Brand', 'Model', 'Condition', 'Age', 'Specifications'],
    'Food': ['Type', 'Expiry Date', 'Dietary Info', 'Weight']
  };

  // Current dynamic fields based on selected category
  List<String> _currentFields = [];

  // Controllers for dynamic fields
  final Map<String, TextEditingController> _dynamicControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize dynamic controllers for all possible fields
    for (var category in _categoryFields.keys) {
      for (var field in _categoryFields[category]!) {
        _dynamicControllers[field] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();

    // Dispose all dynamic controllers
    for (var controller in _dynamicControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Update fields when category changes
  void _updateFieldsForCategory(String category) {
    setState(() {
      _currentFields = _categoryFields[category] ?? [];
    });
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: ${e.toString()}');
    }
  }

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
                        'Add Item',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Dropdown
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.transparent),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    border: InputBorder.none,
                  ),
                  value: _selectedCategory,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF8A56AC)),
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                      if (_selectedCategory != 'Choose category') {
                        _updateFieldsForCategory(_selectedCategory);
                      } else {
                        _currentFields = [];
                      }
                    });
                  },
                  items: _categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFF8A56AC),
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
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          if (_imageFile == null)
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  color: Color(0xFF8A56AC),
                                  size: 40,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Optional',
                                  style: TextStyle(
                                    color: Color(0xFF8A56AC),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            )
                          else
                            ClipOval(
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF8A56AC),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _imageFile == null ? Icons.add : Icons.edit,
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
                    color: const Color(0xFFF9E7FF),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
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
                    color: const Color(0xFFF9E7FF),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: _selectedStatus),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // Dynamic Fields based on Category
                ..._currentFields.map((field) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field,
                        style: const TextStyle(
                          color: Color(0xFF473173),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9E7FF),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: TextField(
                          controller: _dynamicControllers[field],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            border: InputBorder.none,
                            hintText: 'Enter $field',
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),

                // Price Field (RM)
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
                    color: const Color(0xFFF9E7FF),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      border: InputBorder.none,
                      hintText: 'Enter price',
                    ),
                  ),
                ),

                // Save Button
                Center(
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading 
                            ? Colors.grey 
                            : const Color(0xFF8BC34A),
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
                              'Save',
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF8A56AC),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            // Home - Go back to home screen
            Navigator.of(context).pop();
          }
          // Add other navigation logic as needed
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF8A56AC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            label: 'Sell',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Updates',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: 2, // Sell tab is selected
      ),
    );
  }

  // Save item method with Firebase integration
  void _saveItem() async {
    // Validate form
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

    // Validate price
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

    // Image is now optional - no validation needed

    setState(() {
      _isLoading = true;
    });

    try {
      // Collect additional fields
      final additionalFields = <String, dynamic>{};
      for (var field in _currentFields) {
        final controller = _dynamicControllers[field];
        if (controller != null && controller.text.trim().isNotEmpty) {
          additionalFields[field.toLowerCase()] = controller.text.trim();
        }
      }

      // Save item using ItemService
      await _itemService.addItem(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        status: _selectedStatus,
        price: price,
        imageFile: _imageFile,
        additionalFields: additionalFields,
      );

      // Show success and navigate back
      _showSuccessSnackBar('Item saved successfully!');
      
      // Wait a moment for user to see the success message
      await Future.delayed(const Duration(seconds: 1));
      
      // Navigate back to home screen with success result
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      _showErrorSnackBar('Error saving item: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Show error SnackBar
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

  // Show success SnackBar
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