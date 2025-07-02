import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koopon/data/services/supabase_image_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ADD THIS IMPORT

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final SupabaseImageService _imageService = SupabaseImageService();

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
            // Use actual display name or derive from email, avoid 'User' default
            String displayName = freshUser.displayName ?? '';

            // If no display name is set, derive from email
            if (displayName.isEmpty && freshUser.email != null) {
              displayName = freshUser.email!.split('@')[0];
            }

            // Only use 'User' as absolute last resort if everything else fails
            if (displayName.isEmpty) {
              displayName = 'User';
            }

            _nameController.text = displayName;
            _emailController.text = freshUser.email ?? '';
          });

          print('👤 Loaded user data for editing:');
          print(
              '   - Display Name: "${freshUser.displayName ?? "Not set"}" -> TextField: "${_nameController.text}"');
          print('   - Email: "${freshUser.email ?? "Not set"}" -> TextField');
          print('   - Photo URL: ${freshUser.photoURL ?? "Not set"}');
        }
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      // Set defaults if loading fails
      if (mounted) {
        setState(() {
          final currentUser = _auth.currentUser;
          String fallbackName = '';

          // Try to get display name even in error case
          if (currentUser?.displayName != null &&
              currentUser!.displayName!.isNotEmpty) {
            fallbackName = currentUser.displayName!;
          } else if (currentUser?.email != null) {
            fallbackName = currentUser!.email!.split('@')[0];
          } else {
            fallbackName = 'User'; // Last resort only
          }

          _nameController.text = fallbackName;
          _emailController.text = currentUser?.email ?? '';
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
        maxWidth: 512,
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
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF473173)),
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
              // Profile Picture Section
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF9C27B0), width: 3),
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
                          child: _buildProfileImage(),
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
                              _selectedImage != null ||
                                      _auth.currentUser?.photoURL != null
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

              // Image status text
              if (_selectedImage != null)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF9C27B0).withOpacity(0.3)),
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

              // Display Name Field
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    border: InputBorder.none,
                    hintText: 'Enter your display name',
                  ),
                ),
              ),

              // Email Field (Read-only)
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    border: InputBorder.none,
                    hintText: 'Email cannot be changed',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Text
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

              // Save Button
              Center(
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isLoading ? Colors.grey : const Color(0xFF8BC34A),
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
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

  // Build profile image widget
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

  // INTEGRATED: Updated Firestore user info method
  Future<void> _updateUserInfo() async {
    final user = _auth.currentUser;
    if (user?.uid == null) return;

    setState(() => _isLoading = true);

    try {
      // Update Firestore user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'displayName': _nameController.text.trim(),
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showSuccessSnackBar('User information updated successfully');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Error updating user info: $e');
      }
    }
  }

  // IMPROVED: Enhanced save profile with Firestore integration
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
        _showErrorSnackBar('User not found. Please log in again.');
        return;
      }

      print('🚀 Starting profile update process...');
      print('   - Current user: ${user.email}');
      print('   - New display name: "${_nameController.text.trim()}"');
      print('   - Has new image: ${_selectedImage != null}');

      String? newPhotoURL = user.photoURL;
      bool imageUploadSuccess = true;

      // Step 1: Handle profile image upload first (if selected)
      if (_selectedImage != null) {
        try {
          print('📸 Uploading profile image to Supabase...');
          newPhotoURL =
              await _imageService.uploadProfileImage(_selectedImage!, user.uid);

          if (newPhotoURL == null) {
            throw Exception('Image upload returned null URL');
          }
          print('✅ Image uploaded successfully: $newPhotoURL');
        } catch (imageError) {
          print('❌ Image upload failed: $imageError');
          imageUploadSuccess = false;
          _showErrorSnackBar(
              'Failed to upload profile picture. Saving name only.');
        }
      }

      // Step 2: Update Firebase Auth
      bool displayNameUpdated = false;
      bool photoURLUpdated = false;

      // Update Display Name in Firebase Auth
      try {
        print('📝 Updating Firebase Auth display name...');
        await user.updateDisplayName(_nameController.text.trim());
        displayNameUpdated = true;
        print('✅ Firebase Auth display name updated successfully');
      } catch (nameError) {
        print('❌ Firebase Auth display name update failed: $nameError');
      }

      // Update Photo URL in Firebase Auth (only if image was uploaded successfully)
      if (imageUploadSuccess && _selectedImage != null && newPhotoURL != null) {
        try {
          print('📷 Updating Firebase Auth photo URL...');
          await user.updatePhotoURL(newPhotoURL);
          photoURLUpdated = true;
          print('✅ Firebase Auth photo URL updated successfully');
        } catch (photoError) {
          print('⚠️ Firebase Auth photo URL update failed: $photoError');
        }
      }

      // Step 3: Update Firestore user document
      try {
        print('📝 Updating Firestore user document...');
        final updateData = {
          'displayName': _nameController.text.trim(),
          'email': user.email ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add photo URL to Firestore if available
        if (newPhotoURL != null) {
          updateData['photoURL'] = newPhotoURL;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(updateData);

        print('✅ Firestore user document updated successfully');
      } catch (firestoreError) {
        print('⚠️ Firestore update failed: $firestoreError');
        // Continue - Firestore update failure shouldn't block the entire operation
      }

      // Step 4: Reload user data
      try {
        print('🔄 Reloading user data...');
        await user.reload();
        print('✅ User data reloaded');
      } catch (reloadError) {
        print('⚠️ User reload failed: $reloadError');
      }

      // Step 5: Show appropriate success message
      String successMessage = 'Profile updated successfully!';

      if (displayNameUpdated && imageUploadSuccess && photoURLUpdated) {
        successMessage = 'Profile and picture updated successfully!';
      } else if (displayNameUpdated &&
          !photoURLUpdated &&
          _selectedImage != null) {
        successMessage =
            'Profile updated! Picture uploaded but may take time to sync.';
      } else if (displayNameUpdated) {
        successMessage = 'Profile name updated successfully!';
      }

      _showSuccessSnackBar(successMessage);

      // Step 6: Wait and navigate back
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('❌ Profile update failed: $e');

      // Show user-friendly error message
      String errorMessage = 'Failed to update profile';

      if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'Please log out and log back in to update your profile.';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. Please try logging in again.';
      } else if (e.toString().contains('user-disabled')) {
        errorMessage = 'Your account has been disabled. Contact support.';
      } else {
        final String fullError = e.toString();
        if (fullError.startsWith('Exception: ')) {
          errorMessage = fullError.substring(11);
        } else {
          errorMessage = 'Update failed. Please try again.';
        }
      }

      _showErrorSnackBar(errorMessage);
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
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
