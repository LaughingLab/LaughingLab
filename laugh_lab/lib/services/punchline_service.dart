import 'package:http/http.dart' as http;
import 'dart:convert';

class MistralPunchlineService {
  final String apiKey = 'your_mistral_api_key'; // Get from Mistral platform
  final String apiUrl = 'https://api.mistral.ai/v1/chat/completions';
  
  // Default punchlines if API fails
  final List<String> _defaultPunchlines = [
    "That's why I always bring a ladder to the bar - for all those high hopes!",
    "I guess that's why they call it 'comfort food'!",
    "And that's when I realized - some experiences are better left in the cloud!",
    "That's the last time I try to multitask during a video call!",
    "I guess you could say I've been 'ghosted' by technology!"
  ];
  
  // Map of setup to potential punchlines for fallback
  final Map<String, List<String>> _punchlineMap = {
    "why did the chicken cross the road": [
      "To get to the other side!",
      "To prove to the possum it could be done!",
      "Because the rooster was calling!",
      "KFC was on the other side!",
      "GPS said to make a U-turn!"
    ],
    "what do you call a deer with no eyes": [
      "No eye deer!",
      "A blind date!",
      "Severely visually impaired!",
      "Doe-n't see!",
      "Forest Stump!"
    ],
  };
  
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
    // Return punchlines from the map or defaults if not found
    return _punchlineMap[setup.toLowerCase()] ?? _defaultPunchlines;
  }
} 