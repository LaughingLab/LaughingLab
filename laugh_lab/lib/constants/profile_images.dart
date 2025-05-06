import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    Colors.deepOrange,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.lime,
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

class MistralPunchlineService {
  final String apiKey = 'your_mistral_api_key'; // Get from Mistral platform
  final String apiUrl = 'https://api.mistral.ai/v1/chat/completions';
  
  Future<List<String>> generatePunchlines(String setup) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'mistral-tiny', // Their smallest model, very affordable
          'messages': [
            {
              'role': 'system',
              'content': 'You are a comedy writer specialized in creating funny punchlines for jokes. Generate 5 unique, funny punchlines that specifically relate to the setup. Make each punchline distinct and directly related to the key elements in the joke setup.'
            },
            {
              'role': 'user',
              'content': 'Create 5 funny punchlines for this joke setup: "$setup"'
            }
          ],
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Parse the response to extract individual punchlines
        final punchlines = _extractPunchlinesFromText(content);
        return punchlines;
      }
    } catch (e) {
      print('Error generating punchlines: $e');
    }
    
    // Fallback to local generation if API fails
    return _localGeneratePunchlines(setup);
  }
  
  List<String> _extractPunchlinesFromText(String text) {
    // Split by numbered lists, newlines, or other separators
    final List<String> punchlines = [];
    final RegExp exp = RegExp(r'\d\.\s(.*?)(?=\n\d\.|\n\n|$)');
    
    final matches = exp.allMatches(text);
    for (final match in matches) {
      if (match.group(1) != null) {
        punchlines.add(match.group(1)!.trim());
      }
    }
    
    // If regex failed to extract properly, fallback to line splitting
    if (punchlines.isEmpty) {
      return text.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(5)
          .toList();
    }
    
    return punchlines;
  }
  
  Future<List<String>> _localGeneratePunchlines(String setup) async {
    // Your existing implementation as fallback
    return _punchlineMap[setup.toLowerCase()] ?? _defaultPunchlines;
  }
} 