// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:tuncforwork/models/models.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/theme/app_theme.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context),
          tablet: _buildTabletLayout(context),
        ),
      ),
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
            color: AppTheme.primarySwatch.shade50,
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
                backgroundImage: NetworkImage(controller.imageUrl.value),
              ),
              const SizedBox(height: 16),
              Text(
                controller.name.value,
                style: AppTheme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.profession.value,
                style: AppTheme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: AppTheme.primarySwatch),
                  const SizedBox(width: 8),
                  Text(
                    '${controller.city.value}, ${controller.country.value}',
                    style: AppTheme.textTheme.bodyLarge,
                  ),
                ],
              ),
              if (controller.isCurrentUser.value) ...[
                const SizedBox(height: 24),
                ModernButton(
                  text: 'Edit Profile',
                  onPressed: controller.navigateToAccountSettings,
                  isOutlined: true,
                ),
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
              _buildInfoSection(
                'About',
                controller.profileHeading.value,
                Icons.person,
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                'Contact',
                controller.email.value,
                Icons.email,
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                'Education',
                controller.education.value,
                Icons.school,
              ),
            ],
          ),
        ));
  }

  Widget _buildProfileContent(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isTablet) _buildBasicInfo(false),
          const SizedBox(height: 24),
          _buildExperienceSection(isTablet),
          const SizedBox(height: 24),
          _buildSkillsSection(isTablet),
          const SizedBox(height: 24),
          _buildProjectsSection(isTablet),
          const SizedBox(height: 24),
          _buildSocialLinks(isTablet),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primarySwatch),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTheme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: AppTheme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildExperienceSection(bool isTablet) {
    return Obx(() => ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Work Experience',
                style: AppTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...controller.workExperiences.map(
                (exp) => _buildExperienceItem(exp, isTablet),
              ),
            ],
          ),
        ));
  }

  Widget _buildExperienceItem(WorkExperience exp, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.primarySwatch,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp.title,
                  style: AppTheme.textTheme.titleMedium,
                ),
                Text(
                  exp.company,
                  style: AppTheme.textTheme.bodyLarge,
                ),
                Text(
                  '${exp.startDate} - ${exp.endDate ?? 'Present'}',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                if (exp.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    exp.description!,
                    style: AppTheme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(bool isTablet) {
    return Obx(() => ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skills',
                style: AppTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.skills
                    .map((skill) => Chip(
                          label: Text(skill),
                          backgroundColor: AppTheme.primarySwatch.shade50,
                          labelStyle: TextStyle(color: AppTheme.primarySwatch),
                        ))
                    .toList(),
              ),
            ],
          ),
        ));
  }

  Widget _buildProjectsSection(bool isTablet) {
    return Obx(() => ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projects',
                style: AppTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...controller.projects.map(
                (project) => _buildProjectItem(project, isTablet),
              ),
            ],
          ),
        ));
  }

  Widget _buildProjectItem(Project project, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: AppTheme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: AppTheme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: project.technologies
                .map((tech) => Chip(
                      label: Text(tech),
                      backgroundColor: AppTheme.primarySwatch.shade50,
                      labelStyle: TextStyle(color: AppTheme.primarySwatch),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(bool isTablet) {
    return Obx(() => ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Social Links',
                style: AppTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (controller.linkedInUrl.value.isNotEmpty)
                _buildSocialLink(
                  'LinkedIn',
                  controller.linkedInUrl.value,
                  'assets/linkedin.svg',
                ),
              if (controller.githubUrl.value.isNotEmpty)
                _buildSocialLink(
                  'GitHub',
                  controller.githubUrl.value,
                  'assets/github.svg',
                ),
              if (controller.instagramUrl.value.isNotEmpty)
                _buildSocialLink(
                  'Instagram',
                  controller.instagramUrl.value,
                  'assets/instagram.svg',
                ),
            ],
          ),
        ));
  }

  Widget _buildSocialLink(String platform, String url, String iconPath) {
    return InkWell(
      onTap: () => controller.launchURL(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              color: AppTheme.primarySwatch,
            ),
            const SizedBox(width: 16),
            Text(
              platform,
              style: AppTheme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileActionButtons extends GetView<SwipeController> {
  final String instagramUsername;
  final String linkedInUsername;
  final String github;
  final String phoneNo;
  final bool isTablet;

  const ProfileActionButtons({
    super.key,
    required this.instagramUsername,
    required this.linkedInUsername,
    required this.github,
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
              title: "Instagram",
              value: instagramUsername,
              onTap: () => controller.openInstagramProfile(
                instagramUsername: instagramUsername,
                context: context,
              ),
            ),
            _buildConnectionButton(
              context: context,
              icon: 'assets/linkedin.svg',
              title: "LinkedIn",
              value: linkedInUsername,
              onTap: () => controller.openLinkedInProfile(
                linkedInUsername: linkedInUsername,
                context: context,
              ),
            ),
            _buildConnectionButton(
              context: context,
              icon: 'assets/whatsapp.svg',
              title: "WhatsApp",
              value: phoneNo,
              onTap: () => controller.startChattingInWhatsApp(
                receiverPhoneNumber: phoneNo,
                context: context,
              ),
            ),
            _buildConnectionButton(
              context: context,
              icon: 'assets/github.svg',
              title: "GitHub",
              value: github,
              onTap: () => controller.openGitHubProfile(
                gitHubUsername: github,
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
    final bool hasValue = value.isNotEmpty && value != 'Not Provided';

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 16.0 : 12.0),
      child: Row(
        children: [
          Container(
            width: isTablet ? 48.0 : 40.0,
            height: isTablet ? 48.0 : 40.0,
            decoration: BoxDecoration(
              color: hasValue
                  ? AppTheme.primarySwatch
                  : AppTheme.primarySwatch.withOpacity(0.3),
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
                    color: Colors.white,
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
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontSize: isTablet ? 16.0 : 14.0,
                  ),
                ),
                Text(
                  value.isNotEmpty ? value : 'Not Provided',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
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
