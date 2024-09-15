import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/pages/account_info_settings.dart';

class PhotoSettingsScreen extends GetView<AccountSettingsController> {
  const PhotoSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ElegantTheme.primaryColor,
        title: Text(
          "Edit Photos",
          style:
              ElegantTheme.textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () => Get.to(() => ProfileInfoScreen()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Add 2 or More Pictures',
              style: ElegantTheme.textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: _buildImageGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return Obx(() {
      return GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
        ),
        itemCount: controller.images.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index < controller.images.length) {
            return _buildExistingImageTile(controller.images[index], index);
          } else {
            return _buildAddImageButton();
          }
        },
      );
    });
  }

  Widget _buildExistingImageTile(dynamic image, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: ElegantTheme.primaryColor,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: image is String
                ? Image.network(image, fit: BoxFit.cover)
                : Image.file(image, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 5.h,
          right: 5.w,
          child: GestureDetector(
            onTap: () => controller.removeImage(index),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: () => _pickImage(),
      child: Container(
        decoration: BoxDecoration(
          color: ElegantTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          Icons.add_photo_alternate,
          color: ElegantTheme.primaryColor,
          size: 40.sp,
        ),
      ),
    );
  }

  void _pickImage() async {
    if (controller.images.length >= 5) {
      Get.snackbar(
        'Maximum Images',
        'You can only select up to 5 images.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      controller.addImage(image);
    } else {
      Get.snackbar(
        'No Image Selected',
        'Please select an image to add.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
