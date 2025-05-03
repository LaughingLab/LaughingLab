import 'package:flutter/material.dart';

class ProfileImages {
  // Default profile avatar icons
  static const List<IconData> defaultAvatarIcons = [
    Icons.face,
    Icons.face_2,
    Icons.face_3,
    Icons.face_4,
    Icons.face_5,
    Icons.face_6,
    Icons.person,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
    Icons.emoji_emotions,
  ];

  // Colors for avatar backgrounds
  static const List<Color> avatarColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];
  
  // Get a combination of icon and color by index
  static IconData getIconByIndex(int index) {
    return defaultAvatarIcons[index % defaultAvatarIcons.length];
  }
  
  static Color getColorByIndex(int index) {
    return avatarColors[index % avatarColors.length];
  }
  
  // Get total available combinations
  static int get totalCombinations => 
      defaultAvatarIcons.length * avatarColors.length;
} 