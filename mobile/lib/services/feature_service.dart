import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/feature.dart';

class FeatureService {
  // Dynamic base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // For web, use localhost directly
      return 'http://localhost:3000/api';
    } else {
      // For mobile platforms, check if we're likely on Android emulator
      // This is a simple heuristic - in production you'd want more robust detection
      return 'http://10.0.2.2:3000/api';
    }
  }

  final http.Client _client;

  FeatureService({http.Client? client}) : _client = client ?? http.Client();

  // GET /features - Fetch all features
  Future<List<Feature>> getFeatures() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/features'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> featuresJson =
              responseData['data'] as List<dynamic>;
          return featuresJson
              .map((json) => Feature.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Failed to fetch features: ${errorData['error'] ?? 'Unknown error'}',
        );
      }
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (errorMessage.contains('HttpException')) {
        throw Exception('Failed to communicate with server.');
      } else if (errorMessage.contains('TimeoutException')) {
        throw Exception('Request timeout. Please try again.');
      }
      throw Exception('An unexpected error occurred: $errorMessage');
    }
  }

  // POST /features/:id/vote - Upvote a feature
  Future<Feature> upvoteFeature(int featureId) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/features/$featureId/vote'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return Feature.fromJson(responseData['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Failed to vote: ${errorData['error'] ?? 'Unknown error'}',
        );
      }
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (errorMessage.contains('HttpException')) {
        throw Exception('Failed to communicate with server.');
      } else if (errorMessage.contains('TimeoutException')) {
        throw Exception('Request timeout. Please try again.');
      }
      throw Exception('An unexpected error occurred: $errorMessage');
    }
  }

  // POST /features - Create a new feature (bonus functionality)
  Future<Feature> createFeature(String title, {String? description}) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/features'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'title': title,
              if (description != null) 'description': description,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return Feature.fromJson(responseData['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Failed to create feature: ${errorData['error'] ?? 'Unknown error'}',
        );
      }
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (errorMessage.contains('HttpException')) {
        throw Exception('Failed to communicate with server.');
      } else if (errorMessage.contains('TimeoutException')) {
        throw Exception('Request timeout. Please try again.');
      }
      throw Exception('An unexpected error occurred: $errorMessage');
    }
  }

  void dispose() {
    _client.close();
  }
}
