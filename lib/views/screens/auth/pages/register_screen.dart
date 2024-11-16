import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/service/validation.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';

class RegistrationScreen extends GetView<AuthController> {
  static const routeName = "/register";
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: ElegantTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isTablet),
            Expanded(
              child: Row(
                children: [
                  if (isTablet) _buildTabletNavigation(),
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      itemCount: 6,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        controller.currentPage.value = index;
                      },
                      itemBuilder: (context, index) {
                        return _buildPage(index, isTablet, context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (!isTablet) _buildNavigationButtons(isTablet),
            _buildProgressIndicator(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletNavigation() {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: ElegantTheme.primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Obx(() => Column(
            children: [
              _buildNavItem('Start', 0, Icons.person),
              _buildNavItem('Personal Info', 1, Icons.person_outline),
              _buildNavItem('Appearance', 2, Icons.face_3_outlined),
              _buildNavItem('Lifestyle', 3, Icons.health_and_safety),
              _buildNavItem('Background', 4, Icons.history_edu),
              _buildNavItem('Connections', 5, Icons.connect_without_contact),
            ],
          )),
    );
  }

  Widget _buildNavItem(String title, int index, IconData icon) {
    final isSelected = controller.currentPage.value == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? ElegantTheme.primaryColor : Colors.black,
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? ElegantTheme.primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      onTap: () => controller.pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      selected: isSelected,
      selectedTileColor: ElegantTheme.primaryColor.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      decoration: BoxDecoration(
        color: ElegantTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  controller.clearAllFields();
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios),
                iconSize: isTablet ? 28.0 : 24.0,
                padding: EdgeInsets.all(isTablet ? 12.0 : 8.0),
              ),
              Text(
                "Create Account",
                style: ElegantTheme.textTheme.headlineMedium?.copyWith(
                  color: ElegantTheme.primaryColor,
                  fontSize: isTablet ? 32.0 : 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 15.0 : 10.0),
          Text(
            "to get Started Now.",
            style: ElegantTheme.textTheme.titleMedium?.copyWith(
              fontSize: isTablet ? 20.0 : 16.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: isTablet ? 25.0 : 20.0),
          Obx(() => LinearProgressIndicator(
                value: (controller.currentPage.value + 1) / 6,
                backgroundColor: ElegantTheme.primaryColor.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  ElegantTheme.primaryColor,
                ),
                minHeight: isTablet ? 8.0 : 4.0,
                borderRadius: BorderRadius.circular(isTablet ? 4.0 : 2.0),
              )),
        ],
      ),
    );
  }

  Widget _buildPage(int index, bool isTablet, BuildContext context) {
    final content = switch (index) {
      0 => _buildStartPage(isTablet, context),
      1 => _buildPersonalInfoPage(isTablet),
      2 => _buildAppearancePage(isTablet),
      3 => _buildLifestylePage(isTablet),
      4 => _buildBackgroundPage(isTablet),
      5 => _buildConnectionsPage(isTablet),
      _ => Container(),
    };

    return _buildPageContent(content, isTablet);
  }

// Form elemanları için temel stiller
  InputDecoration _getInputDecoration(
      String label, IconData icon, bool isTablet, bool password) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: isTablet ? 18.0 : 16.0,
        color: Colors.black,
      ),
      prefixIcon: Icon(
        icon,
        color: ElegantTheme.primaryColor,
        size: isTablet ? 28.0 : 24.0,
      ),
      suffixIcon: password
          ? IconButton(
              onPressed: () {
                controller.obsPass.value = !controller.obsPass.value;
              },
              icon: Icon(Icons.remove_red_eye))
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
        borderSide: const BorderSide(color: ElegantTheme.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
        borderSide: BorderSide(
          color: Colors.black,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
        borderSide: BorderSide(
          color: ElegantTheme.primaryColor,
          width: isTablet ? 2.5 : 2.0,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20.0 : 15.0,
        vertical: isTablet ? 20.0 : 15.0,
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isTablet, {
    bool isObscure = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 15.0),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
        decoration: _getInputDecoration(label, icon, isTablet, false),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    List<String> items,
    Function(String) onChanged,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 15.0),
      child: DropdownButtonFormField<String>(
        value: items.first,
        onChanged: (newValue) => onChanged(newValue ?? items[0]),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: isTablet ? 15.0 : 13.0),
            ),
          );
        }).toList(),
        decoration: _getInputDecoration(label, icon, isTablet, false),
        dropdownColor: ElegantTheme.backgroundColor,
        style: TextStyle(fontSize: isTablet ? 18.0 : 16.0, color: Colors.black),
      ),
    );
  }

  Widget _buildCheckboxGroup(
    String label,
    IconData icon,
    List<String> options,
    RxString selection,
    Function(String) onChanged,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: ElegantTheme.primaryColor,
                size: isTablet ? 28.0 : 24.0,
              ),
              SizedBox(width: isTablet ? 15.0 : 10.0),
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 18.0 : 16.0,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 15.0 : 10.0),
          ...options.map((option) => Obx(() => CheckboxListTile(
                title: Text(
                  option,
                  style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
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
                  horizontal: isTablet ? 20.0 : 15.0,
                  vertical: isTablet ? 12.0 : 8.0,
                ),
              ))),
        ],
      ),
    );
  }

  Widget _buildConnectionsPage(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SocialLinksSection(
                controller: controller,
                isTablet: isTablet,
              ),
              SizedBox(height: isTablet ? 30.0 : 24.0),
              _buildTermsAndConditions(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 15.0 : 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          Obx(() => controller.currentPage.value > 0
              ? ElevatedButton(
                  onPressed: controller.previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElegantTheme.secondaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 30.0 : 20.0,
                      vertical: isTablet ? 15.0 : 10.0,
                    ),
                    minimumSize: Size(isTablet ? 120.0 : 100.0, 0),
                  ),
                  child: Text(
                    "Previous",
                    style: TextStyle(fontSize: isTablet ? 18.0 : 14.0),
                  ),
                )
              : const SizedBox.shrink()),

          // Next/Create Account Button
          Obx(() {
            final isLastPage = controller.currentPage.value == 5;
            final isLoading = controller.showProgressBar.value;

            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : isLastPage
                      ? () async {
                          if (!controller.termsAccepted.value) {
                            Get.snackbar(
                              'Error',
                              'Please accept the terms and conditions',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          await controller.register();
                        }
                      : controller.nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: ElegantTheme.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 30.0 : 20.0,
                  vertical: isTablet ? 15.0 : 10.0,
                ),
                minimumSize: Size(isTablet ? 120.0 : 100.0, 0),
              ),
              child: isLoading && isLastPage
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isLastPage ? "Create Account" : "Next",
                      style: TextStyle(fontSize: isTablet ? 18.0 : 14.0),
                    ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker(bool isTablet) {
    return Obx(() => Column(
          children: [
            CircleAvatar(
              radius: isTablet ? 80 : 60,
              backgroundImage: controller.pickedImage.value != null
                  ? FileImage(controller.pickedImage.value!)
                  : const AssetImage("assets/profile_avatar.jpg")
                      as ImageProvider,
              backgroundColor: ElegantTheme.primaryColor.withOpacity(0.1),
            ),
            SizedBox(height: isTablet ? 20 : 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.pickImage,
                  icon: Icon(Icons.image, size: isTablet ? 24 : 20),
                  label: Text(
                    "Gallery",
                    style: TextStyle(fontSize: isTablet ? 18 : 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElegantTheme.secondaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 10),
                ElevatedButton.icon(
                  onPressed: controller.captureImage,
                  icon: Icon(Icons.camera_alt, size: isTablet ? 24 : 20),
                  label: Text(
                    "Camera",
                    style: TextStyle(fontSize: isTablet ? 18 : 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElegantTheme.secondaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 40 : 30),
          ],
        ));
  }

  // _buildStartPage güncellendi
  Widget _buildStartPage(bool isTablet, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImagePicker(isTablet),
              _buildTextField(
                controller.nameController,
                "Name",
                Icons.person_outline,
                isTablet,
              ),
              _buildTextField(
                controller.emailController,
                "Email",
                Icons.email_outlined,
                isTablet,
              ),
              _buildPasswordField(
                textController: controller.passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                isTablet: isTablet,
                controller: controller, // AuthController erişimi için
              ),
              _buildPasswordField(
                textController: controller.confirmPasswordController,
                label: "Confirm Password",
                icon: Icons.lock_outline,
                isTablet: isTablet,
                controller: controller,
                isConfirmPassword: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

// Yeni ve geliştirilmiş password field widget'ı
  Widget _buildPasswordField({
    required TextEditingController textController,
    required String label,
    required IconData icon,
    required bool isTablet,
    required AuthController controller,
    bool isConfirmPassword = false,
  }) {
    return Obx(() => Padding(
          padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                obscureText: controller.obsPass.value,
                style: TextStyle(
                  fontSize: isTablet ? 18.0 : 16.0,
                  color: Colors.black,
                ),
                onChanged: (value) {
                  if (!isConfirmPassword) {
                    // Ana şifre alanı için kontroller
                    if (value.length >= 8) {
                      controller.checks[0].value = true;
                    } else {
                      controller.checks[0].value = false;
                    }
                    if (value.contains(RegExp(r'[A-Z]'))) {
                      controller.checks[1].value = true;
                    } else {
                      controller.checks[1].value = false;
                    }
                    if (value.contains(RegExp(r'[a-z]'))) {
                      controller.checks[2].value = true;
                    } else {
                      controller.checks[2].value = false;
                    }
                    if (value.contains(RegExp(r'[0-9]'))) {
                      controller.checks[3].value = true;
                    } else {
                      controller.checks[3].value = false;
                    }
                    if (value.contains(
                        RegExp(r'[!@#$%^&*()_+\-=\[\]{};:\\\|,.<>\/?]+'))) {
                      controller.checks[4].value = true;
                    } else {
                      controller.checks[4].value = false;
                    }
                    if (value.isEmpty) {
                      for (var i = 0; i < 5; i++) {
                        controller.checks[i].value = false;
                      }
                    }

                    // Confirm password ile karşılaştırma
                    if (controller.confirmPasswordController.text.isNotEmpty) {
                      if (value != controller.confirmPasswordController.text) {
                        controller.confirmPasswordError.value =
                            'Passwords do not match';
                      } else {
                        controller.confirmPasswordError.value = '';
                      }
                    }
                  } else {
                    // Confirm password kontrolü
                    if (value != controller.passwordController.text) {
                      controller.confirmPasswordError.value =
                          'Passwords do not match';
                    } else {
                      controller.confirmPasswordError.value = '';
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    fontSize: isTablet ? 18.0 : 16.0,
                    color: Colors.black,
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: ElegantTheme.primaryColor,
                    size: isTablet ? 28.0 : 24.0,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.obsPass.value = !controller.obsPass.value;
                    },
                    icon: Icon(
                      controller.obsPass.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: ElegantTheme.primaryColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
                    borderSide:
                        const BorderSide(color: ElegantTheme.primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
                    borderSide: BorderSide(
                      color: ElegantTheme.primaryColor,
                      width: isTablet ? 2.5 : 2.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20.0 : 15.0,
                    vertical: isTablet ? 20.0 : 15.0,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: isConfirmPassword
                      ? controller.confirmPasswordError.value.isNotEmpty
                          ? controller.confirmPasswordError.value
                          : null
                      : controller.passwordError.value.isNotEmpty
                          ? controller.passwordError.value
                          : null,
                ),
              ),
              if (!isConfirmPassword) ...[
                SizedBox(height: isTablet ? 20.0 : 15.0),
                Text(
                  "Password Strength",
                  style: TextStyle(
                    color: Color(0xFF787A8D),
                    fontSize: isTablet ? 14.0 : 12.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5.0),
                SizedBox(
                  width: double.infinity,
                  height: 12.0,
                  child: CustomProgressBar(
                    var1: controller.checks[0].value,
                    var2: controller.checks[1].value,
                    var3: controller.checks[2].value,
                    var4: controller.checks[3].value,
                    var5: controller.checks[4].value,
                    isTablet: isTablet,
                  ),
                ),
                SizedBox(height: 10.0),
                Column(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: CheckList(
                        index: index,
                        isTablet: isTablet,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ));
  }

  Widget _buildPersonalInfoPage(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller.ageController,
                "Age",
                Icons.cake_outlined,
                isTablet,
              ),
              _buildDropdown(
                "Gender",
                Icons.person_outlined,
                gender,
                (value) => controller.genderController.text = value,
                isTablet,
              ),
              _buildTextField(
                controller.phoneNoController,
                "Phone",
                Icons.phone_outlined,
                isTablet,
              ),
              _buildDropdown(
                "Country",
                Icons.flag_outlined,
                countries,
                (value) => controller.countryController.text = value,
                isTablet,
              ),
              _buildTextField(
                controller.cityController,
                "City",
                Icons.location_city_outlined,
                isTablet,
              ),
              _buildTextField(
                controller.profileHeadingController,
                "Profile Heading",
                Icons.text_fields_outlined,
                isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearancePage(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller.heightController,
                "Height (cm)",
                Icons.height_outlined,
                isTablet,
              ),
              _buildTextField(
                controller.weightController,
                "Weight (kg)",
                Icons.fitness_center_outlined,
                isTablet,
              ),
              _buildDropdown(
                "Body Type",
                Icons.accessibility_new_outlined,
                bodyTypes,
                (value) => controller.bodyTypeController.text = value,
                isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifestylePage(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                "Drinking Habits",
                Icons.local_bar_outlined,
                drinkingHabits,
                (value) => controller.drinkController.text = value,
                isTablet,
              ),
              _buildDropdown(
                "Smoking Habits",
                Icons.smoking_rooms_outlined,
                smokingHabits,
                (value) => controller.smokeController.text = value,
                isTablet,
              ),
              _buildDropdown(
                "Marital Status",
                Icons.people_outline,
                maritalStatuses,
                (value) => controller.martialStatusController.text = value,
                isTablet,
              ),
              _buildCheckboxGroup(
                "Do you have children?",
                Icons.child_care_outlined,
                controller.childrenOptions,
                controller.childrenSelection,
                controller.updateChildrenOption,
                isTablet,
              ),
              if (controller.childrenSelection.value.isNotEmpty)
                _buildTextField(
                  controller.noOfChildrenController,
                  "Number of Children",
                  Icons.child_friendly_outlined,
                  isTablet,
                ),
              _buildDropdown(
                "Profession",
                Icons.work_outline,
                itJobs,
                (value) => controller.professionController.text = value,
                isTablet,
              ),
              _buildDropdown(
                "Employment Status",
                Icons.business_center_outlined,
                employmentStatuses,
                (value) => controller.employmentStatusController.text = value,
                isTablet,
              ),
              _buildTextField(
                controller.incomeController,
                "Annual Income",
                Icons.attach_money_outlined,
                isTablet,
              ),
              _buildDropdown(
                "Living Situation",
                Icons.home_outlined,
                livingSituations,
                (value) => controller.livingSituationController.text = value,
                isTablet,
              ),
              _buildCheckboxGroup(
                "What's your relationship status?",
                Icons.favorite_outline,
                controller.relationshipOptions,
                controller.relationshipSelection,
                controller.updateRelationshipOption,
                isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }

// Widget tarafındaki dialog kodları
  void _showTermsAndConditions() {
    final isTablet = Get.width >= 600;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: isTablet ? Get.width * 0.7 : Get.width * 0.9,
          padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'End User License Agreement',
                style: TextStyle(
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: Get.height * (isTablet ? 0.7 : 0.6),
                child: SingleChildScrollView(
                  child: Text(
                    controller.eula,
                    style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 24.0 : 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.updateTermsAcceptance(false);
                      Get.back();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                    ),
                  ),
                  SizedBox(width: isTablet ? 24.0 : 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _showPrivacyPolicy();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32.0 : 24.0,
                        vertical: isTablet ? 16.0 : 12.0,
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showPrivacyPolicy() {
    final isTablet = Get.width >= 600;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: isTablet ? Get.width * 0.7 : Get.width * 0.9,
          padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: Get.height * (isTablet ? 0.7 : 0.6),
                child: SingleChildScrollView(
                  child: Text(
                    controller.privacyPolicy,
                    style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 24.0 : 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.updateTermsAcceptance(false);
                      Get.back();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                    ),
                  ),
                  SizedBox(width: isTablet ? 24.0 : 16.0),
                  ElevatedButton(
                    onPressed: () {
                      controller.updateTermsAcceptance(true);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32.0 : 24.0,
                        vertical: isTablet ? 16.0 : 12.0,
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildTermsAndConditions(bool isTablet) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ana Checkbox ve EULA linki
            CheckboxListTile(
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'I accept the ',
                      style: TextStyle(
                        fontSize: isTablet ? 18.0 : 16.0,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: TextStyle(
                        fontSize: isTablet ? 18.0 : 16.0,
                        color: ElegantTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showTermsAndConditions(),
                    ),
                  ],
                ),
              ),
              value: controller.termsAccepted.value,
              onChanged: (value) {
                if (value == true) {
                  _showTermsAndConditions();
                } else {
                  controller.updateTermsAcceptance(false);
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20.0 : 16.0,
                vertical: isTablet ? 12.0 : 8.0,
              ),
            ),
            // Kullanıcı İçeriği Politikası Bildirimi
            Container(
              padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
              margin: EdgeInsets.symmetric(
                vertical: isTablet ? 16.0 : 12.0,
                horizontal: isTablet ? 20.0 : 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content Guidelines',
                    style: TextStyle(
                      fontSize: isTablet ? 18.0 : 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• No offensive or inappropriate content\n'
                    '• No harassment or hate speech\n'
                    '• No sharing of personal information\n'
                    '• Reports are reviewed within 24 hours\n'
                    '• Violations result in account termination',
                    style: TextStyle(
                      fontSize: isTablet ? 16.0 : 14.0,
                      color: Colors.red.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Moderasyon Bildirimi
            Container(
              padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? 20.0 : 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content Moderation',
                    style: TextStyle(
                      fontSize: isTablet ? 18.0 : 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• All content is subject to moderation\n'
                    '• Report inappropriate content using 🚩\n'
                    '• Block abusive users using ⛔\n'
                    '• 24-hour moderation response time',
                    style: TextStyle(
                      fontSize: isTablet ? 16.0 : 14.0,
                      color: Colors.blue.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundPage(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                "Nationality",
                Icons.public_outlined,
                nationalities,
                (value) => controller.nationalityController.text = value,
                isTablet,
              ),
              _buildDropdown(
                "Highest Education",
                Icons.school_outlined,
                highSchool,
                (value) => controller.educationController.text = value,
                isTablet,
              ),
              _buildDropdown(
                "Languages",
                Icons.language_outlined,
                languages,
                (value) => controller.languageSpokenController.text = value,
                isTablet,
              ),
              _buildDropdown(
                "Religion",
                Icons.church_outlined,
                religion,
                (value) => controller.religionController.text = value,
                isTablet,
              ),
              _buildDropdown(
                "Ethnicity",
                Icons.people_outline,
                ethnicities,
                (value) => controller.ethnicityController.text = value,
                isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isTablet) {
    return Obx(() => controller.isLoading.value
        ? Container(
            height: isTablet ? 80.0 : 60.0,
            width: isTablet ? 80.0 : 60.0,
            padding: EdgeInsets.all(isTablet ? 20.0 : 15.0),
            child: const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(ElegantTheme.primaryColor),
              strokeWidth: 3,
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildPageContent(Widget content, bool isTablet) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 800.0 : double.infinity,
          maxHeight: double.infinity,
        ),
        child: content,
      ),
    );
  }
}

class PasswordInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isConfirmField;
  final Function(String) onChanged;

  const PasswordInputField({
    Key? key,
    required this.controller,
    required this.label,
    this.isConfirmField = false,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final strength = !isConfirmField
              ? PasswordValidator.validatePassword(controller.text)
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                obscureText: true,
                onChanged: onChanged,
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.visibility_outlined),
                    onPressed: () {
                      // Toggle password visibility
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: strength!.score / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(strength.color),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: strength.requirements.map((req) {
                  return Chip(
                    avatar: Icon(
                      req.isMet ? Icons.check : Icons.close,
                      color: req.isMet ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    label: Text(
                      req.description,
                      style: TextStyle(
                        color: req.isMet ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: req.isMet
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final bool isTablet;
  final bool var1;
  final bool var2;
  final bool var3;
  final bool var4;
  final bool var5;

  const CustomProgressBar({
    required this.isTablet,
    required this.var1,
    required this.var2,
    required this.var3,
    required this.var4,
    required this.var5,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progress =
        [var1, var2, var3, var4, var5].where((element) => element).length;

    return Container(
      width: screenWidth,
      height: isTablet ? 36 : 24,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress / 5,
            child: Container(
              height: isTablet ? 18 : 12,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool value) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: value ? Colors.green : Colors.grey,
      ),
    );
  }
}

class CheckList extends StatelessWidget {
  final bool isTablet;
  final int index;
  CheckList({
    Key? key,
    required this.isTablet,
    required this.index,
  }) : super(key: key);

  AuthController controller = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          controller.checks[index].value ? Icons.done : Icons.close,
          color: controller.checks[index].value ? Colors.green : Colors.red,
          size: isTablet ? 18 : 14,
        ),
        SizedBox(
          width: isTablet ? 12 : 5,
        ),
        Text(controller.textler[index],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 18 : 14,
              color: controller.checks[index].value ? Colors.green : Colors.red,
            ))
      ],
    );
  }
}

class SocialLinksSection extends StatelessWidget {
  final AuthController controller;
  final bool isTablet;

  const SocialLinksSection({
    Key? key,
    required this.controller,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social Media Profiles',
            style: TextStyle(
              fontSize: isTablet ? 20.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: ElegantTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildSocialInput(
            controller: controller.linkedInController,
            prefix: 'linkedin.com/in/',
            icon: Icons.business,
            label: 'LinkedIn',
            color: Color(0xFF0A66C2),
            placeholder: 'username',
          ),
          SizedBox(height: isTablet ? 20.0 : 16.0),
          _buildSocialInput(
            controller: controller.instagramController,
            prefix: '@',
            icon: Icons.camera_alt,
            label: 'Instagram',
            color: Color(0xFFE4405F),
            placeholder: 'username',
          ),
          SizedBox(height: isTablet ? 20.0 : 16.0),
          _buildSocialInput(
            controller: controller.githubController,
            prefix: 'github.com/',
            icon: Icons.code,
            label: 'GitHub',
            color: Color(0xFF24292E),
            placeholder: 'username',
          ),
        ],
      ),
    );
  }

  Widget _buildSocialInput({
    required TextEditingController controller,
    required String prefix,
    required IconData icon,
    required String label,
    required Color color,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: isTablet ? 24.0 : 20.0),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16.0 : 12.0,
                  vertical: isTablet ? 12.0 : 10.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(8)),
                  border:
                      Border(right: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Text(
                  prefix,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: isTablet ? 14.0 : 12.0,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16.0 : 12.0,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.content_paste, color: Colors.grey.shade600),
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    final url = data!.text!;
                    final username = _extractUsername(url, label);
                    if (username != null) {
                      controller.text = username;
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _extractUsername(String text, String platform) {
    switch (platform) {
      case 'LinkedIn':
        final match = RegExp(r'linkedin\.com/in/([^/]+)').firstMatch(text);
        return match?.group(1);
      case 'GitHub':
        final match = RegExp(r'github\.com/([^/]+)').firstMatch(text);
        return match?.group(1);
      case 'Instagram':
        if (text.contains('instagram.com')) {
          final match = RegExp(r'instagram\.com/([^/]+)').firstMatch(text);
          return match?.group(1);
        }
        return text.replaceAll('@', '');
      default:
        return text;
    }
  }
}
