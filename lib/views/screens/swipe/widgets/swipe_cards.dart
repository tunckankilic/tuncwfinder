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

  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: _dragAlignment.y < -0.2
            ? const Alignment(0, -1)
            : _dragAlignment.x > 0.2
                ? const Alignment(1, 0)
                : const Alignment(-1, 0),
      ),
    );

    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation).then((_) {
      if (_dragAlignment.x > 0.2) {
        widget.onSwipeRight(_currentProfile!);
      } else if (_dragAlignment.x < -0.2) {
        widget.onSwipeLeft(_currentProfile!);
      } else if (_dragAlignment.y < -0.2) {
        widget.onSwipeUp(_currentProfile!);
      }
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
    if (widget.profiles.isNotEmpty) {
      _currentProfile = widget.profiles[0];
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
          child: GestureDetector(
            onLongPress: () {
              if (_currentProfile != null) {
                Get.find<SwipeController>().showReportDialog(_currentProfile!);
              }
            },
            onPanDown: (details) {
              _controller.stop();
            },
            onPanUpdate: (details) {
              setState(() {
                _dragAlignment += Alignment(
                  details.delta.dx / (constraints.maxWidth / 2),
                  details.delta.dy / (constraints.maxHeight / 2),
                );
              });
            },
            onPanEnd: (details) {
              _runAnimation(details.velocity.pixelsPerSecond, size);
            },
            child: SwipeCardContent(
              dragAlignment: _dragAlignment,
              currentProfile: _currentProfile,
              isTablet: isTablet,
              constraints: constraints,
            ),
          ),
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
        Image.network(
          person.imageProfile ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.error, size: 48)),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
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
          if (person.linkedInUrl?.isNotEmpty ?? false)
            _buildSocialButton(
              'assets/linkedin.svg',
              () => controller.openLinkedInProfile(
                linkedInUsername: person.linkedInUrl!,
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
          if (person.githubUrl?.isNotEmpty ?? false)
            _buildSocialButton(
              'assets/github.svg',
              () => controller.openGitHubProfile(
                gitHubUsername: person.githubUrl!,
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
