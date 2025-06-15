// lib/data/model/address_model.dart
class Address {
  final String id;
  final String userId;
  final String title;
  final String address;
  final String? building;
  final String? room;
  final String? notes;
  final bool isDefault;
  final DateTime createdAt;

  Address({
    required this.id,
    required this.userId,
    required this.title,
    required this.address,
    this.building,
    this.room,
    this.notes,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'address': address,
      'building': building,
      'room': room,
      'notes': notes,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      address: json['address'],
      building: json['building'],
      room: json['room'],
      notes: json['notes'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get fullAddress {
    List<String> parts = [address];
    if (building != null && building!.isNotEmpty) {
      parts.add('Building: $building');
    }
    if (room != null && room!.isNotEmpty) {
      parts.add('Room: $room');
    }
    return parts.join(', ');
  }
}