import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/theme/modern_theme.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_controller.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details.dart';
import 'package:tuncforwork/views/screens/profile/profile_bindings.dart';

class LikeSentLikeReceived extends GetView<LslrController> {
  const LikeSentLikeReceived({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildResponsiveAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: ModernTheme.primaryColor,
            ),
          );
        }
        return _buildResponsiveBody(context);
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final iconSize = isTablet ? 120.0 : 80.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            color: ModernTheme.secondaryColor,
            size: iconSize,
          ),
          const SizedBox(height: 16),
          Text(
            controller.isLikeSentClicked.value
                ? 'You haven\'t liked anyone yet'
                : 'No one has liked you yet',
            style: TextStyle(
              fontSize: isTablet ? 24.0 : 18.0,
              color: ModernTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final height = isTablet ? 70.0 : kToolbarHeight;

    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: ModernTheme.primaryColor,
        title: isTablet
            ? _buildTabletAppBarTitle(context)
            : _buildPhoneAppBarTitle(context),
        centerTitle: true,
      ),
    );
  }

  Widget _buildTabletAppBarTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: ModernTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton("My Likes", true, isTablet: true),
          const SizedBox(width: 16),
          Container(
            height: 30,
            width: 2,
            color: ModernTheme.secondaryColor,
          ),
          const SizedBox(width: 16),
          _buildTabButton("They liked me", false, isTablet: true),
        ],
      ),
    );
  }

  Widget _buildPhoneAppBarTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabButton("My Likes", true),
        Text(
          "   |   ",
          style: TextStyle(
            color: ModernTheme.secondaryColor,
            fontSize: 16,
          ),
        ),
        _buildTabButton("They liked me", false),
      ],
    );
  }

  Widget _buildResponsiveBody(BuildContext context) {
    final filteredLikes = controller.likedList
        .where((user) => user["uid"] != currentUserId)
        .toList();

    if (filteredLikes.isEmpty) {
      return _buildEmptyState(context);
    }

    final isTablet = MediaQuery.of(context).size.width >= 768;
    final crossAxisCount = isTablet ? 4 : 2;
    final padding = isTablet ? 16.0 : 8.0;
    final spacing = isTablet ? 16.0 : 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimationLimiter(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            padding: EdgeInsets.all(padding),
            itemCount: filteredLikes.length,
            itemBuilder: (context, index) =>
                AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: crossAxisCount,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: _buildLikedCard(
                    filteredLikes[index],
                    context,
                    isTablet,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String text, bool isSent, {bool isTablet = false}) {
    return Obx(() {
      final isSelected = controller.isLikeSentClicked.value == isSent;
      return TextButton(
        onPressed: () => controller.toggleLikeList(isSent),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
            vertical: isTablet ? 12.0 : 8.0,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? ModernTheme.surfaceVariant
                : ModernTheme.secondaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: isTablet ? 16.0 : 14.0,
          ),
        ),
      );
    });
  }

  Widget _buildLikedCard(
    Map<String, dynamic> user,
    BuildContext context,
    bool isTablet,
  ) {
    final double cardElevation = isTablet ? 8.0 : 5.0;
    final double borderRadius = isTablet ? 20.0 : 15.0;
    final double padding = isTablet ? 16.0 : 12.0;
    final double nameSize = isTablet ? 18.0 : 16.0;
    final double locationSize = isTablet ? 14.0 : 12.0;

    return GestureDetector(
      onTap: () => Get.to(() => UserDetails(userId: user["uid"]),
          binding: ProfileBindings()),
      child: Card(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            image: DecorationImage(
              image: NetworkImage(user["imageProfile"]),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
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
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "${user["name"]} • ${user["age"]}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ModernTheme.textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: nameSize,
                    ),
                  ),
                  SizedBox(height: isTablet ? 8.0 : 4.0),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: isTablet ? 20.0 : 16.0,
                      ),
                      SizedBox(width: isTablet ? 8.0 : 4.0),
                      Expanded(
                        child: Text(
                          "${user["city"]}, ${user["country"]}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ModernTheme.textTheme.bodySmall!.copyWith(
                            color: Colors.white70,
                            fontSize: locationSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
