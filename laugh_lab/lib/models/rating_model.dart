class RatingModel {
  final String id;
  final String jokeId;
  final String userId;
  final bool isUpvote;
  final DateTime createdAt;
  final DateTime updatedAt;

  RatingModel({
    required this.id,
    required this.jokeId,
    required this.userId,
    required this.isUpvote,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create an empty rating with default values
  factory RatingModel.empty() {
    return RatingModel(
      id: '',
      jokeId: '',
      userId: '',
      isUpvote: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Convert rating to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jokeId': jokeId,
      'userId': userId,
      'isUpvote': isUpvote,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create a rating from a Firestore document
  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      id: map['id'] ?? '',
      jokeId: map['jokeId'] ?? '',
      userId: map['userId'] ?? '',
      isUpvote: map['isUpvote'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  // Create a copy of this rating with updated fields
  RatingModel copyWith({
    String? id,
    String? jokeId,
    String? userId,
    bool? isUpvote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      jokeId: jokeId ?? this.jokeId,
      userId: userId ?? this.userId,
      isUpvote: isUpvote ?? this.isUpvote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 