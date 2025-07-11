import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/widgets/modern_widgets.dart';

class ModernSwipeCards extends StatefulWidget {
  final List<Person> profiles;
  final Function(Person) onSwipeLeft;
  final Function(Person) onSwipeRight;
  final Function(Person) onSwipeUp;
  final Function(Person)? onTap;

  const ModernSwipeCards({
    Key? key,
    required this.profiles,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
    this.onTap,
  }) : super(key: key);

  @override
  State<ModernSwipeCards> createState() => _ModernSwipeCardsState();
}

class _ModernSwipeCardsState extends State<ModernSwipeCards>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  int _currentIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _swipeCard(SwipeDirection direction) {
    if (_isAnimating || _currentIndex >= widget.profiles.length) return;

    _isAnimating = true;
    final person = widget.profiles[_currentIndex];

    switch (direction) {
      case SwipeDirection.left:
        _slideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1.0, 0.0),
        ).animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeOut));
        widget.onSwipeLeft(person);
        break;
      case SwipeDirection.right:
        _slideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(1.0, 0.0),
        ).animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeOut));
        widget.onSwipeRight(person);
        break;
      case SwipeDirection.up:
        _slideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -1.0),
        ).animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeOut));
        widget.onSwipeUp(person);
        break;
    }

    _animationController.forward().then((_) {
      setState(() {
        _currentIndex++;
        _isAnimating = false;
      });
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profiles.isEmpty || _currentIndex >= widget.profiles.length) {
      return ModernEmptyState(
        icon: Icons.sentiment_dissatisfied,
        title: 'Gösterilecek profil kalmadı',
        subtitle: 'Filtreleri değiştirip tekrar deneyin',
        actionText: 'Yenile',
        onActionPressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      );
    }

    final currentProfile = widget.profiles[_currentIndex];
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: Transform.scale(
                    scale: _animation.value,
                    child: _buildProfileCard(currentProfile, theme),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 24.h),
        _buildActionButtons(),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildProfileCard(Person person, ThemeData theme) {
    return Container(
      width: 0.9.sw,
      height: 0.7.sh,
      child: ModernCard(
        onTap: widget.onTap != null ? () => widget.onTap!(person) : null,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Profile Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(person.imageProfile ?? ''),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Handle image error
                    },
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            person.name ?? 'İsimsiz',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (person.profession != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              person.profession!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Profile Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (person.profileHeading != null) ...[
                      Text(
                        'Hakkında',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        person.profileHeading!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 16.h),
                    ],
                    if (person.skills != null && person.skills!.isNotEmpty) ...[
                      Text(
                        'Yetenekler',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: person.skills!.take(5).map((skill) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              skill.name ?? 'Bilinmeyen',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Dislike Button
        _buildActionButton(
          icon: Icons.close,
          color: Colors.red,
          onPressed: () => _swipeCard(SwipeDirection.left),
        ),
        // Super Like Button
        _buildActionButton(
          icon: Icons.favorite,
          color: Colors.purple,
          onPressed: () => _swipeCard(SwipeDirection.up),
        ),
        // Like Button
        _buildActionButton(
          icon: Icons.favorite_border,
          color: Colors.green,
          onPressed: () => _swipeCard(SwipeDirection.right),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24.w),
        onPressed: onPressed,
      ),
    );
  }
}

enum SwipeDirection { left, right, up }
