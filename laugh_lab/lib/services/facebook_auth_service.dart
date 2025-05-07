import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthService {
  static final FacebookAuthService _instance = FacebookAuthService._internal();
  factory FacebookAuthService() => _instance;
  FacebookAuthService._internal();

  Future<Map<String, dynamic>?> login() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Get user data
        final userData = await FacebookAuth.instance.getUserData(
          fields: "id,name,email,picture",
        );
        
        return {
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'picture': userData['picture']?['data']?['url'],
          'accessToken': result.accessToken?.token,
        };
      }
      return null;
    } catch (e) {
      print('Facebook login error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await FacebookAuth.instance.logOut();
  }
} 