import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:tuncforwork/theme/app_theme.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncforwork/views/screens/auth/pages/forgot_password.dart';
import 'package:tuncforwork/views/screens/auth/pages/register_screen.dart';
import 'package:tuncforwork/widgets/modern_widgets.dart';

class LoginScreen extends GetView<AuthController> {
  static const routeName = "/login";
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context),
          tablet: _buildTabletLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            _buildHeader(false),
            const SizedBox(height: 40),
            _buildLoginForm(false),
            const SizedBox(height: 24),
            _buildSocialLogin(false),
            const SizedBox(height: 24),
            _buildLinks(false),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Sol taraf - Logo ve bilgi
        Expanded(
          child: Container(
            color: AppTheme.primarySwatch.shade50,
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 32),
                Text(
                  AppStrings.welcome,
                  style: AppTheme.textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.loginNow,
                  style: AppTheme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        // Sağ taraf - Login formu
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLoginForm(true),
                  const SizedBox(height: 32),
                  _buildSocialLogin(true),
                  const SizedBox(height: 32),
                  _buildLinks(true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Column(
      children: [
        Image.asset(
          'assets/logo.png',
          width: isTablet ? 180 : 120,
          height: isTablet ? 180 : 120,
        ),
        const SizedBox(height: 24),
        FadeAnimation(
          child: Text(
            AppStrings.welcome,
            style: AppTheme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        FadeAnimation(
          child: Text(
            AppStrings.loginNow,
            style: AppTheme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isTablet) {
    return ModernCard(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.emailController,
            decoration: AppTheme.inputDecoration.copyWith(
              labelText: AppStrings.email,
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Obx(() => TextField(
                controller: controller.passwordController,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: AppStrings.password,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obsPass.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        controller.obsPass.value = !controller.obsPass.value,
                  ),
                ),
                obscureText: controller.obsPass.value,
              )),
          const SizedBox(height: 24),
          _buildTermsAndConditions(isTablet),
          const SizedBox(height: 24),
          Obx(() => ModernButton(
                text: AppStrings.login,
                onPressed: () async {
                  controller.isLoading.value = true;
                  await controller.login();
                  controller.isLoading.value = false;
                },
                isLoading: controller.isLoading.value,
              )),
        ],
      ),
    );
  }

  Widget _buildSocialLogin(bool isTablet) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: AppTheme.textTheme.bodyMedium,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        ModernButton(
          text: 'Continue with Google',
          onPressed: () => controller.handleSocialLogin(SocialLoginType.google),
          isOutlined: true,
        ),
        if (Platform.isIOS) ...[
          const SizedBox(height: 16),
          ModernButton(
            text: 'Continue with Apple',
            onPressed: () =>
                controller.handleSocialLogin(SocialLoginType.apple),
            isOutlined: true,
          ),
        ],
      ],
    );
  }

  Widget _buildLinks(bool isTablet) {
    return Column(
      children: [
        TextButton(
          onPressed: () => Get.toNamed(ForgotPasswordScreen.routeName),
          child: Text(
            AppStrings.forgotPassword,
            style: AppTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.primarySwatch,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.dontHaveAccount,
              style: AppTheme.textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () => Get.toNamed(RegistrationScreen.routeName),
              child: Text(
                AppStrings.createHere,
                style: AppTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primarySwatch,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions(bool isTablet) {
    return GetBuilder<AuthController>(
      builder: (controller) => Column(
        children: [
          CheckboxListTile(
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${AppStrings.iAgree} ',
                    style: AppTheme.textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: AppStrings.termsAndConditions,
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primarySwatch,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _showTermsAndConditions(),
                  ),
                  TextSpan(
                    text: ' ' + AppStrings.and + ' ',
                    style: AppTheme.textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: AppStrings.privacyPolicy,
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primarySwatch,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _showPrivacyPolicy(),
                  ),
                ],
              ),
            ),
            value: controller.termsAccepted.value,
            onChanged: (value) {
              if (value == true) {
                _showTermsAndConditions();
              } else {
                controller.updateTermsAcceptance(false);
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    final isTablet = Get.width >= 600;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ModernCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.termsAndConditions,
                style: AppTheme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: Get.height * 0.6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    controller.eula,
                    style: AppTheme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ModernButton(
                    text: 'Close',
                    onPressed: () {
                      controller.updateTermsAcceptance(false);
                      Get.back();
                    },
                    isOutlined: true,
                  ),
                  const SizedBox(width: 16),
                  ModernButton(
                    text: 'Accept',
                    onPressed: () {
                      Get.back();
                      _showPrivacyPolicy();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showPrivacyPolicy() {
    final isTablet = Get.width >= 600;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ModernCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.privacyPolicy,
                style: AppTheme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: Get.height * 0.6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    controller.privacyPolicy,
                    style: AppTheme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ModernButton(
                    text: 'Close',
                    onPressed: () {
                      controller.updateTermsAcceptance(false);
                      Get.back();
                    },
                    isOutlined: true,
                  ),
                  const SizedBox(width: 16),
                  ModernButton(
                    text: 'Accept',
                    onPressed: () {
                      controller.updateTermsAcceptance(true);
                      Get.back();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
