import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class LoginScreen extends GetView<AuthController> {
  static const routeName = "/login";
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElegantTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),
                _buildHeader(),
                _buildLogo(),
                _buildSubheader(),
                SizedBox(height: 30.h),
                _buildEmailField(),
                SizedBox(height: 20.h),
                _buildPasswordField(),
                SizedBox(height: 30.h),
                _buildLoginButton(),
                SizedBox(height: 20.h),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      "Welcome to TuncForWork",
      style: ElegantTheme.textTheme.headlineMedium?.copyWith(
        color: ElegantTheme.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 24.sp,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Image.asset(
        'assets/logo.png',
        width: 200.w,
        height: 200.h,
      ),
    );
  }

  Widget _buildSubheader() {
    return Text(
      "Login now\nTo find your best match",
      textAlign: TextAlign.center,
      style: ElegantTheme.textTheme.titleLarge?.copyWith(
        color: ElegantTheme.secondaryColor,
        fontSize: 18.sp,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: controller.emailController,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon:
            Icon(Icons.email, color: ElegantTheme.primaryColor, size: 20.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: ElegantTheme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: ElegantTheme.primaryColor, width: 2.w),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: controller.passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon:
            Icon(Icons.lock, color: ElegantTheme.primaryColor, size: 20.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: ElegantTheme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: ElegantTheme.primaryColor, width: 2.w),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            onPressed: () async {
              controller.isLoading.value = true;
              await controller.login();
              controller.isLoading.value = false;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ElegantTheme.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(
                    color: ElegantTheme.backgroundColor)
                : Text("Login",
                    style: ElegantTheme.textTheme.labelLarge
                        ?.copyWith(fontSize: 16.sp)),
          )),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: ElegantTheme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
        ),
        SizedBox(width: 10.w),
        TextButton(
          onPressed: () => Get.toNamed(RegistrationScreen.routeName),
          child: Text(
            "Create Here",
            style: ElegantTheme.textTheme.labelLarge?.copyWith(
              color: ElegantTheme.primaryColor,
              decoration: TextDecoration.underline,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
