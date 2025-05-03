import 'package:flutter/material.dart';
import 'package:laugh_lab/constants/profile_images.dart';

class UserAvatar extends StatelessWidget {
  final int avatarIndex;
  final double size;
  
  const UserAvatar({
    super.key,
    required this.avatarIndex,
    this.size = 40.0,
  });
  
  @override
  Widget build(BuildContext context) {
    final icon = ProfileImages.getIconByIndex(avatarIndex);
    final color = ProfileImages.getColorByIndex(avatarIndex);
    
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
} 