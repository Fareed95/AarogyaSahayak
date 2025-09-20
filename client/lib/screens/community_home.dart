// import 'dart:io';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../services/secure_storage_service.dart';
//
// class CommunityApiService {
//   static const String baseUrl = 'https://your-api-domain.com/api/community';
//   static const String frontendSecret = 'YOUR_FRONTEND_SECRET';
//
//   // Headers with JWT token and frontend secret
//   static Future<Map<String, String>> get headers async {
//     final jwtToken = await SecureStorageService().getJwtToken();
//     return {
//       'Authorization': 'Bearer $jwtToken',
//       'x-auth-app': frontendSecret,
//       'Content-Type': 'application/json',
//     };
//   }
//
//   // Headers for multipart/form-data requests
//   static Future<Map<String, String>> get multipartHeaders async {
//     final jwtToken = await SecureStorageService().getJwtToken();
//     return {
//       'Authorization': 'Bearer $jwtToken',
//       'x-auth-app': frontendSecret,
//     };
//   }
//
//   // ==================== COMMUNITIES ====================
//
//   // Get all communities
//   static Future<List<dynamic>> getCommunities() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/communities/'),
//         headers: await headers,
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load communities: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load communities: $e');
//     }
//   }
//
//   // Get specific community details
//   static Future<Map<String, dynamic>> getCommunityDetail(int communityId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/communities/$communityId/'),
//         headers: await headers,
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load community details: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load community details: $e');
//     }
//   }
//
//   // Create new community
//   static Future<Map<String, dynamic>> createCommunity({
//     required String name,
//     String? description,
//     File? profilePicture,
//   }) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/communities/'),
//       );
//      
//       request.headers.addAll(await multipartHeaders);
//       request.fields['name'] = name;
//       if (description != null) request.fields['description'] = description;
//      
//       if (profilePicture != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'profile_picture',
//           profilePicture.path,
//         ));
//       }
//
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//      
//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to create community: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to create community: $e');
//     }
//   }
//
//   // Update community
//   static Future<Map<String, dynamic>> updateCommunity(int communityId, Map<String, dynamic> data) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/communities/$communityId/'),
//         headers: await headers,
//         body: json.encode(data),
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to update community: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to update community: $e');
//     }
//   }
//
//   // Delete community
//   static Future<bool> deleteCommunity(int communityId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/communities/$communityId/'),
//         headers: await headers,
//       );
//       return response.statusCode == 204;
//     } catch (e) {
//       throw Exception('Failed to delete community: $e');
//     }
//   }
//
//   // ==================== POSTS ====================
//
//   // Get all posts
//   static Future<List<dynamic>> getPosts() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/posts/'),
//         headers: await headers,
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load posts: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load posts: $e');
//     }
//   }
//
//   // Get specific post
//   static Future<Map<String, dynamic>> getPost(int postId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/posts/$postId/'),
//         headers: await headers,
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load post: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load post: $e');
//     }
//   }
//
//   // Create new post
//   static Future<Map<String, dynamic>> createPost({
//     required String title,
//     required String content,
//     required int communityId,
//     List<File>? files,
//   }) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/posts/'),
//       );
//      
//       request.headers.addAll(await multipartHeaders);
//       request.fields['title'] = title;
//       request.fields['content'] = content;
//       request.fields['community'] = communityId.toString();
//      
//       if (files != null) {
//         for (File file in files) {
//           request.files.add(await http.MultipartFile.fromPath(
//             'files',
//             file.path,
//           ));
//         }
//       }
//
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//      
//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to create post: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to create post: $e');
//     }
//   }
//
//   // Update post
//   static Future<Map<String, dynamic>> updatePost(int postId, Map<String, dynamic> data) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/posts/$postId/'),
//         headers: await headers,
//         body: json.encode(data),
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to update post: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to update post: $e');
//     }
//   }
//
//   // Delete post
//   static Future<bool> deletePost(int postId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/posts/$postId/'),
//         headers: await headers,
//       );
//       return response.statusCode == 204;
//     } catch (e) {
//       throw Exception('Failed to delete post: $e');
//     }
//   }
//
//   // ==================== ROLE MANAGEMENT ====================
//
//   // Assign or update role in community
//   static Future<Map<String, dynamic>> assignRole(int communityId, int userId, String role) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/communities/$communityId/roles/'),
//         headers: await headers,
//         body: json.encode({
//           'user_id': userId,
//           'role': role,
//         }),
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to assign role: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to assign role: $e');
//     }
//   }
//
//   // ==================== USER ACTIVITY ====================
//
//   // Get user activity overview
//   static Future<Map<String, dynamic>> getUserActivity() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/users/activity/'),
//         headers: await headers,
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load user activity: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load user activity: $e');
//     }
//   }
//
//   // ==================== FILES ====================
//
//   // Upload file for a post
//   static Future<Map<String, dynamic>> uploadFile(int postId, File file) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/files/'),
//       );
//      
//       request.headers.addAll(await multipartHeaders);
//       request.fields['post'] = postId.toString();
//       request.files.add(await http.MultipartFile.fromPath('file', file.path));
//
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//      
//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to upload file: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to upload file: $e');
//     }
//   }
//
//   // Get all files
//   static Future<List<dynamic>> getFiles() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/files/'),
//         headers: await headers,
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load files: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load files: $e');
//     }
//   }
//
//   // ==================== VOTES ON POSTS ====================
//
//   // Add vote to post
//   static Future<Map<String, dynamic>> votePost(int postId, int value) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/votes/'),
//         headers: await headers,
//         body: json.encode({
//           'post': postId,
//           'value': value, // 1 for upvote, -1 for downvote
//         }),
//       );
//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to vote on post: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to vote on post: $e');
//     }
//   }
//
//   // Update vote on post
//   static Future<Map<String, dynamic>> updateVotePost(int voteId, int value) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/votes/$voteId/'),
//         headers: await headers,
//         body: json.encode({'value': value}),
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to update vote: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to update vote: $e');
//     }
//   }
//
//   // Remove vote from post
//   static Future<bool> removeVotePost(int voteId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/votes/$voteId/'),
//         headers: await headers,
//       );
//       return response.statusCode == 204;
//     } catch (e) {
//       throw Exception('Failed to remove vote: $e');
//     }
//   }
//
//   // ==================== COMMENTS ====================
//
//   // Add comment to post
//   static Future<Map<String, dynamic>> addComment(int postId, String content, {int? tagUserId}) async {
//     try {
//       final body = {
//         'post': postId,
//         'content': content,
//       };
//       if (tagUserId != null) body['tag'] = tagUserId;
//
//       final response = await http.post(
//         Uri.parse('$baseUrl/comments/'),
//         headers: await headers,
//         body: json.encode(body),
//       );
//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to add comment: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to add comment: $e');
//     }
//   }
//
//   // Get all comments
//   static Future<List<dynamic>> getComments() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/comments/'),
//         headers: await headers,
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load comments: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load comments: $e');
//     }
//   }
//
//   // Delete comment
//   static Future<bool> deleteComment(int commentId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/comments/$commentId/'),
//         headers: await headers,
//       );
//       return response.statusCode == 204;
//     } catch (e) {
//       throw Exception('Failed to delete comment: $e');
//     }
//   }
//
//   // ==================== REPLIES ====================
//
//   // Add reply to comment
//   static Future<Map<String, dynamic>> addReply(int commentId, String content, {int? tagUserId}) async {
//     try {
//       final body = {
//         'comment': commentId,
//         'content': content,
//       };
//       if (tagUserId != null) body['tag'] = tagUserId;
//
//       final response = await http.post(
//         Uri.parse('$baseUrl/replies/'),
//         headers: await headers,
//         body: json.encode(body),
//       );
//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to add reply: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to add reply: $e');
//     }
//   }
//
//   // Get all replies
//   static Future<List<dynamic>> getReplies() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/replies/'),
//         headers: await headers,
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load replies: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load replies: $e');
//     }
//   }
//
//   // Delete reply
//   static Future<bool> deleteReply(int replyId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/replies/$replyId/'),
//         headers: await headers,
//       );
//       return response.statusCode == 204;
//     } catch (e) {
//       throw Exception('Failed to delete reply: $e');
//     }
//   }
//
//   // ==================== COMMENT VOTES ====================
//
//   // Vote on comment
//   static Future<Map<String, dynamic>> voteComment(int commentId, int value) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/comment-votes/'),
//         headers: await headers,
//         body: json.encode({
//           'comment': commentId,
//           'value': value,
//         }),
//       );
//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to vote on comment: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to vote on comment: $e');
//     }
//   }
//
//   // Update comment vote
//   static Future<Map<String, dynamic>> updateCommentVote(int voteId, int value) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/comment-votes/$voteId/'),
//         headers: await headers,
//         body: json.encode({'value': value}),
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to update comment vote: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to update comment vote: $e');
//     }
//   }
//
//   // Remove comment vote
//   static Future<bool> removeCommentVote(int voteId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/comment-votes/$voteId/'),
//         headers: await headers,
//       );
//       return response.statusCode == 204;
//     } catch (e) {
//       throw Exception('Failed to remove comment vote: $e');
//     }
//   }
//
//   // ==================== COMMENT REPLY VOTES ====================
//
//   // Vote on reply
//   static Future<Map<String, dynamic>> voteReply(int replyId, int value) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/comment-reply-votes/'),
//         headers: await headers,
//         body: json.encode({
//           'reply': replyId,
//           'value': value,
//         }),
//       );
//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to vote on reply: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to vote on reply: $e');
//     }
//   }
//
//   // Update reply vote
//   static Future<Map<String, dynamic>> updateReplyVote(int voteId, int value) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/comment-reply-votes/$voteId/'),
//         headers: await headers,
//         body: json.encode({'value': value}),
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to update reply vote: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to update reply vote: $e');
//     }
//   }
//
//   // Remove reply vote
//   static Future<bool> removeReplyVote(int voteId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/comment-reply-votes/$voteId/'),
//         headers: await headers,
//       );
//       return response.statusCode == 204;
//     } catch (e) {
//       throw Exception('Failed to remove reply vote: $e');
//     }
//   }
//
//   // ==================== SAVED POSTS ====================
//
//   // Save post
//   static Future<Map<String, dynamic>> savePost(int postId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/saved-posts/'),
//         headers: await headers,
//         body: json.encode({'post': postId}),
//       );
//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to save post: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to save post: $e');
//     }
//   }
//
//   // Get saved posts
//   static Future<List<dynamic>> getSavedPosts() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/saved-posts/'),
//         headers: await headers,
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load saved posts: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load saved posts: $e');
//     }
//   }
//
//   // Unsave post
//   static Future<bool> unsavePost(int savedPostId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/saved-posts/$savedPostId/'),
//         headers: await headers,
//       );
//       return response.statusCode == 204;
//     } catch (e) {
//       throw Exception('Failed to unsave post: $e');
//     }
//   }
//
//   // ==================== COMMUNITY USERS ====================
//
//   // Join community
//   static Future<Map<String, dynamic>> joinCommunity(int communityId, {String role = 'member'}) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/community-users/'),
//         headers: await headers,
//         body: json.encode({
//           'community': communityId,
//           'role': role,
//         }),
//       );
//       if (response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to join community: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to join community: $e');
//     }
//   }
//
//   // Leave community
//   static Future<bool> leaveCommunity(int membershipId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/community-users/$membershipId/'),
//         headers: await headers,
//       );
//       return response.statusCode == 204;
//     } catch (e) {
//       throw Exception('Failed to leave community: $e');
//     }
//   }
//
//   // Get community memberships
//   static Future<List<dynamic>> getCommunityMemberships() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/community-users/'),
//         headers: await headers,
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to load community memberships: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load community memberships: $e');
//     }
//   }
// }

import 'package:flutter/material.dart';

class CommunityApiService extends StatelessWidget {
  const CommunityApiService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("hello"),
    );
  }
}
