import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIPunchlineService {
  // Hardcoded punchlines for different joke setups
  // In a real implementation, this would be replaced with a proper model
  static final Map<String, List<String>> _punchlineMap = {
    'chicken': [
      'To get to the other side!',
      'To prove it wasn\'t chicken!',
      'Because it wanted to stretch its legs!',
      'To show the possum it could be done!',
      'KFC was on the other side!'
    ],
    'knock': [
      'Who\'s there?',
      'Come in, the door\'s open!',
      'Door\'s broken, please use the window!',
      'No one\'s home!',
      'Amazon delivery, your package is here!'
    ],
    'doctor': [
      'Time to get a second opinion!',
      'The doctor says you\'re fine!',
      'And the doctor said, "That\'s not normal!"',
      'The doctor said it\'s just a prescription for laughter!',
      'Doctor\'s orders: take two jokes and call me in the morning!'
    ],
    'donkey': [
      'One is stubborn, loud, and occasionally a pain in the rear... and the other is just a donkey!',
      'The donkey actually has a good excuse for being stubborn!',
      'People expect the donkey to act like an ass!',
      'The donkey knows when to stop talking!',
      'I\'m only stubborn on weekdays!'
    ],
    'difference between': [
      'One has a purpose, the other is just an excuse!',
      'About three drinks and a bad decision!',
      'One is useful, the other is me!',
      'One is awesome, and the other one wrote this joke!',
      'A punchline you didn\'t see coming!'
    ],
    'why did': [
      'Because that\'s what they do when no one is looking!',
      'To prove a point that nobody asked for!',
      'Because the alternative was even worse!',
      'For the same reason anyone does anything - attention on social media!',
      'Sometimes you just have to ask why not!'
    ],
    'what do you call': [
      'A missed opportunity!',
      'A problem waiting for a punchline!',
      'The reason comedians have trust issues!',
      'Something you shouldn\'t call in public!',
      'Too expensive for what it actually does!'
    ],
    'what is': [
      'Something you\'ll never understand until it happens to you!',
      'The reason we can\'t have nice things!',
      'A mystery that science still can\'t explain!',
      'Honestly, I\'m still trying to figure that out myself!',
      'The punchline to a much better joke than this one!'
    ],
  };

  // Default punchlines for when no keywords match
  static final List<String> _defaultPunchlines = [
    'The plot twist no one saw coming!',
    'And that\'s why you should always read the fine print!',
    'That\'s when I realized I should have taken that left turn at Albuquerque!',
    'Apparently, that\'s illegal in at least 12 states!',
    'The punchline was inside us all along!',
    'That\'s what happens when you forget to read the instructions!',
    'And I\'m still not allowed back at that Wendy\'s!',
    'The look on their face was worth every penny!',
    'Who would have thought it would end with a restraining order?',
    'And that\'s why you always leave a note!'
  ];

  // Method to generate punchlines based on the joke setup
  Future<List<String>> generatePunchlines(String setup) async {
    // Add a small delay to simulate "thinking"
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Convert setup to lowercase for matching
    setup = setup.toLowerCase();
    
    // Extract keywords from the setup - check for each keyword in our map
    List<String> matchedPunchlines = [];
    
    // First try exact phrases/patterns
    for (var keyword in _punchlineMap.keys) {
      if (setup.contains(keyword)) {
        matchedPunchlines = _punchlineMap[keyword]!;
        break;
      }
    }
    
    // If no exact matches, try a more advanced approach with context analysis
    if (matchedPunchlines.isEmpty) {
      // Check for comparison jokes (commonly structured as "difference between")
      if (setup.contains('difference') || setup.contains('compared to') || 
          (setup.contains('what') && setup.contains('and') && setup.length < 100)) {
        // Look for objects being compared
        List<String> objects = [];
        
        // Extract potential objects (this is a simplified approach)
        List<String> words = setup.split(' ');
        for (var i = 0; i < words.length; i++) {
          if (words[i] == 'and' && i > 0 && i < words.length - 1) {
            objects.add(words[i-1]);
            objects.add(words[i+1]);
          }
        }
        
        // If we found potential objects, create custom punchlines
        if (objects.length >= 2) {
          // Example: If joke compares "me and a donkey"
          if ((objects.contains('me') || objects.contains('i')) && 
              (objects.contains('donkey') || objects.contains('ass'))) {
            return [
              'One is stubborn, loud, and occasionally a pain in the rear... and the other is just a donkey!',
              'The donkey actually has a good excuse for being stubborn!',
              'People expect the donkey to act like an ass!',
              'The donkey knows when to stop talking!',
              'I\'m only stubborn on weekdays!'
            ];
          }
          
          // Generic comparison punchlines if we detected a comparison but no specific mapping
          return _punchlineMap['difference between']!;
        }
      }
    }
    
    // If we found matches in the first phase, return them
    if (matchedPunchlines.isNotEmpty) {
      return matchedPunchlines;
    }
    
    // If no context-specific matches, return random punchlines from the default list
    final random = Random();
    final shuffled = List<String>.from(_defaultPunchlines);
    shuffled.shuffle(random);
    
    // Return between 3-5 punchlines
    final count = 3 + random.nextInt(3);
    return shuffled.take(count).toList();
  }

  // Save user-selected punchline to learn from
  Future<void> saveFeedback(String setup, String selectedPunchline) async {
    final prefs = await SharedPreferences.getInstance();
    final feedbackKey = 'punchline_feedback';
    
    // Get existing feedback or create new list
    final feedbackList = prefs.getStringList(feedbackKey) ?? [];
    
    // Add new feedback (limit to 100 entries to avoid excessive storage)
    final feedback = jsonEncode({
      'setup': setup,
      'punchline': selectedPunchline,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
    
    feedbackList.add(feedback);
    
    // Keep only the latest 100 entries
    if (feedbackList.length > 100) {
      feedbackList.removeRange(0, feedbackList.length - 100);
    }
    
    await prefs.setStringList(feedbackKey, feedbackList);
  }
} 