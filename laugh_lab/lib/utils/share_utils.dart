import 'package:share_plus/share_plus.dart';
import 'package:laugh_lab/models/joke_model.dart';

class ShareUtils {
  // Share a joke via the platform's share dialog
  static Future<void> shareJoke(JokeModel joke) async {
    final text = 'My joke: ${joke.content} on LaughLab!';
    await Share.share(text);
  }
  
  // Generate a shareable text for a joke
  static String getShareableText(JokeModel joke) {
    return 'My joke: ${joke.content} on LaughLab!';
  }
} 