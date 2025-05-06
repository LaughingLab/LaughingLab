import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/models/joke_model.dart';
import 'package:laugh_lab/models/remix_model.dart';
import 'package:laugh_lab/services/joke_service.dart';
import 'package:laugh_lab/services/remix_service.dart';
import 'package:laugh_lab/widgets/remix_card.dart';
import 'package:laugh_lab/screens/remix/create_remix_screen.dart';
import 'package:laugh_lab/services/migration_service.dart';

class RemixScreen extends StatefulWidget {
  const RemixScreen({super.key});

  @override
  State<RemixScreen> createState() => _RemixScreenState();
}

class _RemixScreenState extends State<RemixScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _openCreateRemixScreen(JokeModel joke) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateRemixScreen(joke: joke),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remix'),
        elevation: 0,
        actions: [
          // Add refresh button that also runs the migration
          IconButton(
            icon: _isLoading 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh and update usernames',
            onPressed: _isLoading ? null : () => _refreshAndMigrateUsernames(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Recent'),
            Tab(text: 'Top Rated'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Recent remixes tab
          _buildRemixesList(
            Provider.of<RemixService>(context).getAllRemixes(),
          ),
          
          // Top-rated remixes tab
          _buildRemixesList(
            Provider.of<RemixService>(context).getTopRatedRemixes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Open a dialog to select a joke to remix
          _showJokeSelectionDialog();
        },
        icon: const Icon(Icons.repeat),
        label: const Text('Create Remix'),
      ),
    );
  }
  
  Widget _buildRemixesList(Stream<List<RemixModel>> remixesStream) {
    return StreamBuilder<List<RemixModel>>(
      stream: remixesStream,
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
        
        final remixes = snapshot.data ?? [];
        
        if (remixes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.repeat,
                  size: 72,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Remixes Found',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Be the first to create a remix by putting your own spin on someone else\'s joke!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    _showJokeSelectionDialog();
                  },
                  icon: const Icon(Icons.repeat),
                  label: const Text('Create First Remix'),
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
            
            // Wait a bit to make the refresh feel real
            await Future.delayed(const Duration(milliseconds: 500));
            
            setState(() {
              _isLoading = false;
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: remixes.length,
            itemBuilder: (context, index) {
              final remix = remixes[index];
              return FutureBuilder<JokeModel?>(
                future: _getOriginalJoke(remix.parentJokeId),
                builder: (context, jokeSnapshot) {
                  final originalJoke = jokeSnapshot.data;
                  return RemixCard(
                    remix: remix,
                    originalJokeContent: originalJoke?.content,
                    onTap: () {
                      // Handle remix tap - maybe show full detail view
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
  
  Future<JokeModel?> _getOriginalJoke(String jokeId) async {
    try {
      final jokeService = Provider.of<JokeService>(context, listen: false);
      return await jokeService.getJokeById(jokeId);
    } catch (e) {
      debugPrint('Error getting original joke: $e');
      return null;
    }
  }
  
  void _showJokeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a Joke to Remix'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _buildJokeSelectionList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildJokeSelectionList() {
    final jokeService = Provider.of<JokeService>(context);
    
    return StreamBuilder<List<JokeModel>>(
      stream: jokeService.getTopRatedJokes(),
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
            child: Text('No jokes found to remix.'),
          );
        }
        
        return ListView.builder(
          itemCount: jokes.length,
          itemBuilder: (context, index) {
            final joke = jokes[index];
            return ListTile(
              title: Text(
                joke.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pop(context);
                _openCreateRemixScreen(joke);
              },
            );
          },
        );
      },
    );
  }

  // Add this new function to run the migration and refresh
  Future<void> _refreshAndMigrateUsernames(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Run the migration service
      final migrationService = Provider.of<MigrationService>(context, listen: false);
      debugPrint('Starting username and display name migration...');
      await migrationService.updateRemixesWithUsernames();
      
      // Force reload by waiting a bit to let Firestore catch up
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Then let the user know we're done
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remixes refreshed and usernames updated!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during refresh: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 