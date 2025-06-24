import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/models/tech_event.dart';
import 'package:tuncforwork/service/tech_event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = Get.put(TechEventService());
  final _auth = FirebaseAuth.instance;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  EventType _selectedType = EventType.meetup;
  bool _isOnline = false;
  bool _isHybrid = false;
  String? _joinLink;
  List<String> _selectedTopics = [];
  List<String> _requirements = [];
  List<String> _speakers = [];
  LatLng? _selectedLocation;
  String? _selectedVenueId;
  String? _selectedVenueName;
  VenueType? _selectedVenueType;

  final List<String> _availableTopics = AppStrings.availableEventTopics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.createEventTitle),
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: AppStrings.createEventTitleField,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.errorEnterTitle;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: AppStrings.createEventDescription,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.errorEnterDescription;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    DropdownButtonFormField<EventType>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: AppStrings.createEventType,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                      items: EventType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.toString().split('.').last,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _maxParticipantsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: AppStrings.maxParticipants,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            style: TextStyle(fontSize: 16.sp),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.errorEnterParticipants;
                              }
                              final number = int.tryParse(value);
                              if (number == null || number <= 0) {
                                return AppStrings.errorInvalidNumber;
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16.w),
                        ElevatedButton(
                          onPressed: () async {
                            final number =
                                int.tryParse(_maxParticipantsController.text);
                            if (number != null && _selectedLocation != null) {
                              final venues = await _eventService.suggestVenues(
                                number,
                                _selectedLocation!,
                              );
                              _showVenueSuggestions(venues);
                            } else {
                              Get.snackbar(
                                'Error',
                                AppStrings.errorSelectLocationAndParticipants,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(
                            AppStrings.suggestVenue,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    ListTile(
                      title: Text(
                        AppStrings.onlineEvent,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      trailing: Switch(
                        value: _isOnline,
                        onChanged: (value) {
                          setState(() {
                            _isOnline = value;
                            if (!value) {
                              _isHybrid = false;
                            }
                          });
                        },
                      ),
                    ),
                    if (_isOnline) ...[
                      ListTile(
                        title: Text(
                          AppStrings.hybridEvent,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        trailing: Switch(
                          value: _isHybrid,
                          onChanged: (value) {
                            setState(() {
                              _isHybrid = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: AppStrings.joinLink,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          style: TextStyle(fontSize: 16.sp),
                          onChanged: (value) {
                            _joinLink = value;
                          },
                          validator: (value) {
                            if (_isOnline && (value == null || value.isEmpty)) {
                              return AppStrings.errorOnlineEventLink;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    Text(
                      AppStrings.eventTopicsList,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _availableTopics.map((topic) {
                        final isSelected = _selectedTopics.contains(topic);
                        return FilterChip(
                          label: Text(
                            topic,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTopics.add(topic);
                              } else {
                                _selectedTopics.remove(topic);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _createEvent,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        AppStrings.createEventButton,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_eventService.isLoading.value)
              Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showVenueSuggestions(List<Map<String, dynamic>> venues) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: venues.length,
          itemBuilder: (context, index) {
            final venue = venues[index];
            return ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              title: Text(
                venue['name'],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                venue['address'],
                style: TextStyle(fontSize: 14.sp),
              ),
              trailing: Text(
                AppStrings.venueCapacity.replaceAll(
                  '%d',
                  venue['capacity'].toString(),
                ),
                style: TextStyle(fontSize: 14.sp),
              ),
              onTap: () {
                setState(() {
                  _selectedVenueId = venue['id'];
                  _selectedVenueName = venue['name'];
                  _selectedVenueType = VenueType.values.firstWhere(
                    (type) => type.toString() == venue['type'],
                  );
                  _addressController.text = venue['address'];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final event = TechEvent(
          id: const Uuid().v4(),
          title: _titleController.text,
          description: _descriptionController.text,
          date: DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          ),
          location: GeoPoint(
            _selectedLocation!.latitude,
            _selectedLocation!.longitude,
          ),
          venueId: _selectedVenueId!,
          venueName: _selectedVenueName!,
          venueType: _selectedVenueType!,
          maxParticipants: int.parse(_maxParticipantsController.text),
          topics: _selectedTopics,
          requirements: _requirements,
          organizerId: _auth.currentUser!.uid,
          participants: [],
          type: _selectedType,
          speakers: _speakers,
          isOnline: _isOnline,
          isHybrid: _isHybrid,
          joinLink: _joinLink,
          sponsors: [],
          agenda: [],
          resources: [],
          address: _addressController.text,
          isPublished: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _eventService.createEvent(event);
        Get.back();
        Get.snackbar(
          'Success',
          AppStrings.eventCreatedSuccess,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          AppStrings.eventCreationError.replaceAll('%s', e.toString()),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
