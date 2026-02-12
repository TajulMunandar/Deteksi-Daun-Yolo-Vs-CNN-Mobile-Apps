import 'package:get/get.dart';

import 'package:deteksi_daun_mobile/app/models/leaf_detection_result.dart';

class ResultController extends GetxController {
  final result = Rx<LeafDetectionResult?>(null);
  final imagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  void _loadArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      result.value = args['result'] as LeafDetectionResult?;
      imagePath.value = args['imagePath'] ?? '';
    }
  }
}
