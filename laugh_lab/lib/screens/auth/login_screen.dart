import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laugh_lab/services/auth_service.dart';
import 'package:laugh_lab/screens/auth/register_screen.dart';
import 'package:laugh_lab/constants/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('firebase_auth')
            ? 'Invalid email or password'
            : 'An error occurred. Please try again later.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/FinalLogo.png',
                      height: 180,
                      width: 180,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // App title
                  const Text(
                    'LaughLab',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share Your Best Jokes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.secondaryTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Email field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: AppTheme.primaryColor),
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: AppTheme.secondaryTextColor),
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.secondaryTextColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Password field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(color: AppTheme.primaryColor),
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: AppTheme.secondaryTextColor),
                        prefixIcon: Icon(Icons.lock_outline, color: AppTheme.secondaryTextColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _login(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Error message
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.errorColor),
                        ),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  
                  // Login button
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.accentColor.withOpacity(0.6),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('LOGIN'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 