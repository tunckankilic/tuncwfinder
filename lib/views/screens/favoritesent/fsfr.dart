import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/favoritesent/fsfr_controller.dart';
import 'package:tuncforwork/views/screens/profile/profile_bindings.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class FavoriteSendFavoriteReceived extends GetView<FsfrController> {
  const FavoriteSendFavoriteReceived({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isTablet = constraints.maxWidth > 768;
      return Scaffold(
        appBar: _buildAppBar(context, isTablet),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: ElegantTheme.primaryColor,
              ),
            );
          }
          return _buildBody(context, isTablet);
        }),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    final double fontSize = isTablet ? 18 : 16;
    final double titleSpacing = isTablet ? 24 : 16;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: ElegantTheme.primaryColor,
      toolbarHeight: isTablet ? 72 : 56,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabButton(context, "My Favorites", true, isTablet),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: titleSpacing),
            child: Text(
              "|",
              style: TextStyle(
                color: ElegantTheme.accentBordeaux,
                fontSize: fontSize,
              ),
            ),
          ),
          _buildTabButton(context, "I'm their Favorite", false, isTablet),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context, bool isTablet) {
    final filteredFavorites = controller.favoritesList
        .where((user) => user["uid"] != currentUserId)
        .toList();

    if (filteredFavorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              color: ElegantTheme.accentBordeaux,
              size: isTablet ? 100 : 80,
            ),
            const SizedBox(height: 16),
            Text(
              controller.isFavoriteSentClicked.value
                  ? 'No favorites added yet'
                  : 'No one has favorited you yet',
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                color: ElegantTheme.accentBordeaux,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          childAspectRatio: isTablet ? 0.85 : 0.75,
          crossAxisSpacing: isTablet ? 16 : 8,
          mainAxisSpacing: isTablet ? 16 : 8,
        ),
        padding: EdgeInsets.all(isTablet ? 16 : 8),
        itemCount: filteredFavorites.length,
        itemBuilder: (context, index) => AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 375),
          columnCount: isTablet ? 3 : 2,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: _buildFavoriteCard(
                context,
                filteredFavorites[index],
                isTablet,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(
      BuildContext context, String text, bool isSent, bool isTablet) {
    final double buttonFontSize = isTablet ? 16 : 14;
    final double horizontalPadding = isTablet ? 24 : 16;

    return Obx(() => TextButton(
          onPressed: () => controller.toggleFavoriteList(isSent),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isTablet ? 16 : 12,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: controller.isFavoriteSentClicked.value == isSent
                  ? ElegantTheme.lightGrey
                  : ElegantTheme.secondaryColor,
              fontWeight: controller.isFavoriteSentClicked.value == isSent
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: buttonFontSize,
            ),
          ),
        ));
  }

  Widget _buildFavoriteCard(
      BuildContext context, Map<String, dynamic> user, bool isTablet) {
    final double cardElevation = isTablet ? 8 : 5;
    final double borderRadius = isTablet ? 20 : 15;
    final double contentPadding = isTablet ? 16 : 12;
    final double nameFontSize = isTablet ? 18 : 16;
    final double locationFontSize = isTablet ? 14 : 12;
    final double iconSize = isTablet ? 20 : 16;

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
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "${user["name"]} • ${user["age"]}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ElegantTheme.textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: nameFontSize,
                    ),
                  ),
                  SizedBox(height: isTablet ? 8 : 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: iconSize,
                      ),
                      SizedBox(width: isTablet ? 8 : 4),
                      Expanded(
                        child: Text(
                          "${user["city"]}, ${user["country"]}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ElegantTheme.textTheme.bodySmall!.copyWith(
                            color: Colors.white70,
                            fontSize: locationFontSize,
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
