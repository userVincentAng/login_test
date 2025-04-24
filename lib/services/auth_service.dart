import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  static const String _baseUrl = 'http://test.shoppazing.com/api';
  static final _storage = FlutterSecureStorage();

  // Fallback token for when user is not logged in
  static const String _accessToken =
      'XMCs9rMmZtL67wu7mX5wl_NEOApQ0iK1gSABGQLt5du3qripHzjKagfGNogFqaDM4L7rOzI-h33zc9qIIeWUXuPjHHaw8ZCQ3PDTyJYAqN3y0w9HEunOwspBS0-kTvUe0r-T3QR_dsU-y0BK0O2pnSQUx32my39xAPpCxlzy99Oj1w7jKiK1ktY2-coe3xGCWVbCcCzDwKVqhjKcJ92bW9mR_3oySjKMlE3Zr7KMUKFYd3Zvi6YPYrLwSP0xYYOzfc0GqVZWJRB33__ViBwCA-Vg5Btu6SjmyhLpKVu7djgNTx5fHHq3a3PCL30ghnfAjDG7M60CQD2YxmD6CSCymO-iFBP3FJPaHH9Ez1fvYCkDAYYPJ_Mt6FSjUxFZiMdS4mGEWyDQNrL3V17Al872-LCHiXXO1cVojicG_sj16BSmw_NcvMj9ovV_fhegL04GKTKz3T-pt9bI3oYGQa4L3nTyuu2h3Rp1vLJntR2ApI6AdyvfaHYv_CQVCg7TOn7MYy3SeMvuse-EiicpxbWUqhzkuhxm3Rx_T_gFXJppbq7ZihkpufqZZ15bGl98SV-9CwiIi9FpjqbWlOKpdH8iFAxCnPbHP9L7yYGG1md9E2I7-TYDYR_SFezOOuzK4ughzGjiWn6hT9IEv7mvDORQmESs6hgEXncIoQV_0eQQn5v8-mAumq11niuG_RKOvvH5MwFicXaP0jGftXNgJskJt4gtyUKDlKzmh2XnPm6WCMgXtLrJzPOD9cgIZlJYVKMYZZhZTHJvnIbMuG2plEgF30c5QGz2T6dxZ5LtZTQQrbnF7Mv6lRCOUnvg4XAZeJdrZb6ZkdcfNHUwsXkHl3qGgK5aieEKp7w1FQa0-8anztqrufrnwwzjN_9aRR_EeIFfkjSugmYvgTYFG1puBFdCZJsgrUKc9NfjurL5W-tCy21nc74srybfTUC2ydv4IVHDc9lsrLabnZG-Cgm_ehkmkpsNCWuFX0_mrXkYEo2pO0KOYpLawY1g4cCqLZRdMOYbKvSOWaKCwMsKeQhoHJK5qp_OJd4cd6SlmKR9KEsM9yt0yxxy1cTsBPHnrKS8AiGECXaVrq2dUQVclnpA4VH-KUNu5MpTCYeF0h6UVXz_vmmZ3a3bTnP6BaCupq5vAfx8sux7xoATFvkTXfkIdU1AALRpFvpM5O1iA8Vamzn56tCE7C-UfPxV3S2-Ok3232_S';

  // Getter for access token
  static String get accessToken => _accessToken;

  // Keys for storing user data
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';

  // Cached user data
  static Map<String, dynamic>? _userData;
  static String? _token;
  static String? _userId;

  // Getter methods
  static String? get token => _token;
  static String? get userId => _userId;
  static Map<String, dynamic>? get userData => _userData;

  // Method to store user data after successful login
  static Future<void> saveUserSession(
      Map<String, dynamic> loginResponse) async {
    try {
      // Extract data from login response
      final token = loginResponse['access_token'];
      final userId = loginResponse['user_id'];

      // Store in secure storage
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userIdKey, value: userId);
      await _storage.write(key: _userDataKey, value: jsonEncode(loginResponse));

      // Cache in memory
      _token = token;
      _userId = userId;
      _userData = loginResponse;
    } catch (e) {
      print('Error saving user session: $e');
      throw Exception('Failed to save user session');
    }
  }

  // Method to load user session on app start
  static Future<bool> loadUserSession() async {
    try {
      _token = await _storage.read(key: _tokenKey);
      _userId = await _storage.read(key: _userIdKey);
      final userDataStr = await _storage.read(key: _userDataKey);

      if (userDataStr != null) {
        _userData = jsonDecode(userDataStr);
      }

      return _token != null;
    } catch (e) {
      print('Error loading user session: $e');
      return false;
    }
  }

  // Method to clear user session on logout
  static Future<void> clearUserSession() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userDataKey);

      _token = null;
      _userId = null;
      _userData = null;
    } catch (e) {
      print('Error clearing user session: $e');
      throw Exception('Failed to clear user session');
    }
  }

  static Map<String, String> getAuthHeaders() {
    final token = _token;
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    // Fallback to static token if no user token is available
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };
  }

  static Future<bool> logout() async {
    try {
      await clearUserSession();
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }
}
