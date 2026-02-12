import 'package:get/get.dart';

class HistoryController extends GetxController {
  final historyList = [].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }
  
  void _loadHistory() {
    // Load history from storage
    // For now, we'll use empty list
  }
  
  void deleteHistory(int index) {
    historyList.removeAt(index);
  }
  
  void clearAllHistory() {
    historyList.clear();
  }
}
