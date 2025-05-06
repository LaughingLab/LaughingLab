import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laugh_lab/models/joke_model.dart';
import 'package:laugh_lab/models/user_model.dart';
import 'package:laugh_lab/services/auth_service.dart';
import 'package:laugh_lab/services/joke_service.dart';
import 'package:laugh_lab/services/user_service.dart';
import 'package:laugh_lab/widgets/joke_card.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isEditing = false;
  bool _isUpdatingPhoto = false;
  UserModel? _userData;
  Map<String, dynamic> _userStats = {'totalJokes': 0, 'totalUpvotes': 0};
  
  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final userService = Provider.of<UserService>(context, listen: false);
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image == null) return;
      
      setState(() {
        _isUpdatingPhoto = true;
      });
      
      final imageFile = File(image.path);
      final downloadUrl = await userService.uploadProfilePicture(imageFile);
      
      if (downloadUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile picture.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPhoto = false;
        });
      }
    }
  }
  
  Future<void> _loadUserStats() async {
    if (_userData == null) return;
    
    final userService = Provider.of<UserService>(context, listen: false);
    final stats = await userService.getUserStats(_userData!.id);
    
    if (mounted) {
      setState(() {
        _userStats = stats;
      });
    }
  }
  
  Future<void> _updateProfile() async {
    if (_displayNameController.text.trim().isEmpty && 
        _usernameController.text.trim().isEmpty) {
      return;
    }
    
    final userService = Provider.of<UserService>(context, listen: false);
    
    try {
      await userService.updateUserProfile(
        displayName: _displayNameController.text.trim().isNotEmpty
            ? _displayNameController.text.trim()
            : null,
        username: _usernameController.text.trim().isNotEmpty
            ? _usernameController.text.trim()
            : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final jokeService = Provider.of<JokeService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: userService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          _userData = snapshot.data;
          if (_userData == null) {
            return const Center(
              child: Text('User data not found. Please log out and try again.'),
            );
          }

          // Load user stats only after user data is available
          // and only if stats haven't been loaded yet or user data changed.
          // This check might need refinement depending on how often stats should refresh.
          if (_userStats['totalJokes'] == 0 && _userStats['totalUpvotes'] == 0) { // Basic check
            _loadUserStats();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info card
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Profile picture with upload option
                        Stack(
                          children: [
                            // Profile image
                            _isUpdatingPhoto
                                ? const CircularProgressIndicator()
                                : GestureDetector(
                                    onTap: _pickImage,
                                    child: CircleAvatar(
                                      radius: AppTheme.avatarSizeLarge / 2,
                                      backgroundColor: AppTheme.primaryColor,
                                      backgroundImage: _userData!.photoUrl != null
                                          ? CachedNetworkImageProvider(_userData!.photoUrl!)
                                          : null,
                                      child: _userData!.photoUrl == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                            
                            // Edit icon
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: _isUpdatingPhoto ? null : _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Display name
                        _isEditing
                            ? Column(
                                children: [
                                  TextField(
                                    controller: _displayNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Display Name',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      hintText: 'Choose a unique username',
                                      helperText: 'Between ${AppConstants.minUsernameLength}-${AppConstants.maxUsernameLength} characters',
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLength: AppConstants.maxUsernameLength,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Text(
                                    _userData!.displayName ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_userData!.username != null)
                                    Text(
                                      '@${_userData!.username}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.secondaryColor,
                                      ),
                                    ),
                                ],
                              ),
                        const SizedBox(height: 8),
                        
                        // Email
                        Text(
                          _userData!.email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // User stats (points, jokes, upvotes)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Points
                            _buildStatContainer(
                              '${_userData!.points}',
                              'Points',
                              Icons.star,
                              AppTheme.primaryColor,
                            ),
                            
                            // Jokes posted
                            _buildStatContainer(
                              '${_userStats['totalJokes']}',
                              'Jokes',
                              Icons.emoji_emotions,
                              AppTheme.accentColor,
                            ),
                            
                            // Upvotes received
                            _buildStatContainer(
                              '${_userStats['totalUpvotes']}',
                              'Upvotes',
                              Icons.thumb_up,
                              AppTheme.secondaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Edit profile button
                        _isEditing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = false;
                                      });
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: _updateProfile,
                                    child: const Text('Save'),
                                  ),
                                ],
                              )
                            : ElevatedButton.icon(
                                onPressed: () {
                                  _displayNameController.text = _userData!.displayName ?? '';
                                  _usernameController.text = _userData!.username ?? '';
                                  setState(() {
                                    _isEditing = true;
                                  });
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Profile'),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Category preferences
                if (_userData!.preferredCategories.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Favorite Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to category selection screen
                        },
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _userData!.preferredCategories.length,
                      itemBuilder: (context, index) {
                        final category = _userData!.preferredCategories[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.categoryColors[index % AppTheme.categoryColors.length],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // My jokes section
                const Text(
                  'My Jokes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Jokes list
                Expanded(
                  child: StreamBuilder<List<JokeModel>>(
                    stream: jokeService.getJokesByUser(_userData!.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      
                      final jokes = snapshot.data ?? [];
                      
                      if (jokes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.sentiment_neutral,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'You haven\'t posted any jokes yet.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to Create screen
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create a joke'),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: jokes.length,
                        itemBuilder: (context, index) {
                          final joke = jokes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: JokeCard(joke: joke),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatContainer(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
} 