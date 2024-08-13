import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/viewsent/vsvr_controller.dart';

class ViewSentViewReceive extends StatelessWidget {
  final VsvrController controller = Get.put(VsvrController());

  ViewSentViewReceive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ElegantTheme.primaryColor, ElegantTheme.accentBordeaux],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton("Profile i Viewed", true),
            _buildTabButton("Viewed My Profile", false),
          ],
        ),
        centerTitle: true,
      ),
      body: Obx(() => controller.viewsList.isEmpty
          ? const Center(
              child: Icon(
                Icons.person_off_sharp,
                color: ElegantTheme.textColor,
                size: 60,
              ),
            )
          : AnimationLimiter(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(8),
                children: List.generate(
                  controller.viewsList.length,
                  (index) => AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _buildGridTile(controller.viewsList[index]),
                      ),
                    ),
                  ),
                ),
              ),
            )),
    );
  }

  Widget _buildTabButton(String text, bool isViewSent) {
    return Obx(() => TextButton(
          onPressed: () {
            controller.isViewSentClicked.value = isViewSent;
            controller.viewSentList.clear();
            controller.viewReceivedList.clear();
            controller.viewsList.clear();
            controller.getViewsListKeys();
          },
          child: Text(
            text,
            style: TextStyle(
              color: controller.isViewSentClicked.value == isViewSent
                  ? Colors.white
                  : Colors.white70,
              fontWeight: controller.isViewSentClicked.value == isViewSent
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ));
  }

  Widget _buildGridTile(Map<String, dynamic> user) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [Colors.black54, Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          image: DecorationImage(
            image: NetworkImage(user["imageProfile"]),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "${user["name"]} ◉ ${user["age"]}",
                maxLines: 2,
                style: ElegantTheme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "${user["city"]}, ${user["country"]}",
                      maxLines: 2,
                      style: ElegantTheme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        shadows: [
                          const Shadow(color: Colors.black, blurRadius: 2)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
