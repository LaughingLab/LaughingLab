import 'package:cloud_firestore/cloud_firestore.dart';

class RemixModel {
  final String id;
  final String parentJokeId;
  final String userId;
  final String content;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;
  final String? userDisplayName;
  final String? userPhotoUrl;
  
  RemixModel({
    required this.id,
    required this.parentJokeId,
    required this.userId,
    required this.content,
    required this.upvotes,
    required this.downvotes,
    required this.createdAt,
    this.userDisplayName,
    this.userPhotoUrl,
  });
  
  // Get score (upvotes - downvotes)
  int get score => upvotes - downvotes;
  
  // Create empty remix
  factory RemixModel.empty() {
    return RemixModel(
      id: '',
      parentJokeId: '',
      userId: '',
      content: '',
      upvotes: 0,
      downvotes: 0,
      createdAt: DateTime.now(),
    );
  }
  
  // Convert remix to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentJokeId': parentJokeId,
      'userId': userId,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
  
  // Create a remix from a Firestore document
  factory RemixModel.fromMap(Map<String, dynamic> map) {
    return RemixModel(
      id: map['id'] ?? '',
      parentJokeId: map['parentJokeId'] ?? '',
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      userDisplayName: map['userDisplayName'],
      userPhotoUrl: map['userPhotoUrl'],
    );
  }
  
  // Create a copy of this remix with updated fields
  RemixModel copyWith({
    String? id,
    String? parentJokeId,
    String? userId,
    String? content,
    int? upvotes,
    int? downvotes,
    DateTime? createdAt,
    String? userDisplayName,
    String? userPhotoUrl,
  }) {
    return RemixModel(
      id: id ?? this.id,
      parentJokeId: parentJokeId ?? this.parentJokeId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      createdAt: createdAt ?? this.createdAt,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
    );
  }
} 