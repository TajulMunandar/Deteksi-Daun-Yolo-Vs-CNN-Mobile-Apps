import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/config/theme.dart';
import 'app/routes/app_pages.dart';
import 'app/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  final apiService = ApiService();
  Get.put<ApiService>(apiService);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Deteksi Daun',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
