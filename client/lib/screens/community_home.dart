import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../services/secure_storage_service.dart';

class CommunityApiService {
  // TODO: Replace with your actual API URL
  static const String baseUrl = 'https://your-api-domain.com/api/community';
  static const String frontendSecret = 'YOUR_FRONTEND_SECRET';

  // Headers with JWT token and frontend secret
  static Future<Map<String, String>> get headers async {
    final jwtToken = await SecureStorageService().getJwtToken();
    return {
      'Authorization': 'Bearer $jwtToken',
      'x-auth-app': frontendSecret,
      'Content-Type': 'application/json',
    };
  }

  // Headers for multipart/form-data requests
  static Future<Map<String, String>> get multipartHeaders async {
    final jwtToken = await SecureStorageService().getJwtToken();
    return {
      'Authorization': 'Bearer $jwtToken',
      'x-auth-app': frontendSecret,
    };
  }

  // Debug helper to check API connectivity
  static Future<void> debugApiConnection() async {
    try {
      if (kDebugMode) {
        print('🔍 Debugging API Connection...');
        print('📡 Base URL: $baseUrl');

        final jwtToken = await SecureStorageService().getJwtToken();
        print('🔑 JWT Token: ${jwtToken != null ? 'Available' : 'Missing'}');
        print('🔒 Frontend Secret: ${frontendSecret.isNotEmpty ? 'Set' : 'Missing'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Debug Error: $e');
      }
    }
  }

  // Enhanced error handling for API responses
  static void _handleApiError(http.Response response, String endpoint) {
    if (kDebugMode) {
      print('❌ API Error for $endpoint:');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body.substring(0, response.body.length.clamp(0, 500).toInt())}...');

    }
  }

  // ==================== COMMUNITIES ====================

  // Get all communities with enhanced error handling
  static Future<List<dynamic>> getCommunities() async {
    try {
      await debugApiConnection();

      final url = '$baseUrl/communities/';
      if (kDebugMode) {
        print('🌐 Making request to: $url');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await headers,
      );

      if (kDebugMode) {
        print('📨 Response Status: ${response.statusCode}');
        print('📨 Response Headers: ${response.headers}');
      }

      if (response.statusCode == 200) {
        // Check if response is actually JSON
        final contentType = response.headers['content-type'];
        if (contentType != null && !contentType.contains('application/json')) {
          throw Exception('API returned non-JSON response. Content-Type: $contentType');
        }

        try {
          final decoded = json.decode(response.body);
          if (kDebugMode) {
            print('✅ Successfully parsed JSON response');
          }
          return decoded is List ? decoded : [decoded];
        } catch (jsonError) {
          if (kDebugMode) {
            print('❌ JSON Decode Error: $jsonError');
            print('Raw Response: ${response.body}');
          }
          throw Exception('Invalid JSON response: $jsonError');
        }
      } else {
        _handleApiError(response, 'getCommunities');

        // Handle specific error codes
        switch (response.statusCode) {
          case 401:
            throw Exception('Authentication failed. Please login again.');
          case 403:
            throw Exception('Access denied. Check your permissions.');
          case 404:
            throw Exception('Communities endpoint not found. Check API URL.');
          case 500:
            throw Exception('Server error. Please try again later.');
          default:
            throw Exception('Failed to load communities: HTTP ${response.statusCode}');
        }
      }
    } on SocketException {
      throw Exception('Network error. Please check your internet connection.');
    } on http.ClientException catch (e) {
      throw Exception('Request failed: $e');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error in getCommunities: $e');
      }
      throw Exception('Failed to load communities: $e');
    }
  }

  // Get specific community details
  static Future<Map<String, dynamic>> getCommunityDetail(int communityId) async {
    try {
      final url = '$baseUrl/communities/$communityId/';
      final response = await http.get(
        Uri.parse(url),
        headers: await headers,
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && !contentType.contains('application/json')) {
          throw Exception('API returned non-JSON response');
        }
        return json.decode(response.body);
      } else {
        _handleApiError(response, 'getCommunityDetail');
        throw Exception('Failed to load community details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load community details: $e');
    }
  }

  // Create new community
  static Future<Map<String, dynamic>> createCommunity({
    required String name,
    String? description,
    File? profilePicture,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/communities/'),
      );

      request.headers.addAll(await multipartHeaders);
      request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;

      if (profilePicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicture.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        _handleApiError(response, 'createCommunity');
        throw Exception('Failed to create community: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create community: $e');
    }
  }

  // Get all posts with enhanced error handling
  static Future<List<dynamic>> getPosts() async {
    try {
      final url = '$baseUrl/posts/';
      final response = await http.get(
        Uri.parse(url),
        headers: await headers,
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && !contentType.contains('application/json')) {
          throw Exception('API returned non-JSON response');
        }

        try {
          final decoded = json.decode(response.body);
          return decoded is List ? decoded : [decoded];
        } catch (jsonError) {
          throw Exception('Invalid JSON response: $jsonError');
        }
      } else {
        _handleApiError(response, 'getPosts');
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  // Get user activity with enhanced error handling
  static Future<Map<String, dynamic>> getUserActivity() async {
    try {
      final url = '$baseUrl/users/activity/';
      final response = await http.get(
        Uri.parse(url),
        headers: await headers,
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && !contentType.contains('application/json')) {
          throw Exception('API returned non-JSON response');
        }
        return json.decode(response.body);
      } else {
        _handleApiError(response, 'getUserActivity');
        throw Exception('Failed to load user activity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load user activity: $e');
    }
  }

  // Mock data for testing when API is not available
  static List<dynamic> getMockCommunities() {
    return [
      {
        "id": 1,
        "name": "Flutter Developers",
        "description": "Community for Flutter enthusiasts",
        "created_at": "2025-01-20T00:00:00Z",
        "total_members_count": 150,
        "user_role": "member",
        "profile_picture": null
      },
      {
        "id": 2,
        "name": "Health & Wellness",
        "description": "Share your health journey",
        "created_at": "2025-01-19T00:00:00Z",
        "total_members_count": 89,
        "user_role": "admin",
        "profile_picture": null
      },
    ];
  }

  static List<dynamic> getMockPosts() {
    return [
      {
        "id": 1,
        "title": "Welcome to our community!",
        "content": "This is a sample post to test the functionality.",
        "created_at": "2025-01-20T12:00:00Z",
        "updated_at": "2025-01-20T12:00:00Z",
        "votes_like_count": 5,
        "votes_dislike_count": 0,
        "saved_count": 2,
        "community_name": "Flutter Developers",
        "files": [],
        "user_vote": null,
        "user_saved": false,
        "user_comments": []
      }
    ];
  }

  static Map<String, dynamic> getMockUserActivity() {
    return {
      "user_id": 1,
      "email": "user@example.com",
      "communities": [
        {
          "community_id": 1,
          "community_name": "Flutter Developers",
          "role": "member",
          "user_posts_count": 3,
          "liked_posts_count": 5,
          "disliked_posts_count": 0,
          "saved_posts_count": 2,
        }
      ]
    };
  }
}
