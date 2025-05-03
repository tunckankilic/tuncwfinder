import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:tuncforwork/service/yandex_map_service.dart';

class MapScreen extends StatelessWidget {
  final YandexMapService mapService = Get.put(YandexMapService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yakındaki Etkinlikler'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => mapService.refreshMap(),
          ),
        ],
      ),
      body: Obx(() {
        if (mapService.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (mapService.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(mapService.errorMessage.value),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => mapService.refreshMap(),
                  child: Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            YandexMap(
              onMapCreated: (YandexMapController controller) {
                mapService.mapController.value = controller;
                mapService.initializeMap();
              },
              mapObjects: mapService.mapObjects,
              onMapTap: (Point point) => print('Tapped map at $point'),
              onCameraPositionChanged: (CameraPosition position,
                  CameraUpdateReason reason, bool finished) {
                if (finished) {
                  print('Camera position changed to $position');
                }
              },
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Yakındaki Yerler',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem('Etkinlikler', Colors.red),
                          _buildLegendItem('Co-working', Colors.green),
                          _buildLegendItem('Tech Cafe', Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
