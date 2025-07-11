/*
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:geolocator/geolocator.dart';

class YandexMapService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<YandexMapController?> mapController = Rx<YandexMapController?>(null);
  final Rx<Position?> currentLocation = Rx<Position?>(null);
  final RxList<MapObject> mapObjects = <MapObject>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  //Harita
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

      // Harita kontrolcüsünü başlatma YandexMap widget'ı içinde yapılacak
      // Aşağıdaki satırları kaldırın:
      // mapController.value = await YandexMapController.create(
      //   mapId: MapObjectId('main_map'),
      //   initialCameraPosition: CameraPosition(
      //     target: Point(
      //       latitude: currentLocation.value!.latitude,
      //       longitude: currentLocation.value!.longitude,
      //     ),
      //     zoom: 15,
      //   ),
      // );

      // Harita nesnelerini temizle
      mapObjects.clear();

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
      final userMarker = PlacemarkMapObject(
        mapId: MapObjectId('user_location'),
        point: Point(
          latitude: currentLocation.value!.latitude,
          longitude: currentLocation.value!.longitude,
        ),
        onTap: (PlacemarkMapObject self, Point point) =>
            onMarkerTap('user_location'),
        direction: 0,
        isDraggable: false,
        opacity: 1,
        isVisible: true,
        text: PlacemarkText(
          text: 'Konumunuz',
          style: PlacemarkTextStyle(
            color: Colors.blue,
            size: 12,
            outlineColor: Colors.white,
          ),
        ),
      );
      mapObjects.add(userMarker);
    }
  }

  // Yakındaki yerleri yükle
  Future<void> loadNearbyPlaces() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (currentLocation.value == null) return;

      // Firestore'dan yakındaki yerleri getir
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
          addEventMarker(event);
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
          addCoWorkingSpaceMarker(space);
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
          addTechCafeMarker(cafe);
        }
      }
    } catch (e) {
      errorMessage.value = 'Yakındaki yerler yüklenirken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Event marker'ı ekle
  void addEventMarker(Map<String, dynamic> event) {
    final marker = PlacemarkMapObject(
      mapId: MapObjectId('event_${event['id']}'),
      point: Point(
        latitude: (event['coordinates'] as GeoPoint).latitude,
        longitude: (event['coordinates'] as GeoPoint).longitude,
      ),
      onTap: (PlacemarkMapObject self, Point point) =>
          onMarkerTap('event_${event['id']}'),
      direction: 0,
      isDraggable: false,
      opacity: 1,
      isVisible: true,
      text: PlacemarkText(
        text: event['title'],
        style: PlacemarkTextStyle(
          color: Colors.red,
          size: 12,
          outlineColor: Colors.white,
        ),
      ),
    );
    mapObjects.add(marker);
  }

  // Co-working Space marker'ı ekle
  void addCoWorkingSpaceMarker(Map<String, dynamic> space) {
    final marker = PlacemarkMapObject(
      mapId: MapObjectId('space_${space['id']}'),
      point: Point(
        latitude: (space['coordinates'] as GeoPoint).latitude,
        longitude: (space['coordinates'] as GeoPoint).longitude,
      ),
      onTap: (PlacemarkMapObject self, Point point) =>
          onMarkerTap('space_${space['id']}'),
      direction: 0,
      isDraggable: false,
      opacity: 1,
      isVisible: true,
      text: PlacemarkText(
        text: space['name'],
        style: PlacemarkTextStyle(
          color: Colors.green,
          size: 12,
          outlineColor: Colors.white,
        ),
      ),
    );
    mapObjects.add(marker);
  }

  // Tech Cafe marker'ı ekle
  void addTechCafeMarker(Map<String, dynamic> cafe) {
    final marker = PlacemarkMapObject(
      mapId: MapObjectId('cafe_${cafe['id']}'),
      point: Point(
        latitude: (cafe['coordinates'] as GeoPoint).latitude,
        longitude: (cafe['coordinates'] as GeoPoint).longitude,
      ),
      onTap: (PlacemarkMapObject self, Point point) =>
          onMarkerTap('cafe_${cafe['id']}'),
      direction: 0,
      isDraggable: false,
      opacity: 1,
      isVisible: true,
      text: PlacemarkText(
        text: cafe['name'],
        style: PlacemarkTextStyle(
          color: Colors.orange,
          size: 12,
          outlineColor: Colors.white,
        ),
      ),
    );
    mapObjects.add(marker);
  }

  // Marker'a tıklandığında
  void onMarkerTap(String markerId) async {
    try {
      final parts = markerId.split('_');
      if (parts.length != 2) return;

      final type = parts[0];
      final id = parts[1];

      // Detay sayfasını göster
      switch (type) {
        case 'event':
          final doc = await _firestore.collection('tech_events').doc(id).get();
          if (doc.exists) {
            showEventDetails(doc.data()!);
          }
          break;
        case 'space':
          final doc =
              await _firestore.collection('coworking_spaces').doc(id).get();
          if (doc.exists) {
            showCoWorkingSpaceDetails(doc.data()!);
          }
          break;
        case 'cafe':
          final doc = await _firestore.collection('tech_cafes').doc(id).get();
          if (doc.exists) {
            showTechCafeDetails(doc.data()!);
          }
          break;
      }
    } catch (e) {
      errorMessage.value = 'Detaylar gösterilirken hata: $e';
    }
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
    mapObjects.clear();
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
*/
