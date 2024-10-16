import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details.dart';
import 'package:tuncforwork/views/screens/viewsent/vsvr_controller.dart';

class ViewSentViewReceive extends GetView<VsvrController> {
  ViewSentViewReceive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => VsvrController());
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
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
    );
  }

  Widget _buildBody() {
    final filteredViews = controller.viewsList
        .where((user) => user["uid"] != currentUserId)
        .toList();

    return filteredViews.isEmpty
        ? Center(
            child: Icon(
              Icons.person_off_sharp,
              color: ElegantTheme.textColor,
              size: 60.sp,
            ),
          )
        : AnimationLimiter(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(8.w),
              childAspectRatio: 0.75,
              children: List.generate(
                filteredViews.length,
                (index) => AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _buildGridTile(filteredViews[index]),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildTabButton(String text, bool isViewSent) {
    return Obx(() => TextButton(
          onPressed: () => controller.switchTab(isViewSent),
          child: Text(
            text,
            style: TextStyle(
              color: controller.isViewSentClicked.value == isViewSent
                  ? Colors.white
                  : Colors.white70,
              fontWeight: controller.isViewSentClicked.value == isViewSent
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 12.sp,
            ),
          ),
        ));
  }

  Widget _buildGridTile(Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () => Get.to(() => UserDetails()),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
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
            padding: EdgeInsets.all(12.w),
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
                    fontSize: 18.sp,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2.r)],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        "${user["city"]}, ${user["country"]}",
                        maxLines: 2,
                        style: ElegantTheme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 2.r)
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
      ),
    );
  }
}
