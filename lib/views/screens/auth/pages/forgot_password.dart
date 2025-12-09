import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:tuncforwork/theme/app_theme.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncforwork/widgets/modern_widgets.dart';

class ForgotPasswordScreen extends GetView<AuthController> {
  static const routeName = "/forgot-password";
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.forgotPassword),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: isTablet ? 40.0 : 24.0),
                Text(
                  AppStrings.forgotPasswordTitle,
                  style: AppTheme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 24.0 : 16.0),
                Text(
                  AppStrings.forgotPasswordDescription,
                  style: AppTheme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 48.0 : 32.0),
                TextField(
                  controller: controller.emailController,
                  decoration: AppTheme.inputDecoration.copyWith(
                    labelText: AppStrings.email,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: isTablet ? 32.0 : 24.0),
                Obx(() => ModernButton(
                      text: AppStrings.sendPasswordResetLink,
                      onPressed: () => controller.resetPassword(
                        controller.emailController.text.trim(),
                      ),
                      isLoading: controller.isLoading.value,
                    )),
                SizedBox(height: isTablet ? 24.0 : 16.0),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    AppStrings.backToLogin,
                    style: AppTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.primarySwatch,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
