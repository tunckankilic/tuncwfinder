import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/home/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  static const routeName = "/home";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PushNotificationSystem().whenNotificationReceived(context);
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          body: Obx(() => controller.currentScreen),
          bottomNavigationBar: _buildBottomNavigationBar(controller),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: BottomNavigationBar(
        onTap: controller.changeScreen,
        type: BottomNavigationBarType.fixed,
        backgroundColor: ElegantTheme.primaryColor,
        selectedItemColor: ElegantTheme.secondaryColor,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        currentIndex: controller.screenIndex.value,
        items: [
          _buildNavItem(Icons.home, "Home"),
          _buildNavItem(Icons.remove_red_eye, "Views"),
          _buildNavItem(Icons.star, "Favorites"),
          _buildNavItem(Icons.favorite, "Likes"),
          _buildNavItem(Icons.person, "Profile"),
        ],
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12.sp,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24.sp),
      activeIcon: Icon(icon, size: 28.sp),
      label: label,
    );
  }
}
