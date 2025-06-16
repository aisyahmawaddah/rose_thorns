import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String email;
  String? displayName;
  String? universityName;
  String? role;
  String? studentType;
  String? profileImageUrl;
  bool? emailVerified;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.universityName,
    this.role,
    this.studentType,
    this.profileImageUrl,
    this.emailVerified,
    this.createdAt,
    this.updatedAt, DateTime? dateCreated,
  });

  // For backward compatibility
  DateTime? get dateCreated => createdAt;

  // Convert Firestore document to UserModel - FIXED to match your actual data
  static UserModel fromMap(Map<String, dynamic> data, String id) {
    try {
      DateTime? createdDate;
      DateTime? updatedDate;
      
      // Handle createdAt field
      if (data['createdAt'] != null) {
        if (data['createdAt'] is Timestamp) {
          createdDate = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is DateTime) {
          createdDate = data['createdAt'] as DateTime;
        }
      }
      
      // Handle updatedAt field
      if (data['updatedAt'] != null) {
        if (data['updatedAt'] is Timestamp) {
          updatedDate = (data['updatedAt'] as Timestamp).toDate();
        } else if (data['updatedAt'] is DateTime) {
          updatedDate = data['updatedAt'] as DateTime;
        }
      }
      
      return UserModel(
        id: id,
        email: data['email'] ?? '',
        displayName: data['displayName'],
        universityName: data['universityName'],
        role: data['role'], // Don't default to 'buyer' - keep actual value
        studentType: data['studentType'],
        profileImageUrl: data['profileImageUrl'],
        emailVerified: data['emailVerified'] ?? false,
        createdAt: createdDate,
        updatedAt: updatedDate,
      );
    } catch (e) {
      print('Error creating UserModel from map: $e');
      print('Problematic data: $data');
      
      // Return a basic model with minimal data if parsing fails
      return UserModel(
        id: id,
        email: data['email'] ?? 'unknown@email.com',
        displayName: data['displayName'] ?? 'Unknown User',
        role: data['role'] ?? 'graduate_student', // Default to actual role in your system
        universityName: data['universityName'],
        createdAt: DateTime.now(),
      );
    }
  }

  // Convert UserModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'universityName': universityName,
      'role': role,
      'studentType': studentType,
      'profileImageUrl': profileImageUrl,
      'emailVerified': emailVerified,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, role: $role, studentType: $studentType)';
  }

  // Helper method to get role display name
  String get roleDisplayName {
    switch (role) {
      case 'graduate_student':
        return 'Graduate Student';
      case 'admin':
        return 'Admin';
      case 'seller':
        return 'Seller';
      case 'buyer':
        return 'Buyer';
      default:
        return role?.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
        ).join(' ') ?? 'User';
    }
  }
}