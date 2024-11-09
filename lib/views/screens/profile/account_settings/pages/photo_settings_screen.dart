import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/pages/account_info_settings.dart';

class PhotoSettingsScreen extends GetView<AccountSettingsController> {
  const PhotoSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        return Scaffold(
          appBar: _buildAppBar(context, isTablet),
          body: Column(
            children: [
              _buildHeader(context, isTablet),
              Expanded(
                child: _buildImageGrid(context, isTablet),
              ),
            ],
          ),
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
        "Edit Photos",
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
      actions: [
        IconButton(
          icon: Icon(
            Icons.check,
            color: Colors.white,
            size: isTablet ? 28.0 : 24.0,
          ),
          onPressed: () => Get.to(() => ProfileInfoScreen()),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        children: [
          Text(
            'Add 2 or More Pictures',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: isTablet ? 20.0 : 16.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: isTablet ? 8.0 : 4.0),
          Text(
            'High quality photos will help you get more connections',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isTablet ? 16.0 : 14.0,
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, bool isTablet) {
    final crossAxisCount = isTablet ? 4 : 3;
    final padding = isTablet ? 24.0 : 16.0;
    final spacing = isTablet ? 16.0 : 10.0;

    return Obx(() {
      return GridView.builder(
        padding: EdgeInsets.all(padding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: controller.images.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index < controller.images.length) {
            return _buildExistingImageTile(
              context: context,
              image: controller.images[index],
              index: index,
              isTablet: isTablet,
            );
          } else {
            return _buildAddImageButton(context, isTablet);
          }
        },
      );
    });
  }

  Widget _buildExistingImageTile({
    required dynamic image,
    required int index,
    required bool isTablet,
    required BuildContext context,
  }) {
    final borderRadius = isTablet ? 12.0 : 8.0;
    final closeIconSize = isTablet ? 24.0 : 18.0;
    final closeButtonPadding = isTablet ? 6.0 : 4.0;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: isTablet ? 1.5 : 1.0,
              color: ElegantTheme.primaryColor,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: image is String
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorImage(isTablet),
                  )
                : Image.file(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorImage(isTablet),
                  ),
          ),
        ),
        Positioned(
          top: isTablet ? 8.0 : 5.0,
          right: isTablet ? 8.0 : 5.0,
          child: GestureDetector(
            onTap: () => _showDeleteConfirmation(context, index),
            child: Container(
              padding: EdgeInsets.all(closeButtonPadding),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                size: closeIconSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorImage(bool isTablet) {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.broken_image,
        size: isTablet ? 48.0 : 32.0,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildAddImageButton(BuildContext context, bool isTablet) {
    final borderRadius = isTablet ? 12.0 : 8.0;
    final iconSize = isTablet ? 48.0 : 40.0;

    return InkWell(
      onTap: () => _pickImage(context),
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: ElegantTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: ElegantTheme.primaryColor.withOpacity(0.3),
            width: isTablet ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: ElegantTheme.primaryColor,
              size: iconSize,
            ),
            SizedBox(height: isTablet ? 12.0 : 8.0),
            Text(
              'Add Photo',
              style: TextStyle(
                color: ElegantTheme.primaryColor,
                fontSize: isTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int index) async {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16.0 : 12.0),
          ),
          title: Text(
            'Delete Photo',
            style: TextStyle(fontSize: isTablet ? 22.0 : 18.0),
          ),
          content: Text(
            'Are you sure you want to delete this photo?',
            style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: isTablet ? 16.0 : 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                controller.removeImage(index);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: isTablet ? 16.0 : 14.0,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    if (controller.images.length >= 5) {
      _showMaxImagesWarning(context);
      return;
    }

    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      controller.addImage(image);
    }
  }

  void _showMaxImagesWarning(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You can only select up to 5 images',
          style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
        ),
        margin: EdgeInsets.all(isTablet ? 20.0 : 16.0),
      ),
    );
  }
}
