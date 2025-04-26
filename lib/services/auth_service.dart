import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://test.shoppazing.com/api';
  static final _storage = FlutterSecureStorage();

  // Fallback token for when user is not logged in
  static const String _accessToken =
      'iruYYlxyILK0XYOI7Av8nxO7AV5wEIgdDbCKATKM-Rvn2xiA7DbkORaTgd4VHBsuP--nN62Eh0PdEYiOfRH1kDlV6D5ua7pHP-l_QLtxkqUB_kpR3DgfbKq1sbuFspOmLMrP9baEO56nJ8bAF2DGy6Ey04jcYo9Tv5taX6Rsvm-2jGDrE1Pk4VPgfdYbUzP5cE3kWMnBn3g9VGydbCPk6pbkmUErXLNYqhRWg-iF6qBmvN3WOZ8wIYnT4cWNyqiGbxYrfTrm8YlOQeNX0f3s6eeJtbir26QXtNBhuW3MyW0pjOfOnbaIjajoZCUaagmq8eSzsWT48GMbSV86JIZHXUZj76dDqErr1bIJbt8-ok85hfCM2O7mFs5EMLafwDGXDI9kShzULfSw_RQoCl9upfyyOXkQazMi5fkKKGFHKff85S6-gI3U7ikwOGYe8tKPyLpndKyL-S0_tqPSnhfA4M0MnswNegIGkTkCXPBMBTLoRiATkRNKdyMKxj8R6LVFdHxMe59L98mTFF7onm1UBkHTbflrGkRAPpD4bHA4D8FXWbxp0JINdyXEhMi1jE9Am5MsmKcZw8A11K-tFKvUObyHBABNwJCEDLdZojTn2FDi3a0ezulx35MMb-j4Fg-0DSV_WdwjcAf3FyEzDnxEy_rhaa9sTPKae-u2d23m5as';

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

  static Future<bool> verifyOTP(String mobileNumber, String otp) async {
    try {
      print('Verifying OTP for: $mobileNumber with OTP: $otp');
      final requestBody = {'UserId': '', 'MobileNo': mobileNumber, 'OTP': otp};
      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$_baseUrl/shop/verifyotplogin'),
        headers: getAuthHeaders(),
        body: jsonEncode(requestBody),
      );

      print('Verify OTP Response Status: ${response.statusCode}');
      print('Verify OTP Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Parsed response data: $responseData');

        // Log all possible success indicators
        print('Status code: ${responseData['status_code']}');
        print('Message: ${responseData['message']}');
        print('Success flag: ${responseData['success']}');
        print('Is verified: ${responseData['isVerified']}');

        // Check various success indicators
        if (responseData['status_code'] == 200 ||
            responseData['message'] == 'Ok' ||
            responseData['success'] == true ||
            responseData['isVerified'] == true) {
          print('OTP verification successful');
          return true;
        }

        // If we get here, the OTP was not accepted
        print('OTP verification failed. Response data: $responseData');
        throw Exception(responseData['message'] ?? 'Invalid OTP');
      }

      // If we get a specific error response, throw it
      final errorBody = jsonDecode(response.body);
      print('Error response body: $errorBody');
      throw Exception(errorBody['message'] ?? 'Failed to verify OTP');
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }
}
