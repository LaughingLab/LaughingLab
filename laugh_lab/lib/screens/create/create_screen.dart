import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/services/joke_service.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _jokeController = TextEditingController();
  String _selectedCategory = AppConstants.jokeCategories.first;
  bool _isSubmitting = false;
  int _charactersLeft = AppConstants.maxJokeLength;
  
  @override
  void initState() {
    super.initState();
    _jokeController.addListener(_updateCharacterCount);
  }
  
  @override
  void dispose() {
    _jokeController.removeListener(_updateCharacterCount);
    _jokeController.dispose();
    super.dispose();
  }
  
  void _updateCharacterCount() {
    setState(() {
      _charactersLeft = AppConstants.maxJokeLength - _jokeController.text.length;
    });
  }
  
  Future<void> _postJoke() async {
    if (_jokeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a joke first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final jokeService = Provider.of<JokeService>(context, listen: false);
      
      await jokeService.createJoke(
        content: _jokeController.text.trim(),
        category: _selectedCategory,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Joke posted successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Clear the form
        _jokeController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  void _getAIHelp() {
    // Navigate to prompter screen or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon: AI punchline suggestions!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Joke'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.jokeCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Joke content
            Expanded(
              child: TextField(
                controller: _jokeController,
                maxLength: AppConstants.maxJokeLength,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: 'Joke',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  hintText: 'Type your joke here...',
                  counterText: '$_charactersLeft characters left',
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // AI Help button
            OutlinedButton.icon(
              onPressed: _getAIHelp,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Get AI Help'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            
            // Post button
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _postJoke,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: const Text('Post Joke'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 