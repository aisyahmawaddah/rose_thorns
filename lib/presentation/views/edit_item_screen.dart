// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:koopon/data/services/item_service.dart';
// import 'package:koopon/data/models/item_model.dart';

// class EditItemPage extends StatefulWidget {
//   final ItemModel item;

//   const EditItemPage({Key? key, required this.item}) : super(key: key);

//   @override
//   _EditItemPageState createState() => _EditItemPageState();
// }

// class _EditItemPageState extends State<EditItemPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();

//   String _selectedCategory = 'Choose category';
//   String _selectedStatus = 'Lightly used';
//   File? _newImageFile;
//   String? _currentImageUrl;
//   final ImagePicker _picker = ImagePicker();
//   bool _isLoading = false;

//   // Instance of ItemService
//   final ItemService _itemService = ItemService();

//   // List of categories
//   final List<String> _categories = [
//     'Choose category',
//     'Clothes',
//     'Cosmetics',
//     'Shoes',
//     'Electronics',
//     'Food'
//   ];

//   // List of status options
//   final List<String> _statusOptions = [
//     'Brand new',
//     'Lightly used',
//     'Well used',
//     'Heavily used'
//   ];

//   // Map to store dynamic fields for each category
//   final Map<String, List<String>> _categoryFields = {
//     'Clothes': ['Brand', 'Size', 'Condition', 'Material', 'Color'],
//     'Cosmetics': ['Brand', 'Type', 'Volume', 'Expiry Date'],
//     'Shoes': ['Brand', 'Size', 'Condition', 'Color', 'Material'],
//     'Electronics': ['Brand', 'Model', 'Condition', 'Age', 'Specifications'],
//     'Food': ['Type', 'Expiry Date', 'Dietary Info', 'Weight']
//   };

//   // Current dynamic fields based on selected category
//   List<String> _currentFields = [];

//   // Controllers for dynamic fields
//   final Map<String, TextEditingController> _dynamicControllers = {};

//   @override
//   void initState() {
//     super.initState();
//     _initializeWithItemData();
//   }

//   void _initializeWithItemData() {
//     // Pre-fill form with existing item data
//     _nameController.text = widget.item.name;
//     _priceController.text = widget.item.price.toString();
//     _selectedCategory = widget.item.category;
//     _selectedStatus = widget.item.status;
//     _currentImageUrl = widget.item.imageUrl;

//     // Initialize dynamic controllers for all possible fields
//     for (var category in _categoryFields.keys) {
//       for (var field in _categoryFields[category]!) {
//         _dynamicControllers[field] = TextEditingController();
//       }
//     }

//     // Set up current fields for the category
//     if (_selectedCategory != 'Choose category') {
//       _updateFieldsForCategory(_selectedCategory);
      
//       // Pre-fill dynamic fields with existing data
//       widget.item.additionalFields.forEach((key, value) {
//         final fieldName = _capitalizeFirst(key);
//         if (_dynamicControllers.containsKey(fieldName)) {
//           _dynamicControllers[fieldName]!.text = value.toString();
//         }
//       });
//     }
//   }

//   String _capitalizeFirst(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1);
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();

//     // Dispose all dynamic controllers
//     for (var controller in _dynamicControllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   // Update fields when category changes
//   void _updateFieldsForCategory(String category) {
//     setState(() {
//       _currentFields = _categoryFields[category] ?? [];
//     });
//   }

//   // Pick image from gallery
//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 80,
//       );
      
//       if (pickedFile != null) {
//         setState(() {
//           _newImageFile = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       _showErrorSnackBar('Error picking image: ${e.toString()}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE5F6FF),
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(90),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: Color(0xFFD4E8FF),
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(30),
//               bottomRight: Radius.circular(30),
//             ),
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Color(0xFF473173)),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                   const Expanded(
//                     child: Center(
//                       child: Text(
//                         'Edit Item',
//                         style: TextStyle(
//                           color: Color(0xFF473173),
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.person,
//                       color: Color(0xFF8A56AC),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Category Dropdown
//               Container(
//                 margin: const EdgeInsets.only(bottom: 16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20.0),
//                   border: Border.all(color: Colors.transparent),
//                 ),
//                 child: DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                     border: InputBorder.none,
//                   ),
//                   value: _selectedCategory,
//                   icon: const Icon(Icons.keyboard_arrow_down,
//                       color: Color(0xFF8A56AC)),
//                   isExpanded: true,
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedCategory = newValue!;
//                       if (_selectedCategory != 'Choose category') {
//                         _updateFieldsForCategory(_selectedCategory);
//                       } else {
//                         _currentFields = [];
//                       }
//                     });
//                   },
//                   items: _categories.map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(
//                         value,
//                         style: const TextStyle(
//                           color: Color(0xFF8A56AC),
//                           fontSize: 14,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),

//               if (_selectedCategory != 'Choose category') ...[
//                 // Image Upload Section
//                 Center(
//                   child: GestureDetector(
//                     onTap: _pickImage,
//                     child: Container(
//                       width: 120,
//                       height: 120,
//                       margin: const EdgeInsets.symmetric(vertical: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 4,
//                             spreadRadius: 1,
//                           ),
//                         ],
//                       ),
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           if (_newImageFile != null)
//                             // Show new selected image
//                             ClipOval(
//                               child: Image.file(
//                                 _newImageFile!,
//                                 fit: BoxFit.cover,
//                                 width: 120,
//                                 height: 120,
//                               ),
//                             )
//                           else if (_currentImageUrl != null)
//                             // Show existing image
//                             ClipOval(
//                               child: Image.network(
//                                 _currentImageUrl!,
//                                 fit: BoxFit.cover,
//                                 width: 120,
//                                 height: 120,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return const Icon(
//                                     Icons.add_photo_alternate,
//                                     color: Color(0xFF8A56AC),
//                                     size: 40,
//                                   );
//                                 },
//                               ),
//                             )
//                           else
//                             // Show placeholder
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.add_photo_alternate,
//                                   color: Color(0xFF8A56AC),
//                                   size: 40,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 const Text(
//                                   'Optional',
//                                   style: TextStyle(
//                                     color: Color(0xFF8A56AC),
//                                     fontSize: 10,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           Positioned(
//                             right: 0,
//                             bottom: 0,
//                             child: Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: const BoxDecoration(
//                                 color: Color(0xFF8A56AC),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.edit,
//                                 color: Colors.white,
//                                 size: 18,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Item Name Field
//                 const Text(
//                   "Item Name",
//                   style: TextStyle(
//                     color: Color(0xFF473173),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 16.0),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF9E7FF),
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   child: TextField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       contentPadding: EdgeInsets.symmetric(
//                           horizontal: 16.0, vertical: 12.0),
//                       border: InputBorder.none,
//                       hintText: 'Enter item name',
//                     ),
//                   ),
//                 ),

//                 // Status Field
//                 const Text(
//                   "Status",
//                   style: TextStyle(
//                     color: Color(0xFF473173),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 16.0),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF9E7FF),
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   child: DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       contentPadding: EdgeInsets.symmetric(
//                           horizontal: 16.0, vertical: 12.0),
//                       border: InputBorder.none,
//                     ),
//                     value: _selectedStatus,
//                     icon: const Icon(Icons.keyboard_arrow_down,
//                         color: Color(0xFF8A56AC)),
//                     isExpanded: true,
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedStatus = newValue!;
//                       });
//                     },
//                     items: _statusOptions.map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(
//                           value,
//                           style: const TextStyle(
//                             color: Color(0xFF8A56AC),
//                             fontSize: 14,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),

//                 // Dynamic Fields based on Category
//                 ..._currentFields.map((field) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         field,
//                         style: const TextStyle(
//                           color: Color(0xFF473173),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Container(
//                         margin: const EdgeInsets.only(bottom: 16.0),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF9E7FF),
//                           borderRadius: BorderRadius.circular(20.0),
//                         ),
//                         child: TextField(
//                           controller: _dynamicControllers[field],
//                           decoration: InputDecoration(
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16.0, vertical: 12.0),
//                             border: InputBorder.none,
//                             hintText: 'Enter $field',
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 }).toList(),

//                 // Price Field (RM)
//                 const Text(
//                   "Price (RM)",
//                   style: TextStyle(
//                     color: Color(0xFF473173),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 16.0),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF9E7FF),
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   child: TextField(
//                     controller: _priceController,
//                     keyboardType:
//                         const TextInputType.numberWithOptions(decimal: true),
//                     decoration: const InputDecoration(
//                       contentPadding: EdgeInsets.symmetric(
//                           horizontal: 16.0, vertical: 12.0),
//                       border: InputBorder.none,
//                       hintText: 'Enter price',
//                     ),
//                   ),
//                 ),

//                 // Update Button
//                 Center(
//                   child: Container(
//                     width: 200,
//                     margin: const EdgeInsets.symmetric(vertical: 16.0),
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _updateItem,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _isLoading 
//                             ? Colors.grey 
//                             : const Color(0xFF2196F3), // Blue for update
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                               ),
//                             )
//                           : const Text(
//                               'Update Item',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Update item method with Firebase integration
//   void _updateItem() async {
//     // Validate form
//     if (_nameController.text.trim().isEmpty) {
//       _showErrorSnackBar('Please enter item name');
//       return;
//     }

//     if (_selectedCategory == 'Choose category') {
//       _showErrorSnackBar('Please select a category');
//       return;
//     }

//     if (_priceController.text.trim().isEmpty) {
//       _showErrorSnackBar('Please enter price');
//       return;
//     }

//     // Validate price
//     double? price;
//     try {
//       price = double.parse(_priceController.text.trim());
//       if (price <= 0) {
//         _showErrorSnackBar('Please enter a valid price');
//         return;
//       }
//     } catch (e) {
//       _showErrorSnackBar('Please enter a valid price');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Collect additional fields
//       final additionalFields = <String, dynamic>{};
//       for (var field in _currentFields) {
//         final controller = _dynamicControllers[field];
//         if (controller != null && controller.text.trim().isNotEmpty) {
//           additionalFields[field.toLowerCase()] = controller.text.trim();
//         }
//       }

//       // Prepare update data
//       final updateData = <String, dynamic>{
//         'name': _nameController.text.trim(),
//         'category': _selectedCategory,
//         'status': _selectedStatus,
//         'price': price,
//         'updatedAt': DateTime.now(),
//         ...additionalFields,
//       };

//       // Handle image update
//       if (_newImageFile != null) {
//         // Upload new image and get URL
//         final imageUrl = await _itemService.uploadItemImage(_newImageFile!, widget.item.id!);
//         updateData['imageUrl'] = imageUrl;
//       }

//       // Update item using ItemService
//       await _itemService.updateItem(widget.item.id!, updateData);

//       // Show success and navigate back
//       _showSuccessSnackBar('Item updated successfully!');
      
//       // Wait a moment for user to see the success message
//       await Future.delayed(const Duration(seconds: 1));
      
//       // Navigate back with success result
//       if (mounted) {
//         Navigator.of(context).pop(true); // Return true to indicate success
//       }
//     } catch (e) {
//       _showErrorSnackBar('Error updating item: ${e.toString()}');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // Show error SnackBar
//   void _showErrorSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   // Show success SnackBar
//   void _showSuccessSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }
// }