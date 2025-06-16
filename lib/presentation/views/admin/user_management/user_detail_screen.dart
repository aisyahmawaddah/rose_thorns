import 'package:flutter/material.dart';
import 'package:koopon/data/models/user_model.dart';
import 'package:koopon/data/services/admin_service.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final AdminService _adminService = AdminService();
  late UserModel _user;
  bool _isLoading = false;
  bool _isEditing = false;
  
  final _displayNameController = TextEditingController();
  final _universityController = TextEditingController();
  String _selectedRole = 'buyer';

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _initializeControllers();
  }

  void _initializeControllers() {
    _displayNameController.text = _user.displayName ?? '';
    _universityController.text = _user.universityName ?? '';
    _selectedRole = _user.role ?? 'buyer';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  Future<void> _updateUserRole(String newRole) async {
    if (newRole == _user.role) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Text(
          'Are you sure you want to change ${_user.email}\'s role from ${_user.role?.toUpperCase()} to ${newRole.toUpperCase()}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Change Role'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        final success = await _adminService.updateUserRole(_user.id, newRole);
        if (success) {
          setState(() {
            _user = UserModel(
              id: _user.id,
              email: _user.email,
              displayName: _user.displayName,
              universityName: _user.universityName,
              role: newRole,
              dateCreated: _user.dateCreated,
            );
            _selectedRole = newRole;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User role updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to update user role');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this user?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ This action will:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Permanently deactivate the user account\n• Remove access to the application\n• This action cannot be undone',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete User', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        final success = await _adminService.deactivateUser(_user.id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Return to user list
        } else {
          throw Exception('Failed to delete user');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'User Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3066BE),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteUser();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Card
                  _buildProfileCard(screenWidth),
                  SizedBox(height: screenWidth * 0.04),
                  
                  // User Information Card
                  _buildUserInfoCard(screenWidth),
                  SizedBox(height: screenWidth * 0.04),
                  
                  // Role Management Card
                  _buildRoleManagementCard(screenWidth),
                  SizedBox(height: screenWidth * 0.04),
                  
                  // Account Actions Card
                  _buildAccountActionsCard(screenWidth),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getRoleColor(_user.role ?? 'buyer').withOpacity(0.8),
              _getRoleColor(_user.role ?? 'buyer'),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: screenWidth * 0.12,
              backgroundColor: Colors.white,
              child: Icon(
                _getRoleIcon(_user.role ?? 'buyer'),
                size: screenWidth * 0.12,
                color: _getRoleColor(_user.role ?? 'buyer'),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              _user.displayName ?? 'No Display Name',
              style: TextStyle(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              _user.email,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenWidth * 0.03),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Text(
                (_user.role ?? 'buyer').toUpperCase(),
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            
            _buildInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: _user.email,
              screenWidth: screenWidth,
            ),
            
            _buildInfoRow(
              icon: Icons.person,
              label: 'Display Name',
              value: _user.displayName ?? 'Not set',
              screenWidth: screenWidth,
            ),
            
            _buildInfoRow(
              icon: Icons.school,
              label: 'University',
              value: _user.universityName ?? 'Not specified',
              screenWidth: screenWidth,
            ),
            
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Registration Date',
              value: _formatDetailedDate(_user.dateCreated),
              screenWidth: screenWidth,
            ),
            
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Account Age',
              value: _calculateAccountAge(_user.dateCreated),
              screenWidth: screenWidth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required double screenWidth,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: screenWidth * 0.05,
            color: const Color(0xFF3066BE),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenWidth * 0.005),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: const Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleManagementCard(double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role Management',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            
            Text(
              'Current Role: ${(_user.role ?? 'buyer').toUpperCase()}',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            
            // Role Selection
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Role:',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleButton(
                          'buyer',
                          'Buyer',
                          Icons.person,
                          Colors.blue,
                          screenWidth,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: _buildRoleButton(
                          'seller',
                          'Seller',
                          Icons.store,
                          Colors.orange,
                          screenWidth,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    String role,
    String label,
    IconData icon,
    Color color,
    double screenWidth,
  ) {
    final isSelected = _user.role == role;
    
    return InkWell(
      onTap: () => _updateUserRole(role),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.03,
          horizontal: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: screenWidth * 0.06,
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: screenWidth * 0.005),
              Icon(
                Icons.check_circle,
                color: color,
                size: screenWidth * 0.04,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActionsCard(double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Actions',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            
            // Delete Account Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _deleteUser,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete User Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            
            // Warning Text
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red[600],
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      'Deleting a user account is permanent and cannot be undone. The user will lose access to the application immediately.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.red[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'seller':
        return Colors.orange;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'seller':
        return Icons.store;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  String _formatDetailedDate(DateTime? date) {
    if (date == null) return 'Unknown';
    
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _calculateAccountAge(DateTime? date) {
    if (date == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} old';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} old';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} old';
    } else {
      return 'Less than a day old';
    }
  }
}