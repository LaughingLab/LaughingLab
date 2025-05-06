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
  bool _isAIAssisted = false;
  
  @override
  void initState() {
    super.initState();
    _jokeController.addListener(_updateCharacterCount);
    
    // Process this after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPrompterData();
    });
  }
  
  void _processPrompterData() {
    // Get arguments if coming from prompter screen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final setup = args['setup'] as String?;
      final punchline = args['punchline'] as String?;
      final isAIAssisted = args['is_ai_assisted'] as bool? ?? false;
      
      if (setup != null && punchline != null) {
        // Format the joke with setup and punchline
        final joke = '$setup\n\n$punchline';
        _jokeController.text = joke;
        
        setState(() {
          _isAIAssisted = isAIAssisted;
          // Try to match category based on content
          if (setup.toLowerCase().contains('knock')) {
            _selectedCategory = 'Knock-knock';
          } else if (setup.toLowerCase().contains('chicken')) {
            _selectedCategory = 'Silly';
          }
        });
      }
    }
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
        isAIAssisted: _isAIAssisted,
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
        setState(() {
          _isAIAssisted = false;
        });
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
    // Navigate to prompter screen
    Navigator.of(context).pushNamed('/prompter');
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
            
            // AI assisted badge
            if (_isAIAssisted) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.accentColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'AI Assisted',
                      style: TextStyle(color: AppTheme.accentColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
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