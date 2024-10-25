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
    Key? key,
    required this.profiles,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
  }) : super(key: key);

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
            ? Alignment(0, -1)
            : _dragAlignment.x > 0.2
                ? Alignment(1, 0)
                : Alignment(-1, 0),
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
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
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
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 2),
            details.delta.dy / (size.height / 2),
          );
        });
      },
      onPanEnd: (details) {
        _runAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Align(
        alignment: _dragAlignment,
        child: Card(
          child: SizedBox(
            width: size.width * 0.9,
            height: size.height * 0.7,
            child: _currentProfile != null
                ? _buildUserCard(_currentProfile!)
                : Container(),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Person person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                person.imageProfile ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: Icon(Icons.error)),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: SocialActionButtons(
                  instagramUsername: person.instagramUrl ?? '',
                  linkedInUsername: person.linkedInUrl ?? '',
                  whatsappNumber: person.phoneNo ?? '',
                  gitHub: person.githubUrl ?? '',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.name ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('${person.age ?? ''} • ${person.city ?? ''}'),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildInfoChip(person.profession ?? ''),
                  _buildInfoChip(person.religion ?? ''),
                  _buildInfoChip(person.country ?? ''),
                  _buildInfoChip(person.ethnicity ?? ''),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey[200],
    );
  }
}

class SocialActionButtons extends GetView<SwipeController> {
  final String instagramUsername;
  final String linkedInUsername;
  final String whatsappNumber;
  final String gitHub;

  const SocialActionButtons({
    Key? key,
    required this.instagramUsername,
    required this.linkedInUsername,
    required this.whatsappNumber,
    required this.gitHub,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (instagramUsername.isNotEmpty)
            _buildSocialButton(
                'assets/instagram.svg',
                () => controller.openInstagramProfile(
                    instagramUsername: instagramUsername, context: context)),
          if (linkedInUsername.isNotEmpty)
            _buildSocialButton(
                'assets/linkedin.svg',
                () => controller.openLinkedInProfile(
                    linkedInUsername: linkedInUsername, context: context)),
          if (whatsappNumber.isNotEmpty)
            _buildSocialButton(
                'assets/whatsapp.svg',
                () => controller.startChattingInWhatsApp(
                    receiverPhoneNumber: whatsappNumber, context: context)),
          if (gitHub.isNotEmpty)
            _buildSocialButton(
                'assets/github.svg',
                () => controller.openGitHubProfile(
                    gitHubUsername: gitHub, context: context)),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: SvgPicture.asset(
            asset,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
