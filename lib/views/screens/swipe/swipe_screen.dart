import 'package:flutter/material.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';
import 'package:tuncforwork/views/screens/swipe/widgets/swipe_cards.dart';

class SwipeScreen extends GetView<SwipeController> {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    Get.put(SwipeController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
        actions: [
          IconButton(
            icon: Icon(Icons.report_problem),
            onPressed: () {
              if (controller.allUsersProfileList.isNotEmpty) {
                controller.showReportDialog(controller.allUsersProfileList[0]);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => controller.applyFilter(isTablet),
          ),
        ],
      ),
      body: Obx(() {
        final profiles = controller.allUsersProfileList;
        return profiles.isEmpty
            ? Center(child: Text('No profiles found'))
            : SwipeCards(
                profiles: profiles,
                onSwipeLeft: (Person person) {
                  controller.removeTopProfile();
                },
                onSwipeRight: (Person person) {
                  controller.likeSentAndLikeReceived(
                    toUserId: person.uid ?? '',
                    senderName: controller.senderName.value,
                  );
                  controller.removeTopProfile();
                },
                onSwipeUp: (Person person) {
                  controller.favoriteSentAndFavoriteReceived(
                    toUserID: person.uid ?? '',
                    senderName: controller.senderName.value,
                  );
                  controller.removeTopProfile();
                },
              );
      }),
    );
  }
}
