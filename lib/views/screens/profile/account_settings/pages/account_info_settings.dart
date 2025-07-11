import 'package:flutter/material.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';
import 'dart:io';

class ProfileInfoScreen extends GetView<AccountSettingsController> {
  ProfileInfoScreen({super.key});

  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    'personal': GlobalKey(),
    'appearance': GlobalKey(),
    'lifestyle': GlobalKey(),
    'background': GlobalKey(),
    'connections': GlobalKey(),
  };

  void _scrollToSection(String sectionName, BuildContext context) {
    controller.currentSection.value = sectionName;

    if (_sectionKeys[sectionName]?.currentContext != null) {
      final RenderBox box = _sectionKeys[sectionName]!
          .currentContext!
          .findRenderObject() as RenderBox;
      final offset = box.localToGlobal(Offset.zero);

      final scrollPosition = (offset.dy + _scrollController.offset) -
          (kToolbarHeight + MediaQuery.of(context).padding.top + 20);

      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Controller'ın varlığını kontrol et
    if (!Get.isRegistered<AccountSettingsController>()) {
      Get.put(AccountSettingsController());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        return Scaffold(
          appBar: _buildAppBar(context, isTablet),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return _buildResponsiveLayout(context, isTablet);
          }),
        );
      },
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.1;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          // Left Navigation Panel
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildNavigationPanel(context),
          ),
          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController, // ScrollController eklendi
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileImageSection(context, true),
                    _buildTabletFormLayout(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required bool isTablet,
    required Widget child,
  }) {
    // Title'ı key formatına çevir
    final sectionKey = title
        .toLowerCase()
        .replaceAll(' info', '')
        .replaceAll(' links', 'connections');

    return Container(
      key: _sectionKeys[sectionKey], // Section key eklendi
      margin: EdgeInsets.only(bottom: isTablet ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: isTablet ? 24.0 : 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).primaryColor,
                  size: isTablet ? 24.0 : 20.0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          child,
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    final double toolbarHeight = isTablet ? 70.0 : kToolbarHeight;

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      toolbarHeight: toolbarHeight,
      centerTitle: true,
      title: Text(
        "Edit Profile Info",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontSize: isTablet ? 24.0 : 20.0,
              fontWeight: FontWeight.bold,
            ),
      ),
      leading: IconButton(
        icon: Icon(
          Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
          size: isTablet ? 28.0 : 24.0,
          color: Colors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, bool isTablet) {
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    return _buildPhoneLayout(context);
  }

  // Widget _buildTabletLayout(BuildContext context) {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final horizontalPadding = screenWidth * 0.1;

  //   return Container(
  //     color: Theme.of(context).scaffoldBackgroundColor,
  //     child: Row(
  //       children: [
  //         // Left Navigation Panel
  //         Container(
  //           width: 280,
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.1),
  //                 spreadRadius: 1,
  //                 blurRadius: 10,
  //                 offset: const Offset(0, 3),
  //               ),
  //             ],
  //           ),
  //           child: _buildNavigationPanel(context),
  //         ),
  //         // Main Content Area
  //         Expanded(
  //           child: SingleChildScrollView(
  //             padding: EdgeInsets.symmetric(
  //               horizontal: horizontalPadding,
  //               vertical: 24.0,
  //             ),
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(16.0),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.grey.withOpacity(0.1),
  //                     spreadRadius: 1,
  //                     blurRadius: 10,
  //                     offset: const Offset(0, 3),
  //                   ),
  //                 ],
  //               ),
  //               padding: const EdgeInsets.all(24.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   _buildProfileImageSection(context, true),
  //                   _buildTabletFormLayout(context),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPhoneLayout(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileImageSection(context, false),
                  const SizedBox(height: 24.0),
                  _buildPhoneFormLayout(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              "Profile Sections",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 8.0),
          _buildNavItem(
            context: context,
            icon: Icons.person_outline_rounded,
            title: "Personal Info",
            isSelected: controller.currentSection.value == "personal",
            onTap: () => _scrollToSection("personal", context),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.face_outlined,
            title: "Appearance",
            isSelected: controller.currentSection.value == "appearance",
            onTap: () => _scrollToSection("appearance", context),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.favorite_border_rounded,
            title: "Lifestyle",
            isSelected: controller.currentSection.value == "lifestyle",
            onTap: () => _scrollToSection("lifestyle", context),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.school_outlined,
            title: "Background",
            isSelected: controller.currentSection.value == "background",
            onTap: () => _scrollToSection("background", context),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.share_outlined,
            title: "Social Links",
            isSelected: controller.currentSection.value == "connections",
            onTap: () => _scrollToSection("connections", context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 4.0,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              size: 24.0,
            ),
            const SizedBox(width: 16.0),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletFormLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context: context,
                    title: "Personal Info",
                    isTablet: true,
                    child: _buildPersonalInfoFields(context, true),
                  ),
                  _buildSection(
                    context: context,
                    title: "Appearance",
                    isTablet: true,
                    child: _buildAppearanceFields(context, true),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context: context,
                    title: "Lifestyle",
                    isTablet: true,
                    child: _buildLifestyleFields(context, true),
                  ),
                  _buildSection(
                    context: context,
                    title: "Background",
                    isTablet: true,
                    child: _buildBackgroundFields(context, true),
                  ),
                  _buildSection(
                    context: context,
                    title: "Career",
                    isTablet: true,
                    child: _buildCareerFields(context, true),
                  ),
                  _buildSection(
                    context: context,
                    title: "Social Links",
                    isTablet: true,
                    child: _buildSocialLinksFields(context, true),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32.0),
        _buildUpdateButton(context, true),
      ],
    );
  }

  Widget _buildPhoneFormLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context: context,
          title: "Personal Info",
          isTablet: false,
          child: _buildPersonalInfoFields(context, false),
        ),
        _buildSection(
          context: context,
          title: "Appearance",
          isTablet: false,
          child: _buildAppearanceFields(context, false),
        ),
        _buildSection(
          context: context,
          title: "Lifestyle",
          isTablet: false,
          child: _buildLifestyleFields(context, false),
        ),
        _buildSection(
          context: context,
          title: "Background",
          isTablet: false,
          child: _buildBackgroundFields(context, false),
        ),
        _buildSection(
          context: context,
          title: "Career",
          isTablet: false,
          child: _buildCareerFields(context, false),
        ),
        _buildSection(
          context: context,
          title: "Social Links",
          isTablet: false,
          child: _buildSocialLinksFields(context, false),
        ),
        const SizedBox(height: 24.0),
        _buildUpdateButton(context, false),
      ],
    );
  }

  Widget _buildProfileImageSection(BuildContext context, bool isTablet) {
    final double avatarSize = isTablet ? 160.0 : 120.0;
    final double buttonHeight = isTablet ? 48.0 : 40.0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isTablet ? 40.0 : 32.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Obx(
                () => Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 3.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(avatarSize / 2),
                    child: controller.pickedImage.value != null
                        ? Image.file(
                            controller.pickedImage.value!,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/profile_avatar.jpg",
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () => _showImagePickerOptions(context, isTablet),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          Text(
            "Profile Picture",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            "Recommended size: 400x400px",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, bool isTablet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose Profile Picture",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            SizedBox(height: isTablet ? 24.0 : 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  context: context,
                  icon: Icons.photo_library_outlined,
                  label: "Gallery",
                  onTap: () {
                    controller.pickImage();
                    Navigator.pop(context);
                  },
                  isTablet: isTablet,
                ),
                _buildImagePickerOption(
                  context: context,
                  icon: Icons.camera_alt_outlined,
                  label: "Camera",
                  onTap: () {
                    controller.captureImage();
                    Navigator.pop(context);
                  },
                  isTablet: isTablet,
                ),
              ],
            ),
            SizedBox(height: isTablet ? 24.0 : 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isTablet ? 16.0 : 12.0),
      child: Container(
        width: isTablet ? 120.0 : 100.0,
        padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isTablet ? 16.0 : 12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isTablet ? 32.0 : 28.0,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: isTablet ? 12.0 : 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    bool readOnly = false,
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isTablet,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? helperText,
  }) {
    final fieldHeight = isTablet ? 60.0 : 48.0;
    final fontSize = isTablet ? 16.0 : 14.0;
    final iconSize = isTablet ? 24.0 : 20.0;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            readOnly: readOnly,
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey[800],
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: fontSize,
                color: Colors.grey[600],
              ),
              prefixIcon: Icon(
                icon,
                size: iconSize,
                color: Theme.of(context).primaryColor,
              ),
              helperText: helperText,
              helperStyle: TextStyle(
                fontSize: fontSize - 2,
                color: Colors.grey[600],
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16.0 : 12.0,
                vertical: isTablet ? 20.0 : 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: isTablet ? 2.0 : 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String value,
    required Function(String?) onChanged,
    required bool isTablet,
    required String collectionName,
    bool isDropdownExpanded = true,
  }) {
    // Firestore'dan gelen değerler veya varsayılan değerler
    final List<String> items = controller.dropdownValues[collectionName] ?? [];

    // Eğer mevcut değer listede yoksa, listeye ekle
    if (!items.contains(value) && value.isNotEmpty) {
      items.add(value);
    }

    // Eğer liste boşsa, varsayılan değerleri kullan
    final List<String> defaultItems = _getDefaultItems(collectionName);
    final List<String> allItems = items.isEmpty ? defaultItems : items;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 24.0 : 16.0),
      child: DropdownButtonFormField<String>(
        value: allItems.contains(value) ? value : allItems.first,
        isExpanded: isDropdownExpanded,
        items: allItems.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTablet ? 16.0 : 14.0,
                color: Colors.grey[800],
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(
            icon,
            size: isTablet ? 24.0 : 20.0,
            color: Theme.of(context).primaryColor,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16.0 : 12.0,
            vertical: isTablet ? 20.0 : 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: isTablet ? 2.0 : 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  List<String> _getDefaultItems(String collectionName) {
    switch (collectionName) {
      case 'genders':
        return gender;
      case 'countries':
        return countries;
      case 'bodyTypes':
        return bodyTypes;
      case 'drinkingHabits':
        return drinkingHabits;
      case 'smokingHabits':
        return smokingHabits;
      case 'maritalStatuses':
        return maritalStatuses;
      case 'employmentStatuses':
        return employmentStatuses;
      case 'livingSituations':
        return livingSituations;
      case 'nationalities':
        return nationalities;
      case 'educationLevels':
        return educationLevels;
      case 'languages':
        return languages;
      case 'religions':
        return religion;
      case 'ethnicities':
        return ethnicities;
      case 'professions':
        return itJobs;
      default:
        return [];
    }
  }

  Widget _buildCheckboxGroup({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<String> options,
    required RxString selection,
    required Function(String) onChanged,
    required bool isTablet,
  }) {
    final fontSize = isTablet ? 16.0 : 14.0;
    final iconSize = isTablet ? 24.0 : 20.0;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 24.0 : 16.0),
      padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: iconSize,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: isTablet ? 16.0 : 12.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          ...options.map(
            (option) => Obx(
              () => Container(
                margin: EdgeInsets.only(bottom: isTablet ? 8.0 : 4.0),
                decoration: BoxDecoration(
                  color: selection.value == option
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(isTablet ? 8.0 : 6.0),
                ),
                child: CheckboxListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.grey[800],
                    ),
                  ),
                  value: selection.value == option,
                  onChanged: (bool? value) {
                    if (value == true) {
                      onChanged(option);
                    } else if (selection.value == option) {
                      onChanged('');
                    }
                  },
                  activeColor: Theme.of(context).primaryColor,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12.0 : 8.0,
                    vertical: isTablet ? 8.0 : 4.0,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: !isTablet,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksFields(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(isTablet ? 16.0 : 12.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSocialLinkField(
            context: context,
            controller: controller.instagramController,
            label: "Instagram",
            icon: Icons.camera_alt_outlined,
            prefix: "@",
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinkField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String prefix,
    required bool isTablet,
    bool isLast = false,
  }) {
    final fontSize = isTablet ? 16.0 : 14.0;
    final iconSize = isTablet ? 24.0 : 20.0;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : (isTablet ? 20.0 : 16.0)),
      child: Row(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: isTablet ? 16.0 : 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Text(
                      prefix,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: isTablet ? 8.0 : 4.0),
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.grey[800],
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isTablet ? 12.0 : 8.0,
                          ),
                          border: InputBorder.none,
                          hintText: "Enter your username",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context, bool isTablet) {
    final buttonHeight = isTablet ? 56.0 : 48.0;
    final fontSize = isTablet ? 18.0 : 16.0;

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 16.0 : 12.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => ElevatedButton(
          onPressed:
              controller.uploading.value ? null : () => _handleUpdate(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 16.0 : 12.0),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32.0 : 24.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.uploading.value) ...[
                SizedBox(
                  height: isTablet ? 24.0 : 20.0,
                  width: isTablet ? 24.0 : 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: isTablet ? 3.0 : 2.0,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: isTablet ? 16.0 : 12.0),
                Text(
                  "Updating Profile...",
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.check_circle_outline,
                  size: isTablet ? 24.0 : 20.0,
                  color: Colors.white,
                ),
                SizedBox(width: isTablet ? 16.0 : 12.0),
                Text(
                  "Update Profile",
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdate(BuildContext context) async {
    try {
      // Form doğrulama
      if (!_validateForm()) {
        _showErrorSnackbar(
          context,
          "Please fill in all required fields correctly.",
        );
        return;
      }

      // Profil güncelleme
      await controller.updateUserDataToFirestore();

      // Başarılı güncelleme bildirimi
      _showSuccessSnackbar(context);
    } catch (e) {
      _showErrorSnackbar(
        context,
        "An error occurred while updating your profile. Please try again.",
      );
    }
  }

  bool _validateForm() {
    // Gerekli alanları kontrol et
    if (controller.nameController.text.isEmpty ||
        controller.emailController.text.isEmpty ||
        controller.phoneNoController.text.isEmpty) {
      return false;
    }

    // Email formatını kontrol et
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(controller.emailController.text)) {
      return false;
    }

    // Telefon numarası formatını kontrol et
    final phoneRegex = RegExp(r'^\+?[\d\s-]+$');
    if (!phoneRegex.hasMatch(controller.phoneNoController.text)) {
      return false;
    }

    return true;
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(
            MediaQuery.of(context).size.width > 600 ? 40.0 : 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Updated',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          MediaQuery.of(context).size.width > 600 ? 16.0 : 14.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your profile has been successfully updated.',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width > 600 ? 14.0 : 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(
            MediaQuery.of(context).size.width > 600 ? 40.0 : 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          MediaQuery.of(context).size.width > 600 ? 16.0 : 14.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width > 600 ? 14.0 : 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildPersonalInfoFields(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          readOnly: true,
          context: context,
          controller: controller.nameController,
          label: "Full Name",
          icon: Icons.person_outline,
          isTablet: isTablet,
          helperText:
              "Enter your full name as it appears on official documents",
        ),
        _buildTextField(
          readOnly: true,
          context: context,
          controller: controller.emailController,
          label: "Email Address",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          isTablet: isTablet,
          helperText: "Your primary email address for communications",
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildTextField(
                context: context,
                controller: controller.ageController,
                label: "Age",
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                isTablet: isTablet,
              ),
            ),
            SizedBox(width: isTablet ? 24.0 : 16.0),
            Expanded(
              flex: 2,
              child: _buildDropdownField(
                context: context,
                label: "Gender",
                icon: Icons.person_outline_rounded,
                value: controller.genderController.text,
                onChanged: (value) =>
                    controller.genderController.text = value ?? '',
                isTablet: isTablet,
                collectionName: 'genders',
              ),
            ),
          ],
        ),
        _buildTextField(
          context: context,
          controller: controller.phoneNoController,
          label: "Phone Number",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isTablet: isTablet,
          helperText: "Include country code (e.g., +1 234 567 8900)",
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildDropdownField(
                context: context,
                label: "Country",
                icon: Icons.public_outlined,
                value: controller.countryController.text,
                onChanged: (value) =>
                    controller.countryController.text = value ?? '',
                isTablet: isTablet,
                collectionName: 'countries',
              ),
            ),
            SizedBox(width: isTablet ? 24.0 : 16.0),
            Expanded(
              flex: 1,
              child: _buildTextField(
                context: context,
                controller: controller.cityController,
                label: "City",
                icon: Icons.location_city_outlined,
                isTablet: isTablet,
              ),
            ),
          ],
        ),
        _buildTextField(
          context: context,
          controller: controller.profileHeadingController,
          label: "Profile Headline",
          icon: Icons.text_fields_outlined,
          maxLines: 2,
          isTablet: isTablet,
          helperText:
              "A brief description that appears at the top of your profile",
        ),
      ],
    );
  }

  Widget _buildAppearanceFields(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context: context,
                controller: controller.heightController,
                label: "Height",
                icon: Icons.height_outlined,
                keyboardType: TextInputType.number,
                isTablet: isTablet,
                helperText: "In centimeters",
              ),
            ),
            SizedBox(width: isTablet ? 24.0 : 16.0),
            Expanded(
              child: _buildTextField(
                context: context,
                controller: controller.weightController,
                label: "Weight",
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
                isTablet: isTablet,
                helperText: "In kilograms",
              ),
            ),
          ],
        ),
        _buildDropdownField(
          context: context,
          label: "Body Type",
          icon: Icons.accessibility_new_outlined,
          value: controller.bodyTypeController.text,
          onChanged: (value) =>
              controller.bodyTypeController.text = value ?? '',
          isTablet: isTablet,
          collectionName: 'bodyTypes',
        ),
      ],
    );
  }

  Widget _buildLifestyleFields(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxGroup(
          context: context,
          title: "Do you have children?",
          icon: Icons.child_care_outlined,
          options: controller.childrenOptions,
          selection: controller.childrenSelection,
          onChanged: controller.updateChildrenOption,
          isTablet: isTablet,
        ),
        if (controller.childrenSelection.value.isNotEmpty &&
            controller.childrenSelection.value != "No")
          _buildTextField(
            context: context,
            controller: controller.noOfChildrenController,
            label: "Number of Children",
            icon: Icons.child_friendly_outlined,
            keyboardType: TextInputType.number,
            isTablet: isTablet,
          ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                context: context,
                label: "Employment Status",
                icon: Icons.work_outline_outlined,
                value: controller.employmentStatusController.text,
                onChanged: (value) =>
                    controller.employmentStatusController.text = value ?? '',
                isTablet: isTablet,
                collectionName: 'employmentStatuses',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                context: context,
                label: "Profession",
                icon: Icons.business_center_outlined,
                value: controller.professionController.text,
                onChanged: (value) =>
                    controller.professionController.text = value ?? "",
                isTablet: isTablet,
                collectionName: 'professions',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                context: context,
                label: "Living Situation",
                icon: Icons.home_outlined,
                value: controller.livingSituationController.text,
                onChanged: (value) =>
                    controller.livingSituationController.text = value ?? '',
                isTablet: isTablet,
                collectionName: 'livingSituations',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCareerFields(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İş Deneyimi Ekleme Formu
        _buildTextField(
          context: context,
          controller: controller.titleController,
          label: "İş Ünvanı",
          icon: Icons.work_outline,
          isTablet: isTablet,
        ),
        _buildTextField(
          context: context,
          controller: controller.companyController,
          label: "Şirket",
          icon: Icons.business_outlined,
          isTablet: isTablet,
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context: context,
                controller: controller.startDateController,
                label: "Başlangıç Tarihi",
                icon: Icons.calendar_today_outlined,
                isTablet: isTablet,
              ),
            ),
            SizedBox(width: isTablet ? 24.0 : 16.0),
            Expanded(
              child: _buildTextField(
                context: context,
                controller: controller.endDateController,
                label: "Bitiş Tarihi",
                icon: Icons.calendar_today_outlined,
                isTablet: isTablet,
                helperText: "Devam ediyorsa boş bırakın",
              ),
            ),
          ],
        ),
        _buildTextField(
          context: context,
          controller: controller.descriptionController,
          label: "Açıklama",
          icon: Icons.description_outlined,
          isTablet: isTablet,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: controller.addWorkExperience,
          child: const Text("İş Deneyimi Ekle"),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),

        // İş Deneyimi Listesi
        Text(
          "İş Deneyimleri",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.workExperiences.length,
              itemBuilder: (context, index) {
                final exp = controller.workExperiences[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(exp.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exp.company),
                        Text(
                            "${exp.startDate} - ${exp.endDate ?? 'Devam ediyor'}"),
                        if (exp.description != null)
                          Text(
                            exp.description!,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                );
              },
            )),

        const SizedBox(height: 32),

        // Yetenekler
        Text(
          "Yetenekler",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context: context,
                controller: controller.skillController,
                label: "Yetenek",
                icon: Icons.psychology_outlined,
                isTablet: isTablet,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                if (controller.skillController.text.isNotEmpty) {
                  controller.addSkill(controller.skillController.text);
                  controller.skillController.clear();
                }
              },
              child: const Text("Ekle"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => controller.removeSkill(skill),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildBackgroundFields(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                context: context,
                label: "Nationality",
                icon: Icons.flag_outlined,
                value: controller.nationalityController.text,
                onChanged: (value) =>
                    controller.nationalityController.text = value ?? '',
                isTablet: isTablet,
                collectionName: 'nationalities',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                context: context,
                label: "Education Level",
                icon: Icons.school_outlined,
                value: controller.educationController.text,
                onChanged: (value) =>
                    controller.educationController.text = value ?? '',
                isTablet: isTablet,
                collectionName: 'educationLevels',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                context: context,
                label: "Primary Language",
                icon: Icons.language_outlined,
                value: controller.languageSpokenController.text,
                onChanged: (value) =>
                    controller.languageSpokenController.text = value ?? '',
                isTablet: isTablet,
                collectionName: 'languages',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
