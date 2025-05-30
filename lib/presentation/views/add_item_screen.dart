import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: const AddItemPage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

class AddItemPage extends StatefulWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  String _selectedCategory = 'Choose category';
  final String _selectedStatus = 'Lightly used';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

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
    _descriptionController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _brandController.dispose();

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
  Future<void> _pickImage(dynamic ImageSource) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF473173)),
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
                  items:
                      _categories.map<DropdownMenuItem<String>>((String value) {
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
                    onTap: () => _pickImage(ImageSource),
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
                            const Icon(
                              Icons.add_photo_alternate,
                              color: Color(0xFF8A56AC),
                              size: 40,
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
                              child: const Icon(
                                Icons.add,
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
                  if (field == "Description") return Container();

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
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            border: InputBorder.none,
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
                    ),
                  ),
                ),

                // Save Button
                Center(
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _saveItem();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
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

  // Save item method
  void _saveItem() async {
    // Validate form
    if (_nameController.text.isEmpty) {
      _showErrorSnackBar('Please enter item name');
      return;
    }

    if (_selectedCategory == 'Choose category') {
      _showErrorSnackBar('Please select a category');
      return;
    }

    if (_priceController.text.isEmpty) {
      _showErrorSnackBar('Please enter price');
      return;
    }

    if (_imageFile == null) {
      _showErrorSnackBar('Please add an image');
      return;
    }

    // Here you would upload the image to your database
    // For example with Firebase Storage:
    /*
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('item_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageRef.putFile(_imageFile!);
      final imageUrl = await imageRef.getDownloadURL();
      
      // Create item data
      final itemData = {
        'name': _nameController.text,
        'category': _selectedCategory,
        'status': _selectedStatus,
        'price': double.parse(_priceController.text),
        'imageUrl': imageUrl,
        'createdAt': DateTime.now(),
        // Add other fields based on category
      };
      
      // Add dynamic fields
      for (var field in _currentFields) {
        if (_dynamicControllers[field]?.text.isNotEmpty ?? false) {
          itemData[field.toLowerCase()] = _dynamicControllers[field]!.text;
        }
      }
      
      // Save to Firestore
      await FirebaseFirestore.instance.collection('items').add(itemData);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success and navigate back
      _showSuccessSnackBar('Item saved successfully');
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      _showErrorSnackBar('Error saving item: ${e.toString()}');
    }
    */

    // For now, just show success and navigate back
    _showSuccessSnackBar('Item saved successfully');
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  // Show error SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show success SnackBar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class ImageSource {}

class XFile {
  final String path;
  XFile(this.path);
}

class ImagePicker {
  pickImage({required source}) {}
}
