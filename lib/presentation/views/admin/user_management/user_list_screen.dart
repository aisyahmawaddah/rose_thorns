import 'package:flutter/material.dart';
import 'package:koopon/data/models/user_model.dart';
import 'package:koopon/data/services/admin_service.dart';
import 'package:koopon/presentation/views/admin/user_management/user_detail_screen.dart';


class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, buyer, seller
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final users = await _adminService.getAllUsers();
      setState(() {
        _allUsers = users.cast<UserModel>();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredUsers = _allUsers.where((user) {
      // Apply role filter
      bool roleMatch = true;
      if (_selectedFilter != 'all') {
        roleMatch = user.role == _selectedFilter;
      }
      
      // Apply search filter
      bool searchMatch = true;
      if (_searchQuery.isNotEmpty) {
        searchMatch = user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                     (user.displayName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
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

  Future<void> _deleteUser(UserModel user) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.email}?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _adminService.deactivateUser(user.id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers(); // Refresh the list
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
          'User Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3066BE),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search users by email or name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filter Chips
                Row(
                  children: [
                    const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Users Count
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 8,
            ),
            color: Colors.grey[100],
            child: Text(
              'Showing ${_filteredUsers.length} of ${_allUsers.length} users',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
          
          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.separated(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          itemCount: _filteredUsers.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user, screenWidth);
                          },
                        ),
                      ),
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
      onSelected: (selected) => _onFilterChanged(value),
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF3066BE).withOpacity(0.2),
      checkmarkColor: const Color(0xFF3066BE),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF3066BE) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'No users found matching your criteria'
                : 'No users found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Try adjusting your search or filter'
                : 'Users will appear here once they register',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailScreen(user: user),
            ),
          ).then((_) => _loadUsers()); // Refresh list when returning
        },
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: screenWidth * 0.06,
                    backgroundColor: _getRoleColor(user.role ?? 'buyer').withOpacity(0.2),
                    child: Icon(
                      _getRoleIcon(user.role ?? 'buyer'),
                      color: _getRoleColor(user.role ?? 'buyer'),
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'No Name',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role ?? 'buyer').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getRoleColor(user.role ?? 'buyer').withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      (user.role ?? 'buyer').toUpperCase(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.025,
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(user.role ?? 'buyer'),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenWidth * 0.03),
              
              // User Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user.universityName != null) ...[
                          Text(
                            '🏫 ${user.universityName}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.01),
                        ],
                        Text(
                          '📅 Joined ${_formatDate(user.dateCreated)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.visibility,
                          color: Colors.blue[600],
                          size: screenWidth * 0.05,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailScreen(user: user),
                            ),
                          ).then((_) => _loadUsers());
                        },
                        tooltip: 'View Details',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[600],
                          size: screenWidth * 0.05,
                        ),
                        onPressed: () => _deleteUser(user),
                        tooltip: 'Delete User',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays > 59 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Today';
    }
  }
}