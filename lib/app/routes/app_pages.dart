import 'package:get/get.dart';

import 'package:deteksi_daun_mobile/app/modules/home/bindings/home_binding.dart';
import 'package:deteksi_daun_mobile/app/modules/home/views/home_view.dart';
import 'package:deteksi_daun_mobile/app/modules/camera/bindings/camera_binding.dart';
import 'package:deteksi_daun_mobile/app/modules/camera/views/camera_view.dart';
import 'package:deteksi_daun_mobile/app/modules/result/bindings/result_binding.dart';
import 'package:deteksi_daun_mobile/app/modules/result/views/result_view.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.CAMERA,
      page: () => const CameraView(),
      binding: CameraBinding(),
    ),
    GetPage(
      name: Routes.RESULT,
      page: () => const ResultView(),
      binding: ResultBinding(),
    ),
  ];
}

class Routes {
  static const HOME = '/home';
  static const CAMERA = '/camera';
  static const RESULT = '/result';
}
