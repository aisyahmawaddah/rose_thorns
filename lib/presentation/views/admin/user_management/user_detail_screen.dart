import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koopon/data/models/login_model.dart';
import 'package:koopon/data/services/admin_service.dart';

class UserDetailScreen extends StatefulWidget {
  final LoginModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with TickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late LoginModel _user;
  bool _isLoading = false;
  bool _isEditing = false;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  final _displayNameController = TextEditingController();
  final _universityController = TextEditingController();
  String _selectedRole = 'buyer';

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _initializeControllers();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    _animationController?.forward();
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
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _updateUserRole(String newRole) async {
    if (newRole == _user.role) return;

    final confirmed = await _showRoleChangeDialog(newRole);

    if (confirmed == true && _user.id != null) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user.id!)
            .update({'role': newRole});

        setState(() {
          _user = _user.copyWith(role: newRole);
          _selectedRole = newRole;
          _isLoading = false;
        });

        if (mounted) {
          _showSnackBar('User role updated to ${newRole.toUpperCase()}');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          _showSnackBar('Error updating user role: $e', isError: true);
        }
      }
    }
  }

  Future<bool?> _showRoleChangeDialog(String newRole) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings,
                color: const Color.fromARGB(255, 185, 144, 242)),
            const SizedBox(width: 12),
            const Text('Change User Role'),
          ],
        ),
        content: Text(
          'Are you sure you want to change ${_user.email}\'s role from ${_user.role?.toUpperCase()} to ${newRole.toUpperCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 185, 144, 242),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserInfo() async {
    if (_user.id == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.id!)
          .update({
        'displayName': _displayNameController.text.trim(),
        'universityName': _universityController.text.trim(),
        'role': _selectedRole,
      });

      setState(() {
        _user = _user.copyWith(
          displayName: _displayNameController.text.trim(),
          universityName: _universityController.text.trim(),
          role: _selectedRole,
        );
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        _showSnackBar('User information updated successfully');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Error updating user info: $e', isError: true);
      }
    }
  }

  Future<void> _toggleUserStatus() async {
    if (_user.id == null) return;

    final newStatus = !(_user.isActive ?? true);
    final action = newStatus ? 'activate' : 'deactivate';

    final confirmed = await _showStatusChangeDialog(action);

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user.id!)
            .update({'isActive': newStatus});

        setState(() {
          _user = _user.copyWith(isActive: newStatus);
          _isLoading = false;
        });

        if (mounted) {
          _showSnackBar(
              'User ${newStatus ? 'activated' : 'deactivated'} successfully');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          _showSnackBar('Error updating user status: $e', isError: true);
        }
      }
    }
  }

  Future<bool?> _showStatusChangeDialog(String action) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              action == 'activate' ? Icons.check_circle : Icons.block,
              color: action == 'activate'
                  ? const Color.fromARGB(255, 180, 229, 180)
                  : const Color.fromARGB(255, 255, 180, 180),
            ),
            const SizedBox(width: 12),
            Text('${action.toUpperCase()} User'),
          ],
        ),
        content: Text('Are you sure you want to $action ${_user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'activate'
                  ? const Color.fromARGB(255, 180, 229, 180)
                  : const Color.fromARGB(255, 255, 180, 180),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color.fromARGB(255, 255, 180, 180)
            : const Color.fromARGB(255, 126, 255, 126),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 153, 167, 226), // Pastel blue
              Color.fromARGB(255, 165, 129, 195), // Pastel purple
              Color.fromARGB(255, 212, 146, 189), // Pastel pink
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : FadeTransition(
                        opacity: _fadeAnimation!,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildUserProfileCard(),
                              const SizedBox(height: 16),
                              _buildUserInformationCard(),
                              const SizedBox(height: 16),
                              _buildActionsCard(),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color.fromARGB(255, 185, 144, 242)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Spacer(),
          Text(
            _user.displayName ?? _user.email,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 251, 251, 251),
            ),
          ),
          const Spacer(),
          if (!_isEditing)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_rounded,
                    color: Color.fromARGB(255, 185, 144, 242)),
                onPressed: () => setState(() => _isEditing = true),
              ),
            ),
          if (_isEditing) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.save_rounded,
                    color: Color.fromARGB(255, 185, 144, 242)),
                onPressed: _isLoading ? null : _updateUserInfo,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.cancel_rounded,
                    color: Color.fromARGB(255, 185, 144, 242)),
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _initializeControllers();
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 24),
          Text(
            'Updating user...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Avatar and Basic Info
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getRoleColor(_user.role ?? 'buyer'),
                        _getRoleColor(_user.role ?? 'buyer').withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getRoleColor(_user.role ?? 'buyer')
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (_user.displayName?.isNotEmpty == true
                              ? _user.displayName!.substring(0, 1)
                              : _user.email.substring(0, 1))
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user.displayName ?? 'No display name',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Role and Status Badges
            Row(
              children: [
                _buildRoleBadge(_user.role ?? 'buyer'),
                const SizedBox(width: 12),
                _buildStatusBadge(
                  (_user.isActive ?? true) ? 'ACTIVE' : 'INACTIVE',
                  (_user.isActive ?? true)
                      ? const Color.fromARGB(255, 180, 229, 180)
                      : const Color.fromARGB(255, 255, 180, 180),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInformationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),

            // Display Name Field
            _buildTextField(
              controller: _displayNameController,
              label: 'Display Name',
              icon: Icons.person_rounded,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),

            // University Name Field
            _buildTextField(
              controller: _universityController,
              label: 'University Name',
              icon: Icons.school_rounded,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),

            // Role Dropdown
            Container(
              decoration: BoxDecoration(
                color: _isEditing ? Colors.white : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      const Color.fromARGB(255, 185, 144, 242).withOpacity(0.3),
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(
                    Icons.admin_panel_settings_rounded,
                    color: const Color.fromARGB(255, 185, 144, 242),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                  DropdownMenuItem(value: 'seller', child: Text('Seller')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: _isEditing
                    ? (value) {
                        if (value != null) {
                          setState(() => _selectedRole = value);
                        }
                      }
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Account Info
            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Account Created',
              value: _user.dateCreated != null
                  ? '${_user.dateCreated!.day}/${_user.dateCreated!.month}/${_user.dateCreated!.year}'
                  : 'Unknown',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.fingerprint_rounded,
              label: 'User ID',
              value: _user.id ?? 'Unknown',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),

            // Toggle Status Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleUserStatus,
                icon: Icon(
                  (_user.isActive ?? true)
                      ? Icons.block_rounded
                      : Icons.check_circle_rounded,
                ),
                label: Text(
                  (_user.isActive ?? true)
                      ? 'Deactivate User'
                      : 'Activate User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_user.isActive ?? true)
                      ? const Color.fromARGB(255, 255, 21, 21)
                      : const Color.fromARGB(255, 82, 255, 82),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            if (!_isEditing) ...[
              const SizedBox(height: 20),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'Quick Role Change',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // Quick Role Change Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildRoleButton(
                      'Buyer',
                      'buyer',
                      const Color.fromARGB(255, 149, 195, 255),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRoleButton(
                      'Seller',
                      'seller',
                      const Color.fromARGB(255, 255, 189, 139),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRoleButton(
                      'Admin',
                      'admin',
                      const Color.fromARGB(255, 255, 144, 144),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 185, 144, 242).withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color.fromARGB(255, 185, 144, 242),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color.fromARGB(255, 185, 144, 242),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRoleColor(role),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getRoleColor(role).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRoleButton(String label, String role, Color color) {
    final isCurrentRole = _user.role == role;
    return ElevatedButton(
      onPressed: isCurrentRole ? null : () => _updateUserRole(role),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrentRole ? Colors.grey[300] : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color.fromARGB(255, 255, 144, 144); // Pastel red
      case 'seller':
        return const Color.fromARGB(255, 255, 189, 139); // Pastel orange
      case 'buyer':
      default:
        return const Color.fromARGB(255, 149, 195, 255); // Pastel blue
    }
  }
}
