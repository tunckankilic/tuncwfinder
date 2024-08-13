import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/profile/account_settings/account_settings_controller.dart';

class AccountSettings extends GetView<AccountSettingsController> {
  const AccountSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() =>
          controller.next.value ? _buildProfileForm() : _buildImagePicker()),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ElegantTheme.primaryColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Obx(() => Text(
            controller.next.value ? "Profile Information" : "Choose 5 Images",
            style: ElegantTheme.textTheme.titleLarge!
                .copyWith(color: Colors.white),
          )),
      actions: [
        Obx(
          () => !controller.next.value
              ? IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () {
                    if (controller.images.length == 5) {
                      controller.next.value = true;
                    } else {
                      Get.snackbar("Images Required", "Please choose 5 images");
                    }
                  },
                )
              : Container(),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.images.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildAddImageButton();
            } else {
              return _buildImageTile(controller.images[index - 1]);
            }
          },
        ),
        Obx(
          () => controller.uploading.value
              ? Center(
                  child: CircularProgressIndicator(
                    value: controller.uploadProgress.value,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        ElegantTheme.primaryColor),
                  ),
                )
              : Container(),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: controller.chooseImage,
      child: Container(
        decoration: BoxDecoration(
          color: ElegantTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add_photo_alternate,
            color: ElegantTheme.primaryColor, size: 40),
      ),
    );
  }

  Widget _buildImageTile(File image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(image, fit: BoxFit.cover),
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Personal Info"),
          _buildTextField(controller.nameController, "Name", Icons.person),
          _buildTextField(controller.ageController, "Age", Icons.cake),
          _buildTextField(controller.phoneNoController, "Phone", Icons.phone),
          _buildTextField(
              controller.cityController, "City", Icons.location_city),
          _buildTextField(controller.countryController, "Country", Icons.flag),
          _buildTextField(controller.profileHeadingController,
              "Profile Heading", Icons.short_text),
          _buildTextField(controller.lookingForInaPartnerController,
              "Looking for in a Partner", Icons.favorite),
          _buildTextField(controller.genderController, "Gender", Icons.wc),
          _buildSectionTitle("Appearance"),
          _buildTextField(controller.heightController, "Height", Icons.height),
          _buildTextField(
              controller.weightController, "Weight", Icons.fitness_center),
          _buildTextField(controller.bodyTypeController, "Body Type",
              Icons.accessibility_new),
          _buildSectionTitle("Life style"),
          _buildTextField(controller.drinkController, "Drink", Icons.local_bar),
          _buildTextField(
              controller.smokeController, "Smoke", Icons.smoking_rooms),
          _buildTextField(controller.martialStatusController, "Marital Status",
              Icons.people),
          _buildTextField(controller.haveChildrenController, "Have Children",
              Icons.child_care),
          _buildTextField(controller.noOfChildrenController,
              "Number of Children", Icons.child_friendly),
          _buildTextField(
              controller.professionController, "Profession", Icons.work),
          _buildTextField(controller.employmentStatusController,
              "Employment Status", Icons.business_center),
          _buildTextField(
              controller.incomeController, "Income", Icons.attach_money),
          _buildTextField(controller.livingSituationController,
              "Living Situation", Icons.home),
          _buildTextField(controller.willingToRelocateController,
              "Willing to Relocate", Icons.transfer_within_a_station),
          _buildTextField(controller.relationshipYouAreLookingForController,
              "Relationship You're Looking For", Icons.favorite_border),
          _buildSectionTitle("Background - Cultural Values"),
          _buildTextField(
              controller.nationalityController, "Nationality", Icons.public),
          _buildTextField(
              controller.educationController, "Education", Icons.school),
          _buildTextField(controller.languageSpokenController,
              "Language Spoken", Icons.language),
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
          const SizedBox(height: 20),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title,
          style: ElegantTheme.textTheme.titleLarge
              ?.copyWith(color: ElegantTheme.primaryColor)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ElegantTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: ElegantTheme.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: controller.updateUserDataToFirestore,
      style: ElevatedButton.styleFrom(
        backgroundColor: ElegantTheme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("Update Profile"),
    );
  }
}
