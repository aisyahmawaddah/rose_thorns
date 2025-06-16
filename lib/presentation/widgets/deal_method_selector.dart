// lib/presentation/widgets/deal_method_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/order_request_viewmodel.dart';
import '../../data/models/order_model.dart';

class DealMethodSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderRequestViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          children: [
            _buildDealMethodCard(
              context: context,
              dealMethod: DealMethod.inCampusMeetup,
              title: 'In Campus Meetup',
              subtitle: 'Meet the seller on campus',
              fee: 'RM 0',
              icon: Icons.location_on,
              isSelected: viewModel.selectedDealMethod == DealMethod.inCampusMeetup,
              onTap: () => viewModel.selectDealMethod(DealMethod.inCampusMeetup),
            ),
            SizedBox(height: 16),
            _buildDealMethodCard(
              context: context,
              dealMethod: DealMethod.delivery,
              title: 'Delivery',
              subtitle: 'Get it delivered to your location',
              fee: 'RM 3.00',
              icon: Icons.delivery_dining,
              isSelected: viewModel.selectedDealMethod == DealMethod.delivery,
              onTap: () => viewModel.selectDealMethod(DealMethod.delivery),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDealMethodCard({
    required BuildContext context,
    required DealMethod dealMethod,
    required String title,
    required String subtitle,
    required String fee,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue.shade700 : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fee,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue.shade700 : Colors.black,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 20,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}