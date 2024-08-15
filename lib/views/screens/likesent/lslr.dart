import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_controller.dart';

class LikeSentLikeReceived extends GetView<LslrController> {
  const LikeSentLikeReceived({Key? key}) : super(key: key);

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
            _buildTabButton("My Likes", true),
            const Text(
              "   |   ",
              style: TextStyle(color: ElegantTheme.accentBordeaux),
            ),
            _buildTabButton("They liked me", false),
          ],
        ),
        centerTitle: true,
      ),
      body: Obx(() => controller.likedList.isEmpty
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
                  controller.likedList.length,
                  (index) => AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _buildLikedCard(controller.likedList[index]),
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
          onPressed: () => controller.toggleLikeList(isSent),
          child: Text(
            text,
            style: TextStyle(
              color: controller.isLikeSentClicked.value == isSent
                  ? ElegantTheme.accentBordeaux
                  : ElegantTheme.textColor.withOpacity(0.7),
              fontWeight: controller.isLikeSentClicked.value == isSent
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ));
  }

  Widget _buildLikedCard(Map<String, dynamic> user) {
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
