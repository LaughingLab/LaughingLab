import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/models/joke_model.dart';
import 'package:laugh_lab/models/remix_model.dart';
import 'package:laugh_lab/models/user_model.dart';
import 'package:laugh_lab/services/auth_service.dart';
import 'package:laugh_lab/services/user_service.dart';

class RemixService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  final UserService _userService;
  
  RemixService(this._authService, this._userService);
  
  // Create a new remix
  Future<RemixModel> createRemix({
    required String parentJokeId,
    required String content,
  }) async {
    try {
      // Check if user is authenticated
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to create a remix');
      }
      
      // Get the parent joke to ensure it exists
      final jokeDoc = await _firestore
          .collection(AppConstants.jokesCollection)
          .doc(parentJokeId)
          .get();
      
      if (!jokeDoc.exists) {
        throw Exception('Parent joke not found');
      }
      
      // Get current user data
      final userData = await _userService.getCurrentUser();
      if (userData == null) {
        throw Exception('User data not found');
      }
      
      // Create a reference for the new remix
      final remixRef = _firestore
          .collection(AppConstants.remixesCollection)
          .doc();
      
      // Create the remix model
      final remix = RemixModel(
        id: remixRef.id,
        parentJokeId: parentJokeId,
        userId: currentUser.uid,
        content: content,
        upvotes: 0,
        downvotes: 0,
        createdAt: DateTime.now(),
        userDisplayName: userData.displayName ?? 'Anonymous',
        userPhotoUrl: userData.photoUrl,
        username: userData.username,
      );
      
      // Save the remix to Firestore
      await remixRef.set(remix.toMap());
      
      // Award points to the original joke creator
      final joke = JokeModel.fromMap(jokeDoc.data() as Map<String, dynamic>);
      if (joke.userId != currentUser.uid) {
        // Only award points if the remix is by a different user
        await _userService.updateUserPoints(
          userId: joke.userId,
          points: AppConstants.pointsForRemix,
        );
      }
      
      // Award points to the remix creator
      await _userService.updateUserPoints(
        userId: currentUser.uid,
        points: AppConstants.pointsForNewJoke,
      );
      
      notifyListeners();
      return remix;
    } catch (e) {
      debugPrint('Error creating remix: $e');
      rethrow;
    }
  }
  
  // Get remixes for a specific joke
  Stream<List<RemixModel>> getRemixesForJoke(String jokeId) {
    return _firestore
        .collection(AppConstants.remixesCollection)
        .where('parentJokeId', isEqualTo: jokeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RemixModel.fromMap(doc.data()))
              .toList();
        });
  }
  
  // Get all remixes (for the remix feed)
  Stream<List<RemixModel>> getAllRemixes() {
    return _firestore
        .collection(AppConstants.remixesCollection)
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit to the 50 most recent remixes
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RemixModel.fromMap(doc.data()))
              .toList();
        });
  }
  
  // Get top-rated remixes
  Stream<List<RemixModel>> getTopRatedRemixes() {
    return _firestore
        .collection(AppConstants.remixesCollection)
        .orderBy('upvotes', descending: true)
        .limit(50) // Limit to the 50 highest-rated remixes
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RemixModel.fromMap(doc.data()))
              .toList();
        });
  }
  
  // Get remixes created by a specific user
  Stream<List<RemixModel>> getRemixesByUser(String userId) {
    return _firestore
        .collection(AppConstants.remixesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RemixModel.fromMap(doc.data()))
              .toList();
        });
  }
  
  // Upvote a remix
  Future<void> upvoteRemix(String remixId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to vote');
      }
      
      final ratingRef = _firestore
          .collection(AppConstants.ratingsCollection)
          .doc('${currentUser.uid}_${remixId}');
      
      final ratingDoc = await ratingRef.get();
      
      final batch = _firestore.batch();
      
      if (ratingDoc.exists) {
        final data = ratingDoc.data() as Map<String, dynamic>;
        final isUpvote = data['isUpvote'] as bool? ?? false;
        
        if (isUpvote) {
          // User already upvoted, remove the upvote
          batch.delete(ratingRef);
          batch.update(
            _firestore.collection(AppConstants.remixesCollection).doc(remixId),
            {'upvotes': FieldValue.increment(-1)},
          );
        } else {
          // User previously downvoted, change to upvote
          batch.update(ratingRef, {'isUpvote': true});
          batch.update(
            _firestore.collection(AppConstants.remixesCollection).doc(remixId),
            {
              'upvotes': FieldValue.increment(1),
              'downvotes': FieldValue.increment(-1),
            },
          );
        }
      } else {
        // No previous vote, add an upvote
        batch.set(ratingRef, {
          'userId': currentUser.uid,
          'jokeId': null,
          'remixId': remixId,
          'isUpvote': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        batch.update(
          _firestore.collection(AppConstants.remixesCollection).doc(remixId),
          {'upvotes': FieldValue.increment(1)},
        );
        
        // Award points to the remix creator
        final remixDoc = await _firestore
            .collection(AppConstants.remixesCollection)
            .doc(remixId)
            .get();
        
        if (remixDoc.exists) {
          final remix = RemixModel.fromMap(remixDoc.data() as Map<String, dynamic>);
          if (remix.userId != currentUser.uid) {
            // Only award points if the upvote is from a different user
            await _userService.updateUserPoints(
              userId: remix.userId,
              points: AppConstants.pointsForUpvote,
            );
          }
        }
      }
      
      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint('Error upvoting remix: $e');
      rethrow;
    }
  }
  
  // Downvote a remix
  Future<void> downvoteRemix(String remixId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to vote');
      }
      
      final ratingRef = _firestore
          .collection(AppConstants.ratingsCollection)
          .doc('${currentUser.uid}_${remixId}');
      
      final ratingDoc = await ratingRef.get();
      
      final batch = _firestore.batch();
      
      if (ratingDoc.exists) {
        final data = ratingDoc.data() as Map<String, dynamic>;
        final isUpvote = data['isUpvote'] as bool? ?? false;
        
        if (isUpvote) {
          // User previously upvoted, change to downvote
          batch.update(ratingRef, {'isUpvote': false});
          batch.update(
            _firestore.collection(AppConstants.remixesCollection).doc(remixId),
            {
              'upvotes': FieldValue.increment(-1),
              'downvotes': FieldValue.increment(1),
            },
          );
        } else {
          // User already downvoted, remove the downvote
          batch.delete(ratingRef);
          batch.update(
            _firestore.collection(AppConstants.remixesCollection).doc(remixId),
            {'downvotes': FieldValue.increment(-1)},
          );
        }
      } else {
        // No previous vote, add a downvote
        batch.set(ratingRef, {
          'userId': currentUser.uid,
          'jokeId': null,
          'remixId': remixId,
          'isUpvote': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        batch.update(
          _firestore.collection(AppConstants.remixesCollection).doc(remixId),
          {'downvotes': FieldValue.increment(1)},
        );
      }
      
      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint('Error downvoting remix: $e');
      rethrow;
    }
  }
  
  // Get a user's vote on a specific remix
  Future<bool?> getUserVoteOnRemix(String remixId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return null;
      
      final ratingDoc = await _firestore
          .collection(AppConstants.ratingsCollection)
          .doc('${currentUser.uid}_${remixId}')
          .get();
      
      if (!ratingDoc.exists) return null;
      
      final data = ratingDoc.data() as Map<String, dynamic>;
      return data['isUpvote'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error getting user vote: $e');
      return null;
    }
  }
} 