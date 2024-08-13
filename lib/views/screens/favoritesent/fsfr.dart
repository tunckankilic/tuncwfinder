import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/favoritesent/fsfr_controller.dart';

class FavoriteSendFavoriteReceived extends GetView<FsfrController> {
  const FavoriteSendFavoriteReceived({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: ElegantTheme.primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton("My Favorites", true),
            const Text(
              "   |   ",
              style: TextStyle(color: ElegantTheme.accentBordeaux),
            ),
            _buildTabButton("I'm their Favorite", false),
          ],
        ),
        centerTitle: true,
      ),
      body: Obx(() => controller.favoritesList.isEmpty
          ? const Center(
              child: Icon(
                Icons.favorite_border,
                color: ElegantTheme.accentBordeaux,
                size: 80,
              ),
            )
          : AnimationLimiter(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(8),
                children: List.generate(
                  controller.favoritesList.length,
                  (index) => AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child:
                            _buildFavoriteCard(controller.favoritesList[index]),
                      ),
                    ),
                  ),
                ),
              ),
            )),
    );
  }

  Widget _buildTabButton(String text, bool isSent) {
    return Obx(() => TextButton(
          onPressed: () => controller.toggleFavoriteList(isSent),
          child: Text(
            text,
            style: TextStyle(
              color: controller.isFavoriteSentClicked.value == isSent
                  ? ElegantTheme.accentBordeaux
                  : ElegantTheme.textColor.withOpacity(0.7),
              fontWeight: controller.isFavoriteSentClicked.value == isSent
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ));
  }

  Widget _buildFavoriteCard(Map<String, dynamic> user) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: NetworkImage(user["imageProfile"]),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
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
            padding: const EdgeInsets.all(12.0),
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
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${user["city"]}, ${user["country"]}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ElegantTheme.textTheme.bodySmall!.copyWith(
                          color: Colors.white70,
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
    );
  }
}
