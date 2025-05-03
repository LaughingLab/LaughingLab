class JokeModel {
  final String id;
  final String userId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final String category;
  final int upvotes;
  final int downvotes;
  final int score;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  JokeModel({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    required this.category,
    required this.upvotes,
    required this.downvotes,
    required this.score,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create an empty joke with default values
  factory JokeModel.empty() {
    return JokeModel(
      id: '',
      userId: '',
      authorName: '',
      content: '',
      category: '',
      upvotes: 0,
      downvotes: 0,
      score: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Convert joke to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'category': category,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'score': score,
      'commentCount': commentCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create a joke from a Firestore document
  factory JokeModel.fromMap(Map<String, dynamic> map) {
    return JokeModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorPhotoUrl: map['authorPhotoUrl'],
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      score: map['score'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  // Create a copy of this joke with updated fields
  JokeModel copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    String? category,
    int? upvotes,
    int? downvotes,
    int? score,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JokeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      content: content ?? this.content,
      category: category ?? this.category,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      score: score ?? this.score,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 