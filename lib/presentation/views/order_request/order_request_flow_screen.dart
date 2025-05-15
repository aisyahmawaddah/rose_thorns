// // views/order_request/order_request_flow_screen.dart
// import 'package:flutter/material.dart';
// import 'deal_method_screen.dart';
// import 'address_selection_screen.dart';
// import 'timeslot_selection_screen.dart';
// import 'order_summary_screen.dart';


// class OrderRequestFlowScreen extends StatefulWidget {
//   final Map<String, dynamic> productData;

//   OrderRequestFlowScreen({required this.productData});

//   @override
//   _OrderRequestFlowScreenState createState() => _OrderRequestFlowScreenState();
// }

// class _OrderRequestFlowScreenState extends State<OrderRequestFlowScreen> {
//   PageController _pageController = PageController();
//   int _currentPage = 0;
  
//   // Store selections
//   String? selectedDealMethod;
//   Map<String, dynamic>? selectedAddress;
//   Map<String, dynamic>? selectedTimeslot;

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_currentPage > 0) {
//           _previousPage();
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         body: PageView(
//           controller: _pageController,
//           physics: NeverScrollableScrollPhysics(), // Disable swipe navigation
//           onPageChanged: (index) {
//             setState(() {
//               _currentPage = index;
//             });
//           },
//           children: [
//             // Step 1: Deal Method Selection
//             DealMethodScreenWrapper(
//               onMethodSelected: (method) {
//                 selectedDealMethod = method;
//                 _nextPage();
//               },
//             ),
            
//             // Step 2: Address Selection
//             AddressSelectionScreenWrapper(
//               dealMethod: selectedDealMethod,
//               onAddressSelected: (address) {
//                 selectedAddress = address;
//                 _nextPage();
//               },
//               onBack: () => _previousPage(),
//             ),
            
//             // Step 3: Timeslot Selection
//             TimeslotSelectionScreenWrapper(
//               dealMethod: selectedDealMethod,
//               onTimeslotSelected: (timeslot) {
//                 selectedTimeslot = timeslot;
//                 _nextPage();
//               },
//               onBack: () => _previousPage(),
//             ),
            
//             // Step 4: Order Summary
//             OrderSummaryScreenWrapper(
//               productData: widget.productData,
//               dealMethod: selectedDealMethod,
//               address: selectedAddress,
//               timeslot: selectedTimeslot,
//               onBack: () => _previousPage(),
//               onPlaceOrder: () {
//                 // Handle order placement
//                 _handleOrderPlacement();
//               },
//               onEditMethod: () => _goToPage(0),
//               onEditAddress: () => _goToPage(1),
//               onEditTimeslot: () => _goToPage(2),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _nextPage() {
//     if (_currentPage < 3) {
//       _pageController.nextPage(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _previousPage() {
//     if (_currentPage > 0) {
//       _pageController.previousPage(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _goToPage(int page) {
//     _pageController.animateToPage(
//       page,
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   void _handleOrderPlacement() {
//     // Create order object
//     final orderData = {
//       'product': widget.productData,
//       'dealMethod': selectedDealMethod,
//       'address': selectedAddress,
//       'timeslot': selectedTimeslot,
//       'timestamp': DateTime.now().toIso8601String(),
//     };

//     // Show success dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Order Placed Successfully!'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.check_circle,
//                 color: Colors.green,
//                 size: 60,
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Your order request has been sent to the seller.',
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//                 Navigator.of(context).pop(); // Go back to previous screen
//                 // You can also navigate to purchase history here
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }

// // Wrapper classes to handle navigation and data passing
// class DealMethodScreenWrapper extends StatelessWidget {
//   final Function(String) onMethodSelected;

//   DealMethodScreenWrapper({required this.onMethodSelected});

//   @override
//   Widget build(BuildContext context) {
//     return DealMethodScreen(
//       onMethodSelected: onMethodSelected,
//     );
//   }
// }

// class AddressSelectionScreenWrapper extends StatelessWidget {
//   final String? dealMethod;
//   final Function(Map<String, dynamic>) onAddressSelected;
//   final VoidCallback onBack;

//   AddressSelectionScreenWrapper({
//     required this.dealMethod,
//     required this.onAddressSelected,
//     required this.onBack,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AddressSelectionScreen(
//       dealMethod: dealMethod,
//       onAddressSelected: onAddressSelected,
//       onBack: onBack,
//     );
//   }
// }

// class TimeslotSelectionScreenWrapper extends StatelessWidget {
//   final String? dealMethod;
//   final Function(Map<String, dynamic>) onTimeslotSelected;
//   final VoidCallback onBack;

//   TimeslotSelectionScreenWrapper({
//     required this.dealMethod,
//     required this.onTimeslotSelected,
//     required this.onBack,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TimeslotSelectionScreen(
//       dealMethod: dealMethod,
//       onTimeslotSelected: onTimeslotSelected,
//       onBack: onBack,
//     );
//   }
// }

// class OrderSummaryScreenWrapper extends StatelessWidget {
//   final Map<String, dynamic> productData;
//   final String? dealMethod;
//   final Map<String, dynamic>? address;
//   final Map<String, dynamic>? timeslot;
//   final VoidCallback onBack;
//   final VoidCallback onPlaceOrder;
//   final VoidCallback onEditMethod;
//   final VoidCallback onEditAddress;
//   final VoidCallback onEditTimeslot;

//   OrderSummaryScreenWrapper({
//     required this.productData,
//     required this.dealMethod,
//     required this.address,
//     required this.timeslot,
//     required this.onBack,
//     required this.onPlaceOrder,
//     required this.onEditMethod,
//     required this.onEditAddress,
//     required this.onEditTimeslot,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return OrderSummaryScreen(
//       productData: productData,
//       dealMethod: dealMethod,
//       address: address,
//       timeslot: timeslot,
//       onBack: onBack,
//       onPlaceOrder: onPlaceOrder,
//       onEditMethod: onEditMethod,
//       onEditAddress: onEditAddress,
//       onEditTimeslot: onEditTimeslot,
//     );
//   }
// }

// // Usage example:
// void main() {
//   final sampleProduct = {
//     'title': 'Zara Trenched Coat',
//     'condition': 'Lightly used',
//     'price': 30.00,
//     'image': 'assets/trench_coat.jpg',
//   };

//   runApp(MaterialApp(
//     home: OrderRequestFlowScreen(productData: sampleProduct),
//     debugShowCheckedModeBanner: false,
//   ));
// }