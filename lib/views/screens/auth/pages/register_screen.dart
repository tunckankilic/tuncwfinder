import 'package:flutter/material.dart';
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildProfileImagePicker(),
                _buildPersonalInfoSection(),
                _buildAppearanceSection(),
                _buildLifestyleSection(),
                _buildBackgroundSection(),
                _buildConnectionsSection(),
                _buildRegisterButton(),
                _buildLoginLink(),
                _buildProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create Account",
          style: ElegantTheme.textTheme.headlineMedium
              ?.copyWith(color: ElegantTheme.primaryColor),
        ),
        const SizedBox(height: 10),
        Text(
          "to get Started Now.",
          style: ElegantTheme.textTheme.titleMedium,
        ),
        const SizedBox(height: 30),
      ],
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
                      backgroundColor: ElegantTheme.secondaryColor),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: controller.captureImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ElegantTheme.secondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ));
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      "Personal Info",
      [
        _buildTextField(
            controller.nameController, "Name", Icons.person_outline),
        _buildTextField(
            controller.emailController, "Email", Icons.email_outlined),
        _buildTextField(
            controller.passwordController, "Password", Icons.lock_outline,
            isObscure: true),
        _buildTextField(controller.ageController, "Age", Icons.cake_outlined),
        _buildTextField(
            controller.genderController, "Gender", Icons.person_outlined),
        _buildTextField(
            controller.phoneNoController, "Phone", Icons.phone_outlined),
        _buildTextField(
            controller.cityController, "City", Icons.location_city_outlined),
        _buildTextField(
            controller.countryController, "Country", Icons.flag_outlined),
        _buildTextField(controller.profileHeadingController, "Profile Heading",
            Icons.text_fields_outlined),
        _buildTextField(controller.lookingForInaPartnerController,
            "Looking for in a partner", Icons.favorite_outline),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      "Appearance",
      [
        _buildTextField(
            controller.heightController, "Height", Icons.height_outlined),
        _buildTextField(controller.weightController, "Weight",
            Icons.fitness_center_outlined),
        _buildTextField(controller.bodyTypeController, "Body Type",
            Icons.accessibility_new_outlined),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return _buildSection(
      "Lifestyle",
      [
        _buildTextField(
            controller.drinkController, "Drink", Icons.local_bar_outlined),
        _buildTextField(
            controller.smokeController, "Smoke", Icons.smoking_rooms_outlined),
        _buildTextField(controller.martialStatusController, "Marital Status",
            Icons.people_outline),
        _buildTextField(controller.haveChildrenController, "Have Children",
            Icons.child_care_outlined),
        _buildTextField(controller.noOfChildrenController, "Number of Children",
            Icons.child_friendly_outlined),
        _buildTextField(
            controller.professionController, "Profession", Icons.work_outline),
        _buildTextField(controller.employmentStatusController,
            "Employment Status", Icons.business_center_outlined),
        _buildTextField(
            controller.incomeController, "Income", Icons.attach_money_outlined),
        _buildTextField(controller.livingSituationController,
            "Living Situation", Icons.home_outlined),
        _buildTextField(controller.willingToRelocateController,
            "Willing to Relocate", Icons.location_on_outlined),
        _buildTextField(controller.relationshipYouAreLookingForController,
            "Relationship You're Looking For", Icons.favorite_border_outlined),
      ],
    );
  }

  Widget _buildBackgroundSection() {
    return _buildSection(
      "Background - Cultural Values",
      [
        _buildTextField(controller.nationalityController, "Nationality",
            Icons.public_outlined),
        _buildTextField(
            controller.educationController, "Education", Icons.school_outlined),
        _buildTextField(controller.languageSpokenController, "Language Spoken",
            Icons.language_outlined),
        _buildTextField(
            controller.religionController, "Religion", Icons.church_outlined),
        _buildTextField(
            controller.ethnicityController, "Ethnicity", Icons.people_outline),
      ],
    );
  }

  Widget _buildConnectionsSection() {
    return _buildSection(
      "Connections",
      [
        _buildTextField(
            controller.linkedInController, "LinkedIn", Icons.link_outlined),
        _buildTextField(controller.instagramController, "Instagram",
            Icons.camera_alt_outlined),
        _buildTextField(
            controller.githubController, "GitHub", Icons.code_outlined),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ElegantTheme.textTheme.titleLarge
              ?.copyWith(color: ElegantTheme.primaryColor),
        ),
        const SizedBox(height: 10),
        ...fields,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isObscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await controller.register();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ElegantTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text("Create Account", style: ElegantTheme.textTheme.labelLarge),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Already have an account?",
              style: ElegantTheme.textTheme.bodyMedium),
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Login Here",
                style: ElegantTheme.textTheme.labelLarge
                    ?.copyWith(color: ElegantTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Obx(() => controller.isLoading.value
        ? const Center(
            child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(ElegantTheme.primaryColor)))
        : const SizedBox.shrink());
  }
}
