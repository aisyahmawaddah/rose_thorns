// lib/presentation/views/purchase_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koopon/presentation/viewmodels/purchase_history_viewmodel.dart';
import 'package:koopon/data/models/order_model.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseHistoryViewModel>().loadOrderHistory();
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
              child: Consumer<PurchaseHistoryViewModel>(
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
                      
                      // Purchase TabView
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOrderList(viewModel.orders, viewModel), // All purchases
                            _buildOrderList(viewModel.getOrdersByStatus([OrderStatus.placed, OrderStatus.confirmed]), viewModel), // In Progress
                            _buildOrderList(viewModel.getOrdersByStatus([OrderStatus.completed]), viewModel), // Completed
                            _buildOrderList(viewModel.getOrdersByStatus([OrderStatus.cancelled]), viewModel), // Cancelled
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
            Colors.blue.withOpacity(0.1),
            Colors.blue.withOpacity(0.05),
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Purchase History',
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
                'Track your orders and purchases',
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
                context.read<PurchaseHistoryViewModel>().loadOrderHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Purchase history refreshed'),
                    backgroundColor: Colors.blue,
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
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
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
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          tabs: const [
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('All', textAlign: TextAlign.center),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('In Progress', textAlign: TextAlign.center),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('Completed', textAlign: TextAlign.center),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('Cancelled', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(PurchaseHistoryViewModel viewModel) {
    final stats = viewModel.getPurchaseStats();
    
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Purchase Overview',
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
                  Colors.blue,
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
                  'Total Spent',
                  'RM${viewModel.getTotalSpent().toStringAsFixed(0)}',
                  Icons.monetization_on_outlined,
                  const Color(0xFFE91E63),
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

  Widget _buildErrorWidget(PurchaseHistoryViewModel viewModel) {
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
                viewModel.loadOrderHistory();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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

  Widget _buildOrderList(List<OrderRequest> orders, PurchaseHistoryViewModel viewModel) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.loadOrderHistory();
      },
      color: Colors.blue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildPurchaseCard(orders[index], viewModel);
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
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Purchases Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1B35),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your purchase history will appear here.\nStart shopping to see your orders!',
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

  Widget _buildPurchaseCard(OrderRequest order, PurchaseHistoryViewModel viewModel) {
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
                      color: Colors.blue,
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
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Qty: ${order.items.first.quantity} × RM${order.items.first.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.blue,
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
                          color: Colors.blue.withOpacity(0.05),
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
                                  color: Colors.blue,
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
                        color: Colors.blue.withOpacity(0.05),
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
                              color: Color(0xFFE91E63),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Paid',
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

                // Action buttons (NO CANCEL - only RECEIVED for confirmed orders)
                _buildActionButtons(order, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderRequest order, PurchaseHistoryViewModel viewModel) {
    switch (order.status) {
      case OrderStatus.placed:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, color: Colors.orange, size: 20),
              SizedBox(width: 12),
              Text(
                'Waiting for Seller Confirmation',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );

      case OrderStatus.confirmed:
        return Container(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _markAsReceived(order, viewModel),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Mark as Received'),
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

      case OrderStatus.cancelled:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text(
                'Order Cancelled',
                style: TextStyle(
                  color: Colors.red,
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
      case OrderStatus.confirmed:
        return const Color(0xFF2196F3); // Blue
      case OrderStatus.completed:
        return const Color(0xFF4CAF50); // Green
      case OrderStatus.cancelled:
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.local_shipping_outlined;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // Helper to format DateTime as a readable string
  String _formatDate(DateTime date) {
    // Example: 2024-06-01 14:23 -> Jun 1, 2024
    return "${_monthName(date.month)} ${date.day}, ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Add this method to handle marking an order as received
  void _markAsReceived(OrderRequest order, PurchaseHistoryViewModel viewModel) async {
    await viewModel.markOrderAsReceived(order.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order marked as received!'),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}