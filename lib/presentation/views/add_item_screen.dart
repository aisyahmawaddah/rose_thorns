import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/data/services/item_services.dart';
import 'package:koopon/presentation/views/cart/cart_screen.dart';
import 'package:koopon/presentation/views/order_request/purchase_history_screen.dart';
import 'package:koopon/presentation/views/profile/profile_screen.dart';
import 'package:koopon/presentation/viewmodels/cart_viewmodel.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCategory = 'Choose category';
  String _selectedCondition = 'Like New'; // For dropdown conditions
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  int _selectedNavIndex = 2; // Sell tab is selected

  // Instance of ItemService
  final ItemService _itemService = ItemService();

  // List of categories (Food changed to Book)
  final List<String> _categories = [
    'Choose category',
    'Clothes',
    'Cosmetics',
    'Shoes',
    'Electronics',
    'Book'
  ];

  // Condition options for dropdown
  final List<String> _conditionOptions = [
    'Like New',
    'Lightly Used',
    'Heavily Used'
  ];

  // Map to store dynamic fields for each category (updated fields)
  final Map<String, List<String>> _categoryFields = {
    'Clothes': ['Brand', 'Size', 'Material', 'Color'],
    'Cosmetics': ['Brand', 'Percentage Used (%)', 'Expiry Date (DD/MM/YYYY)'],
    'Shoes': ['Brand', 'Size', 'Material', 'Color'],
    'Electronics': ['Brand', 'Model', 'Specifications'],
    'Book': ['Author'], // Book Title will be the item name
  };

  // Categories that need condition dropdown
  final Set<String> _categoriesWithCondition = {
    'Clothes', 'Shoes', 'Electronics', 'Book', 'Cosmetics'
  };

  // Current dynamic fields based on selected category
  List<String> _currentFields = [];

  // Controllers for dynamic fields
  final Map<String, TextEditingController> _dynamicControllers = {};

  // Timeslot data structure
  final Map<String, List<String?>> _weeklyTimeslots = {
    'Monday': [null, null, null],
    'Tuesday': [null, null, null],
    'Wednesday': [null, null, null],
    'Thursday': [null, null, null],
    'Friday': [null, null, null],
    'Saturday': [null, null, null],
    'Sunday': [null, null, null],
  };

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
      // Reset condition to default when category changes
      _selectedCondition = 'Like New';
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

  // Show time picker popup for timeslots
  Future<void> _showTimePickerPopup(String day, int slotIndex) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      // Check if time is within allowed range (7 AM - 7 PM)
      if (selectedTime.hour < 7 || selectedTime.hour > 19) {
        _showErrorSnackBar('Please select a time between 7:00 AM and 7:00 PM');
        return;
      }

      setState(() {
        String formattedTime = selectedTime.format(context);
        _weeklyTimeslots[day]![slotIndex] = formattedTime;
      });
    }
  }

  // Remove timeslot
  void _removeTimeslot(String day, int slotIndex) {
    setState(() {
      _weeklyTimeslots[day]![slotIndex] = null;
    });
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

                // Item Name / Book Title Field
                Text(
                  _selectedCategory == 'Book' ? "Book Title" : "Item Name",
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
                    controller: _nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      border: InputBorder.none,
                      hintText: _selectedCategory == 'Book' 
                          ? 'Enter book title' 
                          : 'Enter item name',
                    ),
                  ),
                ),

                // Condition Field (for categories that need it, except Cosmetics)
                if (_categoriesWithCondition.contains(_selectedCategory) && _selectedCategory != 'Cosmetics') ...[
                  const Text(
                    "Condition",
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
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        border: InputBorder.none,
                      ),
                      value: _selectedCondition,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF8A56AC)),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCondition = newValue!;
                        });
                      },
                      items: _conditionOptions.map<DropdownMenuItem<String>>((String value) {
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
                ],

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
                          keyboardType: field == 'Percentage Used (%)' 
                              ? TextInputType.number 
                              : TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            border: InputBorder.none,
                            hintText: field == 'Expiry Date (DD/MM/YYYY)'
                                ? 'DD/MM/YYYY'
                                : field == 'Percentage Used (%)'
                                    ? '0-100'
                                    : 'Enter $field',
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),

                // Price Field (RM) - Enhanced validation
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
                      hintText: 'Enter price (must be greater than 0)',
                    ),
                  ),
                ),

                // Meetup Timeslots Section
                const Text(
                  "Meetup Timeslot",
                  style: TextStyle(
                    color: Color(0xFF473173),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Select up to 3 time slots per day when you're available for meetup with buyer (7AM - 7PM)",
                  style: TextStyle(
                    color: Color(0xFF473173),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                // Weekly Timeslot Selection
                ..._weeklyTimeslots.keys.map((day) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF8A56AC).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day,
                          style: const TextStyle(
                            color: Color(0xFF473173),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            // Display existing time slots
                            ...List.generate(3, (index) {
                              final timeSlot = _weeklyTimeslots[day]![index];
                              if (timeSlot != null) {
                                return Chip(
                                  label: Text(
                                    timeSlot,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => _removeTimeslot(day, index),
                                  backgroundColor: const Color(0xFFF9E7FF),
                                  deleteIconColor: const Color(0xFF8A56AC),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            // Add time slot button (if less than 3 slots)
                            if (_weeklyTimeslots[day]!.where((slot) => slot != null).length < 3)
                              GestureDetector(
                                onTap: () {
                                  final nextIndex = _weeklyTimeslots[day]!.indexWhere((slot) => slot == null);
                                  if (nextIndex != -1) {
                                    _showTimePickerPopup(day, nextIndex);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8A56AC).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: const Color(0xFF8A56AC)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add,
                                          size: 16, color: Color(0xFF8A56AC)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Add Time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8A56AC),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),

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
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.shopping_cart, 'Cart', 1), // Changed from bookmark to cart
            _buildSellButton(),
            _buildNavItem(Icons.receipt_long, 'History', 3), // Changed from notifications to receipt/history
            _buildNavItem(Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        
        // Handle navigation based on index
        switch (index) {
          case 0:
            // Home - Navigate back to home screen
            Navigator.of(context).pop();
            break;
          case 1:
            // Cart - Navigate to CartScreen
            if (FirebaseAuth.instance.currentUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              ).then((value) {
                // Reset navigation selection when returning from cart
                setState(() {
                  _selectedNavIndex = 2; // Keep sell selected
                });
              });
            } else {
              // Show login message for unauthenticated users
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please login to access your cart'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              // Reset selection to sell
              setState(() {
                _selectedNavIndex = 2;
              });
            }
            break;
          case 3:
            // Purchase History - Navigate to PurchaseHistoryScreen
            if (FirebaseAuth.instance.currentUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PurchaseHistoryScreen(),
                ),
              ).then((value) {
                // Reset navigation selection when returning from history
                setState(() {
                  _selectedNavIndex = 2; // Keep sell selected
                });
              });
            } else {
              // Show login message for unauthenticated users
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please login to view your purchase history'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              // Reset selection to sell
              setState(() {
                _selectedNavIndex = 2;
              });
            }
            break;
          case 4:
            // Profile - Navigate to ProfileScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            ).then((value) {
              // Reset navigation selection when returning from profile
              setState(() {
                _selectedNavIndex = 2; // Keep sell selected
              });
            });
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label selected')),
            );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add cart badge for cart navigation item
            index == 1 ? // Cart navigation item
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Consumer<CartViewModel>(
                      builder: (context, cartViewModel, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              icon,
                              color: isSelected ? const Color(0xFF8A56AC) : Colors.grey[400],
                              size: 24,
                            ),
                            // Cart count badge (only show if items > 0 and user has token)
                            if (cartViewModel.itemCount > 0 && cartViewModel.userToken != null)
                              Positioned(
                                right: -8,
                                top: -8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE91E63),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white, width: 1),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${cartViewModel.itemCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Show cart icon without badge if user has no token
                    return Icon(
                      icon,
                      color: isSelected ? const Color(0xFF8A56AC) : Colors.grey[400],
                      size: 24,
                    );
                  }
                },
              )
            : // Regular navigation items
              Icon(
                icon,
                color: isSelected ? const Color(0xFF8A56AC) : Colors.grey[400],
                size: 24,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF8A56AC) : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellButton() {
    return GestureDetector(
      onTap: () {
        // Already on add item screen, show message or do nothing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are currently adding an item'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF8A56AC),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A56AC).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Save item method with enhanced validation
  void _saveItem() async {
    // Validate form
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar(_selectedCategory == 'Book' 
          ? 'Please enter book title' 
          : 'Please enter item name');
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

    // Enhanced price validation - check for 0
    double? price;
    try {
      price = double.parse(_priceController.text.trim());
      if (price <= 0) {
        _showErrorSnackBar('Price must be greater than 0');
        return;
      }
    } catch (e) {
      _showErrorSnackBar('Please enter a valid price');
      return;
    }

    // Validate percentage for cosmetics
    if (_selectedCategory == 'Cosmetics') {
      final percentageController = _dynamicControllers['Percentage Used (%)'];
      if (percentageController != null && percentageController.text.trim().isNotEmpty) {
        try {
          final percentage = double.parse(percentageController.text.trim());
          if (percentage < 0 || percentage > 100) {
            _showErrorSnackBar('Percentage used must be between 0 and 100');
            return;
          }
        } catch (e) {
          _showErrorSnackBar('Please enter a valid percentage (0-100)');
          return;
        }}}}}