class AuthService {
  static const String _baseUrl = 'http://test.shoppazing.com/api';

  static const String _accessToken =
      'JqD8V-CktgK2HYL1imkemDy_HStPtGaOnUCKHCHVB_FXoPrdRv2d8Jt-cMi9yjNbgjcUAtayszEv5gkHZuTBBq1JWvP6WxsnYpS5EnSxI_H14oHOC2SrfR1ndVC0fop2XxptubEswJI_DQDHdBrVfX_mKUgPrbVmNLOnMNCtPBr3ndCrtMYcZy6AgKRlxVuFi9x7hj3F2XrwPwo3m-bniQfxNzYI6afQgK8XLKXryf0cVhq-ENwlGNb7zgrfGAbdbzT3Sn5oL-RwJ4OaPz_-_KNUeZiN5pfH3kN0949ZC9jwBfXaqgJASoglZrYPfOuSOzpOlf5jKaoR6mreVH5zm3XjgUba7cFm_w0bovoRhctRU2suuIZfYOAMKOwmk0t8MMT3L_sUDpXKlhvxn-mAzOs1AcwYTPGQPW3lFT5jcgmNbW5kwKiRunjMIDkml4AcG84I-MFTmUZVWZGpz05_SWNX61njnfl3ZH1w9PdWecXDTpsBMPFO7gUgqT5nCrBKX3oW92l-p4jxfViNgKH2KDBYSOWtSWjrK5MOznwmvH5y_MUwO25fKt5ltIRdngpKin8j__lgk-iwRDhockeqNRhkL_5r1NVvbDo6Tq-vgmagz80UmhkNr4v1tCa0qoSa1UaJcq73afOv1J0hObqHCcuZCZBV9JwFaqrgCyRiWO1v6O7aKIv_d5wyqg2-vsgYhYm4AXx68IOxcU-cVhAn5vxvxsYFYPyS0w8TjFdDQrxPmJiTEfroiPW4yYJ8vkKn38Xo9fIsGO8f-f1aw-bpPtH63vdvfr5i8ZjSRNWocvuEjXHf92kmK0JZQ8cKz4gKle8U77p2o4-W47kQSnw4gFT_FAPQAdqNFJ8J1hh1L-BuzXLf4f5ARo5xcEedyU43aLEOqS22VSTqipGoEE-mMSWKgK6oiFiYUVv5-c92oGexVEM4ZCYtudAJNFt-eKS2upXkJ_xoIfrfRCct-6WZiuogAfT0QfneotC3rkEr-40E6W1w2U6mmksY_V_Q_c452NX204Pi1vPKB7x1lRxcq4tZwKjDY0jHx1xQKf0mlZz4UiQBVGGdHQnRX9aGhp4IjEJL7-Ck8H7ghJBz9vVspyaCiIF8ji2t0lr22xXmyz7puYMf3niQZALDaigqkKvRAcjg1nE_p7FQyWRokj0yKk_Q7Ot8h7D2kpCu3lS7IYofHa2-nEys_7gFsYCHBTLv';

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
