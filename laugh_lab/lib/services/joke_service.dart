import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/models/joke_model.dart';
import 'package:laugh_lab/models/rating_model.dart';
import 'package:laugh_lab/services/auth_service.dart';

class JokeService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService;

  JokeService(this._authService);

  // Get the current user ID or empty string if not logged in
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Create a new joke
  Future<JokeModel> createJoke({
    required String content,
    required String category,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final jokeRef = _firestore.collection(AppConstants.jokesCollection).doc();
      
      final joke = JokeModel(
        id: jokeRef.id,
        userId: user.uid,
        authorName: user.displayName ?? 'Anonymous',
        authorPhotoUrl: user.photoURL,
        content: content,
        category: category,
        upvotes: 0,
        downvotes: 0,
        score: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await jokeRef.set(joke.toMap());
      
      // Add points for creating a joke
      await _authService.updateUserPoints(AppConstants.pointsForNewJoke);

      return joke;
    } catch (e) {
      rethrow;
    }
  }

  // Get recent jokes (last 24 hours)
  Stream<List<JokeModel>> getRecentJokes() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    
    return _firestore
        .collection(AppConstants.jokesCollection)
        .where('createdAt', isGreaterThan: yesterday.millisecondsSinceEpoch)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JokeModel.fromMap(doc.data()))
            .toList());
  }

  // Get top rated jokes
  Stream<List<JokeModel>> getTopRatedJokes() {
    return _firestore
        .collection(AppConstants.jokesCollection)
        .orderBy('score', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JokeModel.fromMap(doc.data()))
            .toList());
  }

  // Get jokes by category
  Stream<List<JokeModel>> getJokesByCategory(String category) {
    return _firestore
        .collection(AppConstants.jokesCollection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JokeModel.fromMap(doc.data()))
            .toList());
  }

  // Get jokes by user
  Stream<List<JokeModel>> getJokesByUser(String userId) {
    return _firestore
        .collection(AppConstants.jokesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JokeModel.fromMap(doc.data()))
            .toList());
  }

  // Get a single joke by ID
  Future<JokeModel?> getJokeById(String jokeId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.jokesCollection)
          .doc(jokeId)
          .get();
      
      if (doc.exists) {
        return JokeModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Rate a joke (upvote or downvote)
  Future<void> rateJoke(String jokeId, bool isUpvote) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Create a unique ID for the rating (userId_jokeId)
      final ratingId = '${user.uid}_$jokeId';
      
      // Get the existing rating if it exists
      final ratingDoc = await _firestore
          .collection(AppConstants.ratingsCollection)
          .doc(ratingId)
          .get();
      
      // Get the joke document
      final jokeDoc = await _firestore
          .collection(AppConstants.jokesCollection)
          .doc(jokeId)
          .get();
      
      if (!jokeDoc.exists) {
        throw Exception('Joke not found');
      }
      
      final joke = JokeModel.fromMap(jokeDoc.data() as Map<String, dynamic>);
      final jokeAuthorId = joke.userId;
      
      // Begin a batch write
      final batch = _firestore.batch();
      
      if (ratingDoc.exists) {
        // Rating exists, check if it's changed
        final existingRating = RatingModel.fromMap(ratingDoc.data() as Map<String, dynamic>);
        
        if (existingRating.isUpvote == isUpvote) {
          // Rating hasn't changed, do nothing
          return;
        }
        
        // Update the existing rating
        final newRating = existingRating.copyWith(
          isUpvote: isUpvote,
          updatedAt: DateTime.now(),
        );
        
        batch.set(
          _firestore.collection(AppConstants.ratingsCollection).doc(ratingId),
          newRating.toMap()
        );
        
        // Update joke's upvotes and downvotes
        final jokeRef = _firestore.collection(AppConstants.jokesCollection).doc(jokeId);
        
        if (isUpvote) {
          // Changed from downvote to upvote
          batch.update(jokeRef, {
            'upvotes': FieldValue.increment(1),
            'downvotes': FieldValue.increment(-1),
            'score': FieldValue.increment(2),
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
          
          // Add points for receiving an upvote (if not the joke author)
          if (jokeAuthorId != user.uid) {
            batch.update(
              _firestore.collection(AppConstants.usersCollection).doc(jokeAuthorId),
              {
                'points': FieldValue.increment(AppConstants.pointsForUpvote),
                'updatedAt': DateTime.now().millisecondsSinceEpoch,
              }
            );
          }
        } else {
          // Changed from upvote to downvote
          batch.update(jokeRef, {
            'upvotes': FieldValue.increment(-1),
            'downvotes': FieldValue.increment(1),
            'score': FieldValue.increment(-2),
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
          
          // Remove points for losing an upvote (if not the joke author)
          if (jokeAuthorId != user.uid) {
            batch.update(
              _firestore.collection(AppConstants.usersCollection).doc(jokeAuthorId),
              {
                'points': FieldValue.increment(-AppConstants.pointsForUpvote),
                'updatedAt': DateTime.now().millisecondsSinceEpoch,
              }
            );
          }
        }
      } else {
        // Create a new rating
        final rating = RatingModel(
          id: ratingId,
          jokeId: jokeId,
          userId: user.uid,
          isUpvote: isUpvote,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        batch.set(
          _firestore.collection(AppConstants.ratingsCollection).doc(ratingId),
          rating.toMap()
        );
        
        // Update joke's upvotes and downvotes
        final jokeRef = _firestore.collection(AppConstants.jokesCollection).doc(jokeId);
        
        if (isUpvote) {
          batch.update(jokeRef, {
            'upvotes': FieldValue.increment(1),
            'score': FieldValue.increment(1),
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
          
          // Add points for receiving an upvote (if not the joke author)
          if (jokeAuthorId != user.uid) {
            batch.update(
              _firestore.collection(AppConstants.usersCollection).doc(jokeAuthorId),
              {
                'points': FieldValue.increment(AppConstants.pointsForUpvote),
                'updatedAt': DateTime.now().millisecondsSinceEpoch,
              }
            );
          }
        } else {
          batch.update(jokeRef, {
            'downvotes': FieldValue.increment(1),
            'score': FieldValue.increment(-1),
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }
      
      // Commit the batch
      await batch.commit();
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Check if the current user has rated a joke
  Future<bool?> hasUserRatedJoke(String jokeId) async {
    try {
      if (currentUserId.isEmpty) {
        return null;
      }
      
      final ratingId = '${currentUserId}_$jokeId';
      final doc = await _firestore
          .collection(AppConstants.ratingsCollection)
          .doc(ratingId)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      final rating = RatingModel.fromMap(doc.data() as Map<String, dynamic>);
      return rating.isUpvote;
    } catch (e) {
      return null;
    }
  }

  // Get all jokes (limited to 50)
  Stream<List<JokeModel>> getAllJokes() {
    return _firestore
        .collection(AppConstants.jokesCollection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JokeModel.fromMap(doc.data()))
            .toList());
  }
} 