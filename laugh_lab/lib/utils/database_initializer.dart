import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laugh_lab/services/comment_service.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/models/joke_model.dart';

class DatabaseInitializer {
  static Future<void> initializeDatabase(BuildContext context) async {
    try {
      // Get Firestore instance
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // First check and create test joke if needed
      String jokeId = await _ensureTestJokeExists(firestore);
      
      // Check if we need to initialize comments collection
      final commentsCollection = await firestore.collection(AppConstants.commentsCollection).limit(1).get();
      
      if (commentsCollection.docs.isEmpty) {
        print('Initializing comments collection with proper structure...');
        
        // Initialize comment collection with correct structure
        final commentService = CommentService();
        await commentService.initializeCommentCollection(jokeId);
        
        print('Comments collection initialized successfully');
      } else {
        print('Comments collection already exists');
      }
    } catch (e) {
      print('Error initializing database: $e');
    }
  }
  
  // Helper method to ensure a test joke exists
  static Future<String> _ensureTestJokeExists(FirebaseFirestore firestore) async {
    // Check if jokes collection has at least one document
    final jokesCollection = await firestore.collection(AppConstants.jokesCollection).limit(1).get();
    
    if (jokesCollection.docs.isEmpty) {
      print('Creating test joke for database initialization...');
      
      // Create a test joke document
      final testJokeRef = firestore.collection(AppConstants.jokesCollection).doc('test_joke');
      
      // Create a test joke with all required fields
      final testJoke = JokeModel(
        id: 'test_joke',
        userId: 'test_user',
        authorName: 'Test User',
        authorPhotoUrl: AppConstants.defaultAvatarUrl,
        content: 'Why did the developer go broke? Because they lost their domain in a crash!',
        category: 'Puns',
        upvotes: 1,
        downvotes: 0,
        score: 1,
        commentCount: 0,
        isAIAssisted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Add the test joke to Firestore
      await testJokeRef.set(testJoke.toMap());
      
      print('Test joke created successfully');
      return 'test_joke';
    } else {
      return jokesCollection.docs.first.id;
    }
  }
} 