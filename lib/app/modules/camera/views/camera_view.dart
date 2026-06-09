import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/camera_controller.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambil Foto Daun'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildModelSelector(),
            Expanded(
              child: _buildImagePreview(),
            ),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSelector() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildModelChip('Auto', 'unified'),
          const SizedBox(width: 8),
          _buildModelChip('CNN', 'cnn'),
          const SizedBox(width: 8),
          _buildModelChip('YOLO', 'yolo'),
        ],
      ),
    ));
  }

  Widget _buildModelChip(String label, String value) {
    final isSelected = controller.selectedModel.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.green[300],
      onSelected: (selected) {
        if (selected) {
          controller.setModel(value);
        }
      },
    );
  }

  Widget _buildImagePreview() {
    return Obx(() {
      if (controller.selectedImageXFile.value != null) {
        // For web, use Image.network with blob URL
        if (kIsWeb) {
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.network(
              controller.selectedImageXFile.value!.path,
              fit: BoxFit.contain,
            ),
          );
        }
        // For native, use FileImage
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: FileImage(controller.selectedImage.value!),
              fit: BoxFit.contain,
            ),
          ),
        );
      } else if (controller.selectedImage.value != null) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: FileImage(controller.selectedImage.value!),
              fit: BoxFit.contain,
            ),
          ),
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_camera,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Ambil foto daun untuk deteksi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildActionButtons() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const CircularProgressIndicator(
          color: Colors.green,
        );
      }
      
      final hasImage = controller.selectedImage.value != null || controller.selectedImageXFile.value != null;
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              if (hasImage) {
                controller.analyzeImage();
              } else {
                controller.pickImage();
              }
            },
            icon: Icon(hasImage ? Icons.search : Icons.photo_library),
            label: Text(
              hasImage ? 'Deteksi' : 'Pilih dari Galeri',
              style: const TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    });
  }
}
