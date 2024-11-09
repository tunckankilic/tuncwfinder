import 'package:flutter/material.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';
import 'dart:io';

class ProfileInfoScreen extends GetView<AccountSettingsController> {
  const ProfileInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        return Scaffold(
          appBar: _buildAppBar(context, isTablet),
          body: _buildResponsiveLayout(context, isTablet),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    final double toolbarHeight = isTablet ? 70.0 : kToolbarHeight;

    return AppBar(
      backgroundColor: ElegantTheme.primaryColor,
      toolbarHeight: toolbarHeight,
      title: Text(
        "Edit Profile Info",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontSize: isTablet ? 24.0 : 20.0,
            ),
      ),
      leading: IconButton(
        icon: Icon(
          Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
          size: isTablet ? 28.0 : 24.0,
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

  Widget _buildTabletLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.1; // 10% padding on each side

    return Row(
      children: [
        // Left Navigation Panel
        SizedBox(
          width: 280,
          child: _buildNavigationPanel(context),
        ),
        // Main Content Area
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileImageSection(context, true),
                _buildTabletFormLayout(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImageSection(context, false),
            const SizedBox(height: 24.0),
            _buildPhoneFormLayout(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationPanel(BuildContext context) {
    return Container(
      color: ElegantTheme.primaryColor.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavItem(
            context: context,
            icon: Icons.person,
            title: "Personal Info",
            isSelected: controller.currentSection.value == "personal",
            onTap: () => _scrollToSection("personal"),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.face,
            title: "Appearance",
            isSelected: controller.currentSection.value == "appearance",
            onTap: () => _scrollToSection("appearance"),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.health_and_safety,
            title: "Lifestyle",
            isSelected: controller.currentSection.value == "lifestyle",
            onTap: () => _scrollToSection("lifestyle"),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.history_edu,
            title: "Background",
            isSelected: controller.currentSection.value == "background",
            onTap: () => _scrollToSection("background"),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.connect_without_contact,
            title: "Connections",
            isSelected: controller.currentSection.value == "connections",
            onTap: () => _scrollToSection("connections"),
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
              ? ElegantTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color:
                  isSelected ? ElegantTheme.primaryColor : Colors.transparent,
              width: 4.0,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ElegantTheme.primaryColor
                  : ElegantTheme.primaryColor.withOpacity(0.7),
              size: 24.0,
            ),
            const SizedBox(width: 16.0),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? ElegantTheme.primaryColor
                        : ElegantTheme.primaryColor.withOpacity(0.7),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToSection(String sectionName) {
    controller.currentSection.value = sectionName;
    // Implement smooth scrolling to section
  }

  Widget _buildTabletFormLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
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
            // Right Column
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
                    title: "Connections",
                    isTablet: true,
                    child: _buildConnectionFields(context, true),
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
          title: "Connections",
          isTablet: false,
          child: _buildConnectionFields(context, false),
        ),
        const SizedBox(height: 24.0),
        _buildUpdateButton(context, false),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required bool isTablet,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ElegantTheme.primaryColor,
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16.0),
          child,
        ],
      ),
    );
  }

  Widget _buildProfileImageSection(BuildContext context, bool isTablet) {
    final double avatarSize = isTablet ? 160.0 : 120.0;
    final double buttonHeight = isTablet ? 48.0 : 40.0;

    return Center(
      child: Column(
        children: [
          Obx(
            () => CircleAvatar(
              radius: avatarSize / 2,
              backgroundImage: controller.pickedImage.value != null
                  ? FileImage(controller.pickedImage.value!)
                  : const AssetImage("assets/profile_avatar.jpg")
                      as ImageProvider,
              backgroundColor: ElegantTheme.primaryColor.withOpacity(0.1),
            ),
          ),
          SizedBox(height: isTablet ? 24.0 : 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImagePickerButton(
                context: context,
                icon: Icons.image,
                label: "Gallery",
                onPressed: controller.pickImage,
                isTablet: isTablet,
                height: buttonHeight,
              ),
              SizedBox(width: isTablet ? 16.0 : 12.0),
              _buildImagePickerButton(
                context: context,
                icon: Icons.camera_alt,
                label: "Camera",
                onPressed: controller.captureImage,
                isTablet: isTablet,
                height: buttonHeight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoFields(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          context: context,
          controller: controller.nameController,
          label: "Name",
          icon: Icons.person,
          isTablet: isTablet,
        ),
        _buildTextField(
          context: context,
          controller: controller.emailController,
          label: "Email",
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          isTablet: isTablet,
        ),
        _buildTextField(
          context: context,
          controller: controller.ageController,
          label: "Age",
          icon: Icons.cake,
          keyboardType: TextInputType.number,
          isTablet: isTablet,
        ),
        _buildDropdownField(
          context: context,
          label: "Gender",
          icon: Icons.person_outlined,
          items: gender,
          value: controller.genderController.text,
          onChanged: (value) => controller.genderController.text = value ?? '',
          isTablet: isTablet,
        ),
        _buildTextField(
          context: context,
          controller: controller.phoneNoController,
          label: "Phone Number",
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          isTablet: isTablet,
        ),
        _buildDropdownField(
          context: context,
          label: "Country",
          icon: Icons.flag_outlined,
          items: countries,
          value: controller.countryController.text,
          onChanged: (value) => controller.countryController.text = value ?? '',
          isTablet: isTablet,
        ),
        _buildTextField(
          context: context,
          controller: controller.cityController,
          label: "City",
          icon: Icons.location_city,
          isTablet: isTablet,
        ),
        _buildTextField(
          context: context,
          controller: controller.profileHeadingController,
          label: "Profile Heading",
          icon: Icons.title,
          maxLines: 3,
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildAppearanceFields(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          context: context,
          controller: controller.heightController,
          label: "Height (cm)",
          icon: Icons.height,
          keyboardType: TextInputType.number,
          isTablet: isTablet,
        ),
        _buildTextField(
          context: context,
          controller: controller.weightController,
          label: "Weight (kg)",
          icon: Icons.fitness_center,
          keyboardType: TextInputType.number,
          isTablet: isTablet,
        ),
        _buildDropdownField(
          context: context,
          label: "Body Type",
          icon: Icons.accessibility_new_outlined,
          items: bodyTypes,
          value: controller.bodyTypeController.text,
          onChanged: (value) =>
              controller.bodyTypeController.text = value ?? '',
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isTablet,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final fieldHeight = isTablet ? 60.0 : 48.0;
    final fontSize = isTablet ? 16.0 : 14.0;
    final iconSize = isTablet ? 24.0 : 20.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 24.0 : 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: fontSize),
          prefixIcon:
              Icon(icon, size: iconSize, color: ElegantTheme.primaryColor),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16.0 : 12.0,
            vertical: isTablet ? 20.0 : 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
            borderSide: BorderSide(color: ElegantTheme.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
            borderSide: BorderSide(
              color: ElegantTheme.primaryColor,
              width: isTablet ? 2.0 : 1.5,
            ),
          ),
          constraints: BoxConstraints(
            minHeight: fieldHeight,
            maxHeight: fieldHeight * maxLines,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required List<String> items,
    required String value,
    required Function(String?) onChanged,
    required bool isTablet,
  }) {
    final fieldHeight = isTablet ? 60.0 : 48.0;
    final fontSize = isTablet ? 16.0 : 14.0;
    final iconSize = isTablet ? 24.0 : 20.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 24.0 : 16.0),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? items.first : value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: TextStyle(fontSize: fontSize)),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: fontSize),
          prefixIcon:
              Icon(icon, size: iconSize, color: ElegantTheme.primaryColor),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16.0 : 12.0,
            vertical: isTablet ? 20.0 : 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
            borderSide: BorderSide(color: ElegantTheme.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
            borderSide: BorderSide(
              color: ElegantTheme.primaryColor,
              width: isTablet ? 2.0 : 1.5,
            ),
          ),
          constraints: BoxConstraints(
            minHeight: fieldHeight,
            maxHeight: fieldHeight,
          ),
        ),
      ),
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
        if (controller.childrenSelection.value.isNotEmpty)
          _buildTextField(
            context: context,
            controller: controller.noOfChildrenController,
            label: "Number of Children",
            icon: Icons.child_friendly_outlined,
            keyboardType: TextInputType.number,
            isTablet: isTablet,
          ),
        _buildDropdownField(
          context: context,
          label: "Employment Status",
          icon: Icons.business_center_outlined,
          items: employmentStatuses,
          value: controller.employmentStatusController.text,
          onChanged: (value) =>
              controller.employmentStatusController.text = value ?? '',
          isTablet: isTablet,
        ),
        _buildTextField(
          context: context,
          controller: controller.incomeController,
          label: "Annual Income",
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          isTablet: isTablet,
        ),
        _buildDropdownField(
          context: context,
          label: "Living Situation",
          icon: Icons.home_outlined,
          items: livingSituations,
          value: controller.livingSituationController.text,
          onChanged: (value) =>
              controller.livingSituationController.text = value ?? '',
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildBackgroundFields(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
          context: context,
          label: "Nationality",
          icon: Icons.public_outlined,
          items: nationalities,
          value: controller.nationalityController.text,
          onChanged: (value) =>
              controller.nationalityController.text = value ?? '',
          isTablet: isTablet,
        ),
        _buildDropdownField(
          context: context,
          label: "Highest Education",
          icon: Icons.school_outlined,
          items: highSchool,
          value: controller.educationController.text,
          onChanged: (value) =>
              controller.educationController.text = value ?? '',
          isTablet: isTablet,
        ),
        _buildDropdownField(
          context: context,
          label: "Languages",
          icon: Icons.language_outlined,
          items: languages,
          value: controller.languageSpokenController.text,
          onChanged: (value) =>
              controller.languageSpokenController.text = value ?? '',
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildConnectionFields(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          context: context,
          controller: controller.linkedInController,
          label: "LinkedIn Profile",
          icon: Icons.link,
          isTablet: isTablet,
        ),
        _buildTextField(
          context: context,
          controller: controller.instagramController,
          label: "Instagram Handle",
          icon: Icons.camera_alt,
          isTablet: isTablet,
        ),
        _buildTextField(
          context: context,
          controller: controller.gitHubController,
          label: "GitHub Profile",
          icon: Icons.code,
          isTablet: isTablet,
        ),
      ],
    );
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
    final verticalPadding = isTablet ? 12.0 : 8.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: iconSize, color: ElegantTheme.primaryColor),
              SizedBox(width: isTablet ? 16.0 : 12.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          ...options.map(
            (option) => Obx(
              () => CheckboxListTile(
                title: Text(
                  option,
                  style: TextStyle(fontSize: fontSize),
                ),
                value: selection.value == option,
                onChanged: (bool? value) {
                  if (value == true) {
                    onChanged(option);
                  } else if (selection.value == option) {
                    onChanged('');
                  }
                },
                activeColor: ElegantTheme.primaryColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: verticalPadding,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: !isTablet,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context, bool isTablet) {
    final buttonHeight = isTablet ? 56.0 : 48.0;
    final fontSize = isTablet ? 18.0 : 16.0;
    final horizontalPadding = isTablet ? 48.0 : 32.0;

    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: controller.uploading.value
              ? null
              : controller.updateUserDataToFirestore,
          style: ElevatedButton.styleFrom(
            backgroundColor: ElegantTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 16.0 : 12.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          ),
          child: controller.uploading.value
              ? SizedBox(
                  height: isTablet ? 24.0 : 20.0,
                  width: isTablet ? 24.0 : 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: isTablet ? 3.0 : 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  "Update Profile",
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildImagePickerButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isTablet,
    required double height,
  }) {
    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: isTablet ? 24.0 : 20.0,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ElegantTheme.secondaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
          ),
        ),
      ),
    );
  }
}
