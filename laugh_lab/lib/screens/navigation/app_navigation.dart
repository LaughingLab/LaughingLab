import 'package:flutter/material.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/screens/home/home_screen.dart';
import 'package:laugh_lab/screens/create/create_screen.dart';
import 'package:laugh_lab/screens/explore/explore_screen.dart';
import 'package:laugh_lab/screens/profile/profile_screen.dart';
import 'package:laugh_lab/screens/remix/remix_screen.dart';
import 'package:laugh_lab/screens/prompter/prompter_screen.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const CreateScreen(),
    const ExploreScreen(),
    const ProfileScreen(),
    const RemixScreen(),
    const PrompterScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // Needed for more than 3 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppConstants.homeScreen,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: AppConstants.createScreen,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: AppConstants.exploreScreen,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppConstants.profileScreen,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: AppConstants.remixScreen,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: AppConstants.prompterScreen,
          ),
        ],
      ),
    );
  }
} 