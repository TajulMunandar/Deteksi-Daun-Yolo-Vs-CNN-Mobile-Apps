import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/result_controller.dart';

class ResultView extends GetView<ResultController> {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final result = controller.result.value;
    
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hasil Deteksi')),
        body: const Center(child: Text('Tidak ada hasil deteksi')),
      );
    }

    // Check if both models are available
    final bool isBoth = result.modelUsed == 'both' || result.modelUsed == 'unified';
    final bool hasYolo = result.yoloClass != null;
    final bool hasCnn = result.cnnClass != null;
    
    // For YOLO, get class and confidence from first detection; for CNN, use top-level
    final displayClass = result.detections != null && result.detections!.isNotEmpty
        ? result.detections![0].className
        : (result.predictedClass ?? 'Tidak terdeteksi');
    
    final confidence = result.detections != null && result.detections!.isNotEmpty
        ? result.detections![0].confidence * 100
        : (result.confidence ?? 0) * 100;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Deteksi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Show both YOLO and CNN results if available
              if (isBoth && hasYolo && hasCnn) ...[
                _buildBothResultsCard(result),
                const SizedBox(height: 20),
              ] else ...[
                _buildResultCard(displayClass, confidence),
                const SizedBox(height: 20),
                _buildConfidenceIndicator(confidence),
                const SizedBox(height: 20),
              ],
              _buildModelInfo(result.modelUsed),
              const SizedBox(height: 20),
              _buildImagePreview(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBothResultsCard(result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple[700]!,
            Colors.deepPurple[500]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.compare_arrows,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'Hasil Deteksi Ganda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // YOLO Result
              Expanded(
                child: _buildModelResultCard(
                  'YOLO',
                  result.yoloClass ?? 'Tidak terdeteksi',
                  (result.yoloConfidence ?? 0) * 100,
                  Icons.location_on,
                ),
              ),
              const SizedBox(width: 16),
              // CNN Result
              Expanded(
                child: _buildModelResultCard(
                  'CNN',
                  result.cnnClass ?? 'Tidak terdeteksi',
                  (result.cnnConfidence ?? 0) * 100,
                  Icons.psychology,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Comparison note if available
          if (result.message.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModelResultCard(String modelName, String leafClass, double confidence, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.deepPurple[600], size: 28),
          const SizedBox(height: 8),
          Text(
            modelName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatLeafName(leafClass),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getConfidenceColor(confidence).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${confidence.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getConfidenceColor(confidence),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String displayClass, double confidence) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[700]!,
            Colors.green[500]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.eco,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Jenis Daun:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[100],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatLeafName(displayClass),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Confidence: ${confidence.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tingkat Kepercayaan',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${confidence.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getConfidenceColor(confidence),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getConfidenceColor(confidence),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelInfo(String model) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.smart_toy,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Model yang digunakan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                ),
              ),
              Text(
                model.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (controller.imagePath.value.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gambar yang dianalisis:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: kIsWeb
                ? Image.network(
                    controller.imagePath.value,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(controller.imagePath.value),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.refresh),
        label: const Text('Deteksi Ulang'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  String _formatLeafName(String name) {
    if (name == 'Tidak terdeteksi') {
      return 'Tidak terdeteksi';
    }
    if (name.startsWith('daun ')) {
      return name.substring(0, 1).toUpperCase() + name.substring(1);
    }
    return 'Daun ${name.substring(0, 1).toUpperCase()}${name.substring(1)}';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) {
      return Colors.green;
    } else if (confidence >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
