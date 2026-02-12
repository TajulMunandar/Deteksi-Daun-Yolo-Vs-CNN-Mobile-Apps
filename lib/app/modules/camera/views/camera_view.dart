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
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.pickImage(fromCamera: false),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeri'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (controller.selectedImage.value != null || controller.selectedImageXFile.value != null)
                    ? () => controller.analyzeImage()
                    : () => controller.pickImage(fromCamera: true),
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  (controller.selectedImage.value != null || controller.selectedImageXFile.value != null)
                      ? 'Deteksi'
                      : 'Kamera',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
