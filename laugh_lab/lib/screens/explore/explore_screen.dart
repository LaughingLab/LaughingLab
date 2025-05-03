import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/models/joke_model.dart';
import 'package:laugh_lab/services/joke_service.dart';
import 'package:laugh_lab/widgets/joke_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category filter
          _buildCategoryFilter(),
          
          // Jokes list
          Expanded(
            child: _buildJokeList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.jokeCategories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          // First item is "All"
          if (index == 0) {
            return _buildCategoryChip("All", null);
          }
          
          final category = AppConstants.jokeCategories[index - 1];
          return _buildCategoryChip(
            category, 
            category,
            color: AppTheme.categoryColors[(index - 1) % AppTheme.categoryColors.length],
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryChip(String label, String? category, {Color? color}) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: color ?? Colors.grey[200],
        selectedColor: color ?? AppTheme.primaryColor,
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
    );
  }
  
  Widget _buildJokeList() {
    final jokeService = Provider.of<JokeService>(context);
    
    return StreamBuilder<List<JokeModel>>(
      stream: _selectedCategory != null
          ? jokeService.getJokesByCategory(_selectedCategory!)
          : jokeService.getAllJokes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final jokes = snapshot.data ?? [];
        
        if (jokes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sentiment_dissatisfied,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedCategory != null
                      ? 'No jokes found in the "${_selectedCategory!}" category.'
                      : 'No jokes found.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                if (_selectedCategory != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    child: const Text('Show all jokes'),
                  ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _isLoading = true;
            });
            
            // Simulate refresh delay
            await Future.delayed(const Duration(milliseconds: 500));
            
            setState(() {
              _isLoading = false;
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jokes.length,
            itemBuilder: (context, index) {
              final joke = jokes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: JokeCard(joke: joke),
              );
            },
          ),
        );
      },
    );
  }
} 