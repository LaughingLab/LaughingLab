import 'package:flutter/material.dart';
import 'package:laugh_lab/constants/app_theme.dart';

class PrompterScreen extends StatefulWidget {
  const PrompterScreen({super.key});

  @override
  State<PrompterScreen> createState() => _PrompterScreenState();
}

class _PrompterScreenState extends State<PrompterScreen> {
  final TextEditingController _setupController = TextEditingController();
  bool _isGenerating = false;
  List<String> _suggestedPunchlines = [];
  
  @override
  void dispose() {
    _setupController.dispose();
    super.dispose();
  }
  
  void _generatePunchlines() {
    if (_setupController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a joke setup first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      _isGenerating = true;
    });
    
    // Simulate AI generation with a delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isGenerating = false;
        _suggestedPunchlines = [
          "This is a placeholder punchline!",
          "AI will suggest better jokes soon...",
          "Laughing is good for your health!",
          "Stay tuned for real AI punchlines.",
          "Coming soon: actual joke generation."
        ];
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Punchline Prompter'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Joke setup input
            TextField(
              controller: _setupController,
              decoration: const InputDecoration(
                labelText: 'Enter your joke setup',
                hintText: 'Why did the chicken cross the road?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 150,
            ),
            const SizedBox(height: 16),
            
            // Generate button
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generatePunchlines,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lightbulb_outline),
              label: const Text('Generate Punchlines'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            
            // Suggested punchlines
            if (_suggestedPunchlines.isNotEmpty) ...[
              const Text(
                'Suggested Punchlines:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestedPunchlines.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(_suggestedPunchlines[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.content_copy),
                              tooltip: 'Copy',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Punchline copied to clipboard!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.thumb_up_alt_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              tooltip: 'Use this',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Feature coming soon!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 