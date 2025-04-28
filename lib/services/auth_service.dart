import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://test.shoppazing.com/api';
  static const _storage = FlutterSecureStorage();

  // Fallback token for when user is not logged in
  static const String _accessToken =
      'jCTLMKE0Tquj_YfsRRtdvdAhwUOqPitbDLg_erWfqbA3TZhfotC1pkKiwJOSOO3iHircLe5dQHsLwoiDqUbGn4PQ_-e-XtZk2Zg5jutVapVHgQL4sSx2dAWRLJb9lm9Lhg7KoPCrHAdwmOnCxUOHOuJLwtSj2YmddqIImInaaemYFNuMRQ1f0XfXp3Une8Yl5lNcJYJPR1S-71Yvjzm7AeERP_x4V7JdUE3F8jvVBw6gETO28ko8_vPsWXfAwHmBHbgPXY6KQ2lvNRwq7EwkNEJTdWl1N5ygDZSEBoh8zLnOyo_7nupEjFBMliMqBJ3TYYQSgGXSnf9YKNOmFlBzlyI5liBzmvklL966uFhwKKeuPefbc4WVpDFl25DgZXjiiO6bIqnlS_iwMM3kQGT4b4U5_qH1OF_p_5dd3U21PDT_EvjWvkXaluoae0jzEQh7v2SBiunHK6nBpLrbHfGYpiAlYjpZym6Ays48FOkLN_ZuAXNvnvXKmpTbDVTai71-gb22uiHuYdpH1zs01iq76MXl_MOq0ktoP-acFTN7T21MRfd_jFdShgzU6-8AMAXSzYVlIuXDCSM-9ST8LXLMYbNJsvcAwCq0t1C-Godwn7rMw02HmI4-ZbM8jC2ezZ9sHC9g0GIM-H9tc1AcTW6axvoLwaFLm_k2aMxl2wITFZB8RelJpW5dbpD7sr9hxKMvkvrTfyEij7EbeZjysg3H8vBT_i6LmMGo0Rw_tPAUh1hNSD4td8BJva_afteVUWaxDNm1y3VVlaOZgZ6DgarRgloOoWx7sTvQg-bUmFot5qJtCkwRARLujfEiXGCqrD7pNCW1ITTD-phaN5nzlwdfPz-yg63bA4fqtQCWYu3aJn8ECw4hqZHwAObZ4obqOrBJIan4fQRrG6Lkfn4t2NEyr6QxBQGrWAqNjx_SPvCqtVHNE1HXVQHaYoqyY3Tli_9GPxVGQLgOg4ROuj2yryw0bFqpdOF8zhMPaXOKXx1rAyQinOVwLeeQVujb9jZjg3_vUAOM2T1L3iPYq3Qsu_pu15LuzjOwQgamJycP6Ejr0eFdhVCHaLDKFpTN_E16uqlrf1q0URqJcS4KqGcYR3cEZBWQzAsMfhWZG3KE1Ulsgmf9xO4D_KboTsalL2_2Ai1AXdIBQV5vIUGGOjretkDaSxxQDmVCYH3nA4N_Qe76DS6UGCHJjSAY-wwn4CMrKMoM';

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
