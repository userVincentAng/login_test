class AuthService {
  static const String _baseUrl = 'http://test.shoppazing.com/api';

  static const String _accessToken =
      'RoTmGqamVvr0XtFny5qEaB6pPDna6vyln4LStc990a0nfHFHInyAnKbFW2Z4PKlzyu4b1mMeRWsaZMS8wkGMSlspbd4qLY8t09hcNlQbZGcNduGKf7z5ExWI2ZjTmYUXW_7usQQmU4OGisnSZ1iEw7eRAvmakAtReaXNvK1KR98W_5gV7lBQWFQ-T3QndKOme5Mkwi7CUtaIvB7q1nB0-dWBFNbCopzo9QWwGqwvCUzmC0CIbUW_9ZDsmYRXQNvpHGBWQeCjhzObXL-52q9nn9vScjRfYvE-9eygAik-bMUthvFnCz0sHR_jvbXs0uBMt6xxpp9a0RpGbLEEsrID1Hkglx8E_LPsaC_ZT8zKxrZ3d-F8lnps5O4UBe9x2Jf5OXDaRiGoMjLMZzaGfgMaDqtmyCl-ELTQlSi16onP065GfMROrbjy8O_OdDXhygKKRyhJk8zl_YFojzJ_imhwQBuPqWJA1WqRh8pisz4VI8dzBhig0AN--fEIW0j00REnhrJxhRS7mvt1atV6RGQ29Jsgp5unEeSvz1T8qHty0cpjqPG0dXHoE_ePp8TPOAn9UzuVKGdrQGS-C_IIjK-NNyCW1DJBDMC1huoqH4FyB1mUSsN14oXIajuJsZ2CFEFf38dKxClWjSiE4Zlo2CCFZa6JiqN5rWlsVDdISz-VfgRVW9fGFbbOUlfN7swqaUM4U3QKPjIOomLbdg3PK5vUztnOHnIQWXeahGq0eWd6Giip2xhB-RoD3qn5betMmRfeGdEyh-dvW_toG1vTC7eh-VCe6_aEmaA-saWy3WMelque_OsG7bHVoHhzfpgqfSoSWe_9VKM7sKo1C6GpBNeoZcqfMBjmhT_vmxfwxeg0JAvg6HKQJW2Aj1dQJeHSQHYIGNuIRD9S04a5vKo7nAJLIXLferwd4gfzbPl2RjQhJ5KYn3MfcMM7DOar1H0g3rnd6hMsJNpEyMBMI8ky_7KTUNCDiZtlw-LOwx4vLSaumeAoqGpZHNYAKFbSHPZ17a4nT8GzW_5VQysyY3rozrVGqzphvUYqwRb_wdNpRhBg9odF-NBsOQFQP7ShcdZS5WXoDO9l30Qe4lTTuDIKGb0JWNU9UeMncIK3v20vD_sXXtsp1GyxPoQpiJxBd_RA13xIWuFGtHtQgNEcZCbmsTriGo--nRhzbH9GjCWiq47BrxGn7Fzd_lxPhi19lzR15DSK';

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
