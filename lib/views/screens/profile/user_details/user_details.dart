// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.name.value,
          style: const TextStyle(color: Colors.black),
        ),
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
                backgroundImage: controller.imageUrl.value.isNotEmpty
                    ? NetworkImage(controller.imageUrl.value)
                    : null,
                child: controller.imageUrl.value.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 16),
              Text(
                controller.name.value.isNotEmpty
                    ? controller.name.value
                    : 'İsimsiz Kullanıcı',
                style: AppTheme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.profession.value.isNotEmpty
                    ? controller.profession.value
                    : 'Meslek belirtilmemiş',
                style: AppTheme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (controller.city.value.isNotEmpty ||
                  controller.country.value.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: AppTheme.primarySwatch),
                    const SizedBox(width: 8),
                    Text(
                      [
                        if (controller.city.value.isNotEmpty)
                          controller.city.value,
                        if (controller.country.value.isNotEmpty)
                          controller.country.value,
                      ].join(', '),
                      style: AppTheme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              if (controller.isCurrentUser.value) ...[
                const SizedBox(height: 24),
                ModernButton(
                  text: 'Profili Düzenle',
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
                              'Eksik Bilgiler',
                              style: AppTheme.textTheme.titleMedium?.copyWith(
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Profilinizi daha etkili hale getirmek için aşağıdaki bilgileri ekleyebilirsiniz:',
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
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
                'Temel Bilgiler',
                style: AppTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Yaş', controller.age.value),
              _buildInfoRow('Cinsiyet', controller.gender.value),
              _buildInfoRow('E-posta', controller.email.value),
              _buildInfoRow('Telefon', controller.phoneNo.value),
              _buildInfoRow('Şehir', controller.city.value),
              _buildInfoRow('Ülke', controller.country.value),
              _buildInfoRow('Eğitim', controller.education.value),
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
                'Ek Bilgiler',
                style: AppTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Boy', controller.height.value),
              _buildInfoRow('Kilo', controller.weight.value),
              _buildInfoRow('Vücut Tipi', controller.bodyType.value),
              _buildInfoRow('İçki', controller.drink.value),
              _buildInfoRow('Sigara', controller.smoke.value),
              _buildInfoRow('Medeni Durum', controller.martialStatus.value),
              _buildInfoRow('Çocuk', controller.haveChildren.value),
              if (controller.haveChildren.value == 'Yes')
                _buildInfoRow('Çocuk Sayısı', controller.noOfChildren.value),
              _buildInfoRow('İş Durumu', controller.employmentStatus.value),
              _buildInfoRow('Gelir', controller.income.value),
              _buildInfoRow('Yaşam Durumu', controller.livingSituation.value),
              _buildInfoRow('Uyruk', controller.nationality.value),
              _buildInfoRow('Konuşulan Dil', controller.languageSpoken.value),
              _buildInfoRow('Din', controller.religion.value),
              _buildInfoRow('Etnik Köken', controller.ethnicity.value),
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
                'Kariyer Bilgileri',
                style: AppTheme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Meslek', controller.profession.value),
              if (controller.workExperiences.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'İş Deneyimleri',
                  style: AppTheme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...controller.workExperiences
                    .map((exp) => _buildExperienceItem(exp, isTablet)),
              ],
              if (controller.skills.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Yetenekler',
                  style: AppTheme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.skills
                      .map((skill) => Chip(
                            label: Text(skill),
                            backgroundColor: AppTheme.primarySwatch.shade100,
                          ))
                      .toList(),
                ),
              ],
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
                'Sosyal Medya',
                style: AppTheme.textTheme.titleLarge,
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
              style: AppTheme.textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.textTheme.bodyMedium,
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
            style: AppTheme.textTheme.titleSmall,
          ),
          Text(
            exp.company,
            style: AppTheme.textTheme.bodyMedium,
          ),
          Text(
            '${exp.startDate} - ${exp.endDate ?? 'Present'}',
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          if (exp.description != null && exp.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                exp.description!,
                style: AppTheme.textTheme.bodyMedium,
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
              title: "Instagram",
              value: instagramUsername,
              onTap: () => controller.openInstagramProfile(
                instagramUsername: instagramUsername,
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
