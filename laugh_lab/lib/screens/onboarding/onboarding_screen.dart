import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/screens/auth/login_screen.dart';
import 'package:laugh_lab/screens/auth/register_screen.dart';
import 'package:laugh_lab/services/auth_service.dart';
import 'package:laugh_lab/services/user_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<String> _selectedCategories = [];
  int _currentPage = 0;
  bool _isLoading = false;
  
  final int _totalPages = 2;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _selectCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        if (_selectedCategories.length < 3) {
          _selectedCategories.add(category);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select up to 3 categories'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }
  
  Future<void> _completeOnboarding() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Save selected categories to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        AppConstants.preferredCategoriesKey, 
        _selectedCategories
      );
      
      // Mark onboarding as completed
      await prefs.setBool(AppConstants.onboardingCompletedKey, true);
      
      // If user is logged in, save categories to Firestore
      final userService = Provider.of<UserService>(context, listen: false);
      if (userService.isLoggedIn) {
        await userService.saveUserPreferredCategories(_selectedCategories);
      }
      
      if (mounted) {
        // Navigate to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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
  
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // Welcome page
                  _buildWelcomePage(),
                  
                  // Category selection page
                  _buildCategorySelectionPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button (only on first page)
                  _currentPage == 0
                      ? TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text('Skip'),
                        )
                      : TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Back'),
                        ),
                  
                  // Next/Finish button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _nextPage,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _currentPage == _totalPages - 1 ? 'Finish' : 'Next',
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App title
          const Text(
            'Welcome to LaughLab!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // App description
          const Text(
            'The app where you can share your best jokes, get feedback, and laugh with others.',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          // Login and register buttons
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Login'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Register'),
          ),
          const SizedBox(height: 32),
          
          // Continue as guest option
          TextButton(
            onPressed: () {
              // Go to next page
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('Continue as guest'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategorySelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Choose Your Favorites',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            'Select 1-3 joke categories you enjoy the most. This helps us personalize your feed.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Selected categories counter
          Text(
            'Selected: ${_selectedCategories.length}/3',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _selectedCategories.length == 3
                  ? AppTheme.primaryColor
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Category grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: AppConstants.jokeCategories.length,
              itemBuilder: (context, index) {
                final category = AppConstants.jokeCategories[index];
                final isSelected = _selectedCategories.contains(category);
                
                return InkWell(
                  onTap: () => _selectCategory(category),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.categoryColors[index % AppTheme.categoryColors.length]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.categoryColors[index % AppTheme.categoryColors.length]
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 