import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get the current user stream from Firebase Auth
  Stream<User?> get user => _auth.authStateChanges();
  
  // Get the current Firebase user
  User? get currentUser => _auth.currentUser;
  
  // Get the current user ID or empty string if not logged in
  String get currentUserId => _auth.currentUser?.uid ?? '';
  
  // Check if a user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create a new user document in Firestore
      final user = UserModel.fromFirebase(credential.user!.uid, email);
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toMap());
      
      notifyListeners();
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Get the current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    if (!isLoggedIn) return null;
    
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update the user's display name
  Future<void> updateDisplayName(String displayName) async {
    if (!isLoggedIn) return;
    
    try {
      await _auth.currentUser!.updateDisplayName(displayName);
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update({
        'displayName': displayName,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Update the user's points
  Future<void> updateUserPoints(int points) async {
    if (!isLoggedIn) return;
    
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update({
        'points': FieldValue.increment(points),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      rethrow;
    }
  }
} 