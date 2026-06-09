import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:deteksi_daun_mobile/app/services/api_service.dart';
import 'package:deteksi_daun_mobile/app/models/leaf_detection_result.dart';

class CameraController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  
  final isLoading = false.obs;
  final selectedImage = Rx<File?>(null);
  final selectedImageXFile = Rx<XFile?>(null); // For web support
  final selectedModel = 'unified'.obs;
  final result = Rx<LeafDetectionResult?>(null);
  final errorMessage = ''.obs;

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        print('DEBUG: Picked image path: ${image.path}');
        print('DEBUG: Picked image name: ${image.name}');
        
        // For web, store XFile directly
        selectedImageXFile.value = image;
        
        // Try to create File for non-web
        try {
          selectedImage.value = File(image.path);
          print('DEBUG: File created successfully: ${selectedImage.value?.path}');
        } catch (e) {
          print('DEBUG: Failed to create File: $e');
          selectedImage.value = null;
        }
        
        result.value = null;
        errorMessage.value = '';
        print('===> GAMBAR DIPILIH: ${image.name} <===');
      }
    } catch (e) {
      print('ERROR in pickImage: $e');
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
    }
  }

  Future<void> analyzeImage() async {
    if (selectedImage.value == null && selectedImageXFile.value == null) {
      Get.snackbar(
        'Peringatan',
        'Silakan pilih gambar terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF9800),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    print('===> MEMULAI ANALISIS GAMBAR <===');

    try {
      print('===> MEMANGGIL ApiService.detectLeaf() <===');
      final apiService = Get.find<ApiService>();
      print('===> ApiService instance obtained: $apiService <===');
      
      // Use XFile for web, File for other platforms
      if (selectedImageXFile.value != null) {
        // For web: read bytes from XFile
        final bytes = await selectedImageXFile.value!.readAsBytes();
        print('===> Image bytes read, size: ${bytes.length} <===');
        
        // On web, we need a different approach - use dart:typed_data
        print('===> Creating multipart request with bytes <===');
        
        // Create multipart request manually
        final modelEndpoint = selectedModel.value;
        final uri = Uri.parse('${ApiService.baseUrl}/predict${modelEndpoint == 'unified' ? '' : '/$modelEndpoint'}');
        print('DEBUG: Target URL: $uri');
        
        // Create multipart request
        final request = http.MultipartRequest('POST', uri);
        
        // Add image as bytes
        final multipartFile = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: selectedImageXFile.value!.name.split('/').last,
        );
        request.files.add(multipartFile);
        print('DEBUG: Added multipart file with ${bytes.length} bytes');
        
        print('===> Sending request... <===');
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        print('===> Response received: ${response.statusCode} <===');
        print('DEBUG: Response body: ${response.body}');
        
        // Parse response
        var jsonResponse = json.decode(response.body);
        final detectionResult = LeafDetectionResult.fromJson(jsonResponse);
        print('===> detectLeaf() returned: $detectionResult <===');
        
        // Navigate to result if successful (even if no detections for YOLO)
        if (detectionResult.success) {
          Get.toNamed('/result', arguments: {
            'result': detectionResult,
            'imagePath': selectedImageXFile.value!.path,
          });
        } else {
          errorMessage.value = detectionResult.message;
          Get.snackbar(
            'Error',
            detectionResult.message,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
            backgroundColor: const Color(0xFFD32F2F),
            colorText: Colors.white,
          );
        }
      } else if (selectedImage.value != null) {
        final detectionResult = await apiService.detectLeaf(
          image: selectedImage.value!,
          model: selectedModel.value,
        );
        
        // Navigate to result if successful (even if no detections for YOLO)
        if (detectionResult.success) {
          Get.toNamed('/result', arguments: {
            'result': detectionResult,
            'imagePath': selectedImage.value!.path,
          });
        } else {
          errorMessage.value = detectionResult.message;
          Get.snackbar(
            'Error',
            detectionResult.message,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
            backgroundColor: const Color(0xFFD32F2F),
            colorText: Colors.white,
          );
        }
      }
      
      print('===> ApiService.detectLeaf() SELESAI <===');
      print('===> Hasil: success=${result.value?.success ?? false}, class=${result.value?.predictedClass ?? "N/A"} <===');
    } catch (e) {
      print('!!! ERROR DALAM analyzeImage(): $e');
      errorMessage.value = 'Terjadi kesalahan: $e';
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e\n\nPastikan Flask server sudah berjalan.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setModel(String model) {
    selectedModel.value = model;
  }

  void clearImage() {
    selectedImage.value = null;
    selectedImageXFile.value = null;
    result.value = null;
    errorMessage.value = '';
  }
}
