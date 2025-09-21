import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Create storage instance with Android options
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Store JWT token
  Future<void> storeJwtToken(String token) async {
    try {
      await _storage.write(key: 'jwt_token', value: token);
      print('JWT token stored successfully');
    } catch (e) {
      print('Error storing JWT: $e');
      throw Exception('Failed to store token');
    }
  }

  // Retrieve JWT token
  Future<String?> getJwtToken() async {
    try {
      return await _storage.read(key: 'jwt_token');
    } catch (e) {
      print('Error retrieving JWT: $e');
      return null;
    }
  }

  // Delete JWT token (for logout)
  Future<void> deleteJwtToken() async {
    try {
      await _storage.delete(key: 'jwt_token');
      print('JWT token deleted successfully');
    } catch (e) {
      print('Error deleting JWT: $e');
      throw Exception('Failed to delete token');
    }
  }



}