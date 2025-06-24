import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:tuncforwork/views/screens/home/home_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/models/tech_event.dart';
import 'package:tuncforwork/service/tech_event_service.dart';

class EventListScreen extends GetView<HomeController> {
  const EventListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eventService = Get.find<TechEventService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 24.w),
            onPressed: () => controller.navigateToCreateEvent(),
          ),
        ],
      ),
      body: Obx(
        () => eventService.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: eventService.upcomingEvents.length,
                itemBuilder: (context, index) {
                  final event = eventService.upcomingEvents[index];
                  return _buildEventCard(event);
                },
              ),
      ),
    );
  }

  Widget _buildEventCard(TechEvent event) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => controller.navigateToEventDetails(event),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16.w),
                  SizedBox(width: 4.w),
                  Text(
                    event.date.toString(),
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.location_on, size: 16.w),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      event.venueName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: event.topics.map((topic) {
                  return Chip(
                    label: Text(
                      topic,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 0,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
