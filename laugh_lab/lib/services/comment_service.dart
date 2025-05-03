import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/models/comment_model.dart';

class CommentService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID or empty string if not logged in
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Create a new comment
  Future<CommentModel> createComment(String jokeId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Check if the joke exists
      final jokeDoc = await _firestore
          .collection(AppConstants.jokesCollection)
          .doc(jokeId)
          .get();
      
      if (!jokeDoc.exists) {
        throw Exception('Joke not found');
      }
      
      // Check if max comments limit has been reached
      final commentsCount = await _firestore
          .collection(AppConstants.commentsCollection)
          .where('jokeId', isEqualTo: jokeId)
          .count()
          .get();
      
      if ((commentsCount.count ?? 0) >= AppConstants.maxCommentsPerJoke) {
        throw Exception('Maximum comments limit reached for this joke');
      }

      // Create a new comment
      final commentRef = _firestore.collection(AppConstants.commentsCollection).doc();
      
      final comment = CommentModel(
        id: commentRef.id,
        jokeId: jokeId,
        userId: user.uid,
        authorName: user.displayName ?? 'Anonymous',
        authorPhotoUrl: user.photoURL,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Begin a batch write
      final batch = _firestore.batch();
      
      // Add the comment
      batch.set(commentRef, comment.toMap());
      
      // Increment the joke's comment count
      batch.update(
        _firestore.collection(AppConstants.jokesCollection).doc(jokeId),
        {
          'commentCount': FieldValue.increment(1),
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        }
      );
      
      // Commit the batch
      await batch.commit();
      
      notifyListeners();
      return comment;
    } catch (e) {
      rethrow;
    }
  }

  // Get comments for a joke
  Stream<List<CommentModel>> getCommentsForJoke(String jokeId) {
    return _firestore
        .collection(AppConstants.commentsCollection)
        .where('jokeId', isEqualTo: jokeId)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.maxCommentsPerJoke)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data()))
            .toList());
  }

  // Delete a comment (only if user is the author)
  Future<void> deleteComment(String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get the comment
      final commentDoc = await _firestore
          .collection(AppConstants.commentsCollection)
          .doc(commentId)
          .get();
      
      if (!commentDoc.exists) {
        throw Exception('Comment not found');
      }
      
      final comment = CommentModel.fromMap(commentDoc.data() as Map<String, dynamic>);
      
      // Check if the user is the author
      if (comment.userId != user.uid) {
        throw Exception('You are not authorized to delete this comment');
      }
      
      // Begin a batch write
      final batch = _firestore.batch();
      
      // Delete the comment
      batch.delete(_firestore.collection(AppConstants.commentsCollection).doc(commentId));
      
      // Decrement the joke's comment count
      batch.update(
        _firestore.collection(AppConstants.jokesCollection).doc(comment.jokeId),
        {
          'commentCount': FieldValue.increment(-1),
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        }
      );
      
      // Commit the batch
      await batch.commit();
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
} 