import 'package:flutter/material.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';
import 'package:tuncforwork/views/screens/swipe/widgets/swipe_cards.dart';

class SwipeScreen extends GetView<SwipeController> {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SwipeController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: controller.applyFilter,
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
                  controller.blockUser(person.uid ?? '');
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
