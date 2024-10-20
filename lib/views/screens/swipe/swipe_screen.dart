import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/profile_bindings.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';

class SwipeScreen extends GetView<SwipeController> {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => SwipeController());
    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          final filteredProfiles = controller.allUsersProfileList
              .where((profile) => profile.uid != controller.currentUserId)
              .toList();
          return PageView.builder(
            pageSnapping: true,
            physics: const BouncingScrollPhysics(),
            itemCount: filteredProfiles.length,
            controller: controller.pageController.value,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final eachProfile = filteredProfiles[index];
              return _buildUserCard(context, eachProfile);
            },
          );
        }),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Person eachProfile) {
    return GestureDetector(
      onTap: () {
        if (eachProfile.uid != null) {
          log(eachProfile.uid.toString());
          Get.to(
            () => UserDetails(
              userId: eachProfile.uid!,
            ),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => UserDetailsController(userId: eachProfile.uid!),
                  tag: eachProfile.uid);
            }),
            arguments: {'userId': eachProfile.uid},
          );
        } else {
          print("Invalid user ID");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(eachProfile.imageProfile ?? ''),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: _buildGradientDecoration(),
          child: Padding(
            padding: EdgeInsets.all(20.w),
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
      ),
    );
  }

  BoxDecoration _buildGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.7),
        ],
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
          size: 30.sp,
          color: ElegantTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, Person eachProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eachProfile.name ?? '',
          style: ElegantTheme.textTheme.headlineMedium!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "${eachProfile.age ?? 'XX'} • ${eachProfile.city ?? 'XX'}",
          style: ElegantTheme.textTheme.titleMedium!.copyWith(
            color: Colors.white70,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 16.h),
        _buildInfoChips(eachProfile),
      ],
    );
  }

  Widget _buildInfoChips(Person eachProfile) {
    return Column(
      children: [
        Row(
          children: [
            _buildInfoChip(eachProfile.profession ?? ''),
            SizedBox(width: 5.w),
            _buildInfoChip(eachProfile.religion ?? ''),
          ],
        ),
        Row(
          children: [
            _buildInfoChip(eachProfile.country ?? ''),
            SizedBox(width: 5.w),
            _buildInfoChip(eachProfile.ethnicity ?? ''),
          ],
        )
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
        fontSize: 12.sp,
      ),
    );
  }

  Widget _buildActionButtons(Person eachProfile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          "assets/favorite.png",
          () => controller.favoriteSentAndFavoriteReceived(
            toUserID: eachProfile.uid ?? '',
            senderName: controller.senderName.value,
          ),
        ),
        SocialActionButtons(
          instagramUsername: eachProfile.instagramUrl ?? '',
          linkedInUsername: eachProfile.linkedInUrl ?? '',
          whatsappNumber: eachProfile.phoneNo ?? '',
          gitHub: eachProfile.githubUrl ?? '',
        ),
        _buildActionButton(
          "assets/like.png",
          () => controller.likeSentAndLikeReceived(
            toUserId: eachProfile.uid ?? '',
            senderName: controller.senderName.value,
          ),
        ),
      ],
    );
  }
}

Widget _buildActionButton(String asset, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: ElegantTheme.primaryColor.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Image.asset(asset),
      ),
    ),
  );
}

class SocialActionButtons extends GetView<SwipeController> {
  final String instagramUsername;
  final String linkedInUsername;
  final String whatsappNumber;
  final String gitHub;

  const SocialActionButtons({
    Key? key,
    required this.gitHub,
    required this.instagramUsername,
    required this.linkedInUsername,
    required this.whatsappNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: ElegantTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildSocialButton(
                  'assets/instagram.svg',
                  () => controller.openInstagramProfile(
                      instagramUsername: instagramUsername, context: context)),
              SizedBox(width: 12.w),
              _buildSocialButton(
                  'assets/linkedin.svg',
                  () => controller.openLinkedInProfile(
                      linkedInUsername: linkedInUsername, context: context)),
            ],
          ),
          SizedBox(height: 5.w),
          Row(
            children: [
              _buildSocialButton(
                  'assets/whatsapp.svg',
                  () => controller.startChattingInWhatsApp(
                      receiverPhoneNumber: whatsappNumber, context: context)),
              SizedBox(width: 12.w),
              _buildSocialButton(
                  'assets/github.svg',
                  () => controller.openGitHubProfile(
                      gitHubUsername: gitHub, context: context)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSocialButton(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: ElegantTheme.primaryColor.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: SvgPicture.asset(
            asset,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
