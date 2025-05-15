import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String email;
  String? displayName;
  String? universityName;
  String? role;
  DateTime? dateCreated;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.universityName,
    this.role = 'buyer', // Default role
    this.dateCreated,
  });

  // Convert Firestore document to UserModel
  static Future<UserModel?> fromMap(Map<String, dynamic> data, String id) {
    try {
      return Future.value(UserModel(
        id: id,
        email: data['email'] ?? '',
        displayName: data['displayName'],
        universityName: data['universityName'],
        role: data['role'] ?? 'buyer',
        dateCreated: data['dateCreated'] != null
            ? (data['dateCreated'] as Timestamp).toDate()
            : null,
      ));
    } catch (e) {
      print('Error creating UserModel from map: $e');
      return Future.value(null);
    }
  }

  // Convert UserModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'universityName': universityName,
      'role': role,
      'dateCreated': dateCreated != null
          ? Timestamp.fromDate(dateCreated!)
          : FieldValue.serverTimestamp(),
    };
  }
}
