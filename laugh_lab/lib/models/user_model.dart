class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? username;
  final String? photoUrl;
  final int points;
  final List<String> preferredCategories;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.username,
    this.photoUrl,
    required this.points,
    required this.preferredCategories,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create an empty user with default values
  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      points: 0,
      preferredCategories: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Create a user from Firebase auth
  factory UserModel.fromFirebase(String uid, String email) {
    return UserModel(
      id: uid,
      email: email,
      points: 0,
      preferredCategories: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Convert user to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'points': points,
      'preferredCategories': preferredCategories,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create a user from a Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      username: map['username'],
      photoUrl: map['photoUrl'],
      points: map['points'] ?? 0,
      preferredCategories: map['preferredCategories'] != null
          ? List<String>.from(map['preferredCategories'])
          : [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  // Create a copy of this user with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? username,
    String? photoUrl,
    int? points,
    List<String>? preferredCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 