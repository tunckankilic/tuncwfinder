import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:tuncdating/service/service.dart";
import "package:tuncdating/views/screens/swipe/swipe_controller.dart";

class SwipeScreen extends GetView<SwipeController> {
  SwipeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get.put(() => SwipeController());
    Get.lazyPut(() => SwipeController());
    return SafeArea(
      child: Scaffold(
        body: Obx(
          () => PageView.builder(
            pageSnapping: true,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.allUsersProfileList.length,
            controller: controller.pageController.value,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final eachProfile = controller.allUsersProfileList[index];
              return _buildUserCard(context, eachProfile);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, dynamic eachProfile) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(eachProfile['imageProfile']?.toString() ?? ''),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterButton(),
              _buildUserInfo(context, eachProfile),
              _buildActionButtons(eachProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: controller.applyFilter,
        icon: Icon(
          Icons.filter_list_outlined,
          size: 30,
          color: ElegantTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, dynamic eachProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eachProfile["name"].toString(),
          style: ElegantTheme.textTheme.headlineMedium!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "${eachProfile["age"] ?? "XX"} • ${eachProfile["city"] ?? "XX"}",
          style: ElegantTheme.textTheme.titleMedium!.copyWith(
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildInfoChip(eachProfile["profession"].toString()),
            _buildInfoChip(eachProfile["religion"].toString()),
            _buildInfoChip(eachProfile["country"].toString()),
            _buildInfoChip(eachProfile["ethnicity"].toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: ElegantTheme.secondaryColor.withOpacity(0.8),
      labelStyle: ElegantTheme.textTheme.bodyMedium!.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildActionButtons(dynamic eachProfile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          "assets/favorite.png",
          () => controller.favoriteSentAndFavoriteReceived(
            toUserID: eachProfile["uid"].toString(),
            senderName: controller.senderName.value,
          ),
        ),
        SocialActionButtons(
            instagramUsername: eachProfile["instagram"],
            linkedInUsername: eachProfile["linkedIn"],
            whatsappNumber: eachProfile["phoneNo"]),
        _buildActionButton(
          "assets/like.png",
          () => controller.likeSentAndLikeReceived(
            toUserId: eachProfile["uid"].toString(),
            senderName: controller.senderName.value,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: ElegantTheme.primaryColor.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            asset,
          ),
        ),
      ),
    );
  }
}

class SocialActionButtons extends GetView<SwipeController> {
  final String instagramUsername;
  final String linkedInUsername;
  final String whatsappNumber;

  const SocialActionButtons({
    Key? key,
    required this.instagramUsername,
    required this.linkedInUsername,
    required this.whatsappNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ElegantTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
              'assets/instagram.svg',
              () => controller.openInstagramProfile(
                  instagramUsername: instagramUsername, context: context)),
          const SizedBox(width: 12),
          _buildActionButton(
            'assets/linkedin.svg',
            () => controller.openLinkedInProfile(
                linkedInUsername: linkedInUsername, context: context),
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            'assets/whatsapp.svg',
            () => controller.startChattingInWhatsApp(
                receiverPhoneNumber: whatsappNumber, context: context),
          ),
        ],
      ),
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
