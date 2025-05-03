import 'package:laugh_lab/constants/app_constants.dart';

class ModerationUtil {
  // Check if content contains offensive words
  static bool containsOffensiveContent(String content) {
    final lowerContent = content.toLowerCase();
    
    // Check against list of offensive words
    for (final word in AppConstants.offensiveWords) {
      if (lowerContent.contains(word.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }
  
  // Filter content to replace offensive words with asterisks
  static String filterContent(String content) {
    String filteredContent = content;
    
    for (final word in AppConstants.offensiveWords) {
      final regex = RegExp(
        word,
        caseSensitive: false,
      );
      
      filteredContent = filteredContent.replaceAllMapped(
        regex,
        (match) => '*' * match.group(0)!.length,
      );
    }
    
    return filteredContent;
  }
  
  // Check if username is appropriate
  static bool isUsernameAppropriate(String username) {
    return !containsOffensiveContent(username);
  }
  
  // Check if content meets length requirements
  static bool meetsLengthRequirements(String content, int maxLength) {
    return content.length <= maxLength;
  }
  
  // Count offensive words in content
  static int countOffensiveWords(String content) {
    final lowerContent = content.toLowerCase();
    int count = 0;
    
    for (final word in AppConstants.offensiveWords) {
      final regex = RegExp(
        word,
        caseSensitive: false,
      );
      
      count += regex.allMatches(lowerContent).length;
    }
    
    return count;
  }
} 