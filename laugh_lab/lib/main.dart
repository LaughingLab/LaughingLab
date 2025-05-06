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
import 'package:laugh_lab/services/migration_service.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/screens/onboarding/onboarding_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:laugh_lab/screens/create/create_screen.dart';
import 'package:laugh_lab/screens/prompter/prompter_screen.dart';
import 'package:laugh_lab/screens/splash/splash_screen.dart';
import 'package:laugh_lab/utils/database_initializer.dart';

// No longer needed
// bool _firebaseInitialized = false;

// Make main asynchronous
Future<void> main() async {
  // Ensure bindings are initialized FIRST
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only ONCE here
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Activate App Check AFTER Firebase init
    await FirebaseAppCheck.instance.activate(
      // For testing, use AndroidProvider.debug
      // For release, use AndroidProvider.playIntegrity
      // TODO: Switch to playIntegrity for release builds
      androidProvider: AndroidProvider.debug, 
      // appleProvider: AppleProvider.appAttest, // If targeting iOS
    );
  } catch (e) {
    // Handle initialization error, maybe show a simple error screen
    // or log the error. For now, just print it.
    print('Failed to initialize Firebase or App Check: $e');
    // Optionally run an error app: runApp(ErrorApp(e)); return;
  }

  // Run the main app after initialization
  runApp(const MyApp());
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
        Provider<MigrationService>(
          create: (context) => MigrationService(
            Provider.of<UserService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'LaughLab',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: SplashScreen(nextScreen: const AuthWrapper()),
        routes: {
          '/create': (context) => const CreateScreen(),
          '/prompter': (context) => const PrompterScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Initialize database structure
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DatabaseInitializer.initializeDatabase(context);
      
      // Run username migration for remixes when a user is logged in
      authService.user.listen((user) {
        if (user != null) {
          // User is logged in, update remixes with usernames
          final migrationService = Provider.of<MigrationService>(context, listen: false);
          migrationService.updateRemixesWithUsernames().catchError((error) {
            print('Error during remix username migration: $error');
          });
        }
      });
    });
    
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
