import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/models/joke_model.dart';
import 'package:laugh_lab/services/remix_service.dart';
import 'package:laugh_lab/utils/moderation_util.dart';

class CreateRemixScreen extends StatefulWidget {
  final JokeModel joke;
  
  const CreateRemixScreen({
    super.key,
    required this.joke,
  });

  @override
  State<CreateRemixScreen> createState() => _CreateRemixScreenState();
}

class _CreateRemixScreenState extends State<CreateRemixScreen> {
  final TextEditingController _remixController = TextEditingController();
  bool _isSubmitting = false;
  int _charactersLeft = AppConstants.maxRemixLength;
  
  @override
  void initState() {
    super.initState();
    _remixController.addListener(_updateCharacterCount);
  }
  
  @override
  void dispose() {
    _remixController.removeListener(_updateCharacterCount);
    _remixController.dispose();
    super.dispose();
  }
  
  void _updateCharacterCount() {
    setState(() {
      _charactersLeft = AppConstants.maxRemixLength - _remixController.text.length;
    });
  }
  
  Future<void> _submitRemix() async {
    final remixContent = _remixController.text.trim();
    
    if (remixContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your remix first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Check for offensive content
    if (ModerationUtil.containsOffensiveContent(remixContent)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your remix contains inappropriate content. Please revise.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final remixService = Provider.of<RemixService>(context, listen: false);
      
      await remixService.createRemix(
        parentJokeId: widget.joke.id,
        content: remixContent,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remix created successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate back
        Navigator.pop(context);
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
        content: Text('Coming soon: AI remix suggestions!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Remix'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Original joke
            Card(
              margin: EdgeInsets.zero,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppTheme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.format_quote,
                          size: 18,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Original Joke:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.joke.content,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person, 
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.joke.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.thumb_up, 
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.joke.upvotes}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.secondaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.joke.category,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Remix guidance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Create your own version of this joke with a different punchline or twist!',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Remix input
            Expanded(
              child: TextField(
                controller: _remixController,
                maxLength: AppConstants.maxRemixLength,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: 'Your Remix',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  hintText: 'Type your remix here...',
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
            
            // Submit button
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitRemix,
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
              label: const Text('Post Remix'),
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