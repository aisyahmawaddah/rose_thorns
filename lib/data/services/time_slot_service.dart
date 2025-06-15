// lib/data/services/timeslot_service.dart
import '../models/time_slot_model.dart';
import 'package:intl/intl.dart';

class TimeslotService {
  /// Converts weekly timeslots from item to specific date TimeSlot objects
  List<TimeSlot> convertWeeklyToSpecificTimeslots({
    required String itemId,
    required String sellerId,
    required Map<String, dynamic> weeklyTimeslots,
    int weeksAhead = 4, // Generate timeslots for next 4 weeks
  }) {
    final List<TimeSlot> specificTimeslots = [];
    final now = DateTime.now();
    
    // Map day names to weekday numbers
    final Map<String, int> dayToWeekday = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };
    
    // Generate timeslots for the next few weeks
    for (int week = 0; week < weeksAhead; week++) {
      weeklyTimeslots.forEach((dayName, timeSlots) {
        final weekday = dayToWeekday[dayName.toLowerCase()];
        if (weekday == null) return;
        
        // Calculate the next occurrence of this weekday
        final daysUntilTarget = (weekday - now.weekday + 7) % 7;
        final targetDate = now.add(Duration(days: daysUntilTarget + (week * 7)));
        
        // Skip dates that are in the past
        if (targetDate.isBefore(now.subtract(Duration(days: 1)))) return;
        
        if (timeSlots is List) {
          for (String timeSlot in timeSlots) {
            try {
              final timeSlotObj = _parseTimeSlot(
                id: '${itemId}_${DateFormat('yyyyMMdd').format(targetDate)}_${timeSlot.replaceAll(' ', '').replaceAll(':', '')}',
                date: targetDate,
                timeSlot: timeSlot,
                sellerId: sellerId,
              );
              
              if (timeSlotObj != null) {
                specificTimeslots.add(timeSlotObj);
              }
            } catch (e) {
              print('Error parsing timeslot: $timeSlot - $e');
            }
          }
        }
      });
    }
    
    // Sort by date and time
    specificTimeslots.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      return a.startTime.compareTo(b.startTime);
    });
    
    return specificTimeslots;
  }
  
  /// Parse a time string like "9:00 AM" to create a TimeSlot object
  TimeSlot? _parseTimeSlot({
    required String id,
    required DateTime date,
    required String timeSlot,
    required String sellerId,
  }) {
    try {
      // Parse time like "9:00 AM" or "2:30 PM"
      final timeFormat = DateFormat('h:mm a');
      final parsedTime = timeFormat.parse(timeSlot.trim());
      
      // Create start and end times (assuming 1-hour slots)
      final startTime = timeSlot.trim();
      final endDateTime = DateTime(
        parsedTime.year,
        parsedTime.month,
        parsedTime.day,
        parsedTime.hour + 1,
        parsedTime.minute,
      );
      final endTime = timeFormat.format(endDateTime);
      
      return TimeSlot(
        id: id,
        date: DateTime(date.year, date.month, date.day), // Date only, no time
        startTime: startTime,
        endTime: endTime,
        isAvailable: true,
        userId: sellerId,
      );
    } catch (e) {
      print('Error parsing time slot: $timeSlot - $e');
      return null;
    }
  }
  
  /// Get available timeslots for a specific item
  Future<List<TimeSlot>> getAvailableTimeslotsForItem(String itemId) async {
    try {
      // This would typically fetch from your database
      // For now, returning empty list - you'll need to implement based on your data structure
      
      // Example implementation:
      // 1. Fetch item from database
      // 2. Extract meetup_timeslots from additionalFields
      // 3. Convert using convertWeeklyToSpecificTimeslots
      
      return [];
    } catch (e) {
      print('Error fetching timeslots for item $itemId: $e');
      return [];
    }
  }
  
  /// Group timeslots by date for easier display
  Map<DateTime, List<TimeSlot>> groupTimeslotsByDate(List<TimeSlot> timeslots) {
    final Map<DateTime, List<TimeSlot>> grouped = {};
    
    for (final slot in timeslots) {
      final dateKey = DateTime(slot.date.year, slot.date.month, slot.date.day);
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(slot);
    }
    
    return grouped;
  }
  
  /// Format date for display
  String formatDateForDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) {
      return 'Today, ${DateFormat('MMM d').format(date)}';
    } else if (targetDate == tomorrow) {
      return 'Tomorrow, ${DateFormat('MMM d').format(date)}';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }
}