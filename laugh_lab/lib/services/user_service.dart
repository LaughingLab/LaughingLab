import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/models/user_model.dart';
import 'package:path/path.dart' as path;

class UserService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Get the current user ID or empty string if not logged in
  String get currentUserId => _auth.currentUser?.uid ?? '';
  
  // Check if a user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
  
  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }
  
  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    if (!isLoggedIn) return null;
    return getUserById(currentUserId);
  }
  
  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? username,
  }) async {
    if (!isLoggedIn) return;
    
    try {
      // Check if username is unique if provided
      if (username != null && username.isNotEmpty) {
        final usernameQuery = await _firestore
            .collection(AppConstants.usersCollection)
            .where('username', isEqualTo: username)
            .get();
        
        if (usernameQuery.docs.isNotEmpty) {
          // Check if the username belongs to the current user
          if (usernameQuery.docs.first.id != currentUserId) {
            throw Exception('Username already taken');
          }
        }
      }
      
      // Update Firebase Auth display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await _auth.currentUser!.updateDisplayName(displayName);
      }
      
      // Update Firestore profile
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      
      if (displayName != null && displayName.isNotEmpty) {
        updateData['displayName'] = displayName;
      }
      
      if (username != null && username.isNotEmpty) {
        updateData['username'] = username;
      }
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update(updateData);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }
  
  // Upload profile picture
  Future<String?> uploadProfilePicture(File imageFile) async {
    if (!isLoggedIn) return null;
    
    try {
      // Create a reference to the user's profile image
      final storageRef = _storage
          .ref()
          .child('profile_pictures')
          .child('${currentUserId}_${path.basename(imageFile.path)}');
      
      // Upload the file
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update the user's profile
      await _auth.currentUser!.updatePhotoURL(downloadUrl);
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update({
        'photoUrl': downloadUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      notifyListeners();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      return null;
    }
  }
  
  // Get user stats
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get total jokes posted
      final jokesQuery = await _firestore
          .collection(AppConstants.jokesCollection)
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      
      final totalJokes = jokesQuery.count;
      
      // Get total upvotes received
      final jokesDocs = await _firestore
          .collection(AppConstants.jokesCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      int totalUpvotes = 0;
      for (final doc in jokesDocs.docs) {
        final joke = doc.data();
        totalUpvotes += joke['upvotes'] as int;
      }
      
      // Get total remixes
      final remixesQuery = await _firestore
          .collection(AppConstants.remixesCollection)
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      
      final totalRemixes = remixesQuery.count;
      
      return {
        'totalJokes': totalJokes,
        'totalUpvotes': totalUpvotes,
        'totalRemixes': totalRemixes,
      };
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return {
        'totalJokes': 0,
        'totalUpvotes': 0,
        'totalRemixes': 0,
      };
    }
  }
  
  // Save user preferred categories
  Future<void> saveUserPreferredCategories(List<String> categories) async {
    if (!isLoggedIn) return;
    
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update({
        'preferredCategories': categories,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving preferred categories: $e');
    }
  }
  
  // Update user points
  Future<void> updateUserPoints({
    required String userId, 
    required int points,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'points': FieldValue.increment(points),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user points: $e');
    }
  }
} 