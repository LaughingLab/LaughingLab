class CommentModel {
  final String id;
  final String jokeId;
  final String userId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentModel({
    required this.id,
    required this.jokeId,
    required this.userId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create an empty comment with default values
  factory CommentModel.empty() {
    return CommentModel(
      id: '',
      jokeId: '',
      userId: '',
      authorName: '',
      content: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Convert comment to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jokeId': jokeId,
      'userId': userId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create a comment from a Firestore document
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      jokeId: map['jokeId'] ?? '',
      userId: map['userId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorPhotoUrl: map['authorPhotoUrl'],
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  // Create a copy of this comment with updated fields
  CommentModel copyWith({
    String? id,
    String? jokeId,
    String? userId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      jokeId: jokeId ?? this.jokeId,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 