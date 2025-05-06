import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/services/ai_punchline_service.dart';

class PrompterScreen extends StatefulWidget {
  const PrompterScreen({super.key});

  @override
  State<PrompterScreen> createState() => _PrompterScreenState();
}

class _PrompterScreenState extends State<PrompterScreen> {
  final TextEditingController _setupController = TextEditingController();
  final AIPunchlineService _aiService = AIPunchlineService();
  bool _isGenerating = false;
  List<String> _suggestedPunchlines = [];
  
  @override
  void dispose() {
    _setupController.dispose();
    super.dispose();
  }
  
  Future<void> _generatePunchlines() async {
    final setup = _setupController.text.trim();
    if (setup.isEmpty) {
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
    
    try {
      // Use the AI service to generate punchlines
      final punchlines = await _aiService.generatePunchlines(setup);
      
      setState(() {
        _isGenerating = false;
        _suggestedPunchlines = punchlines;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating punchlines: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Punchline copied to clipboard!'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  void _usePunchline(String punchline) {
    // Save feedback for future improvements
    _aiService.saveFeedback(_setupController.text, punchline);
    
    // Navigate to the create screen with this setup and punchline
    Navigator.of(context).pushNamed(
      '/create', 
      arguments: {
        'setup': _setupController.text,
        'punchline': punchline,
        'is_ai_assisted': true,
      },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Punchline selected! Create your joke now.'),
        duration: Duration(seconds: 2),
      ),
    );
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
                              onPressed: () => _copyToClipboard(_suggestedPunchlines[index]),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.thumb_up_alt_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              tooltip: 'Use this',
                              onPressed: () => _usePunchline(_suggestedPunchlines[index]),
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