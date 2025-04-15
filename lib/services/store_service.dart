import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import '../models/store_item.dart';
import 'auth_service.dart';

class StoreService {
  final String baseUrl = 'http://test.shoppazing.com/api/shop';
  final bool useMockData = false; // Set to false to use real API

  Future<List<Store>> getNearbyStores({
    required double lat,
    required double lng,
    int offset = 0,
    int recordsPerPage = 4,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getNearByStoresByPage'),
        headers: AuthService.getAuthHeaders(),
        body: json.encode({
          'Lat': lat,
          'Lng': lng,
          'OffSet': offset,
          'RecordsPerPage': recordsPerPage,
        }),
      );

      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status_code'] == 0) {
          final stores = (data['Stores'] as List)
              .map((store) => Store(
                    storeId: store['StoreId'],
                    name: store['Name'],
                    addressLine1: store['AddressLine1'],
                    addressLine2: store['AddressLine2'],
                    storeUrl: store['StoreUrl'],
                    lat: store['Lat'],
                    lng: store['Lng'],
                    storeRating: store['StoreRating'] ?? 0.0,
                    storeHours: (store['StoreHours'] as List?)
                            ?.map((hours) => StoreHours(
                                  id: hours['Id'],
                                  storeId: hours['StoreId'],
                                  dayOfWeek: hours['DayOfWeek'],
                                  startTime: hours['StartTime'],
                                  endTime: hours['EndTime'],
                                  isEnabled: hours['IsEnabled'],
                                  isWholeDay: hours['IsWholeDay'],
                                ))
                            .toList() ??
                        [],
                    isStoreOnline: store['IsStoreOnline'] ?? false,
                  ))
              .toList();

          // Always add Gabs Binalot United if it's not already in the list
          final gabsStore = Store(
            storeId: 1,
            name: 'Gabs Binalot United',
            addressLine1:
                '2889 Batulao St., Holiday Homes II Brgy San Antonio, San Pedro Laguna',
            addressLine2: null,
            storeUrl: '/images/b-cpa.jpg',
            lat: 14.3106081,
            lng: 121.1157218,
            storeRating: 5.0,
            storeHours: [
              StoreHours(
                id: 1,
                storeId: 1,
                dayOfWeek: 0,
                startTime: '06:00',
                endTime: '22:00',
                isEnabled: true,
                isWholeDay: false,
              ),
              StoreHours(
                id: 2,
                storeId: 1,
                dayOfWeek: 1,
                startTime: '06:00',
                endTime: '22:00',
                isEnabled: true,
                isWholeDay: false,
              ),
              StoreHours(
                id: 3,
                storeId: 1,
                dayOfWeek: 2,
                startTime: '06:00',
                endTime: '22:00',
                isEnabled: true,
                isWholeDay: false,
              ),
              StoreHours(
                id: 4,
                storeId: 1,
                dayOfWeek: 3,
                startTime: '06:00',
                endTime: '22:00',
                isEnabled: true,
                isWholeDay: false,
              ),
              StoreHours(
                id: 5,
                storeId: 1,
                dayOfWeek: 4,
                startTime: '08:00',
                endTime: '22:00',
                isEnabled: true,
                isWholeDay: false,
              ),
              StoreHours(
                id: 6,
                storeId: 1,
                dayOfWeek: 5,
                startTime: '06:00',
                endTime: '22:00',
                isEnabled: true,
                isWholeDay: false,
              ),
              StoreHours(
                id: 7,
                storeId: 1,
                dayOfWeek: 6,
                startTime: '06:00',
                endTime: '22:00',
                isEnabled: true,
                isWholeDay: false,
              ),
            ],
            isStoreOnline: false,
          );

          if (!stores.any((store) => store.storeId == 1)) {
            stores.insert(0, gabsStore); // Add at the beginning of the list
          }

          return stores;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch stores');
        }
      } else {
        throw Exception('Failed to load stores: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stores: $e');
      return []; // Return empty list instead of mock data
    }
  }

  Future<Map<String, dynamic>> getStoreItems(int storeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getstoreitemsbystoreid'),
        headers: AuthService.getAuthHeaders(),
        body: json.encode({'storeid': storeId}),
      );

      print('Store Items API Response status: ${response.statusCode}');
      print('Store Items API Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status_code'] == 200) {
          final items = (data['Items'] as List)
              .map((item) => StoreItem.fromJson(item))
              .toList();

          final categories = (data['Categories'] as List)
              .map((category) => Category.fromJson(category))
              .toList();

          return {
            'items': items,
            'categories': categories,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch store items');
        }
      } else {
        throw Exception('Failed to load store items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching store items: $e');
      return {
        'items': [],
        'categories': [],
      };
    }
  }
}
