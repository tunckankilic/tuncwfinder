// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';

class UserDetails extends GetView<UserDetailsController> {
  static const routeName = "/user";

  const UserDetails({
    super.key,
    required this.userId,
  });
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(),
                  const SizedBox(height: 24),
                  _buildSection("Personal Info", _buildPersonalInfo()),
                  _buildSection("Appearance", _buildAppearance()),
                  _buildSection("Lifestyle", _buildLifestyle()),
                  _buildSection("Background", _buildBackground()),
                  _buildSection("Connections", _buildConnections()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      leading: Obx(() => controller.isMainProfilePage.value
          ? SizedBox.shrink()
          : IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )),
      flexibleSpace: FlexibleSpaceBar(
        title: Obx(() => Text(controller.name.value,
            style: ElegantTheme.textTheme.titleLarge
                ?.copyWith(color: Colors.white))),
        background: Obx(() => controller.imageUrls.isNotEmpty
            ? Image.network(controller.imageUrls[0], fit: BoxFit.cover)
            : Container(color: ElegantTheme.primaryColor)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: controller.navigateToAccountSettings,
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: controller.signOut,
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Obx(() => CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            enlargeCenterPage: true,
            autoPlay: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.8,
          ),
          items: controller.imageUrls.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ));
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: ElegantTheme.textTheme.headlineSmall
                ?.copyWith(color: ElegantTheme.primaryColor)),
        const Divider(color: ElegantTheme.primaryColor),
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      children: [
        _buildInfoRow("Age", controller.age),
        _buildInfoRow("Gender", controller.gender),
        _buildInfoRow("City", controller.city),
        _buildInfoRow("Country", controller.country),
        _buildInfoRow("Looking for", controller.lookingForInaPartner),
      ],
    );
  }

  Widget _buildAppearance() {
    return Column(
      children: [
        _buildInfoRow("Height", controller.height),
        _buildInfoRow("Weight", controller.weight),
        _buildInfoRow("Body Type", controller.bodyType),
      ],
    );
  }

  Widget _buildLifestyle() {
    return Column(
      children: [
        _buildInfoRow("Drink", controller.drink),
        _buildInfoRow("Smoke", controller.smoke),
        _buildInfoRow("Marital Status", controller.martialStatus),
        _buildInfoRow("Have Children", controller.haveChildren),
        _buildInfoRow("Profession", controller.profession),
        _buildInfoRow("Income", controller.income),
      ],
    );
  }

  Widget _buildBackground() {
    return Column(
      children: [
        _buildInfoRow("Nationality", controller.nationality),
        _buildInfoRow("Education", controller.education),
        _buildInfoRow("Language", controller.languageSpoken),
        _buildInfoRow("Religion", controller.religion),
        _buildInfoRow("Ethnicity", controller.ethnicity),
      ],
    );
  }

  Widget _buildConnections() {
    return ProfileActionButtons(
        phoneNo: controller.phoneNo.value,
        instagramUsername: controller.instagramUrl.value,
        linkedInUsername: controller.linkedInUrl.value,
        github: controller.githubUrl.value);
  }

  Widget _buildInfoRow(String label, RxString value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: ElegantTheme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Obx(() => Text(
                  value.value,
                  style: ElegantTheme.textTheme.bodyLarge,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                )),
          ),
        ],
      ),
    );
  }
}

class ProfileActionButtons extends GetView<SwipeController> {
  final String instagramUsername;
  final String linkedInUsername;
  final String github;
  final String phoneNo;

  const ProfileActionButtons({
    Key? key,
    required this.instagramUsername,
    required this.linkedInUsername,
    required this.github,
    required this.phoneNo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ElegantTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileButton(
              context: context,
              widget: _buildActionButton(
                  'assets/instagram.svg',
                  () => controller.openInstagramProfile(
                      instagramUsername: instagramUsername, context: context)),
              title: "Instagram"),
          _profileButton(
              context: context,
              widget: _buildActionButton(
                'assets/linkedin.svg',
                () => controller.openLinkedInProfile(
                    linkedInUsername: linkedInUsername, context: context),
              ),
              title: "LinkedIn"),
          _profileButton(
              context: context,
              widget: _buildActionButton(
                'assets/whatsapp.svg',
                () => controller.startChattingInWhatsApp(
                    receiverPhoneNumber: phoneNo, context: context),
              ),
              title: "Whatsapp"),
          _profileButton(
              context: context,
              widget: _buildActionButton(
                'assets/whatsapp.svg',
                () => controller.startChattingInWhatsApp(
                    receiverPhoneNumber: phoneNo, context: context),
              ),
              title: "GitHub")
        ],
      ),
    );
  }

  Column _profileButton(
      {required BuildContext context, required Widget widget, required title}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              title,
              style: ElegantTheme.textTheme.titleMedium,
            ),
            widget
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildActionButton(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: ElegantTheme.primaryColor.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            asset,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
