import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/views/screens/profile/profile_bindings.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class NotificationDialog extends StatelessWidget {
  final String name;
  final String age;
  final String city;
  final String country;
  final String profileImage;
  final String profession;
  final String senderId;

  const NotificationDialog({
    Key? key,
    required this.name,
    required this.age,
    required this.city,
    required this.country,
    required this.profileImage,
    required this.profession,
    required this.senderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(left: 20.w, top: 65.h, right: 20.w, bottom: 20.h),
          margin: EdgeInsets.only(top: 45.h),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 10.h),
                blurRadius: 10.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 15.h),
              Text(
                "$age years old, $profession",
                style: TextStyle(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                "$city, $country",
                style: TextStyle(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.to(
                          () => UserDetails(
                            userId: senderId,
                          ),
                          binding: ProfileBindings(userId: senderId),
                          arguments: {'userId': senderId},
                        );
                      },
                      child: Text('View Profile',
                          style: TextStyle(fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('Close', style: TextStyle(fontSize: 18.sp)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 45.r,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(45.r)),
              child: Image.network(profileImage),
            ),
          ),
        ),
      ],
    );
  }
}
