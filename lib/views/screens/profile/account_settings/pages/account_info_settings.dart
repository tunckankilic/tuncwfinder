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
            _buildProfileImagePicker(),
            _buildSectionTitle("Personal Info"),
            _buildTextField(controller.nameController, "Name", Icons.person),
            _buildTextField(controller.emailController, "Email", Icons.email),
            _buildTextField(controller.ageController, "Age", Icons.cake,
                keyboardType: TextInputType.number),
            _buildDropdown("Gender", Icons.person_outlined, gender,
                (value) => controller.genderController.text = value),
            _buildTextField(
                controller.phoneNoController, "Phone Number", Icons.phone,
                keyboardType: TextInputType.phone),
            _buildDropdown("Country", Icons.flag_outlined, countries,
                (value) => controller.countryController.text = value),
            _buildTextField(
                controller.cityController, "City", Icons.location_city),
            _buildTextField(controller.profileHeadingController,
                "Profile Heading", Icons.title),
            _buildSectionTitle("Appearance"),
            _buildTextField(
                controller.heightController, "Height (cm)", Icons.height,
                keyboardType: TextInputType.number),
            _buildTextField(controller.weightController, "Weight (kg)",
                Icons.fitness_center,
                keyboardType: TextInputType.number),
            _buildDropdown(
                "Body Type",
                Icons.accessibility_new_outlined,
                bodyTypes,
                (value) => controller.bodyTypeController.text = value),
            _buildSectionTitle("Lifestyle"),
            _buildDropdown(
                "Drinking Habits",
                Icons.local_bar_outlined,
                drinkingHabits,
                (value) => controller.drinkController.text = value),
            _buildDropdown(
                "Smoking Habits",
                Icons.smoking_rooms_outlined,
                smokingHabits,
                (value) => controller.smokeController.text = value),
            _buildDropdown(
                "Marital Status",
                Icons.people_outline,
                maritalStatuses,
                (value) => controller.martialStatusController.text = value),
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
                (value) => controller.employmentStatusController.text = value),
            _buildTextField(controller.incomeController, "Annual Income",
                Icons.attach_money),
            _buildDropdown(
                "Living Situation",
                Icons.home_outlined,
                livingSituations,
                (value) => controller.livingSituationController.text = value),
            _buildCheckboxGroup(
              "What's your relationship status?",
              Icons.favorite_outline,
              controller.relationshipOptions,
              controller.relationshipSelection,
              controller.updateRelationshipOption,
            ),
            _buildSectionTitle("Background"),
            _buildDropdown("Nationality", Icons.public_outlined, nationalities,
                (value) => controller.nationalityController.text = value),
            _buildDropdown(
                "Highest Education",
                Icons.school_outlined,
                highSchool,
                (value) => controller.educationController.text = value),
            _buildDropdown("Languages", Icons.language_outlined, languages,
                (value) => controller.languageSpokenController.text = value),
            _buildDropdown("Religion", Icons.church_outlined, religion,
                (value) => controller.religionController.text = value),
            _buildDropdown("Ethnicity", Icons.people_outline, ethnicities,
                (value) => controller.ethnicityController.text = value),
            _buildSectionTitle("Connections"),
            _buildTextField(
                controller.linkedInController, "LinkedIn Profile", Icons.link),
            _buildTextField(controller.instagramController, "Instagram Handle",
                Icons.camera_alt),
            _buildTextField(
                controller.gitHubController, "GitHub Profile", Icons.code),
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
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: ElegantTheme.primaryColor),
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

  Widget _buildDropdown(String label, IconData icon, List<String> items,
      Function(String) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
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
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: ElegantTheme.primaryColor),
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

  Widget _buildCheckboxGroup(String label, IconData icon, List<String> options,
      RxString selection, Function(String) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ElegantTheme.primaryColor),
              SizedBox(width: 10.w),
              Text(label, style: ElegantTheme.textTheme.titleMedium),
            ],
          ),
          SizedBox(height: 5.h),
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

  Widget _buildProfileImagePicker() {
    return Obx(() => Column(
          children: [
            CircleAvatar(
              radius: 60.r,
              backgroundImage: controller.pickedImage.value != null
                  ? FileImage(controller.pickedImage.value!)
                  : AssetImage("assets/profile_avatar.jpg") as ImageProvider,
              backgroundColor: ElegantTheme.primaryColor.withOpacity(0.1),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.pickImage,
                  icon: Icon(Icons.image),
                  label: Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElegantTheme.secondaryColor,
                  ),
                ),
                SizedBox(width: 10.w),
                ElevatedButton.icon(
                  onPressed: controller.captureImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElegantTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ));
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
