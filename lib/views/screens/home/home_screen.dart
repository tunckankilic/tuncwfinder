import 'package:flutter/material.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/theme/modern_theme.dart';
import 'package:tuncforwork/views/screens/home/home_controller.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:tuncforwork/views/screens/profile/controller/profile_controllers.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends GetView<HomeController> {
  static const routeName = AppStrings.routeHome;

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //  Push notification system kaldırıldı (performans için)
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Get.put(HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<UserDetailsController>(
        () => UserDetailsController(userId: currentUserId),
        tag: currentUserId);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tablet breakpoint
        if (constraints.maxWidth >= 768) {
          return _buildTabletLayout(context);
        }
        // Phone layout
        return _buildPhoneLayout(context);
      },
    );
  }

  // Tablet Layout with Side Navigation
  Widget _buildTabletLayout(BuildContext context) {
    final double sideNavWidth = MediaQuery.of(context).size.width * 0.08;

    return Scaffold(
      body: Row(
        children: [
          // Side Navigation for Tablet
          Container(
            width: sideNavWidth,
            decoration: BoxDecoration(
              color: ModernTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildTabletNavItem(Icons.home, AppStrings.navHome, 0),
                _buildTabletNavItem(Icons.star, AppStrings.navFavorites, 1),
                _buildTabletNavItem(Icons.favorite, AppStrings.navLikes, 2),
                _buildTabletNavItem(Icons.person, AppStrings.navProfile, 3),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Obx(() => controller.currentScreen),
          ),
        ],
      ),
    );
  }

  // Phone Layout with Bottom Navigation
  Widget _buildPhoneLayout(BuildContext context) {
    return Obx(() {
      if (!controller.isInitialized.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Scaffold(
        body: Obx(() => controller.currentScreen),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      );
    });
  }

  // Tablet Navigation Item
  Widget _buildTabletNavItem(IconData icon, String label, int index) {
    return Obx(() {
      final isSelected = controller.screenIndex.value == index;
      return InkWell(
        onTap: () => controller.changeScreen(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                icon,
                size: isSelected ? 32 : 28,
                color: isSelected
                    ? ModernTheme.secondaryColor
                    : Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? ModernTheme.secondaryColor
                      : Colors.white.withValues(alpha: 0.6),
                  fontSize: isSelected ? 14 : 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Phone Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        onTap: controller.changeScreen,
        type: BottomNavigationBarType.fixed,
        backgroundColor: ModernTheme.primaryColor,
        selectedItemColor: ModernTheme.secondaryColor,
        unselectedItemColor: Colors.white.withValues(alpha: 0.6),
        currentIndex: controller.screenIndex.value,
        items: [
          _buildNavItem(Icons.home, AppStrings.navHome, context),
          _buildNavItem(Icons.star, AppStrings.navFavorites, context),
          _buildNavItem(Icons.favorite, AppStrings.navLikes, context),
          _buildNavItem(Icons.person, AppStrings.navProfile, context),
        ],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return BottomNavigationBarItem(
      icon: Icon(icon, size: isSmallScreen ? 20 : 24),
      activeIcon: Icon(icon, size: isSmallScreen ? 24 : 28),
      label: label,
    );
  }
}
