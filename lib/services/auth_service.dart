class AuthService {
  static const String _baseUrl = 'http://test.shoppazing.com/api';

  static const String _accessToken =
      '4Vk_dUwST35pjzCcYGeqsc_A8Q5L0czvKZgpHrTy_zTZMG1m4EOr6IomFrE-Vj4_aQVxjcfX-skZ1Pb1o8WPFpCO4szqi1kwdihfufeHaZ4-UN5uk5v2kjFSVURGKTzdWb-gkw3vhWnoii9HR74u__-J62LLEvyY07RWRwYF2f2kK5EuqqvD24Pe3DaGcp0y3asm2TvCsd97EovbLj-ALCpfvYScv18nPJNTYhRoSw2tRGPfDBwHS6peikHR-lmCI0MqTm4DnjA8V9C0nARYDxg5_mr_DLnY6XPg-pNvy0GNu0J2y_d2u4FguNNwERxf3UfhArHl3LmeRSEAzeFO_lgD7ux6N4_0BwZzwRyukiaoYPKRvactcTAfG9WnnleUQxtPeaxCbnXke3S0lq5u2zyyzpKZnvAhozqCN1okGqioSFZn_hoEGqK-M44PHmO_r84UPAJrlZDqW8yTiuMpNux_4d73L5rNjXENi30-oVjQXffDnHvP5-_yothC-_jh4-vKlVklkX7_1B1JaD7Qyu45iLh3C_7XEdaY8sqGCLqC2ozRMyYVrdUHVNvRU1q23eoOgEcw8dfFyGmTZm3t0UmL0ed8tIVvv4PTGzWy6Tol4vOkQUVOkYkRcCqzWAoR0D4MuYTNHXBs_7LlGleYQ-8rXb7MxIHi_4LvQArYl8Q';

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
