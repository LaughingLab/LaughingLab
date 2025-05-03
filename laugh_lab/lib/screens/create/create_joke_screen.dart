import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/services/joke_service.dart';
import 'package:laugh_lab/utils/draft_utils.dart';

class CreateJokeScreen extends StatefulWidget {
  const CreateJokeScreen({super.key});

  @override
  State<CreateJokeScreen> createState() => _CreateJokeScreenState();
}

class _CreateJokeScreenState extends State<CreateJokeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  
  String _selectedCategory = AppConstants.jokeCategories.first;
  bool _isLoading = false;
  String _errorMessage = '';
  int _charactersLeft = AppConstants.maxJokeLength;
  
  @override
  void initState() {
    super.initState();
    _loadDraft();
  }
  
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDraft() async {
    final draftContent = await DraftUtils.loadDraftJoke();
    final draftCategory = await DraftUtils.loadDraftCategory();
    
    if (mounted) {
      setState(() {
        _contentController.text = draftContent;
        _selectedCategory = draftCategory;
        _charactersLeft = AppConstants.maxJokeLength - draftContent.length;
      });
    }
  }
  
  Future<void> _saveDraft() async {
    await DraftUtils.saveDraftJoke(_contentController.text);
    await DraftUtils.saveDraftCategory(_selectedCategory);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft saved'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  Future<void> _createJoke() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final jokeService = Provider.of<JokeService>(context, listen: false);
      await jokeService.createJoke(
        content: _contentController.text.trim(),
        category: _selectedCategory,
      );
      
      // Clear form and draft
      if (mounted) {
        setState(() {
          _contentController.clear();
          _selectedCategory = AppConstants.jokeCategories.first;
          _charactersLeft = AppConstants.maxJokeLength;
          _isLoading = false;
        });
        await DraftUtils.clearDraftJoke();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Joke posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error posting joke: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              value: _selectedCategory,
              items: AppConstants.jokeCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
                _saveDraft();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Joke content field
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              maxLength: AppConstants.maxJokeLength,
              decoration: InputDecoration(
                labelText: 'Joke Content',
                alignLabelWithHint: true,
                hintText: 'Write your joke here...',
                counterText: '$_charactersLeft characters left',
              ),
              onChanged: (value) {
                setState(() {
                  _charactersLeft = AppConstants.maxJokeLength - value.length;
                });
                _saveDraft();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your joke';
                }
                if (value.length < 5) {
                  return 'Joke is too short';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            
            // Character count
            Text(
              '$_charactersLeft characters left',
              style: TextStyle(
                color: _charactersLeft < 30 ? Colors.red : Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.end,
            ),
            
            // Error message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const Spacer(),
            
            // Action buttons
            Row(
              children: [
                // Save draft button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _saveDraft,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Post joke button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createJoke,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: const Text('Post Joke'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 