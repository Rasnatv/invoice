// import 'package:shared_preferences/shared_preferences.dart';
//
// class TokenStorage {
//   TokenStorage._();
//
//   static const _tokenKey = 'auth_token';
//   static const _tokenTypeKey = 'token_type';
//
//   static Future<void> save({required String token, String? tokenType}) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//     await prefs.setString(_tokenTypeKey, tokenType ?? 'Bearer');
//   }
//
//   static Future<String?> readToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }
//
//   static Future<String?> readTokenType() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenTypeKey);
//   }
//
//   static Future<void> clear() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//     await prefs.remove(_tokenTypeKey);
//   }
// }
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();

  static const _tokenKey = 'auth_token';
  static const _tokenTypeKey = 'token_type';
  static const _roleKey = 'user_role';
  static const _onboardingSeenKey = 'onboarding_seen';

  static Future<void> save({required String token, String? tokenType}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenTypeKey, tokenType ?? 'Bearer');
  }

  static Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> readTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  /// Saved alongside the token so Splash can auto-route to the right
  /// dashboard on a fresh app start without hitting the login API again.
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> readRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_roleKey);
    // Onboarding flag deliberately NOT cleared — a logged-out user who
    // already saw onboarding shouldn't see it again.
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
  }
}
