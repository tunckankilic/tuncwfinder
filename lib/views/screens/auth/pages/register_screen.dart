import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';

class RegistrationScreen extends GetView<AuthController> {
  static const routeName = "/register";
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: 5,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  controller.currentPage.value = index;
                },
                itemBuilder: (context, index) {
                  return _buildPage(index);
                },
              ),
            ),
            _buildNavigationButtons(),
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back_ios)),
              Text(
                "Create Account",
                style: ElegantTheme.textTheme.headlineMedium?.copyWith(
                    color: ElegantTheme.primaryColor, fontSize: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            "to get Started Now.",
            style:
                ElegantTheme.textTheme.titleMedium?.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 20.h),
          Obx(() => LinearProgressIndicator(
                value: (controller.currentPage.value + 1) / 5,
                backgroundColor: ElegantTheme.primaryColor.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    ElegantTheme.primaryColor),
              )),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isObscure = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ElegantTheme.primaryColor, size: 20.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: ElegantTheme.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide:
                BorderSide(color: ElegantTheme.primaryColor, width: 2.w),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Obx(() => Padding(
          padding: EdgeInsets.all(20.0.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: controller.currentPage.value > 0
                    ? () {
                        controller.previousPage();
                        print(
                            "Previous page called. Current page: ${controller.currentPage.value}");
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.currentPage.value > 0
                      ? ElegantTheme.secondaryColor
                      : ElegantTheme.secondaryColor.withOpacity(0.5),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                ),
                child: Text("Previous", style: TextStyle(fontSize: 14.sp)),
              ),
              ElevatedButton(
                onPressed: controller.currentPage.value == 4
                    ? controller.register
                    : () {
                        controller.nextPage();
                        print(
                            "Next page called. Current page: ${controller.currentPage.value}");
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElegantTheme.primaryColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                ),
                child: Text(
                  controller.currentPage.value == 4 ? "Register" : "Next",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ));
  }

  void _showTermsAndConditions() {
    Get.dialog(
      AlertDialog(
        title: const Text('End User Licence Agreement'),
        content: SingleChildScrollView(
          child: Text(controller.eula),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('Accept'),
            onPressed: () {
              Get.back();
              _showPrivacyPolicy();
            },
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(controller.privacyPolicy),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              controller.termsAccepted.value = false;
              Get.back();
            },
          ),
          TextButton(
            child: const Text('Accept'),
            onPressed: () {
              controller.termsAccepted.value = true;
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileImagePicker(),
          _buildTextField(
              controller.nameController, "Name", Icons.person_outline),
          _buildTextField(
              controller.emailController, "Email", Icons.email_outlined),
          _buildTextField(
              controller.passwordController, "Password", Icons.lock_outline,
              isObscure: true),
          _buildTextField(controller.ageController, "Age", Icons.cake_outlined),
          _buildDropdown(
            "Gender",
            Icons.person_outlined,
            gender,
            (value) => controller.genderController.text = value,
          ),
          _buildTextField(
              controller.phoneNoController, "Phone", Icons.phone_outlined),
          _buildDropdown("Country", Icons.flag_outlined, countries,
              (value) => controller.countryController.text = value),
          _buildTextField(
              controller.cityController, "City", Icons.location_city_outlined),
          _buildTextField(controller.profileHeadingController,
              "Profile Heading", Icons.text_fields_outlined),
        ],
      ),
    );
  }

  Widget _buildAppearancePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(controller.heightController, "Height (cm)",
              Icons.height_outlined),
          _buildTextField(controller.weightController, "Weight (kg)",
              Icons.fitness_center_outlined),
          _buildDropdown(
            "Body Type",
            Icons.accessibility_new_outlined,
            bodyTypes,
            (value) => controller.bodyTypeController.text = value,
          ),
        ],
      ),
    );
  }

  Widget _buildLifestylePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown(
            "Drinking Habits",
            Icons.local_bar_outlined,
            drinkingHabits,
            (value) => controller.drinkController.text = value,
          ),
          _buildDropdown(
            "Smoking Habits",
            Icons.smoking_rooms_outlined,
            smokingHabits,
            (value) => controller.smokeController.text = value,
          ),
          _buildDropdown(
            "Marital Status",
            Icons.people_outline,
            maritalStatuses,
            (value) => controller.martialStatusController.text = value,
          ),
          _buildCheckboxGroup(
            "Do you have children?",
            Icons.child_care_outlined,
            controller.childrenOptions,
            controller.childrenSelection,
            controller.updateChildrenOption,
          ),
          _buildTextField(controller.noOfChildrenController,
              "Number of Children", Icons.child_friendly_outlined),
          _buildDropdown("Profession", Icons.work_outline, itJobs,
              (value) => controller.professionController.text = value),
          _buildDropdown(
            "Employment Status",
            Icons.business_center_outlined,
            employmentStatuses,
            (value) => controller.employmentStatusController.text = value,
          ),
          _buildTextField(controller.incomeController, "Annual Income",
              Icons.attach_money_outlined),
          _buildDropdown(
            "Living Situation",
            Icons.home_outlined,
            livingSituations,
            (value) => controller.livingSituationController.text = value,
          ),
          _buildCheckboxGroup(
            "What's your relationship status?",
            Icons.favorite_outline,
            controller.relationshipOptions,
            controller.relationshipSelection,
            controller.updateRelationshipOption,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxGroup(
    String label,
    IconData icon,
    List<String> options,
    RxString selection,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ElegantTheme.primaryColor),
              const SizedBox(width: 10),
              Text(label, style: ElegantTheme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 5),
          ...options.map((option) => Obx(() => CheckboxListTile(
                title: Text(option),
                value: selection.value == option,
                onChanged: (bool? value) {
                  if (value == true) {
                    onChanged(option);
                  } else if (selection.value == option) {
                    onChanged('');
                  }
                },
                activeColor: ElegantTheme.primaryColor,
              ))),
        ],
      ),
    );
  }

  Widget _buildBackgroundPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown("Nationality", Icons.public_outlined, nationalities,
              (value) => controller.nationalityController.text = value),
          _buildDropdown(
            "Highest Education",
            Icons.school_outlined,
            highSchool,
            (value) => controller.educationController.text = value,
          ),
          _buildDropdown("Languages", Icons.language_outlined, languages,
              (value) => controller.languageSpokenController.text = value),
          _buildDropdown(
            "Religion",
            Icons.church_outlined,
            religion,
            (value) => controller.religionController.text = value,
          ),
          _buildDropdown(
            "Ethnicity",
            Icons.people_outline,
            ethnicities,
            (value) => controller.ethnicityController.text = value,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(controller.linkedInController, "LinkedIn Profile",
              Icons.link_outlined),
          _buildTextField(controller.instagramController, "Instagram Handle",
              Icons.camera_alt_outlined),
          _buildTextField(controller.githubController, "GitHub Profile",
              Icons.code_outlined),
          _buildCheckbox(
            "I accept the terms and conditions",
            Icons.check_circle_outline,
            (value) => controller.termsAccepted.value = value,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(
    String label,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Obx(
      () => CheckboxListTile(
        title: Text(label),
        value: controller.termsAccepted.value,
        onChanged: (bool? value) {
          if (value == true) {
            _showTermsAndConditions();
          } else {
            onChanged(false);
          }
        },
        secondary: Icon(icon, color: ElegantTheme.primaryColor),
        activeColor: ElegantTheme.primaryColor,
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Obx(() => Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: controller.pickedImage.value != null
                  ? FileImage(controller.pickedImage.value!)
                  : const AssetImage("assets/profile_avatar.jpg")
                      as ImageProvider,
              backgroundColor: ElegantTheme.primaryColor.withOpacity(0.1),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElegantTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: controller.captureImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElegantTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ));
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: items.first,
        onChanged: (newValue) => onChanged(newValue ?? items[0]),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ElegantTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ElegantTheme.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: ElegantTheme.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioGroup(
    String label,
    IconData icon,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ElegantTheme.textTheme.titleMedium),
          const SizedBox(height: 5),
          ...options.map((option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue:
                    null, // You might want to store this value in the controller
                onChanged: (value) => onChanged(value!),
                activeColor: ElegantTheme.primaryColor,
              )),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Obx(() => controller.isLoading.value
        ? const Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(ElegantTheme.primaryColor),
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildPersonalInfoPage();
      case 1:
        return _buildAppearancePage();
      case 2:
        return _buildLifestylePage();
      case 3:
        return _buildBackgroundPage();
      case 4:
        return _buildConnectionsPage();
      default:
        return Container(); // Boş bir container döndür, bu duruma düşmemeli
    }
  }
}
