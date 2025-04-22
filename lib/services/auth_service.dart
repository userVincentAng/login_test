class AuthService {
  static const String _baseUrl = 'http://test.shoppazing.com/api';

  static const String _accessToken =
      'huFpoFs1ekI0zKdyau4-UIlCpOGRhNu0Yme0GOgi-UkDBJrOErAM64KgWrGPHKMCgwK-2v5i-pkdDo_T7CqrOwO0Je7RiY2bXOebSazNUMrvZ5b06D1MWolbYw1RygjEVYOgjBMlYZSBzxlShhoS-oemk0bAddySeyw57BRswXdYaFoC5ilZuLLMj0DHoXIiat8LdgiFvxbuEWCxn5txsiD8xhIm7p8Z-NuUNdlSH-qYoslbQKyRvv3Rk4UMrDkDQkQhSaId5vUI3Ezlx13Q-bXZfgatVlbY4AiXv8Alijmvs8VDtAsOmUmFxNVLY3yKrORV2xEE9-RuKsPeD59fAjBlN4rJl4HfcNg8ssxBhWarQC5c9ow199IFTOx99qmiX_w6d-dI-hfGWyYDdT79dSTocHG375VVcxqp2nuyfpVtIsxYQWVRcx2mJvqtr6jZId2xnmx9tNmwvNtsbMs0S1XqFtXjNaDnte-82kejbCChoSvVXgAK1LyOeSPxoiWYGkViM_q2zGizrxkrjYwgSWXNlkgqC872HcJBH9LhbJXKATughGZYpkZ1m4yk9_7zUSV8GpB-_HClM0WQVb-SZpg4y_obKlCkX6blbD9Duknan_JnJbQ7mgaa482F38BkZNb4CCcYlefKkxZkPA9jOAx_nVzSg-E1PJ6yYk7Fz1s';

  static Future<bool> authenticate() async {
    // Always return true since we're using a static token
    return true;
  }

  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };
  }

  static Future<bool> logout() async {
    try {
      // Since we're using a static token, we don't need to make an API call
      // In a real app, you would make an API call to invalidate the token
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }
}
