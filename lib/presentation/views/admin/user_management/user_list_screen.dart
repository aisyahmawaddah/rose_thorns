import 'package:flutter/material.dart';
import 'package:koopon/data/models/login_model.dart';
import 'package:koopon/data/services/admin_service.dart';
import 'package:koopon/presentation/views/admin/user_management/user_detail_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen>
    with TickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  List<LoginModel> _allUsers = [];
  List<LoginModel> _filteredUsers = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final users = await _adminService.getAllUsers();

      setState(() {
        _allUsers = users;
        _applyFilters();
        _isLoading = false;
      });

      _animationController?.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Error loading users: $e', isError: true);
      }
    }
  }

  void _applyFilters() {
    _filteredUsers = _allUsers.where((user) {
      bool roleMatch = true;
      if (_selectedFilter != 'all') {
        roleMatch = user.role == _selectedFilter;
      }

      bool searchMatch = true;
      if (_searchQuery.isNotEmpty) {
        searchMatch =
            user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (user.displayName
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false);
      }

      return roleMatch && searchMatch;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  Future<void> _deleteUser(LoginModel user) async {
    final confirmed = await _showDeleteConfirmationDialog(user);

    if (confirmed == true && user.id != null) {
      setState(() => _isLoading = true);

      try {
        final success = await _adminService.deactivateUser(user.id!);
        if (success) {
          await _loadUsers();
          if (mounted) {
            _showSnackBar('User ${user.email} has been deactivated');
          }
        } else {
          throw Exception('Failed to deactivate user');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          _showSnackBar('Error deleting user: $e', isError: true);
        }
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(LoginModel user) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: const Color(0xFFFFB4B4)),
            const SizedBox(width: 12),
            const Text('Delete User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${user.email}?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB4B4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
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
            ? const Color.fromARGB(255, 255, 101, 101)
            : const Color.fromARGB(255, 114, 255, 114),
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
                        child: Column(
                          children: [
                            _buildSearchAndFilters(),
                            _buildUsersList(),
                          ],
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
          const Text(
            'User Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 251, 251, 251),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: Color.fromARGB(255, 185, 144, 242)),
              onPressed: _loadUsers,
              tooltip: 'Refresh users',
            ),
          ),
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
            'Loading users...',
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

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by email or name...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 16),

          // Filter chips
          Row(
            children: [
              Text(
                'Filter by role:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Buyers', 'buyer'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Sellers', 'seller'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Admins', 'admin'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Results count
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Showing ${_filteredUsers.length} of ${_allUsers.length} users',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onFilterChanged(value),
      backgroundColor:
          const Color.fromARGB(255, 136, 136, 136).withOpacity(0.3),
      selectedColor: Colors.white.withOpacity(0.9),
      checkmarkColor: const Color(0xFFCBD5FF),
      labelStyle: TextStyle(
        color: isSelected
            ? const Color.fromARGB(255, 185, 161, 242)
            : Colors.white,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return Expanded(
      child: _filteredUsers.isEmpty
          ? _buildEmptyState()
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return _buildUserCard(user, index);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _allUsers.isEmpty ? 'No users found' : 'No users match your search',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _allUsers.isEmpty
                ? 'Users will appear here once they register'
                : 'Try adjusting your search or filter',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(LoginModel user, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildUserAvatar(user),
        title: Text(
          user.displayName?.isNotEmpty == true
              ? user.displayName!
              : 'No display name',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRoleBadge(user.role ?? 'buyer'),
                if (user.isActive == false) ...[
                  const SizedBox(width: 8),
                  _buildStatusBadge('INACTIVE', const Color(0xFFFFB4B4)),
                ],
              ],
            ),
          ],
        ),
        trailing: _buildUserMenu(user),
        onTap: () => _navigateToUserDetail(user),
      ),
    );
  }

  Widget _buildUserAvatar(LoginModel user) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getRoleColor(user.role ?? 'buyer'),
            _getRoleColor(user.role ?? 'buyer').withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getRoleColor(user.role ?? 'buyer').withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          (user.displayName?.isNotEmpty == true
                  ? user.displayName!.substring(0, 1)
                  : user.email.substring(0, 1))
              .toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(role),
        borderRadius: BorderRadius.circular(12),
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
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildUserMenu(LoginModel user) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'view':
            _navigateToUserDetail(user);
            break;
          case 'delete':
            _deleteUser(user);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_rounded, color: const Color(0xFFB4D4FF)),
              const SizedBox(width: 12),
              const Text('View Details'),
            ],
          ),
        ),
        // PopupMenuItem(
        //   value: 'delete',
        //   child: Row(
        //     children: [
        //       Icon(Icons.person_remove_rounded, color: const Color(0xFFFFB4B4)),
        //       const SizedBox(width: 12),
        //       Text(
        //         'Deactivate',
        //         style: TextStyle(color: const Color(0xFFFFB4B4)),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  void _navigateToUserDetail(LoginModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(user: user),
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
