class AuthService {
  static const String _baseUrl = 'http://test.shoppazing.com/api';

  static const String _accessToken =
      'QHQdou_BvzKWEXqlKf9qEkySupzyh5fSj67PSELrLNbclmWB-iY9SzZ1c2fXw_JDCswWZW8SQxTEmV0Nn83o1whqMj9yr6si2YKybkz5knn7Xd0OlLpZa6LWqKVzj497o7S1ntuYbVHcrO1Gxzzbuf_3giYecVfl628IEkl4VSVGV5WF7pbkvslBkbW0q78Yzz2paT3a4jAogZna2UXtk6gAVd_91vuFSaB38wGDApd_5hTc-T8QPYuvOxnIHZUzI9rygdDG3ykXJnCKYxOHnTuuL_VUHpaoUE1uhuzjBOlQQbnXbu3mav-tpU0c0sAxjwU6Zabz8mX2-4j94sTfkiaomCijsKNOuyUZcI_YwGNSkDfb2z5583I_UcQTRlTe2Lhe-FvY21x2z-dXc1qf6VOT1Qk4vrAeh4CV7HKT02zI_bvtGfNA6pVfFkT9vRC8qH9ZdBiswgHsasDnCXMpXT7rgEduG4u1BiGdozzZKqaHsWd7x_Q9YykaXzojlpb9VWzEzWwhtczSaw2kZ7DNs6fy_1XNDx-mBdE0iIk8r_SLQ1YEFVWAEv0smaSnC1Dc8SN5sPwMY2lU7xtZ_-bUqBnMfdVEA3JrA12GybBokPzgW4MR-SDGyFSgDJ3pBnLcu2P54BvbooRWoibcIBA_m1SpwxQJD4NL6iFvKd5jNJA-NL-zQ4Ve_nOvr0xQOb-y-srMKw4HQ39pjzuoeUPFNWjRVQRcLywJc9aCIJrUHXwhUgy3S6DiikBT-scqLfgABusbQUqoZhHvv2hyIerNc3aVE7Uyqzd_5PVJDoGFged3hXye6bDmtqYFrT49QnANgrhSkF0YmaERi2q2xcjDuxmA7TVnYNDOx3gvP7kCCODdzMRC7b6RV6PutIH3TAIOgv9DojXF6dxHBopchSpP3zTFEZMLSglDMGOt1qbvZgCt3RSbSQWnXSkEXXTaCoCbPwYyOPcpaJ8HX-hVoWh1QzzvBCeN05sCzzRkbG9sZJs5SLArF5MlLZ9YA5-fdmxBgTYU1Dn0-pWHcXY6A7VMcO-EK4KTuL_5-iisqWT1aI_eMpsuK5NmefbQsWD5Ql6GJGD-Zo_D4Z6y7uc25BxYjZ0ftVkeG9Mf70oeqAYba9DcYrQIo5qtDKnemPrbyyEqljFaUK-euE862zX8Q9nGG-G0t4LcQZUV8UGKD1p2nZA3R5xPMmr3-1wGX_OJEmyU';

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
}
