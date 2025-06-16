import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  String id;
  String email;
  String? displayName;
  String role;
  DateTime? dateCreated;
  List<String> permissions;
  bool isActive;
  DateTime? lastLoginAt;

  AdminModel({
    required this.id,
    required this.email,
    this.displayName,
    this.role = 'admin',
    this.dateCreated,
    this.permissions = const [
      'user_management',
      'item_management',
      'admin_dashboard',
    ],
    this.isActive = true,
    this.lastLoginAt,
  });

  // Convert Firestore document to AdminModel
  static AdminModel fromMap(Map<String, dynamic> data, String id) {
    return AdminModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      role: data['role'] ?? 'admin',
      dateCreated: data['dateCreated'] != null
          ? (data['dateCreated'] as Timestamp).toDate()
          : null,
      permissions: List<String>.from(
        data['permissions'] ??
            ['user_management', 'item_management', 'admin_dashboard'],
      ),
      isActive: data['isActive'] ?? true,
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert AdminModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'dateCreated': dateCreated != null
          ? Timestamp.fromDate(dateCreated!)
          : FieldValue.serverTimestamp(),
      'permissions': permissions,
      'isActive': isActive,
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
    };
  }

  // Copy with method for state updates
  AdminModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? role,
    DateTime? dateCreated,
    List<String>? permissions,
    bool? isActive,
    DateTime? lastLoginAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      dateCreated: dateCreated ?? this.dateCreated,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  // Check if admin has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  // Check if admin can manage users
  bool canManageUsers() {
    return hasPermission('user_management');
  }

  // Check if admin can manage items
  bool canManageItems() {
    return hasPermission('item_management');
  }

  // Check if admin can access dashboard
  bool canAccessDashboard() {
    return hasPermission('admin_dashboard');
  }
}

// Admin dashboard statistics model
class AdminDashboardModel {
  int totalUsers;
  int totalBuyers;
  int totalSellers;
  int totalItems;
  int totalActiveItems;
  int totalPendingItems;
  int totalSoldItems;
  double totalRevenue;
  int todayRegistrations;
  int todayItemsAdded;
  int todayTransactions;
  DateTime lastUpdated;

  AdminDashboardModel({
    this.totalUsers = 0,
    this.totalBuyers = 0,
    this.totalSellers = 0,
    this.totalItems = 0,
    this.totalActiveItems = 0,
    this.totalPendingItems = 0,
    this.totalSoldItems = 0,
    this.totalRevenue = 0.0,
    this.todayRegistrations = 0,
    this.todayItemsAdded = 0,
    this.todayTransactions = 0,
    required this.lastUpdated,
  });

  // Convert from Firestore document
  static AdminDashboardModel fromMap(Map<String, dynamic> data) {
    return AdminDashboardModel(
      totalUsers: data['totalUsers'] ?? 0,
      totalBuyers: data['totalBuyers'] ?? 0,
      totalSellers: data['totalSellers'] ?? 0,
      totalItems: data['totalItems'] ?? 0,
      totalActiveItems: data['totalActiveItems'] ?? 0,
      totalPendingItems: data['totalPendingItems'] ?? 0,
      totalSoldItems: data['totalSoldItems'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0.0).toDouble(),
      todayRegistrations: data['todayRegistrations'] ?? 0,
      todayItemsAdded: data['todayItemsAdded'] ?? 0,
      todayTransactions: data['todayTransactions'] ?? 0,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'totalBuyers': totalBuyers,
      'totalSellers': totalSellers,
      'totalItems': totalItems,
      'totalActiveItems': totalActiveItems,
      'totalPendingItems': totalPendingItems,
      'totalSoldItems': totalSoldItems,
      'totalRevenue': totalRevenue,
      'todayRegistrations': todayRegistrations,
      'todayItemsAdded': todayItemsAdded,
      'todayTransactions': todayTransactions,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Copy with method
  AdminDashboardModel copyWith({
    int? totalUsers,
    int? totalBuyers,
    int? totalSellers,
    int? totalItems,
    int? totalActiveItems,
    int? totalPendingItems,
    int? totalSoldItems,
    double? totalRevenue,
    int? todayRegistrations,
    int? todayItemsAdded,
    int? todayTransactions,
    DateTime? lastUpdated,
  }) {
    return AdminDashboardModel(
      totalUsers: totalUsers ?? this.totalUsers,
      totalBuyers: totalBuyers ?? this.totalBuyers,
      totalSellers: totalSellers ?? this.totalSellers,
      totalItems: totalItems ?? this.totalItems,
      totalActiveItems: totalActiveItems ?? this.totalActiveItems,
      totalPendingItems: totalPendingItems ?? this.totalPendingItems,
      totalSoldItems: totalSoldItems ?? this.totalSoldItems,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      todayRegistrations: todayRegistrations ?? this.todayRegistrations,
      todayItemsAdded: todayItemsAdded ?? this.todayItemsAdded,
      todayTransactions: todayTransactions ?? this.todayTransactions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
