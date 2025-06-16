// lib/presentation/widgets/order_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/order_request_viewmodel.dart';
import '../../data/models/order_model.dart';

class OrderSummaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderRequestViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Items
            _buildSectionTitle('Items'),
            ...viewModel.cartItems.map((item) => _buildItemRow(item)),
            SizedBox(height: 16),
            
            // Deal method and location
            _buildSectionTitle('Deal Method'),
            _buildInfoRow(
              'Method',
              viewModel.selectedDealMethod == DealMethod.inCampusMeetup
                  ? 'In Campus Meetup'
                  : 'Delivery',
            ),
            
            // Display the appropriate address based on deal method
            if (viewModel.selectedDealMethod == DealMethod.inCampusMeetup && 
                viewModel.selectedMeetupLocation != null)
              _buildInfoRow(
                'Meetup Location',
                '${viewModel.selectedMeetupLocation!.title}\n${viewModel.selectedMeetupLocation!.fullAddress}',
              ),
            
            if (viewModel.selectedDealMethod == DealMethod.delivery && 
                viewModel.selectedAddress != null)
              _buildInfoRow(
                'Delivery Address',
                '${viewModel.selectedAddress!.title}\n${viewModel.selectedAddress!.fullAddress}',
              ),
            
            SizedBox(height: 16),
            
            // Date and time (now for both methods)
            if (viewModel.selectedTimeSlot != null) ...[
              _buildSectionTitle(
                viewModel.selectedDealMethod == DealMethod.inCampusMeetup 
                    ? 'Meetup Schedule'
                    : 'Delivery Schedule'
              ),
              _buildInfoRow(
                'Date',
                DateFormat('EEEE, MMMM d, yyyy').format(viewModel.selectedTimeSlot!.date),
              ),
              _buildInfoRow(
                'Time',
                viewModel.selectedTimeSlot!.timeRange,
              ),
              SizedBox(height: 16),
            ],
            
            // Price breakdown
            _buildSectionTitle('Price Breakdown'),
            _buildPriceRow('Subtotal', viewModel.subtotal),
            if (viewModel.deliveryFee > 0)
              _buildPriceRow('Delivery Fee', viewModel.deliveryFee),
            Divider(thickness: 1),
            _buildPriceRow('Total', viewModel.total, isTotal: true),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildItemRow(dynamic item) {
    // Extract item data with flexible handling
    String itemName = 'Unknown Item';
    int quantity = 1;
    double price = 0.0;
    double totalPrice = 0.0;
    String? imageUrl;
    
    try {
      // Try to get item name
      if (item.name != null) {
        itemName = item.name;
      } else if (item.title != null) {
        itemName = item.title;
      } else {
        try {
          final dynamic itemData = (item as dynamic).item;
          if (itemData?.name != null) {
            itemName = itemData.name;
          } else if (itemData?.title != null) {
            itemName = itemData.title;
          }
        } catch (e) {
          // Keep default name
        }
      }
      
      // Try to get quantity
      try {
        if (item.quantity != null) {
          quantity = item.quantity;
        } else {
          quantity = (item as dynamic).quantity ?? 1;
        }
      } catch (e) {
        quantity = 1;
      }
      
      // Try to get prices
      try {
        if (item.totalPrice != null) {
          totalPrice = item.totalPrice.toDouble();
        } else if (item.price != null) {
          price = item.price.toDouble();
          totalPrice = price * quantity;
        } else {
          // Try accessing through item property
          final dynamic itemData = (item as dynamic).item;
          if (itemData?.price != null) {
            price = itemData.price.toDouble();
            totalPrice = price * quantity;
          }
        }
      } catch (e) {
        print('Error extracting price from cart item: $e');
      }
      
      // Try to get image URL
      try {
        if (item.imageUrl != null) {
          imageUrl = item.imageUrl;
        } else {
          final dynamic itemData = (item as dynamic).item;
          if (itemData?.imageUrl != null) {
            imageUrl = itemData.imageUrl;
          }
        }
      } catch (e) {
        // No image available
      }
    } catch (e) {
      print('Error processing cart item: $e');
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported),
                      );
                    },
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image_not_supported),
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Qty: $quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'RM ${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}