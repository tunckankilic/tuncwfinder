import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tuncforwork/service/google_maps_service.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MapScreen extends StatelessWidget {
  final GoogleMapsService mapService = Get.put(GoogleMapsService());

  MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.nearbyPlaces),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24.w),
            onPressed: () => mapService.refreshMap(),
          ),
        ],
      ),
      body: Obx(
        () => Stack(
          children: [
            if (mapService.currentLocation.value != null)
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    mapService.currentLocation.value!.latitude,
                    mapService.currentLocation.value!.longitude,
                  ),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: mapService.markers,
                onMapCreated: (GoogleMapController controller) {
                  mapService.mapController.value = controller;
                },
              )
            else
              Center(
                child: Text(
                  AppStrings.gettingLocation,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            if (mapService.isLoading.value)
              const Center(child: CircularProgressIndicator()),
            if (mapService.errorMessage.value.isNotEmpty)
              Center(
                child: Container(
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    mapService.errorMessage.value,
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
