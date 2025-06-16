// lib/data/model/time_slot_model.dart

// lib/data/model/time_slot_model.dart
class TimeSlot {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final String userId; // Changed from sellerId to userId

  TimeSlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    required this.userId, // Changed from sellerId to userId
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'userId': userId, // Changed from sellerId to userId
    };
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      isAvailable: json['isAvailable'] ?? true,
      userId: json['userId'], // Changed from sellerId to userId
    );
  }

  String get timeRange => '$startTime - $endTime';
}