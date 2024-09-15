import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';

class ProfileInfoScreen extends GetView<AccountSettingsController> {
  const ProfileInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ElegantTheme.primaryColor,
        title: Text(
          "Edit Profile Info",
          style:
              ElegantTheme.textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Personal Info"),
            _buildTextField(controller.nameController, "Name", Icons.person),
            _buildTextField(controller.ageController, "Age", Icons.cake,
                keyboardType: TextInputType.number),
            _buildTextField(
                controller.phoneNoController, "Phone Number", Icons.phone,
                keyboardType: TextInputType.phone),
            _buildTextField(
                controller.cityController, "City", Icons.location_city),
            _buildTextField(
                controller.countryController, "Country", Icons.flag),
            _buildTextField(controller.profileHeadingController,
                "Profile Heading", Icons.title),
            _buildTextField(controller.lookingForInaPartnerController,
                "Looking for in a Partner", Icons.favorite),
            _buildTextField(
                controller.genderController, "Gender", Icons.person_outline),
            _buildSectionTitle("Appearance"),
            _buildTextField(controller.heightController, "Height", Icons.height,
                keyboardType: TextInputType.number),
            _buildTextField(
                controller.weightController, "Weight", Icons.fitness_center,
                keyboardType: TextInputType.number),
            _buildTextField(controller.bodyTypeController, "Body Type",
                Icons.accessibility_new),
            _buildSectionTitle("Lifestyle"),
            _buildTextField(
                controller.drinkController, "Drinking Habits", Icons.local_bar),
            _buildTextField(controller.smokeController, "Smoking Habits",
                Icons.smoking_rooms),
            _buildTextField(controller.martialStatusController,
                "Marital Status", Icons.people),
            _buildTextField(controller.haveChildrenController, "Have Children",
                Icons.child_care),
            _buildTextField(
                controller.professionController, "Profession", Icons.work),
            _buildTextField(
                controller.incomeController, "Income", Icons.attach_money),
            _buildSectionTitle("Background"),
            _buildTextField(
                controller.nationalityController, "Nationality", Icons.public),
            _buildTextField(
                controller.educationController, "Education", Icons.school),
            _buildTextField(controller.languageSpokenController,
                "Languages Spoken", Icons.language),
            _buildTextField(
                controller.religionController, "Religion", Icons.church),
            _buildTextField(controller.ethnicityController, "Ethnicity",
                Icons.people_outline),
            _buildSectionTitle("Connections"),
            _buildTextField(
                controller.instagramController, "Instagram", Icons.camera_alt),
            _buildTextField(
                controller.linkedInController, "LinkedIn", Icons.work),
            _buildTextField(controller.gitHubController, "GitHub", Icons.code),
            SizedBox(height: 20.h),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text(
        title,
        style: ElegantTheme.textTheme.titleLarge
            ?.copyWith(color: ElegantTheme.primaryColor),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ElegantTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: ElegantTheme.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.uploading.value
              ? null
              : controller.updateUserDataToFirestore,
          style: ElevatedButton.styleFrom(
            backgroundColor: ElegantTheme.primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
          ),
          child: controller.uploading.value
              ? CircularProgressIndicator(color: Colors.white)
              : Text("Update Profile", style: TextStyle(fontSize: 16.sp)),
        ));
  }
}
