import 'package:get/get.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/profile_module/controller/profile_controller.dart';
import 'package:wghdfm_java/screen/favourite/favourite_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashBoardController>(() => DashBoardController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<FavouriteController>(() => FavouriteController());
  }
}

DashBoardController kDashboardController = Get.put(DashBoardController());
ProfileController kProfileController = Get.put(ProfileController());
FavouriteController kFavouriteController = Get.put(FavouriteController());
