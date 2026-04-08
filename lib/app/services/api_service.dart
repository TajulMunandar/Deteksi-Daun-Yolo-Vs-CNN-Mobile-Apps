import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:deteksi_daun_mobile/app/models/leaf_detection_result.dart';

class ApiService extends GetxService {
  static String _baseUrl = 'http://172.23.66.60:5000';
  
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_url') ?? 'http://172.23.66.60:5000';
  }
  
  static String get baseUrl => _baseUrl;
  
  static setBaseUrl(String url) {
    _baseUrl = url;
  }

  Future<LeafDetectionResult> detectLeaf({
    required File image,
    String model = 'unified',
  }) async {
    print('DEBUG: detectLeaf() called with image: ${image.path}');
    try {
      // Refresh URL from preferences
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString('api_url') ?? 'http://172.23.66.60:5000';
      print('DEBUG: Using base URL: $_baseUrl');
      
      String endpoint;
      
      if (model == 'cnn') {
        endpoint = '$_baseUrl/predict/cnn';
      } else if (model == 'yolo') {
        endpoint = '$_baseUrl/predict/yolo';
      } else {
        endpoint = '$_baseUrl/predict';
      }

      print('>>> API HIT: detectLeaf() -> $endpoint');
      print('>>> API INFO: detectLeaf() -> Model: $model');
      print('DEBUG: Image path being sent: ${image.path}');

      var request = http.MultipartRequest('POST', Uri.parse(endpoint));
      print('DEBUG: Created multipart request');
      
      print('DEBUG: About to create MultipartFile from path...');
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );
      print('DEBUG: Added image file to request, file count: ${request.files.length}');
      
      // Skip annotated image to reduce response size
      request.fields['include_image'] = 'false';

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      print('<<< API RESPONSE: detectLeaf() -> Status: ${response.statusCode}');
      print('Response body: $responseData');

      if (response.statusCode == 200) {
        try {
          print('DEBUG: About to parse JSON...');
          var jsonResponse = json.decode(responseData);
          print('DEBUG: JSON parsed successfully: $jsonResponse');
          return LeafDetectionResult.fromJson(jsonResponse);
        } catch (jsonError) {
          print('!!! JSON Parse Error: $jsonError');
          return LeafDetectionResult(
            success: false,
            message: 'Invalid response from server: $jsonError\n\nRaw response: $responseData',
            modelUsed: model,
            timestamp: DateTime.now(),
          );
        }
      } else {
        return LeafDetectionResult(
          success: false,
          message: 'Server error: ${response.statusCode}. Make sure Flask server is running.',
          modelUsed: model,
          timestamp: DateTime.now(),
        );
      }
    } catch (e, stackTrace) {
      print('!!! API Error: $e');
      print('!!! Stack trace: $stackTrace');
      return LeafDetectionResult(
        success: false,
        message: 'Connection error: $e\n\nMake sure Flask server is running at http://172.23.66.60:5000',
        modelUsed: model,
        timestamp: DateTime.now(),
      );
    }
  }

  Future<bool> checkHealth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString('api_url') ?? 'http://172.23.66.60:5000';
      final healthUrl = '$_baseUrl/health';
      print('>>> API HIT: checkHealth() -> $healthUrl');
      final response = await http.get(Uri.parse(healthUrl));
      print('<<< API RESPONSE: checkHealth() -> Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('!!! API ERROR: checkHealth() -> $e');
      return false;
    }
  }

  Future<List<String>> getClasses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString('api_url') ?? 'http://172.23.66.60:5000';
      final classesUrl = '$_baseUrl/classes';
      print('>>> API HIT: getClasses() -> $classesUrl');
      final response = await http.get(Uri.parse(classesUrl));
      print('<<< API RESPONSE: getClasses() -> Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> classes = jsonResponse['classes'] ?? [];
        print('<<< API RESPONSE: getClasses() -> Classes: ${classes.length}');
        return classes.map((c) => c.toString()).toList();
      }
      return [];
    } catch (e) {
      print('!!! API ERROR: getClasses() -> $e');
      return [];
    }
  }
}
