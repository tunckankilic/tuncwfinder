import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';

class SwipeCards extends StatefulWidget {
  final List<Person> profiles;
  final Function(Person) onSwipeLeft;
  final Function(Person) onSwipeRight;
  final Function(Person) onSwipeUp;

  const SwipeCards({
    super.key,
    required this.profiles,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
  });

  @override
  _SwipeCardsState createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<SwipeCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Alignment _dragAlignment = Alignment.center;
  late Animation<Alignment> _animation;
  Person? _currentProfile;
  final SwipeController _swipeController = Get.find<SwipeController>();

  void _runAnimation(Offset pixelsPerSecond, Size size) {
    // Swipe yönünü belirle
    String swipeDirection = '';
    if (_dragAlignment.x > 0.2) {
      swipeDirection = 'right';
    } else if (_dragAlignment.x < -0.2) {
      swipeDirection = 'left';
    } else if (_dragAlignment.y < -0.2) {
      swipeDirection = 'up';
    } else {
      // Swipe yeterli değilse kartı geri getir
      _animation = _controller.drive(
        AlignmentTween(
          begin: _dragAlignment,
          end: Alignment.center,
        ),
      );
      _controller.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 30, stiffness: 1, damping: 1),
          0,
          1,
          0,
        ),
      );
      return;
    }

    // Swipe animasyonu - daha hızlı ve etkili
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: swipeDirection == 'up'
            ? const Alignment(0, -2.0)
            : swipeDirection == 'right'
                ? const Alignment(2.0, 0)
                : const Alignment(-2.0, 0),
      ),
    );

    // Daha hızlı animasyon
    _controller
        .animateWith(
      SpringSimulation(
        const SpringDescription(mass: 30, stiffness: 1, damping: 1),
        0,
        1,
        0,
      ),
    )
        .then((_) {
      // Animasyon tamamlandığında callback'leri çağır
      if (_currentProfile != null) {
        if (swipeDirection == 'right') {
          widget.onSwipeRight(_currentProfile!);
        } else if (swipeDirection == 'left') {
          widget.onSwipeLeft(_currentProfile!);
        } else if (swipeDirection == 'up') {
          widget.onSwipeUp(_currentProfile!);
        }
      }
      // Animasyon sonrası kartı sıfırla
      setState(() {
        _dragAlignment = Alignment.center;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
    _updateCurrentProfile();
  }

  void _updateCurrentProfile() {
    if (widget.profiles.isNotEmpty) {
      setState(() {
        _currentProfile = widget.profiles[0];
      });
    }
  }

  @override
  void didUpdateWidget(SwipeCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Profil listesi güncellendiğinde mevcut profili güncelle
    if (widget.profiles != oldWidget.profiles) {
      _updateCurrentProfile();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final isTablet = size.shortestSide >= 600;

        return Center(
          child: Obx(() {
            // Batch işlem durumunu kontrol et
            if (_swipeController.isBatchProcessing.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('İşlemler işleniyor...'),
                  ],
                ),
              );
            }

            // Profil yoksa mesaj göster
            if (widget.profiles.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_dissatisfied,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Gösterilecek profil kalmadı',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Filtreleri değiştirip tekrar deneyin',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return GestureDetector(
              onLongPress: () {
                if (_currentProfile != null) {
                  _swipeController.showReportDialog(_currentProfile!);
                }
              },
              onPanDown: (details) {
                _controller.stop();
              },
              onPanUpdate: (details) {
                if (_currentProfile != null) {
                  setState(() {
                    _dragAlignment += Alignment(
                      details.delta.dx / (constraints.maxWidth / 2),
                      details.delta.dy / (constraints.maxHeight / 2),
                    );
                  });
                }
              },
              onPanEnd: (details) {
                if (_currentProfile != null) {
                  _runAnimation(details.velocity.pixelsPerSecond, size);
                }
              },
              child: SwipeCardContent(
                dragAlignment: _dragAlignment,
                currentProfile: _currentProfile,
                isTablet: isTablet,
                constraints: constraints,
              ),
            );
          }),
        );
      },
    );
  }
}

class SwipeCardContent extends StatelessWidget {
  final Alignment dragAlignment;
  final Person? currentProfile;
  final bool isTablet;
  final BoxConstraints constraints;

  const SwipeCardContent({
    super.key,
    required this.dragAlignment,
    required this.currentProfile,
    required this.isTablet,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    if (currentProfile == null) return const SizedBox.shrink();

    final cardWidth =
        isTablet ? constraints.maxWidth * 0.7 : constraints.maxWidth * 0.9;
    final cardHeight =
        isTablet ? constraints.maxHeight * 0.8 : constraints.maxHeight * 0.7;

    return Align(
      alignment: dragAlignment,
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16.0 : 12.0),
        ),
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isTablet ? 16.0 : 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildProfileImage(currentProfile!),
                ),
                _buildProfileInfo(context, currentProfile!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(Person person) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () {
            if (person.uid != null) {
              Get.find<SwipeController>().navigateToProfile(person.uid!);
            }
          },
          child: Image.network(
            person.imageProfile ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.error, size: 48)),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        Positioned(
          bottom: isTablet ? 20 : 10,
          right: isTablet ? 20 : 10,
          child: ResponsiveSocialButtons(
            person: person,
            isTablet: isTablet,
          ),
        ),
        // Swipe yönü göstergesi
        Positioned(
          top: isTablet ? 20 : 10,
          left: isTablet ? 20 : 10,
          child: _buildSwipeIndicator(),
        ),
      ],
    );
  }

  Widget _buildSwipeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.thumb_down, color: Colors.red, size: 16),
          SizedBox(width: 4),
          Text(
            'Sola',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(width: 8),
          Icon(Icons.thumb_up, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text(
            'Sağa',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(width: 8),
          Icon(Icons.favorite, color: Colors.pink, size: 16),
          SizedBox(width: 4),
          Text(
            'Yukarı',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, Person person) {
    final theme = Theme.of(context);
    final padding = isTablet ? 16.0 : 8.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            person.name ?? '',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 28 : 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${person.age ?? ''} • ${person.city ?? ''}',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          _buildInfoChips(person),
          // Kariyer bilgileri ekle
          if (person.profession?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            _buildCareerInfo(person),
          ],
        ],
      ),
    );
  }

  Widget _buildCareerInfo(Person person) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.work, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              person.profession ?? '',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChips(Person person) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (person.profession?.isNotEmpty ?? false)
          _buildChip(person.profession!),
        if (person.religion?.isNotEmpty ?? false) _buildChip(person.religion!),
        if (person.country?.isNotEmpty ?? false) _buildChip(person.country!),
        if (person.ethnicity?.isNotEmpty ?? false)
          _buildChip(person.ethnicity!),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: isTablet ? 14 : 12),
      ),
      backgroundColor: Colors.grey[200],
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12.0 : 8.0,
        vertical: isTablet ? 8.0 : 4.0,
      ),
    );
  }
}

class ResponsiveSocialButtons extends GetView<SwipeController> {
  final Person person;
  final bool isTablet;

  const ResponsiveSocialButtons({
    super.key,
    required this.person,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12.0 : 8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(isTablet ? 30 : 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (person.instagramUrl?.isNotEmpty ?? false)
            _buildSocialButton(
              'assets/instagram.svg',
              () => controller.openInstagramProfile(
                instagramUsername: person.instagramUrl!,
                context: context,
              ),
            ),
          if (person.phoneNo?.isNotEmpty ?? false)
            _buildSocialButton(
              'assets/whatsapp.svg',
              () => controller.startChattingInWhatsApp(
                receiverPhoneNumber: person.phoneNo!,
                context: context,
              ),
            ),
          _buildIgnoreButton(
            () => controller.blockUser(person.uid!),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String asset, VoidCallback onTap) {
    final buttonSize = isTablet ? 50.0 : 40.0;
    final iconPadding = isTablet ? 10.0 : 8.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 6.0 : 4.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(iconPadding),
          child: SvgPicture.asset(
            asset,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildIgnoreButton(VoidCallback onTap) {
    final buttonSize = isTablet ? 50.0 : 40.0;
    final iconPadding = isTablet ? 10.0 : 8.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 6.0 : 4.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(iconPadding),
          child: Icon(
            Icons.delete_forever,
            color: Colors.red[900],
          ),
        ),
      ),
    );
  }
}
