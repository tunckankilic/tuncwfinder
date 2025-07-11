import 'package:flutter/material.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';
import 'package:tuncforwork/views/screens/swipe/widgets/button_cards.dart';

class SwipeScreen extends GetView<SwipeController> {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    Get.put(SwipeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keşfet'),
        actions: [
          // İstatistik butonu
          Obx(() {
            final stats = controller.getSwipeStatistics();
            return IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => _showStatisticsDialog(context, stats),
            );
          }),
          // Rapor butonu
          IconButton(
            icon: const Icon(Icons.report_problem),
            onPressed: () {
              if (controller.allUsersProfileList.isNotEmpty) {
                controller.showReportDialog(controller.allUsersProfileList[0]);
              }
            },
          ),
          // Filtre butonu
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => controller.applyFilter(isTablet),
          ),
          // Temizle butonu (opsiyonel)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showClearDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        final profiles = controller.allUsersProfileList;
        return profiles.isEmpty
            ? _buildEmptyState()
            : ButtonCards(
                profiles: profiles,
                onDislike: (Person person) {
                  controller.removeTopProfile();
                },
                onLike: (Person person) {
                  controller.likeSentAndLikeReceived(
                    toUserId: person.uid ?? '',
                    senderName: controller.senderName.value,
                  );
                  controller.removeTopProfile();
                },
                onFavorite: (Person person) {
                  controller.favoriteSentAndFavoriteReceived(
                    toUserID: person.uid ?? '',
                    senderName: controller.senderName.value,
                  );
                  controller.removeTopProfile();
                },
              );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Gösterilecek profil kalmadı',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Filtreleri değiştirip tekrar deneyin',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.getResults(),
            icon: const Icon(Icons.refresh),
            label: const Text('Yenile'),
          ),
        ],
      ),
    );
  }

  void _showStatisticsDialog(BuildContext context, Map<String, dynamic> stats) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Swipe İstatistikleri'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem(
                  'Toplam İşlenen', stats['totalProcessed'].toString()),
              _buildStatItem('Toplam Swipe', stats['totalSwiped'].toString()),
              _buildStatItem(
                  'Kalan Profil', stats['remainingProfiles'].toString()),
              _buildStatItem('İşlem Durumu',
                  stats['isBatchProcessing'] ? 'İşleniyor' : 'Hazır'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İşlenmiş Kullanıcıları Temizle'),
          content: const Text(
            'Bu işlem tüm işlenmiş kullanıcıları temizleyecek. '
            'Bu sayede aynı profiller tekrar görünebilir. '
            'Devam etmek istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.clearProcessedUsers();
                controller.getResults(); // Yeni profiller yükle
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Temizle'),
            ),
          ],
        );
      },
    );
  }
}
