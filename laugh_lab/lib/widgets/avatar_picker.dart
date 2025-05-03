import 'package:flutter/material.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/constants/profile_images.dart';

class AvatarPicker extends StatefulWidget {
  final int initialAvatarIndex;
  final Function(int) onAvatarSelected;
  
  const AvatarPicker({
    super.key,
    required this.initialAvatarIndex,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  late int _selectedIndex;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialAvatarIndex;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Choose an Avatar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 20, // Show first 20 combinations
            itemBuilder: (context, index) {
              final icon = ProfileImages.getIconByIndex(index);
              final color = ProfileImages.getColorByIndex(index);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  widget.onAvatarSelected(index);
                },
                child: CircleAvatar(
                  radius: AppTheme.avatarSizeMedium / 2,
                  backgroundColor: color,
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _selectedIndex);
          },
          child: const Text('Select'),
        ),
      ],
    );
  }
} 