class AuthService {
  static const String _baseUrl = 'http://test.shoppazing.com/api';

  static const String _accessToken =
      'RW6sv0Aly45tW_A3GKx0ubj0rWMg1Vl8-oJbp5M4NpAUBoIjd-2PMhG_VEE0VIQm_up5NMOQMFhB0Re3hLKWY_q1uR3-KfWPX63CWrOl97sW-_02Z-nWqSd7Mm3QCUNGkf1rwu7JuPp-PI_gCgpZ3Furz62B25Z_opbeEjhxgFLQRK6JQI_HiFtHl8pQCNi8ZsDsFsS-GarnYiqReOmXS9svJ8nA8Qv4dNoQX0W_UqY9W8uUFjkZJDj64tweMhf0D2dq6lxyVZxw5wUoJmL5hRmdVPwYRlyLWaL9Nkq--YwLnjxdufvj7ZAUxea8I_vLz_Ovv_5bKDmfpK0LhG_OXEBrgD_sHshGV1W3SIzDVLw2m8kGglykW_WHVk7Xgr4JdNxMpW3q8cMTS-ScscxbDDjXXr8daxytY4G-_w9cYRjfNUpCoAghY62-lWdK9oRIkP5U54sD7GFLl0Epe8EU0uI3M6Ln6NL3BKUKVW8TeeK2OR6DqaOZOMd32JqyHkJHdWi2D8YSYRz9-ywXT9JS3WsNfv6cJbBM2qvTOflMeUE3eQqQZP-BK0IbdMwdX_ywRMLCl4bwrUI_rxl5IZbw3PsawegQxCoCTnSrQIkzRxU6AzlLk3akQTC4BHhZHmkYO9vIM6FWpcO3TJLHT9wz-MjDyI9Up_riXdz4zjHpHr1i_gEP7lWwAwZwB0iVhAplhKxq4lmndDnDUpOc5tcU1HD92e65GtUvT_g7CoX5H7Wi14LflxpxRAY34E4tSjjUgPhLAllygmbYcKqG72JryeqpEnMgJ-jGOiWcvjHwWErRsqQrqEmQFADUQOfc-DxW7SVuq6h1OUdu5U9-3Y7vkfkim8uGYG7SSE5IOILpwb9TfgecLc71gy7ibhurI3uxBYUInlGh3hxaGNKEhmzIqoXhF_m5Wi4FdQuaEdJQOzeeSopVsIMjPRUdBrmvO_LqSy-9cgbx5p-w4KZxy3p_-19vwTLuErXTpBUvKl-Y19yXSHUTOlNVrv4Pd3YPq1O9KWT7ITWjWNPM7MZRery079mZPaCtJUWUsNC4FmugC78LLzc5kxCgwuS6HXi-Q_86TwvWXWyqBhsNs3okz2ciTmSIaD6161ccm9TnM4IfMK3UPiDJ_7TfGIup-G7C9ouerE9Qha5Ro675w01o99wjHcZkDX5c_XDKhBCtBmYY1Dk9T70dethmGdQKdLAP9WtF';

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
