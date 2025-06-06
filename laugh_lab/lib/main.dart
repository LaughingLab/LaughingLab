import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:laugh_lab/screens/auth/login_screen.dart';
import 'package:laugh_lab/screens/navigation/app_navigation.dart';
import 'package:laugh_lab/services/auth_service.dart';
import 'package:laugh_lab/services/joke_service.dart';
import 'package:laugh_lab/services/comment_service.dart';
import 'package:laugh_lab/services/user_service.dart';
import 'package:laugh_lab/services/remix_service.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/screens/onboarding/onboarding_screen.dart';

// Global variable to prevent multiple initialization attempts
bool _firebaseInitialized = false;

void main() {
  // Make app run synchronously
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start with a simple loading screen while Firebase initializes
  runApp(const AppLoader());
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  // For handling errors during initialization
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  // Initialize Firebase and then launch the main app
  Future<void> _initializeApp() async {
    try {
      if (!_firebaseInitialized) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _firebaseInitialized = true;
      }
      
      if (mounted) {
        // Replace the loading screen with the actual app
        runApp(const MyApp());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: _errorMessage != null
              ? Text('Error: $_errorMessage')
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProxyProvider<AuthService, JokeService>(
          create: (context) => JokeService(Provider.of<AuthService>(context, listen: false)),
          update: (context, auth, previous) => JokeService(auth),
        ),
        ChangeNotifierProvider(create: (_) => CommentService()),
        ChangeNotifierProxyProvider2<AuthService, UserService, RemixService>(
          create: (context) => RemixService(
            Provider.of<AuthService>(context, listen: false),
            Provider.of<UserService>(context, listen: false),
          ),
          update: (context, auth, userService, previous) => 
              RemixService(auth, userService),
        ),
      ],
      child: MaterialApp(
        title: 'LaughLab',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, prefsSnapshot) {
        if (!prefsSnapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final prefs = prefsSnapshot.data!;
        final onboardingCompleted = prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
        
        if (!onboardingCompleted) {
          return const OnboardingScreen();
        }
        
        return StreamBuilder(
          stream: authService.user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final user = snapshot.data;
              return user != null ? const AppNavigation() : const LoginScreen();
            }
            
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
    );
  }
}
