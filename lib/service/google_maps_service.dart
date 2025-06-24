import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapsService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final Rx<Position?> currentLocation = Rx<Position?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Harita başlatma
  Future<void> initializeMap() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Konum izinlerini kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage.value = 'Konum izinleri reddedildi';
          return;
        }
      }

      // Mevcut konumu al
      currentLocation.value = await Geolocator.getCurrentPosition();

      // Harita nesnelerini temizle
      markers.clear();

      // Kullanıcı konumunu haritaya ekle
      addUserLocationMarker();

      // Yakındaki yerleri yükle
      await loadNearbyPlaces();
    } catch (e) {
      errorMessage.value = 'Harita başlatılırken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Kullanıcı konumunu haritaya ekle
  void addUserLocationMarker() {
    if (currentLocation.value != null) {
      final marker = Marker(
        markerId: MarkerId('user_location'),
        position: LatLng(
          currentLocation.value!.latitude,
          currentLocation.value!.longitude,
        ),
        infoWindow: InfoWindow(title: 'Konumunuz'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      markers.add(marker);
    }
  }

  // Yakındaki yerleri yükle
  Future<void> loadNearbyPlaces() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (currentLocation.value == null) return;

      final userLocation = GeoPoint(
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
      );

      // Tech Eventleri yükle
      final events = await _firestore
          .collection('tech_events')
          .where('date', isGreaterThan: Timestamp.now())
          .get();

      for (var doc in events.docs) {
        final event = doc.data();
        final eventLocation = event['coordinates'] as GeoPoint;

        // Mesafe hesapla
        double distance = calculateDistance(
          userLocation,
          eventLocation,
        );

        // 10km içindeki eventleri göster
        if (distance <= 10) {
          addEventMarker(event, doc.id);
        }
      }

      // Co-working Space'leri yükle
      final spaces = await _firestore.collection('coworking_spaces').get();
      for (var doc in spaces.docs) {
        final space = doc.data();
        final spaceLocation = space['coordinates'] as GeoPoint;

        double distance = calculateDistance(
          userLocation,
          spaceLocation,
        );

        if (distance <= 10) {
          addCoWorkingSpaceMarker(space, doc.id);
        }
      }

      // Tech Cafe'leri yükle
      final cafes = await _firestore.collection('tech_cafes').get();
      for (var doc in cafes.docs) {
        final cafe = doc.data();
        final cafeLocation = cafe['coordinates'] as GeoPoint;

        double distance = calculateDistance(
          userLocation,
          cafeLocation,
        );

        if (distance <= 10) {
          addTechCafeMarker(cafe, doc.id);
        }
      }
    } catch (e) {
      errorMessage.value = 'Yakındaki yerler yüklenirken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Event marker'ı ekle
  void addEventMarker(Map<String, dynamic> event, String id) {
    final marker = Marker(
      markerId: MarkerId('event_$id'),
      position: LatLng(
        (event['coordinates'] as GeoPoint).latitude,
        (event['coordinates'] as GeoPoint).longitude,
      ),
      infoWindow: InfoWindow(
        title: event['title'],
        snippet: 'Detaylar için tıklayın',
        onTap: () => showEventDetails(event),
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    markers.add(marker);
  }

  // Co-working Space marker'ı ekle
  void addCoWorkingSpaceMarker(Map<String, dynamic> space, String id) {
    final marker = Marker(
      markerId: MarkerId('space_$id'),
      position: LatLng(
        (space['coordinates'] as GeoPoint).latitude,
        (space['coordinates'] as GeoPoint).longitude,
      ),
      infoWindow: InfoWindow(
        title: space['name'],
        snippet: 'Detaylar için tıklayın',
        onTap: () => showCoWorkingSpaceDetails(space),
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    markers.add(marker);
  }

  // Tech Cafe marker'ı ekle
  void addTechCafeMarker(Map<String, dynamic> cafe, String id) {
    final marker = Marker(
      markerId: MarkerId('cafe_$id'),
      position: LatLng(
        (cafe['coordinates'] as GeoPoint).latitude,
        (cafe['coordinates'] as GeoPoint).longitude,
      ),
      infoWindow: InfoWindow(
        title: cafe['name'],
        snippet: 'Detaylar için tıklayın',
        onTap: () => showTechCafeDetails(cafe),
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );
    markers.add(marker);
  }

  // Event detaylarını göster
  void showEventDetails(Map<String, dynamic> event) {
    Get.dialog(
      AlertDialog(
        title: Text(event['title']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Tarih: ${DateTime.fromMillisecondsSinceEpoch(event['date']).toString()}'),
              Text('Konum: ${event['location']}'),
              Text(
                  'Katılımcılar: ${event['participants'].length}/${event['maxParticipants']}'),
              Text('Konular: ${event['topics'].join(', ')}'),
              Text('Açıklama: ${event['description']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Co-working Space detaylarını göster
  void showCoWorkingSpaceDetails(Map<String, dynamic> space) {
    Get.dialog(
      AlertDialog(
        title: Text(space['name']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adres: ${space['address']}'),
              Text('Puan: ${space['rating']}'),
              Text('Müsait Yer: ${space['availableSpots']}'),
              Text('Özellikler: ${space['amenities'].join(', ')}'),
              Text('Açıklama: ${space['description']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Tech Cafe detaylarını göster
  void showTechCafeDetails(Map<String, dynamic> cafe) {
    Get.dialog(
      AlertDialog(
        title: Text(cafe['name']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adres: ${cafe['address']}'),
              Text('Puan: ${cafe['rating']}'),
              Text('Müsait Koltuk: ${cafe['availableSeats']}'),
              Text('Özellikler: ${cafe['features'].join(', ')}'),
              Text('Açıklama: ${cafe['description']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // İki nokta arasındaki mesafeyi hesapla
  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371; // km

    double lat1 = point1.latitude * (pi / 180);
    double lat2 = point2.latitude * (pi / 180);
    double dLat = (point2.latitude - point1.latitude) * (pi / 180);
    double dLon = (point2.longitude - point1.longitude) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  // Haritayı temizle
  void clearMap() {
    markers.clear();
  }

  // Haritayı yenile
  Future<void> refreshMap() async {
    clearMap();
    await initializeMap();
  }

  @override
  void onClose() {
    mapController.value?.dispose();
    super.onClose();
  }
}
