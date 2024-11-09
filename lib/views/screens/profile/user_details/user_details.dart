// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';

class UserDetails extends StatefulWidget {
  final String userId;
  const UserDetails({super.key, required this.userId});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  late final UserDetailsController controller;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserDetailsController(userId: widget.userId));
    controller.retrieveUserInfo(widget.userId);
    controller.checkIfMainProfile();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: ElegantTheme.backgroundColor,
          body: GetX<UserDetailsController>(
            builder: (controller) {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: isTablet ? 3.0 : 2.0,
                  ),
                );
              }
              return isTablet
                  ? _buildTabletLayout(context)
                  : _buildPhoneLayout(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Sol taraf - Profil Resmi ve Temel Bilgiler
            Expanded(
              // SizedBox yerine Expanded kullanıyoruz
              flex: 4, // 40% genişlik için
              child: Column(
                children: [
                  _buildTabletHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        children: [
                          _buildImageCarousel(isTablet: true),
                          const SizedBox(height: 32.0),
                          _buildQuickInfo(context),
                          const SizedBox(height: 24.0),
                          _buildConnections(isTablet: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Sağ taraf - Detaylı Bilgiler
            Expanded(
              // Container yerine Expanded kullanıyoruz
              flex: 6, // 60% genişlik için
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(-2, 0),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    _buildTabletSectionsList(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Header'ı da güncelleyelim
  Widget _buildTabletHeader(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: kToolbarHeight + 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: ElegantTheme.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (controller.isMainProfilePage.value)
              IconButton(
                onPressed: () => controller.deleteAccountAndData(context),
                icon: const Icon(Icons.delete),
                color: Colors.white,
                iconSize: 28.0,
              )
            else
              IconButton(
                icon: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                  color: Colors.white,
                  size: 28.0,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                controller.name.value.isNotEmpty
                    ? controller.name.value
                    : 'No Name',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (controller.isMainProfilePage.value) ...[
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  size: 28.0,
                  color: Colors.white,
                ),
                onPressed: controller.navigateToAccountSettings,
              ),
              IconButton(
                icon: const Icon(
                  Icons.exit_to_app,
                  size: 28.0,
                  color: Colors.white,
                ),
                onPressed: controller.signOut,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        _buildSliverAppBar(context, isTablet: false),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(isTablet: false),
                const SizedBox(height: 24.0),
                _buildSection(
                  "Personal Info",
                  _buildPersonalInfo(isTablet: false),
                  isTablet: false,
                ),
                _buildSection(
                  "Appearance",
                  _buildAppearance(isTablet: false),
                  isTablet: false,
                ),
                _buildSection(
                  "Lifestyle",
                  _buildLifestyle(isTablet: false),
                  isTablet: false,
                ),
                _buildSection(
                  "Background",
                  _buildBackground(isTablet: false),
                  isTablet: false,
                ),
                _buildSection(
                  "Connections",
                  _buildConnections(isTablet: false),
                  isTablet: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildTabletHeader(BuildContext context) {
  //   return Container(
  //     height: kToolbarHeight + 20,
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //     decoration: BoxDecoration(
  //       color: ElegantTheme.primaryColor,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         if (controller.isMainProfilePage.value)
  //           IconButton(
  //             onPressed: () => controller.deleteAccountAndData(context),
  //             icon: const Icon(Icons.delete),
  //             color: Colors.white,
  //             iconSize: 28.0,
  //           )
  //         else
  //           IconButton(
  //             icon: Icon(
  //               Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
  //               color: Colors.white,
  //               size: 28.0,
  //             ),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //         const SizedBox(width: 16.0),
  //         Expanded(
  //           child: Text(
  //             controller.name.value.isNotEmpty
  //                 ? controller.name.value
  //                 : 'No Name',
  //             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
  //                   color: Colors.white,
  //                   fontSize: 24.0,
  //                 ),
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //         if (controller.isMainProfilePage.value) ...[
  //           IconButton(
  //             icon: const Icon(
  //               Icons.settings,
  //               size: 28.0,
  //               color: Colors.white,
  //             ),
  //             onPressed: controller.navigateToAccountSettings,
  //           ),
  //           IconButton(
  //             icon: const Icon(
  //               Icons.exit_to_app,
  //               size: 28.0,
  //               color: Colors.white,
  //             ),
  //             onPressed: controller.signOut,
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildQuickInfo(BuildContext context) {
    // Create a fallback widget to handle missing SVG assets
    Widget buildIcon(String assetPath, IconData fallbackIcon) {
      return SizedBox(
        width: 24.0,
        height: 24.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: ElegantTheme.primaryColor,
        ),
      );
    }

    final List<Map<String, dynamic>> quickInfo = [
      {
        'icon': 'assets/age.svg',
        'fallbackIcon': Icons.calendar_today,
        'label': 'Age',
        'value': controller.age.value
      },
      {
        'icon': 'assets/location.svg',
        'fallbackIcon': Icons.location_on,
        'label': 'Location',
        'value': '${controller.city.value}, ${controller.country.value}'
      },
      {
        'icon': 'assets/work.svg',
        'fallbackIcon': Icons.work,
        'label': 'Profession',
        'value': controller.profession.value
      },
    ];

    // Fix overflow issue by wrapping in LayoutBuilder
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: quickInfo.map((info) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: ElegantTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: buildIcon(info['icon'], info['fallbackIcon']),
                  ),
                  const SizedBox(width: 16.0),
                  // Fix overflow by constraining the width
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth -
                            64.0, // Account for padding and icon
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info['label'],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                          Text(
                            info['value'].isNotEmpty
                                ? info['value']
                                : 'Not Provided',
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, {required bool isTablet}) {
    final double expandedHeight = isTablet ? 300.0 : 200.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      leading: controller.isMainProfilePage.value
          ? IconButton(
              onPressed: () => controller.deleteAccountAndData(context),
              icon: const Icon(Icons.delete),
              color: Colors.white,
              iconSize: isTablet ? 28.0 : 24.0,
            )
          : IconButton(
              icon: Icon(
                Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                color: Colors.white,
                size: isTablet ? 28.0 : 24.0,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          controller.name.value.isNotEmpty ? controller.name.value : 'No Name',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: isTablet ? 24.0 : 18.0,
              ),
        ),
        background: controller.imageUrls.isNotEmpty
            ? Image.network(
                controller.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: ElegantTheme.primaryColor,
                  child: Icon(
                    Icons.broken_image,
                    size: isTablet ? 64.0 : 48.0,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              )
            : Container(color: ElegantTheme.primaryColor),
      ),
      actions: [
        if (controller.isMainProfilePage.value) ...[
          IconButton(
            icon: Icon(
              Icons.settings,
              size: isTablet ? 28.0 : 24.0,
              color: Colors.white,
            ),
            onPressed: controller.navigateToAccountSettings,
          ),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              size: isTablet ? 28.0 : 24.0,
              color: Colors.white,
            ),
            onPressed: controller.signOut,
          ),
        ],
      ],
    );
  }

  Widget _buildTabletSectionsList() {
    return SliverPadding(
      padding: const EdgeInsets.all(24.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildSection(
            "Personal Info",
            _buildPersonalInfo(isTablet: true),
            isTablet: true,
          ),
          _buildSection(
            "Appearance",
            _buildAppearance(isTablet: true),
            isTablet: true,
          ),
          _buildSection(
            "Lifestyle",
            _buildLifestyle(isTablet: true),
            isTablet: true,
          ),
          _buildSection(
            "Background",
            _buildBackground(isTablet: true),
            isTablet: true,
          ),
        ]),
      ),
    );
  }

  Widget _buildImageCarousel({required bool isTablet}) {
    final double carouselHeight = isTablet ? 400.0 : 200.0;

    return SizedBox(
      height: carouselHeight,
      child: controller.imageUrls.isNotEmpty
          ? PageView.builder(
              itemCount: controller.imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 8.0 : 5.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
                    child: Stack(
                      children: [
                        Image.network(
                          controller.imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildErrorImage(isTablet),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildLoadingImage(isTablet);
                          },
                        ),
                        Positioned(
                          bottom: isTablet ? 16.0 : 12.0,
                          right: isTablet ? 16.0 : 12.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 12.0 : 8.0,
                              vertical: isTablet ? 8.0 : 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius:
                                  BorderRadius.circular(isTablet ? 12.0 : 8.0),
                            ),
                            child: Text(
                              '${index + 1}/${controller.imageUrls.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 16.0 : 12.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : _buildNoImagesPlaceholder(isTablet),
    );
  }

  Widget _buildErrorImage(bool isTablet) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: isTablet ? 64.0 : 48.0,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isTablet ? 16.0 : 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingImage(bool isTablet) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: isTablet ? 3.0 : 2.0,
        ),
      ),
    );
  }

  Widget _buildNoImagesPlaceholder(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: isTablet ? 64.0 : 48.0,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16.0),
            Text(
              'No images available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isTablet ? 18.0 : 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content, {required bool isTablet}) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? 4.0 : 3.0,
                height: isTablet ? 24.0 : 20.0,
                decoration: BoxDecoration(
                  color: ElegantTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              SizedBox(width: isTablet ? 12.0 : 8.0),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ElegantTheme.primaryColor,
                      fontSize: isTablet ? 24.0 : 18.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(
              top: isTablet ? 16.0 : 12.0,
              bottom: isTablet ? 24.0 : 16.0,
            ),
            height: 1.0,
            color: ElegantTheme.primaryColor.withOpacity(0.2),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, RxString value, {required bool isTablet}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 8.0 : 4.0,
      ),
      child: Row(
        children: [
          // Label kısmı için Expanded
          Expanded(
            flex: 2, // Label için daha az alan
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: isTablet ? 16.0 : 14.0,
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0), // Araya boşluk ekleyelim
          // Değer kısmı için Expanded
          Expanded(
            flex: 3, // Değer için daha fazla alan
            child: Text(
              value.value.isNotEmpty ? value.value : 'Not Provided',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: value.value.isEmpty ? Colors.grey[500] : null,
                  ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo({required bool isTablet}) {
    return Card(
      elevation: isTablet ? 2.0 : 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          children: [
            _buildInfoRow("Age", controller.age, isTablet: isTablet),
            _buildInfoRow("Gender", controller.gender, isTablet: isTablet),
            _buildInfoRow("City", controller.city, isTablet: isTablet),
            _buildInfoRow("Country", controller.country, isTablet: isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearance({required bool isTablet}) {
    return Card(
      elevation: isTablet ? 2.0 : 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          children: [
            _buildInfoRow("Height", controller.height, isTablet: isTablet),
            _buildInfoRow("Weight", controller.weight, isTablet: isTablet),
            _buildInfoRow("Body Type", controller.bodyType, isTablet: isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyle({required bool isTablet}) {
    return Card(
      elevation: isTablet ? 2.0 : 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          children: [
            _buildInfoRow("Drink", controller.drink, isTablet: isTablet),
            _buildInfoRow("Smoke", controller.smoke, isTablet: isTablet),
            _buildInfoRow("Marital Status", controller.martialStatus,
                isTablet: isTablet),
            _buildInfoRow("Have Children", controller.haveChildren,
                isTablet: isTablet),
            _buildInfoRow("Profession", controller.profession,
                isTablet: isTablet),
            _buildInfoRow("Income", controller.income, isTablet: isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground({required bool isTablet}) {
    return Card(
      elevation: isTablet ? 2.0 : 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 12.0 : 8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          children: [
            _buildInfoRow("Nationality", controller.nationality,
                isTablet: isTablet),
            _buildInfoRow("Education", controller.education,
                isTablet: isTablet),
            _buildInfoRow("Language", controller.languageSpoken,
                isTablet: isTablet),
            _buildInfoRow("Religion", controller.religion, isTablet: isTablet),
            _buildInfoRow("Ethnicity", controller.ethnicity,
                isTablet: isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildConnections({required bool isTablet}) {
    return ProfileActionButtons(
      phoneNo: controller.phoneNo.value,
      instagramUsername: controller.instagramUrl.value,
      linkedInUsername: controller.linkedInUrl.value,
      github: controller.githubUrl.value,
      isTablet: isTablet,
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
                  ? ElegantTheme.primaryColor
                  : ElegantTheme.primaryColor.withOpacity(0.3),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: isTablet ? 16.0 : 14.0,
                      ),
                ),
                Text(
                  value.isNotEmpty ? value : 'Not Provided',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
