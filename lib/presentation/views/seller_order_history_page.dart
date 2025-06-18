// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import 'package:koopon/presentation/viewmodels/seller_order_viewmodel.dart';

// // Remove ChangeNotifierProvider from here.
// // Wrap SellerOrderHistoryPage with ChangeNotifierProvider in your main widget tree instead.

// class SellerOrderHistoryPage extends StatefulWidget {
//   const SellerOrderHistoryPage({Key? key}) : super(key: key);

//   @override
//   State<SellerOrderHistoryPage> createState() => _SellerOrderHistoryPageState();
// }

// class _SellerOrderHistoryPageState extends State<SellerOrderHistoryPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE8D4F1),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header Section (matching profile style)
//             _buildHeader(),
            
//             // TabBar Container (matching profile white card style)
//             _buildTabBarContainer(),
            
//             // TabBarView Content
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildOrderList(['placed', 'pending']), // New Orders
//                   _buildOrderList(['confirmed']), // To Ship
//                   _buildOrderList(['shipped']), // Shipped
//                   _buildOrderList(['delivered', 'completed']), // Completed
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//       child: Row(
//         children: [
//           // Back Icon
//           Container(
//             padding: const EdgeInsets.all(4),
//             child: GestureDetector(
//               onTap: () => Navigator.of(context).pop(),
//               child: const Icon(
//                 Icons.arrow_back,
//                 color: Color(0xFF2D1B35),
//                 size: 24,
//               ),
//             ),
//           ),
          
//           const Spacer(),
          
//           // Title
//           const Text(
//             'My Sales',
//             style: TextStyle(
//               color: Color(0xFF2D1B35),
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
          
//           const Spacer(),
          
//           // Settings Icon
//           Container(
//             padding: const EdgeInsets.all(4),
//             child: GestureDetector(
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Settings coming soon')),
//                 );
//               },
//               child: const Icon(
//                 Icons.settings,
//                 color: Color(0xFF2D1B35),
//                 size: 24,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabBarContainer() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TabBar(
//         controller: _tabController,
//         indicatorColor: const Color(0xFF9C27B0),
//         indicatorWeight: 3,
//         labelColor: const Color(0xFF9C27B0),
//         unselectedLabelColor: Colors.grey[600],
//         labelStyle: const TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//         ),
//         unselectedLabelStyle: const TextStyle(
//           fontWeight: FontWeight.normal,
//           fontSize: 12,
//         ),
//         tabs: const [
//           Tab(text: 'New Orders'),
//           Tab(text: 'To Ship'),
//           Tab(text: 'Shipped'),
//           Tab(text: 'Completed'),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderList(List<String> statuses) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('orders')
//           .where('sellerId', isEqualTo: _auth.currentUser?.uid)
//           .where('status', whereIn: statuses)
//           .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: Color(0xFF9C27B0),
//             ),
//           );
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   size: 64,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Something went wrong',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         final orders = snapshot.data?.docs ?? [];

//         if (orders.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.shopping_bag_outlined,
//                   size: 64,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No orders found',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   _getEmptyStateMessage(statuses),
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[500],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: orders.length,
//           itemBuilder: (context, index) {
//             final orderData = orders[index].data() as Map<String, dynamic>;
//             final orderId = orders[index].id;
            
//             return _buildOrderCard(orderData, orderId);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildOrderCard(Map<String, dynamic> orderData, String orderId) {
//     final status = orderData['status'] as String;
//     final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate();
//     final total = (orderData['total'] as num?)?.toDouble() ?? 0.0;
//     final items = orderData['items'] as List<dynamic>? ?? [];
//     final dealMethod = orderData['dealMethod'] as String? ?? 'delivery';
//     final buyerName = orderData['buyerName'] as String? ?? 'Unknown Buyer';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Order Header
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: _getStatusColor(status).withOpacity(0.1),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Order #${orderId.substring(0, 8).toUpperCase()}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Color(0xFF2D1B35),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Buyer: $buyerName',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                       if (createdAt != null) ...[
//                         const SizedBox(height: 2),
//                         Text(
//                           _formatDate(createdAt),
//                           style: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(status),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     _getStatusText(status),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Order Items
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ...items.map((item) => _buildItemRow(item)).toList(),
                
//                 const Divider(height: 24),
                
//                 // Order Details
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Deal Method',
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Row(
//                             children: [
//                               Icon(
//                                 dealMethod == 'delivery' 
//                                     ? Icons.local_shipping 
//                                     : Icons.handshake,
//                                 size: 16,
//                                 color: const Color(0xFF9C27B0),
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 dealMethod == 'delivery' ? 'Delivery' : 'Meetup',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF2D1B35),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           'Total',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           'RM ${total.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: Color(0xFF9C27B0),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Action Buttons
//                 _buildActionButtons(orderId, status, orderData),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemRow(dynamic itemData) {
//     final item = itemData as Map<String, dynamic>;
//     final name = item['name'] as String? ?? 'Unknown Item';
//     final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//     final quantity = item['quantity'] as int? ?? 1;
//     final imageUrl = item['imageUrl'] as String?;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           // Item Image
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               color: Colors.grey[200],
//             ),
//             child: imageUrl != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Icon(
//                           Icons.image_not_supported,
//                           color: Colors.grey[400],
//                         );
//                       },
//                     ),
//                   )
//                 : Icon(
//                     Icons.image_not_supported,
//                     color: Colors.grey[400],
//                   ),
//           ),
          
//           const SizedBox(width: 12),
          
//           // Item Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                     color: Color(0xFF2D1B35),
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Qty: $quantity × RM ${price.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Item Total
//           Text(
//             'RM ${(price * quantity).toStringAsFixed(2)}',
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//               color: Color(0xFF2D1B35),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(String orderId, String status, Map<String, dynamic> orderData) {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: () => _showOrderDetails(orderId, orderData),
//             style: OutlinedButton.styleFrom(
//               side: const BorderSide(color: Color(0xFF9C27B0)),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//             child: const Text(
//               'View Details',
//               style: TextStyle(
//                 color: Color(0xFF9C27B0),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
        
//         const SizedBox(width: 12),
        
//         if (_canUpdateStatus(status)) ...[
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () => _updateOrderStatus(orderId, status),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF9C27B0),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//               ),
//               child: Text(
//                 _getActionButtonText(status),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   // Helper Methods
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'placed':
//       case 'pending':
//         return Colors.orange;
//       case 'confirmed':
//         return const Color(0xFF9C27B0);
//       case 'shipped':
//         return Colors.purple;
//       case 'delivered':
//       case 'completed':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status) {
//       case 'placed':
//         return 'New Order';
//       case 'pending':
//         return 'Pending';
//       case 'confirmed':
//         return 'To Ship';
//       case 'shipped':
//         return 'Shipped';
//       case 'delivered':
//         return 'Delivered';
//       case 'completed':
//         return 'Completed';
//       case 'cancelled':
//         return 'Cancelled';
//       default:
//         return status.toUpperCase();
//     }
//   }

//   String _getEmptyStateMessage(List<String> statuses) {
//     if (statuses.contains('placed') || statuses.contains('pending')) {
//       return 'No new orders yet.\nYour new orders will appear here.';
//     } else if (statuses.contains('confirmed')) {
//       return 'No orders to ship.\nConfirmed orders ready for shipping will appear here.';
//     } else if (statuses.contains('shipped')) {
//       return 'No shipped orders.\nOrders that have been shipped will appear here.';
//     } else {
//       return 'No completed orders.\nYour completed sales will appear here.';
//     }
//   }

//   bool _canUpdateStatus(String status) {
//     return ['placed', 'pending', 'confirmed', 'shipped'].contains(status);
//   }

//   String _getActionButtonText(String status) {
//     switch (status) {
//       case 'placed':
//       case 'pending':
//         return 'Confirm Order';
//       case 'confirmed':
//         return 'Mark as Shipped';
//       case 'shipped':
//         return 'Mark as Delivered';
//       default:
//         return 'Update Status';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   // Action Methods
//   void _updateOrderStatus(String orderId, String currentStatus) {
//     String nextStatus;
//     switch (currentStatus) {
//       case 'placed':
//       case 'pending':
//         nextStatus = 'confirmed';
//         break;
//       case 'confirmed':
//         nextStatus = 'shipped';
//         break;
//       case 'shipped':
//         nextStatus = 'delivered';
//         break;
//       default:
//         return;
//     }

//     _showStatusUpdateDialog(orderId, currentStatus, nextStatus);
//   }

//   void _showStatusUpdateDialog(String orderId, String currentStatus, String nextStatus) {
//     final TextEditingController trackingController = TextEditingController();
//     final bool needsTracking = nextStatus == 'shipped';

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: const Text(
//           'Update Order Status',
//           style: TextStyle(
//             color: Color(0xFF2D1B35),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Change status to: ${_getStatusText(nextStatus)}',
//               style: TextStyle(
//                 color: Colors.grey[700],
//               ),
//             ),
//             if (needsTracking) ...[
//               const SizedBox(height: 16),
//               TextField(
//                 controller: trackingController,
//                 decoration: InputDecoration(
//                   labelText: 'Tracking Number (Optional)',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     borderSide: const BorderSide(color: Color(0xFF9C27B0)),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => _confirmStatusUpdate(
//               orderId, 
//               nextStatus, 
//               trackingController.text.trim(),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF9C27B0),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//             child: const Text(
//               'Update',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _confirmStatusUpdate(String orderId, String newStatus, String trackingNumber) async {
//     try {
//       Navigator.pop(context); // Close dialog

//       final Map<String, dynamic> updateData = {
//         'status': newStatus,
//         'updatedAt': FieldValue.serverTimestamp(),
//       };

//       if (newStatus == 'shipped' && trackingNumber.isNotEmpty) {
//         updateData['trackingNumber'] = trackingNumber;
//       }

//       await _firestore.collection('orders').doc(orderId).update(updateData);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Order status updated to ${_getStatusText(newStatus)}'),
//           backgroundColor: Colors.green,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update order status: $e'),
//           backgroundColor: Colors.red,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   void _showOrderDetails(String orderId, Map<String, dynamic> orderData) {
//     // Navigate to detailed order view
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: const Text(
//           'Order Details',
//           style: TextStyle(
//             color: Color(0xFF2D1B35),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'Order ID: $orderId\n\nDetailed order view coming soon.',
//           style: TextStyle(
//             color: Colors.grey[700],
//           ),
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF9C27B0),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//             child: const Text(
//               'Close',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }