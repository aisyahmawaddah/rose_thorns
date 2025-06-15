// lib/presentation/widgets/time_slot_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/order_request_viewmodel.dart';
import '../../data/models/time_slot_model.dart';
import '../../data/models/order_model.dart';
import '../../data/services/time_slot_service.dart';
import 'package:intl/intl.dart';

class TimeSlotSelector extends StatefulWidget {
  const TimeSlotSelector({Key? key}) : super(key: key);

  @override
  State<TimeSlotSelector> createState() => _TimeSlotSelectorState();
}

class _TimeSlotSelectorState extends State<TimeSlotSelector> {
  final TimeslotService _timeslotService = TimeslotService();
  Map<DateTime, List<TimeSlot>> _groupedTimeslots = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAvailableTimeslots();
  }

  void _loadAvailableTimeslots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orderViewModel = context.read<OrderRequestViewModel>();
      
      // Debug: Print CartItem structure
      print('=== DEBUG: CartItem Structure Analysis ===');
      for (int i = 0; i < orderViewModel.cartItems.length; i++) {
        final cartItem = orderViewModel.cartItems[i];
        print('CartItem $i:');
        print('  id: ${cartItem.id}');
        print('  itemId: ${cartItem.itemId}');
        print('  sellerId: ${cartItem.sellerId}');
        print('  name: ${cartItem.name}');
        print('  additionalFields: ${cartItem.additionalFields}');
        
        if (cartItem.additionalFields.containsKey('meetup_timeslots')) {
          print('  Found meetup_timeslots: ${cartItem.additionalFields['meetup_timeslots']}');
        } else {
          print('  No meetup_timeslots found');
        }
      }
      print('=== END DEBUG ===');
      
      // Get all unique sellers from cart items
      final sellers = <String>{};
      for (final cartItem in orderViewModel.cartItems) {
        sellers.add(cartItem.sellerId);
      }
      
      if (sellers.length > 1) {
        setState(() {
          _errorMessage = 'Cannot book timeslots for multiple sellers in one order.';
          _isLoading = false;
        });
        return;
      }
      
      if (sellers.isEmpty) {
        setState(() {
          _errorMessage = 'No seller information found in cart items.';
          _isLoading = false;
        });
        return;
      }

      // For each item, get its timeslots and convert them
      final List<TimeSlot> allTimeslots = [];
      
      for (final cartItem in orderViewModel.cartItems) {
        // Check if this item has meetup timeslots
        if (cartItem.additionalFields.containsKey('meetup_timeslots')) {
          final weeklyTimeslots = cartItem.additionalFields['meetup_timeslots'];
          
          if (weeklyTimeslots is Map<String, dynamic>) {
            print('Found timeslots for item ${cartItem.itemId}: $weeklyTimeslots');
            
            final convertedSlots = _timeslotService.convertWeeklyToSpecificTimeslots(
              itemId: cartItem.itemId,
              sellerId: cartItem.sellerId,
              weeklyTimeslots: weeklyTimeslots,
              weeksAhead: 3,
            );
            
            allTimeslots.addAll(convertedSlots);
          }
        } else {
          print('No meetup_timeslots found for item ${cartItem.itemId}');
        }
      }

      // Remove duplicates and group by date
      final uniqueTimeslots = _removeDuplicateTimeslots(allTimeslots);
      final grouped = _timeslotService.groupTimeslotsByDate(uniqueTimeslots);
      
      setState(() {
        _groupedTimeslots = grouped;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading timeslots: ${e.toString()}';
        _isLoading = false;
      });
      print('Error in _loadAvailableTimeslots: $e');
    }
  }

  List<TimeSlot> _removeDuplicateTimeslots(List<TimeSlot> timeslots) {
    final Map<String, TimeSlot> uniqueSlots = {};
    
    for (final slot in timeslots) {
      final key = '${DateFormat('yyyy-MM-dd').format(slot.date)}_${slot.startTime}';
      
      if (!uniqueSlots.containsKey(key)) {
        uniqueSlots[key] = slot;
      }
    }
    
    return uniqueSlots.values.toList()
      ..sort((a, b) {
        final dateComparison = a.date.compareTo(b.date);
        if (dateComparison != 0) return dateComparison;
        return a.startTime.compareTo(b.startTime);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderRequestViewModel>(
      builder: (context, viewModel, _) {
        if (_isLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (_errorMessage != null) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAvailableTimeslots,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_groupedTimeslots.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.schedule, color: Colors.orange, size: 48),
                SizedBox(height: 8),
                Text(
                  'No available timeslots',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  viewModel.selectedDealMethod == DealMethod.inCampusMeetup
                      ? 'The seller has not set any meetup timeslots for these items.'
                      : 'The seller has not set any delivery timeslots for these items.',
                  style: TextStyle(color: Colors.orange.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viewModel.selectedDealMethod == DealMethod.inCampusMeetup
                          ? 'Select a convenient time slot for your meetup with the seller.'
                          : 'Select a convenient time slot for delivery.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // Display grouped timeslots by date
            ...(_groupedTimeslots.entries.map((entry) {
              final date = entry.key;
              final timeslots = entry.value;
              
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _timeslotService.formatDateForDisplay(date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: timeslots.map((timeSlot) {
                        final isSelected = viewModel.selectedTimeSlot?.id == timeSlot.id;
                        
                        return GestureDetector(
                          onTap: () {
                            viewModel.setSelectedTimeSlot(timeSlot);
                            viewModel.setSelectedDate(timeSlot.date);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              timeSlot.timeRange,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }).toList()),
            
            if (viewModel.selectedTimeSlot != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.selectedDealMethod == DealMethod.inCampusMeetup
                            ? 'Meetup scheduled: ${_timeslotService.formatDateForDisplay(viewModel.selectedTimeSlot!.date)} at ${viewModel.selectedTimeSlot!.timeRange}'
                            : 'Delivery scheduled: ${_timeslotService.formatDateForDisplay(viewModel.selectedTimeSlot!.date)} at ${viewModel.selectedTimeSlot!.timeRange}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}