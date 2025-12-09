import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';

class ButtonCards extends StatefulWidget {
  final List<Person> profiles;
  final Function(Person) onDislike;
  final Function(Person) onLike;
  final Function(Person) onFavorite;

  const ButtonCards({
    super.key,
    required this.profiles,
    required this.onDislike,
    required this.onLike,
    required this.onFavorite,
  });

  @override
  ButtonCardsState createState() => ButtonCardsState();
}

class ButtonCardsState extends State<ButtonCards> {
  Person? _currentProfile;
  final SwipeController _swipeController = Get.find<SwipeController>();

  @override
  void initState() {
    super.initState();
    _updateCurrentProfile();
  }

  void _updateCurrentProfile() {
    if (widget.profiles.isNotEmpty) {
      setState(() {
        _currentProfile = widget.profiles[0];
      });
    } else {
      setState(() {
        _currentProfile = null;
      });
    }
  }

  @override
  void didUpdateWidget(ButtonCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Profil listesi değiştiğinde mevcut profili güncelle
    _updateCurrentProfile();
  }

  void _handleAction(Function(Person) action) {
    if (_currentProfile != null) {
      action(_currentProfile!);
      // Controller kartı kaldıracak, burada sadece UI'ı güncelle
      _updateCurrentProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return LayoutBuilder(
      builder: (context, constraints) {
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
                    Text(AppStrings.processingProfiles),
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
                      AppStrings.noProfilesLeft,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppStrings.changeFiltersAndTryAgain,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Kart alanı
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      if (_currentProfile != null) {
                        _swipeController.showReportDialog(_currentProfile!);
                      }
                    },
                    child: CardContent(
                      currentProfile: _currentProfile,
                      isTablet: isTablet,
                      constraints: constraints,
                    ),
                  ),
                ),
                // Buton alanı
                Container(
                  padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Dislike butonu
                      _buildActionButton(
                        icon: Icons.close,
                        color: Colors.red,
                        onPressed: () => _handleAction(widget.onDislike),
                        label: AppStrings.dislike,
                        isTablet: isTablet,
                      ),
                      // Like butonu
                      _buildActionButton(
                        icon: Icons.favorite,
                        color: Colors.green,
                        onPressed: () => _handleAction(widget.onLike),
                        label: AppStrings.like,
                        isTablet: isTablet,
                      ),
                      // Favorite butonu
                      _buildActionButton(
                        icon: Icons.star,
                        color: Colors.orange,
                        onPressed: () => _handleAction(widget.onFavorite),
                        label: AppStrings.favorite,
                        isTablet: isTablet,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String label,
    required bool isTablet,
  }) {
    final buttonSize = isTablet ? 80.0 : 60.0;
    final iconSize = isTablet ? 32.0 : 24.0;

    return Column(
      children: [
        Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class CardContent extends StatelessWidget {
  final Person? currentProfile;
  final bool isTablet;
  final BoxConstraints constraints;

  const CardContent({
    super.key,
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

    return Center(
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
      ],
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
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
        color: Colors.black.withValues(alpha: 0.5),
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
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
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
