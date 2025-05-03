import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/models/joke_model.dart';
import 'package:laugh_lab/services/joke_service.dart';
import 'package:laugh_lab/services/auth_service.dart';
import 'package:laugh_lab/widgets/joke_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;
  String _selectedCategory = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startRefreshTimer();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  void _startRefreshTimer() {
    // Poll for feed updates every 10 seconds
    _refreshTimer = Timer.periodic(
      Duration(seconds: AppConstants.feedRefreshIntervalSeconds),
      (timer) {
        if (mounted) {
          setState(() {
            // This will trigger a rebuild of the stream builder
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jokeService = Provider.of<JokeService>(context);
    
    return Column(
      children: [
        // Tab bar for Recent/Top Jokes
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Recent'),
            Tab(text: 'Top Rated'),
          ],
          onTap: (_) {
            // Force refresh when tab changes
            setState(() {});
          },
        ),
        
        // Category filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Filter by category',
              prefixIcon: Icon(Icons.filter_list),
            ),
            value: _selectedCategory.isEmpty ? null : _selectedCategory,
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Text('All Categories'),
              ),
              ...AppConstants.jokeCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? '';
              });
            },
          ),
        ),
        
        // Joke feed
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Recent jokes tab
              _buildJokeFeed(
                _selectedCategory.isEmpty
                    ? jokeService.getRecentJokes()
                    : jokeService.getJokesByCategory(_selectedCategory),
              ),
              
              // Top rated jokes tab
              _buildJokeFeed(
                _selectedCategory.isEmpty
                    ? jokeService.getTopRatedJokes()
                    : jokeService.getJokesByCategory(_selectedCategory),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildJokeFeed(Stream<List<JokeModel>> jokesStream) {
    return StreamBuilder<List<JokeModel>>(
      stream: jokesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
          return const Center(
            child: Text('No jokes found. Be the first to share a joke!'),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: jokes.length,
            itemBuilder: (context, index) {
              final joke = jokes[index];
              return JokeCard(joke: joke);
            },
          ),
        );
      },
    );
  }
} 