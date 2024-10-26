import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = "/splash";
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // 3 saniye sonra ana sayfaya yönlendir
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed('/login'); // Ana sayfa route'unuzu buraya ekleyin
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Arka plan rengini tercihlerinize göre değiştirin
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: FadeTransition(
                opacity: _animation,
                child: Image.asset(
                  'assets/logo.png',
                  width: 200.w,
                  height: 200.h,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            FadeTransition(
              opacity: _animation,
              child: Text(
                'TuncWFinder',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .blue, // Yazı rengini tercihlerinize göre değiştirin
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
