// lib/presentation/views/order_history_screen.dart
// Enhanced screen for SELLERS to manage orders placed for their items
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koopon/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:koopon/data/models/order_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderHistoryViewModel>().loadSellerOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8D4F1),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildHeader(),
            
            // Enhanced TabBar
            _buildTabBarContainer(),
            
            // Content
            Expanded(
              child: Consumer<OrderHistoryViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF9C27B0),
                        strokeWidth: 3,
                      ),
                    );
                  }

                  if (viewModel.errorMessage != null) {
                    return _buildErrorWidget(viewModel);
                  }

                  return Column(
                    children: [
                      // Statistics Card
                      _buildStatisticsCard(viewModel),
                      
                      // Orders TabView
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOrderList(viewModel.orders, viewModel), // All orders
                            _buildOrderList(viewModel.pendingOrders, viewModel), // Pending orders
                            _buildOrderList(viewModel.completedOrders, viewModel), // Completed orders
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9C27B0).withOpacity(0.1),
            const Color(0xFF9C27B0).withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // Enhanced Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF2D1B35),
                size: 20,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Enhanced Title with Icon
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: Color(0xFF9C27B0),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Order Management',
                    style: TextStyle(
                      color: Color(0xFF2D1B35),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Track and fulfill your orders',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Refresh Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                context.read<OrderHistoryViewModel>().loadSellerOrders();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Orders refreshed'),
                    backgroundColor: const Color(0xFF9C27B0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(
                Icons.refresh,
                color: Color(0xFF2D1B35),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarContainer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF9C27B0),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9C27B0).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          tabs: const [
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('All Orders', textAlign: TextAlign.center),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Pending', textAlign: TextAlign.center),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Completed', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(OrderHistoryViewModel viewModel) {
    final stats = viewModel.getOrderStats();
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sales Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Orders',
                  stats['total'].toString(),
                  Icons.shopping_bag_outlined,
                  const Color(0xFF9C27B0),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[200],
              ),
              Expanded(
                child: _buildStatItem(
                  'Completed',
                  stats['completed'].toString(),
                  Icons.check_circle_outlined,
                  Colors.green,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[200],
              ),
              Expanded(
                child: _buildStatItem(
                  'Revenue',
                  'RM${viewModel.getTotalRevenue().toStringAsFixed(0)}',
                  Icons.monetization_on_outlined,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(OrderHistoryViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1B35),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              viewModel.errorMessage ?? 'Please try again later',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.loadSellerOrders();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderRequest> orders, OrderHistoryViewModel viewModel) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.loadSellerOrders();
      },
      color: const Color(0xFF9C27B0),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index], viewModel);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1B35),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Orders for your items will appear here.\nKeep your products visible to attract more buyers!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderRequest order, OrderHistoryViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getStatusColor(order.status).withOpacity(0.1),
                  _getStatusColor(order.status).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _getStatusIcon(order.status),
                    color: _getStatusColor(order.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D1B35),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Customer: ${order.userId.substring(0, 8)}...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(order.createdAt),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(order.status).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Items Section Header
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF9C27B0),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${order.items.length} Item${order.items.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D1B35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Enhanced Item Display
                if (order.items.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: order.items.first.imageUrl.isNotEmpty
                                ? Image.network(
                                    order.items.first.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[100],
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey[400],
                                          size: 24,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[100],
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey[400],
                                      size: 24,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.items.first.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D1B35),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Qty: ${order.items.first.quantity} × RM${order.items.first.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF9C27B0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (order.items.length > 1) ...[
                                const SizedBox(height: 6),
                                Text(
                                  '+${order.items.length - 1} more item${order.items.length - 1 > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Enhanced Order Summary
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  order.dealMethod == DealMethod.delivery 
                                      ? Icons.local_shipping_outlined 
                                      : Icons.handshake_outlined,
                                  size: 20,
                                  color: const Color(0xFF9C27B0),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  order.dealMethod == DealMethod.delivery ? 'Delivery' : 'Meetup',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D1B35),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Deal Method',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'RM ${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action buttons (NO CANCEL FUNCTIONALITY)
                _buildActionButtons(order, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderRequest order, OrderHistoryViewModel viewModel) {
    switch (order.status) {
      case OrderStatus.placed:
        return Container(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _confirmOrder(order, viewModel),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Confirm Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.green.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        );

      case OrderStatus.confirmed:
        return Container(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _completeOrder(order, viewModel),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Mark as Completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF9C27B0).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        );

      case OrderStatus.completed:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 12),
              Text(
                'Order Successfully Completed',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // Enhanced Helper Methods
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return const Color(0xFFFF9800); // Orange
      case OrderStatus.pendingPayment:
        return const Color(0xFFFFC107); // Amber
      case OrderStatus.confirmed:
        return const Color(0xFF2196F3); // Blue
      case OrderStatus.completed:
        return const Color(0xFF4CAF50); // Green
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return Icons.schedule;
      case OrderStatus.pendingPayment:
        return Icons.payment;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.completed:
        return Icons.done_all;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'New Order';
      case OrderStatus.pendingPayment:
        return 'Pending Payment';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.completed:
        return 'Completed';
      default:
        return status.toString().toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Action methods (NO CANCEL FUNCTIONALITY)
  void _confirmOrder(OrderRequest order, OrderHistoryViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirm Order',
                style: TextStyle(
                  color: Color(0xFF2D1B35),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.tag,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Order: #${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1B35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on_outlined,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Total: RM ${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'By confirming this order, you agree to fulfill it according to the agreed terms and delivery method.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Not Now',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    
                    // Show loading
                    _showLoadingDialog('Confirming order...');
                    
                    final success = await viewModel.confirmOrder(order.id);
                    
                    // Hide loading
                    Navigator.pop(context);
                    
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 12),
                              Text('Order confirmed successfully'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (!success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(viewModel.errorMessage ?? 'Failed to confirm order'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 4,
                    shadowColor: Colors.green.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Order',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _completeOrder(OrderRequest order, OrderHistoryViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.done_all,
                color: Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Complete Order',
                style: TextStyle(
                  color: Color(0xFF2D1B35),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.tag,
                          color: Color(0xFF9C27B0),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Order: #${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1B35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on_outlined,
                          color: Color(0xFF9C27B0),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Total: RM ${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mark this order as completed once the customer has received their items and the transaction is finished.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Not Yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    
                    // Show loading
                    _showLoadingDialog('Completing order...');
                    
                    final success = await viewModel.completeOrder(order.id);
                    
                    // Hide loading
                    Navigator.pop(context);
                    
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.celebration, color: Colors.white),
                              SizedBox(width: 12),
                              Text('Order completed successfully! 🎉'),
                            ],
                          ),
                          backgroundColor: const Color(0xFF9C27B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (!success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(viewModel.errorMessage ?? 'Failed to complete order'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 4,
                    shadowColor: const Color(0xFF9C27B0).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Complete Order',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF9C27B0),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}