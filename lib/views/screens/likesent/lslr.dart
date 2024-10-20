import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_controller.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details.dart';

class LikeSentLikeReceived extends GetView<LslrController> {
  const LikeSentLikeReceived({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: ElegantTheme.primaryColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabButton("My Likes", true),
          Text(
            "   |   ",
            style:
                TextStyle(color: ElegantTheme.accentBordeaux, fontSize: 16.sp),
          ),
          _buildTabButton("They liked me", false),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    final filteredLikes = controller.likedList
        .where((user) => user["uid"] != currentUserId)
        .toList();

    return filteredLikes.isEmpty
        ? Center(
            child: Icon(
              Icons.favorite_border,
              color: ElegantTheme.accentBordeaux,
              size: 80.sp,
            ),
          )
        : AnimationLimiter(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
              ),
              padding: EdgeInsets.all(8.w),
              itemCount: filteredLikes.length,
              itemBuilder: (context, index) =>
                  AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _buildLikedCard(filteredLikes[index]),
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildTabButton(String text, bool isSent) {
    return Obx(() => TextButton(
          onPressed: () => controller.toggleLikeList(isSent),
          child: Text(
            text,
            style: TextStyle(
              color: controller.isLikeSentClicked.value == isSent
                  ? ElegantTheme.lightGrey
                  : ElegantTheme.secondaryColor,
              fontWeight: controller.isLikeSentClicked.value == isSent
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 14.sp,
            ),
          ),
        ));
  }

  Widget _buildLikedCard(Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () => Get.to(() => UserDetails(
            userId: user["uid"],
          )),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            image: DecorationImage(
              image: NetworkImage(user["imageProfile"]),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
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
              padding: EdgeInsets.all(12.w),
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
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          "${user["city"]}, ${user["country"]}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ElegantTheme.textTheme.bodySmall!.copyWith(
                            color: Colors.white70,
                            fontSize: 12.sp,
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
