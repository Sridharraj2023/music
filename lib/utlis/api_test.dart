import 'dart:convert';
import 'package:elevate/utlis/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiTest {
  static Future<void> testMusicApi() async {
    print('=== API Test Started ===');
    
    // Test 1: Check API URL
    final String apiUrl = ApiConstants.apiUrl;
    print('API URL: $apiUrl');
    
    // Test 2: Check if user has auth token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print('Auth Token: ${token != null ? "Present (${token.substring(0, 20)}...)" : "Not Found"}');
    
    if (token == null) {
      print('❌ No auth token found - user needs to login');
      return;
    }
    
    // Test 3: Test music endpoint
    final String musicEndpoint = "$apiUrl/music";
    print('Testing endpoint: $musicEndpoint');
    
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      print('Making API request...');
      final response = await http.get(Uri.parse(musicEndpoint), headers: headers);
      
      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        print('✅ API call successful!');
        
        // Parse response
        try {
          List<dynamic> jsonResponse = jsonDecode(response.body);
          print('✅ JSON parsing successful!');
          print('Number of music items: ${jsonResponse.length}');
          
          if (jsonResponse.isNotEmpty) {
            print('✅ Music data found!');
            
            // Show first item as example
            if (jsonResponse.first is Map<String, dynamic>) {
              final firstItem = jsonResponse.first as Map<String, dynamic>;
              print('First item keys: ${firstItem.keys.toList()}');
              print('First item title: ${firstItem['title'] ?? 'N/A'}');
              print('First item category: ${firstItem['category'] ?? 'N/A'}');
            }
            
            // Count by category
            Map<String, int> categoryCount = {};
            for (var item in jsonResponse) {
              if (item is Map<String, dynamic>) {
                String categoryName = 'Unknown';
                if (item['category'] != null) {
                  if (item['category'] is Map<String, dynamic>) {
                    categoryName = item['category']['name'] ?? 'Unknown';
                  } else if (item['category'] is String) {
                    categoryName = item['category'];
                  }
                }
                categoryCount[categoryName] = (categoryCount[categoryName] ?? 0) + 1;
              }
            }
            
            print('Music by category: $categoryCount');
            
          } else {
            print('⚠️ API returned empty music list');
          }
          
        } catch (e) {
          print('❌ JSON parsing failed: $e');
          print('Response body: ${response.body}');
        }
        
      } else {
        print('❌ API call failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        if (response.statusCode == 401) {
          print('❌ Authentication failed - token may be invalid or expired');
        } else if (response.statusCode == 403) {
          print('❌ Forbidden - user may not have access to music');
        } else if (response.statusCode == 404) {
          print('❌ Music endpoint not found');
        } else if (response.statusCode >= 500) {
          print('❌ Server error - backend may be down');
        }
      }
      
    } catch (e) {
      print('❌ Network error: $e');
      
      if (e.toString().contains('SocketException')) {
        print('❌ Network connectivity issue - check internet connection');
      } else if (e.toString().contains('TimeoutException')) {
        print('❌ Request timeout - server may be slow or down');
      }
    }
    
    // Test 4: Test alternative endpoints
    print('\n--- Testing Alternative Endpoints ---');
    
    // Test health endpoint
    try {
      final healthUrl = apiUrl.replaceAll('/api', '');
      print('Testing health endpoint: $healthUrl');
      final healthResponse = await http.get(Uri.parse(healthUrl));
      print('Health check status: ${healthResponse.statusCode}');
    } catch (e) {
      print('Health check failed: $e');
    }
    
    print('=== API Test Completed ===');
  }
  
  static Future<void> testWithoutAuth() async {
    print('=== Testing API Without Authentication ===');
    
    final String apiUrl = ApiConstants.apiUrl;
    final String musicEndpoint = "$apiUrl/music";
    
    try {
      final response = await http.get(Uri.parse(musicEndpoint));
      print('Response without auth: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Error without auth: $e');
    }
  }
}
