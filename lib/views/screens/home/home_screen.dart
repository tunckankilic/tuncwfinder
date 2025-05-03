import 'package:flutter/material.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/home/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  static const routeName = "/home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PushNotificationSystem().whenNotificationReceived(context);
    Get.put(HomeController());

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
              color: ElegantTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildTabletNavItem(Icons.home, "Home", 0),
                _buildTabletNavItem(Icons.star, "Favorites", 1),
                _buildTabletNavItem(Icons.favorite, "Likes", 2),
                _buildTabletNavItem(Icons.person, "Profile", 3),
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
                    ? ElegantTheme.secondaryColor
                    : Colors.white.withOpacity(0.6),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? ElegantTheme.secondaryColor
                      : Colors.white.withOpacity(0.6),
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
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
          _buildNavItem(Icons.home, "Home", context),
          _buildNavItem(Icons.star, "Favorites", context),
          _buildNavItem(Icons.favorite, "Likes", context),
          _buildNavItem(Icons.person, "Profile", context),
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
