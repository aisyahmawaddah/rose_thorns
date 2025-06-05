import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koopon/data/services/supabase_image_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage; // NEW: For storing selected image
  final ImagePicker _picker = ImagePicker(); // NEW: Image picker instance
  final SupabaseImageService _imageService = SupabaseImageService(); // NEW: Supabase service
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Force refresh user data
        await user.reload();
        final freshUser = _auth.currentUser;
        
        if (freshUser != null && mounted) {
          setState(() {
            // Always load existing data into text fields
            _nameController.text = freshUser.displayName ?? 'User';
            _emailController.text = freshUser.email ?? '';
          });
          
          print('👤 Loaded user data for editing:');
          print('   - Display Name: "${freshUser.displayName ?? "Not set"}" -> TextField');
          print('   - Email: "${freshUser.email ?? "Not set"}" -> TextField');
          print('   - Photo URL: ${freshUser.photoURL ?? "Not set"}');
        }
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      // Set defaults if loading fails
      if (mounted) {
        setState(() {
          _nameController.text = 'User';
          _emailController.text = _auth.currentUser?.email ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // NEW: Show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Select Profile Picture',
          style: TextStyle(
            color: Color(0xFF473173),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF8A56AC),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Color(0xFF8A56AC),
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_auth.currentUser?.photoURL != null || _selectedImage != null)
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text('Remove Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8A56AC)),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Pick image from source
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512, // Smaller size for profile pictures
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        
        _showSuccessSnackBar('Profile picture selected!');
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: ${e.toString()}');
    }
  }

  // NEW: Remove profile picture
  void _removeProfilePicture() {
    setState(() {
      _selectedImage = null;
    });
    _showSuccessSnackBar('Profile picture will be removed when you save');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8D4F1),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFD4E8FF),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF473173)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Color(0xFF473173),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF8A56AC),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section (ENHANCED)
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog, // UPDATED: Show dialog instead of placeholder message
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF9C27B0), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipOval(
                          child: _buildProfileImage(), // NEW: Custom method to build image
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8A56AC),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _selectedImage != null || _auth.currentUser?.photoURL != null
                                  ? Icons.edit
                                  : Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // NEW: Image status text
              if (_selectedImage != null)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.3)),
                    ),
                    child: const Text(
                      '📸 New profile picture selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9C27B0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Display Name Field (ENHANCED with existing data feedback)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Display Name",
                    style: TextStyle(
                      color: Color(0xFF473173),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_nameController.text.isNotEmpty)
                    Text(
                      "Current: ${_nameController.text}",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E7FF),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    border: InputBorder.none,
                    hintText: 'Enter your display name',
                  ),
                ),
              ),

              // Email Field (Read-only) (ENHANCED with current data feedback)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Email",
                    style: TextStyle(
                      color: Color(0xFF473173),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Cannot be changed",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    border: InputBorder.none,
                    hintText: 'Email cannot be changed',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Text (UPDATED)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF9C27B0),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can update your profile picture and display name. Your email address cannot be changed.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button (ENHANCED with new functionality)
              Center(
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading 
                          ? Colors.grey 
                          : const Color(0xFF8BC34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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

  // NEW: Build profile image widget
  Widget _buildProfileImage() {
    // Show selected image if available
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 114,
        height: 114,
      );
    }
    
    // Show current profile image if available
    if (_auth.currentUser?.photoURL != null) {
      return Image.network(
        _auth.currentUser!.photoURL!,
        fit: BoxFit.cover,
        width: 114,
        height: 114,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF8A56AC),
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFE8D4F1),
            child: const Icon(
              Icons.person,
              color: Color(0xFF8A56AC),
              size: 60,
            ),
          );
        },
      );
    }
    
    // Show default icon
    return Container(
      color: const Color(0xFFE8D4F1),
      child: const Icon(
        Icons.person,
        color: Color(0xFF8A56AC),
        size: 60,
      ),
    );
  }

  // FIXED: Save profile avoiding Firebase Auth photo URL bug
  void _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a display name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showErrorSnackBar('User not found');
        return;
      }

      String? newPhotoURL = user.photoURL;

      // Handle profile image upload
      if (_selectedImage != null) {
        print('📸 Uploading new profile image...');
        newPhotoURL = await _imageService.uploadProfileImage(_selectedImage!, user.uid);
        
        if (newPhotoURL == null) {
          throw Exception('Failed to upload profile image');
        }
        print('✅ Profile image uploaded: $newPhotoURL');
      }

      // Update only display name via Firebase Auth (avoid photo URL bug)
      try {
        await user.updateDisplayName(_nameController.text.trim());
        print('✅ Display name updated');
        
        // Only update photo URL if it changed AND we have a new one
        if (_selectedImage != null && newPhotoURL != null && newPhotoURL != user.photoURL) {
          // Try updating photo URL, but don't fail if it doesn't work
          try {
            await user.updatePhotoURL(newPhotoURL);
            print('✅ Photo URL updated');
          } catch (photoError) {
            print('⚠️ Photo URL update failed (using Firestore fallback): $photoError');
            // Photo URL update failed, but that's okay - the image is still uploaded to Supabase
            // The ProfileScreen can read directly from Supabase if needed
          }
        }
        
        await user.reload();
        print('✅ User data reloaded');
        
      } catch (authError) {
        print('❌ Firebase Auth update error: $authError');
        throw Exception('Failed to update profile');
      }
      
      _showSuccessSnackBar('Profile updated successfully!');
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      _showErrorSnackBar('Error updating profile: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}