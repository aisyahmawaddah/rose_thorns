// views/order_request/timeslot_selection_screen.dart
import 'package:flutter/material.dart';
import 'order_summary_screen.dart';

class TimeslotSelectionScreen extends StatefulWidget {
  final Map<String, dynamic>? itemData;

  const TimeslotSelectionScreen({super.key, this.itemData});

  @override
  _TimeslotSelectionScreenState createState() =>
      _TimeslotSelectionScreenState();
}

class _TimeslotSelectionScreenState extends State<TimeslotSelectionScreen> {
  String? selectedSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choose A Timeslot',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Monday, 4 May
                  _buildDaySection('Mon, 4 May', ['12:00 PM', '2:30 PM']),
                  _buildDivider(),

                  // Tuesday, 5 May
                  _buildDaySection('Tues, 5 May', ['11:00 AM', '4:30 PM']),
                  _buildDivider(),

                  // Wednesday, 6 May
                  _buildDaySection('Wed, 6 May', ['6:00 PM']),
                  _buildDivider(),

                  // Thursday, 7 May
                  _buildDaySection('Thu, 7 May', ['8:00 PM']),
                  _buildDivider(),

                  // Friday, 8 May
                  _buildDaySection('Fri, 8 May', []),
                  _buildDivider(),

                  // Saturday, 9 May
                  _buildDaySection('Sat, 9 May', ['9:00 AM']),
                  _buildDivider(),

                  // Sunday, 10 May
                  _buildDaySection('Sun, 10 May', ['11:00 AM', '7:00 PM']),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedSlot != null
                    ? () {
                        // Create updated item data with selected timeslot
                        Map<String, dynamic> updatedItemData = {
                          ...?widget.itemData,
                          'selectedTimeslot': selectedSlot,
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderSummaryScreen(
                              itemData: updatedItemData,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedSlot != null
                      ? const Color(0xFF6B46C1)
                      : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color:
                        selectedSlot != null ? Colors.white : Colors.grey[500],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(String day, List<String> timeSlots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        if (timeSlots.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No available slots',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...timeSlots.map((slot) {
            final slotId = '${day}_$slot';
            final isSelected = selectedSlot == slotId;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSlot = slotId;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6B46C1)
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      slot,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6B46C1)
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF6B46C1),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: Colors.grey[200],
        thickness: 1,
      ),
    );
  }
}

// Add this main function to run this screen directly
void main() {
  runApp(MaterialApp(
    home: TimeslotSelectionScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
