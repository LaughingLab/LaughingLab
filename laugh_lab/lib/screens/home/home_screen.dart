import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laugh_lab/services/auth_service.dart';
import 'package:laugh_lab/screens/home/feed_screen.dart';
import 'package:laugh_lab/screens/create/create_joke_screen.dart';
import 'package:laugh_lab/screens/profile/profile_screen.dart';
import 'package:laugh_lab/constants/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const FeedScreen(),
    const CreateJokeScreen(),
    const ProfileScreen(),
  ];
  
  final List<String> _titles = [
    'Feed',
    'Create Joke',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Refresh feed - will be handled by the FeedScreen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feed refreshed'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.secondaryTextColor,
      ),
    );
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthService>(context, listen: false).signOut();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
} 