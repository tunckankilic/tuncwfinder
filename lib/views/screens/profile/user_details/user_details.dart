// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:tuncforwork/models/models.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/theme/modern_theme.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';
import 'package:tuncforwork/widgets/modern_widgets.dart';

class UserDetails extends GetView<UserDetailsController> {
  final String userId;

  const UserDetails({
    super.key,
    required this.userId,
  });

  @override
  UserDetailsController get controller =>
      Get.find<UserDetailsController>(tag: userId);

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    if (!Get.isRegistered<UserDetailsController>(tag: userId)) {
      Get.lazyPut<UserDetailsController>(
          () => UserDetailsController(userId: userId),
          tag: userId,
          fenix: true);
    }

    return Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: !controller.isCurrentUser.value
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(
          controller.name.value,
          style: const TextStyle(color: Colors.black),
        ),
        actions: controller.isCurrentUser.value
            ? [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: ModernTheme.primaryColor),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        controller.navigateToAccountSettings();
                        break;
                      case 'logout':
                        _showLogoutDialog(context);
                        break;
                      case 'delete':
                        _showDeleteAccountDialog(context);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        leading:
                            Icon(Icons.edit, color: ModernTheme.primaryColor),
                        title: Text(AppStrings.editProfile),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: ListTile(
                        leading:
                            Icon(Icons.logout, color: ModernTheme.primaryColor),
                        title: Text(AppStrings.logout),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading:
                            const Icon(Icons.delete_forever, color: Colors.red),
                        title: Text(AppStrings.deleteAccount),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 768) {
              return _buildTabletLayout(context);
            }
            return _buildMobileLayout(context);
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.logout),
          content: Text(AppStrings.logoutConfirmation),
          actions: [
            TextButton(
              child: Text(AppStrings.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                AppStrings.logout,
                style: TextStyle(color: ModernTheme.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                controller.signOut();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.deleteAccount),
          content: Text(AppStrings.deleteAccountConfirmation),
          actions: [
            TextButton(
              child: Text(AppStrings.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                AppStrings.deleteAccount,
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteAccountAndData(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(false),
          _buildProfileContent(false),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Sol taraf - Profil başlığı ve temel bilgiler
        Expanded(
          flex: 2,
          child: Container(
            color: ModernTheme.primaryColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(true),
                  _buildBasicInfo(true),
                ],
              ),
            ),
          ),
        ),
        // Sağ taraf - Detaylı bilgiler
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: _buildProfileContent(true),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(bool isTablet) {
    return Obx(() => ModernCard(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            children: [
              CircleAvatar(
                radius: isTablet ? 80 : 60,
                backgroundImage: controller.imageUrl.value.isNotEmpty
                    ? NetworkImage(controller.imageUrl.value)
                    : null,
                backgroundColor: Colors.grey[200],
                child: controller.imageUrl.value.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                controller.name.value.isNotEmpty
                    ? controller.name.value
                    : AppStrings.anonymousUser,
                style: ModernTheme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.profession.value.isNotEmpty
                    ? controller.profession.value
                    : AppStrings.noProfessionSpecified,
                style: ModernTheme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (controller.city.value.isNotEmpty ||
                  controller.country.value.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: ModernTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      [
                        if (controller.city.value.isNotEmpty)
                          controller.city.value,
                        if (controller.country.value.isNotEmpty)
                          controller.country.value,
                      ].join(', '),
                      style: ModernTheme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              if (controller.isCurrentUser.value) ...[
                const SizedBox(height: 24),
                ModernButton(
                  text: AppStrings.editProfile,
                  onPressed: controller.navigateToAccountSettings,
                  isOutlined: true,
                ),
                if (controller.missingFields.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.missingInformation,
                              style:
                                  ModernTheme.textTheme.titleMedium?.copyWith(
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.missingInfoDescription,
                          style: ModernTheme.textTheme.bodyMedium?.copyWith(
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.missingFields
                              .map((field) => Chip(
                                    label: Text(field),
                                    backgroundColor: Colors.orange.shade100,
                                    labelStyle: TextStyle(
                                      color: Colors.orange.shade900,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ));
  }

  Widget _buildBasicInfo(bool isTablet) {
    return Obx(() => ModernCard(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.basicInformationTitle,
                style: ModernTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(AppStrings.ageLabel, controller.age.value),
              _buildInfoRow(AppStrings.gender, controller.gender.value),
              _buildInfoRow(AppStrings.emailLabel, controller.email.value),
              _buildInfoRow(AppStrings.phoneLabel, controller.phoneNo.value),
              _buildInfoRow(AppStrings.cityLabel, controller.city.value),
              _buildInfoRow(AppStrings.country, controller.country.value),
              _buildInfoRow(AppStrings.education, controller.education.value),
            ],
          ),
        ));
  }

  Widget _buildAdditionalInfo(bool isTablet) {
    return Obx(() => ModernCard(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.additionalInformation,
                style: ModernTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(AppStrings.height, controller.height.value),
              _buildInfoRow(AppStrings.weight, controller.weight.value),
              _buildInfoRow(
                  AppStrings.bodyTypeField, controller.bodyType.value),
              _buildInfoRow(AppStrings.drinkingField, controller.drink.value),
              _buildInfoRow(AppStrings.smokingField, controller.smoke.value),
              _buildInfoRow(
                  AppStrings.maritalStatusField,
                  controller.maritalStatus.value.isEmpty
                      ? 'Not specified'
                      : controller.maritalStatus.value),
              _buildInfoRow(
                  AppStrings.childrenField, controller.haveChildren.value),
              if (controller.haveChildren.value == 'Yes')
                _buildInfoRow(
                    AppStrings.numberOfChildren, controller.noOfChildren.value),
              _buildInfoRow(
                  AppStrings.employmentField,
                  controller.employmentStatus.value.isEmpty
                      ? 'Not specified'
                      : controller.employmentStatus.value),
              _buildInfoRow(AppStrings.incomeField, controller.income.value),
              _buildInfoRow(
                  AppStrings.livingSituationField,
                  controller.livingSituation.value.isEmpty
                      ? 'Not specified'
                      : controller.livingSituation.value),
              _buildInfoRow(
                  AppStrings.nationalityField,
                  controller.nationality.value.isEmpty
                      ? 'Not specified'
                      : controller.nationality.value),
              _buildInfoRow(
                  AppStrings.spokenLanguageField,
                  controller.languageSpoken.value.isEmpty
                      ? 'Not specified'
                      : controller.languageSpoken.value),
            ],
          ),
        ));
  }

  Widget _buildCareerInfo(bool isTablet) {
    return Obx(() => ModernCard(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.careerInformation,
                style: ModernTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(AppStrings.profession, controller.profession.value),
              if (controller.workExperiences.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  AppStrings.workExperiences,
                  style: ModernTheme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...controller.workExperiences
                    .map((exp) => _buildExperienceItem(exp, isTablet))
              ],
              const SizedBox(height: 16),
              Text(
                AppStrings.skillsLabel,
                style: ModernTheme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (controller.skills.isEmpty)
                Text(
                  AppStrings.noSkillsAdded,
                  style: ModernTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.skills
                      .map((skill) => Chip(
                            label: Text(skill),
                            backgroundColor: ModernTheme.primaryColor,
                            labelStyle: TextStyle(
                              color: ModernTheme.primaryColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ))
                      .toList(),
                ),
            ],
          ),
        ));
  }

  Widget _buildProfileContent(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(isTablet),
          const SizedBox(height: 24),
          _buildAdditionalInfo(isTablet),
          const SizedBox(height: 24),
          _buildCareerInfo(isTablet),
          const SizedBox(height: 24),
          _buildSocialLinks(isTablet),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(bool isTablet) {
    return Obx(() => ModernCard(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.socialMedia,
                style: ModernTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (controller.instagramUrl.value.isNotEmpty)
                ProfileActionButtons(
                  instagramUsername: controller.instagramUrl.value,
                  phoneNo: controller.phoneNo.value,
                  isTablet: isTablet,
                ),
            ],
          ),
        ));
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: ModernTheme.textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: ModernTheme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(WorkExperience exp, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp.title,
            style: ModernTheme.textTheme.titleSmall,
          ),
          Text(
            exp.company,
            style: ModernTheme.textTheme.bodyMedium,
          ),
          Text(
            '${exp.startDate} - ${exp.endDate ?? 'Present'}',
            style: ModernTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          if (exp.description != null && exp.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                exp.description!,
                style: ModernTheme.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class ProfileActionButtons extends GetView<SwipeController> {
  final String instagramUsername;
  final String phoneNo;
  final bool isTablet;

  const ProfileActionButtons({
    super.key,
    required this.instagramUsername,
    required this.phoneNo,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isTablet ? 2.0 : 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionButton(
              context: context,
              icon: 'assets/instagram.svg',
              title: AppStrings.instagramLabel,
              value: instagramUsername,
              onTap: () => controller.openInstagramProfile(
                instagramUsername: instagramUsername,
                context: context,
              ),
            ),
            _buildConnectionButton(
              context: context,
              icon: 'assets/whatsapp.svg',
              title: AppStrings.whatsappLabel,
              value: phoneNo,
              onTap: () => controller.startChattingInWhatsApp(
                receiverPhoneNumber: phoneNo,
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionButton({
    required BuildContext context,
    required String icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final bool hasValue =
        value.isNotEmpty && value != AppStrings.notProvidedLabel;

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 16.0 : 12.0),
      child: Row(
        children: [
          Container(
            width: isTablet ? 48.0 : 40.0,
            height: isTablet ? 48.0 : 40.0,
            decoration: BoxDecoration(
              color: hasValue
                  ? ModernTheme.primaryColor
                  : ModernTheme.primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasValue ? onTap : null,
                borderRadius: BorderRadius.circular(24.0),
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 12.0 : 10.0),
                  child: SvgPicture.asset(
                    icon,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16.0 : 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernTheme.textTheme.titleMedium?.copyWith(
                    fontSize: isTablet ? 16.0 : 14.0,
                  ),
                ),
                Text(
                  value.isNotEmpty ? value : AppStrings.notProvidedLabel,
                  style: ModernTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 14.0 : 12.0,
                    color: hasValue ? null : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (hasValue)
            Icon(
              Icons.arrow_forward_ios,
              size: isTablet ? 20.0 : 16.0,
              color: Colors.grey[400],
            ),
        ],
      ),
    );
  }
}
