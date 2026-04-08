import 'dart:io';

class LeafDetectionResult {
  final bool success;
  final String message;
  // CNN results
  final String? predictedClass;
  final double? confidence;
  // YOLO results
  final List<YOLODetection>? detections;
  // Combined results
  final String? annotatedImagePath;
  final String modelUsed; // 'yolo', 'cnn', 'both', or 'unified'
  final DateTime timestamp;
  
  // Both results for unified model
  final String? yoloClass;
  final double? yoloConfidence;
  final String? cnnClass;
  final double? cnnConfidence;

  LeafDetectionResult({
    required this.success,
    required this.message,
    this.predictedClass,
    this.confidence,
    this.detections,
    this.annotatedImagePath,
    required this.modelUsed,
    required this.timestamp,
    this.yoloClass,
    this.yoloConfidence,
    this.cnnClass,
    this.cnnConfidence,
  });

  factory LeafDetectionResult.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing JSON: ${json.keys}');
    
    // Handle unified endpoint with nested yolo_detection and cnn_classification
    final success = json['success'] ?? false;
    
    // If using unified endpoint with both models
    if (json['yolo_detection'] != null || json['cnn_classification'] != null) {
      final cnnData = json['cnn_classification'];
      final yoloData = json['yolo_detection'];
      
      print('DEBUG: Unified endpoint - yolo: ${yoloData?.keys}, cnn: ${cnnData?.keys}');
      
      // Extract YOLO results
      String? yoloClass;
      double? yoloConfidence;
      List<YOLODetection>? yoloDetections;
      
      if (yoloData != null) {
        if (yoloData['predictions'] != null && (yoloData['predictions'] as List).isNotEmpty) {
          final firstPred = yoloData['predictions'][0];
          yoloClass = firstPred['detected_class'] ?? firstPred['class'];
          yoloConfidence = (firstPred['confidence'] ?? 0).toDouble();
          yoloDetections = (yoloData['predictions'] as List)
              .map((d) => YOLODetection.fromJson(d))
              .toList();
        } else if (yoloData['predicted_class'] != null) {
          yoloClass = yoloData['predicted_class'];
          yoloConfidence = (yoloData['confidence'] ?? 0).toDouble();
        }
      }
      
      // Extract CNN results
      String? cnnClass;
      double? cnnConfidence;
      
      if (cnnData != null) {
        cnnClass = cnnData['predicted_class'];
        cnnConfidence = (cnnData['confidence'] ?? 0).toDouble();
      }
      
      return LeafDetectionResult(
        success: success,
        message: json['comparison_note'] ?? json['message'] ?? '',
        predictedClass: cnnClass ?? yoloClass, // Primary display
        confidence: cnnConfidence ?? yoloConfidence, // Primary confidence
        detections: yoloDetections,
        annotatedImagePath: cnnData?['annotated_image'] ?? yoloData?['annotated_image'],
        modelUsed: 'both',
        timestamp: DateTime.now(),
        yoloClass: yoloClass,
        yoloConfidence: yoloConfidence,
        cnnClass: cnnClass,
        cnnConfidence: cnnConfidence,
      );
    }
    
    // Handle individual model responses
    print('DEBUG: Individual model - keys: ${json.keys}');
    print('DEBUG: predictions key exists: ${json.containsKey("predictions")}');
    
    return LeafDetectionResult(
      success: success,
      message: json['message'] ?? '',
      predictedClass: json['predicted_class'],
      confidence: json['confidence']?.toDouble(),
      detections: json.containsKey('predictions') && json['predictions'] != null
          ? (json['predictions'] as List)
              .map((d) => YOLODetection.fromJson(d))
              .toList()
          : null,
      annotatedImagePath: json['annotated_image'],
      modelUsed: json['model'] ?? 'unknown',
      timestamp: DateTime.now(),
    );
  }
}

class YOLODetection {
  final String className;
  final double confidence;
  final double x;
  final double y;
  final double width;
  final double height;

  YOLODetection({
    required this.className,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory YOLODetection.fromJson(Map<String, dynamic> json) {
    final boundingBox = json['bounding_box'];
    return YOLODetection(
      className: json['detected_class'] ?? json['class'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      x: (boundingBox?['x1'] ?? boundingBox?['x'] ?? 0).toDouble(),
      y: (boundingBox?['y1'] ?? boundingBox?['y'] ?? 0).toDouble(),
      width: (boundingBox?['width'] ?? 0).toDouble(),
      height: (boundingBox?['height'] ?? 0).toDouble(),
    );
  }
}

class DetectionHistory {
  final String id;
  final String imagePath;
  final String predictedClass;
  final double confidence;
  final String modelUsed;
  final DateTime timestamp;

  DetectionHistory({
    required this.id,
    required this.imagePath,
    required this.predictedClass,
    required this.confidence,
    required this.modelUsed,
    required this.timestamp,
  });

  factory DetectionHistory.fromResult(LeafDetectionResult result, String imagePath) {
    return DetectionHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      predictedClass: result.predictedClass ?? 'Unknown',
      confidence: result.confidence ?? 0.0,
      modelUsed: result.modelUsed,
      timestamp: result.timestamp,
    );
  }
}
