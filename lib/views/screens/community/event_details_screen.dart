import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tuncforwork/models/tech_event.dart';
import 'package:tuncforwork/service/tech_event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventDetailsScreen extends StatefulWidget {
  final TechEvent event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _eventService = Get.find<TechEventService>();
  final _auth = FirebaseAuth.instance;
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  bool get _isOrganizer => widget.event.organizerId == _auth.currentUser?.uid;
  bool get _isParticipant =>
      widget.event.participants.contains(_auth.currentUser?.uid);
  bool get _isFull =>
      widget.event.participants.length >= widget.event.maxParticipants;

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: MarkerId(widget.event.id),
        position: LatLng(
          widget.event.location.latitude,
          widget.event.location.longitude,
        ),
        infoWindow: InfoWindow(title: widget.event.venueName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.event.title,
                style: TextStyle(fontSize: 20.sp),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getEventTypeIcon(),
                    size: 64.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventInfo(),
                  SizedBox(height: 24.h),
                  _buildDescription(),
                  SizedBox(height: 24.h),
                  _buildTopics(),
                  SizedBox(height: 24.h),
                  if (widget.event.requirements.isNotEmpty) ...[
                    _buildRequirements(),
                    SizedBox(height: 24.h),
                  ],
                  _buildLocation(),
                  SizedBox(height: 24.h),
                  _buildParticipants(),
                  if (widget.event.speakers.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _buildSpeakers(),
                  ],
                  if (widget.event.agenda.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _buildAgenda(),
                  ],
                  if (widget.event.resources.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _buildResources(),
                  ],
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  IconData _getEventTypeIcon() {
    switch (widget.event.type) {
      case EventType.meetup:
        return Icons.groups;
      case EventType.workshop:
        return Icons.build;
      case EventType.conference:
        return Icons.business_center;
      case EventType.hackathon:
        return Icons.code;
      case EventType.webinar:
        return Icons.computer;
      case EventType.networking:
        return Icons.people;
      case EventType.training:
        return Icons.school;
      default:
        return Icons.event;
    }
  }

  Widget _buildEventInfo() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  DateFormat('dd MMMM yyyy, HH:mm').format(widget.event.date),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: Theme.of(context).primaryColor,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  '${widget.event.participants.length}/${widget.event.maxParticipants} ${AppStrings.eventParticipant}',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ],
            ),
            if (widget.event.isOnline) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.video_call,
                    color: Theme.of(context).primaryColor,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    widget.event.isHybrid
                        ? AppStrings.eventHybrid
                        : AppStrings.eventOnline,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
              if (widget.event.joinLink != null) ...[
                SizedBox(height: 8.h),
                TextButton.icon(
                  icon: Icon(Icons.link, size: 20.w),
                  label: Text(
                    AppStrings.eventJoinLink,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  onPressed: () => _launchUrl(widget.event.joinLink!),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.eventDescription,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.event.description,
          style: TextStyle(fontSize: 16.sp),
        ),
      ],
    );
  }

  Widget _buildTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.eventTopicsList,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: widget.event.topics.map((topic) {
            return Chip(
              label: Text(
                topic,
                style: TextStyle(fontSize: 14.sp),
              ),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.eventRequirements,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.event.requirements.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(
                Icons.check_circle_outline,
                size: 20.w,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                widget.event.requirements[index],
                style: TextStyle(fontSize: 16.sp),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.eventLocation,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        widget.event.location.latitude,
                        widget.event.location.longitude,
                      ),
                      zoom: 15,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) => _mapController = controller,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.venueName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.event.address,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton.icon(
                      icon: Icon(Icons.directions, size: 20.w),
                      label: Text(
                        AppStrings.eventGetDirections,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      onPressed: () => _getDirections(),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.eventParticipants,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.event.participants.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 20.r,
                  child: Icon(Icons.person, size: 24.w),
                ),
                title: Text(
                  '${AppStrings.eventParticipant} ${index + 1}',
                  style: TextStyle(fontSize: 16.sp),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.eventSpeakers,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.event.speakers.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 20.r,
                  child: Icon(Icons.person, size: 24.w),
                ),
                title: Text(
                  widget.event.speakers[index],
                  style: TextStyle(fontSize: 16.sp),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgenda() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.eventSchedule,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.event.agenda.length,
            itemBuilder: (context, index) {
              final item = widget.event.agenda[index];
              return ListTile(
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${DateFormat('HH:mm').format(item.startTime)} - '
                  '${DateFormat('HH:mm').format(item.endTime)}\n'
                  '${item.speaker}',
                  style: TextStyle(fontSize: 14.sp),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                isThreeLine: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResources() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.eventResources,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.event.resources.length,
            itemBuilder: (context, index) {
              final resource = widget.event.resources[index];
              return ListTile(
                title: Text(
                  resource.title,
                  style: TextStyle(fontSize: 16.sp),
                ),
                subtitle: Text(
                  resource.type,
                  style: TextStyle(fontSize: 14.sp),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.open_in_new, size: 20.w),
                  onPressed: () => _launchUrl(resource.url),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (_isOrganizer) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement edit event
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppStrings.eventEdit,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isParticipant) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _leaveEvent(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppStrings.eventLeave,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isFull ? null : () => _joinEvent(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  _isFull ? AppStrings.eventFull : AppStrings.eventJoin,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinEvent() async {
    try {
      await _eventService.joinEvent(widget.event.id, _auth.currentUser!.uid);
      Get.snackbar(
        AppStrings.successTitle,
        AppStrings.successEventJoin,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _leaveEvent() async {
    try {
      await _eventService.leaveEvent(widget.event.id, _auth.currentUser!.uid);
      Get.snackbar(
        AppStrings.successTitle,
        AppStrings.successEventLeave,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _getDirections() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.event.location.latitude},${widget.event.location.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar(
        'Error',
        AppStrings.errorUrlOpen + url,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar(
        'Error',
        AppStrings.errorUrlOpen + url,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
