import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncforwork/views/screens/auth/pages/forgot_password.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class LoginScreen extends GetView<AuthController> {
  static const routeName = "/login";
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: ElegantTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              // Tablet Max Width
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : double.infinity,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 40.0 : 20.0,
                vertical: isTablet ? 40.0 : 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isTablet ? 60.0 : 50.0),
                  _buildHeader(isTablet),
                  _buildLogo(isTablet),
                  _buildSubheader(isTablet),
                  SizedBox(height: isTablet ? 40.0 : 30.0),
                  _buildEmailField(isTablet),
                  SizedBox(height: isTablet ? 30.0 : 20.0),
                  _buildPasswordField(isTablet),
                  SizedBox(height: isTablet ? 40.0 : 30.0),
                  _buildLoginButton(isTablet),
                  SizedBox(height: isTablet ? 30.0 : 20.0),
                  _buildFPLink(isTablet),
                  SizedBox(height: isTablet ? 30.0 : 20.0),
                  _buildSignUpLink(isTablet),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Terms and Conditions Section
        _buildTermsAndConditions(isTablet),

        SizedBox(height: isTablet ? 20.0 : 15.0),

        // Login Button
        SizedBox(
          width: double.infinity,
          height: isTablet ? 60.0 : 50.0,
          child: Obx(() => ElevatedButton(
                onPressed: controller.termsAccepted.value
                    ? () async {
                        controller.isLoading.value = true;
                        await controller.login();
                        controller.isLoading.value = false;
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.termsAccepted.value
                      ? ElegantTheme.primaryColor
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 15.0 : 10.0,
                  ),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: isTablet ? 32.0 : 28.0,
                        width: isTablet ? 32.0 : 28.0,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 18.0 : 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions(bool isTablet) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox ve EULA/Privacy Policy linkleri
            CheckboxListTile(
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(
                        fontSize: isTablet ? 16.0 : 14.0,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        fontSize: isTablet ? 16.0 : 14.0,
                        color: ElegantTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showTermsAndConditions(),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(
                        fontSize: isTablet ? 16.0 : 14.0,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        fontSize: isTablet ? 16.0 : 14.0,
                        color: ElegantTheme.primaryColor,
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
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16.0 : 12.0,
                vertical: isTablet ? 8.0 : 4.0,
              ),
            ),

            // Kullanıcı bilgilendirme kutusu
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? 16.0 : 12.0,
                vertical: isTablet ? 8.0 : 4.0,
              ),
              padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: isTablet ? 24.0 : 20.0,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Important Information',
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Your data is protected under our privacy policy\n'
                    '• You can review terms anytime in app settings\n'
                    '• You must be 13 or older to use this app',
                    style: TextStyle(
                      fontSize: isTablet ? 14.0 : 12.0,
                      color: Colors.blue.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Text(
      "Welcome to TuncForWork",
      style: ElegantTheme.textTheme.headlineMedium?.copyWith(
        color: ElegantTheme.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: isTablet ? 32.0 : 24.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLogo(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 40.0 : 30.0,
      ),
      child: Image.asset(
        'assets/logo.png',
        width: isTablet ? 250.0 : 200.0,
        height: isTablet ? 250.0 : 200.0,
      ),
    );
  }

  Widget _buildSubheader(bool isTablet) {
    return Text(
      "Login now\nTo find your best match",
      textAlign: TextAlign.center,
      style: ElegantTheme.textTheme.titleLarge?.copyWith(
        color: ElegantTheme.secondaryColor,
        fontSize: isTablet ? 22.0 : 18.0,
      ),
    );
  }

  Widget _buildEmailField(bool isTablet) {
    return TextField(
      controller: controller.emailController,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(
          Icons.email,
          color: ElegantTheme.primaryColor,
          size: isTablet ? 24.0 : 20.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
          borderSide: const BorderSide(color: ElegantTheme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
          borderSide: BorderSide(
            color: ElegantTheme.primaryColor,
            width: isTablet ? 2.5 : 2.0,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isTablet ? 20.0 : 15.0,
          horizontal: isTablet ? 20.0 : 15.0,
        ),
      ),
      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
    );
  }

  Widget _buildPasswordField(bool isTablet) {
    return TextField(
      controller: controller.passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: Icon(
          Icons.lock,
          color: ElegantTheme.primaryColor,
          size: isTablet ? 24.0 : 20.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
          borderSide: const BorderSide(color: ElegantTheme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
          borderSide: BorderSide(
            color: ElegantTheme.primaryColor,
            width: isTablet ? 2.5 : 2.0,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isTablet ? 20.0 : 15.0,
          horizontal: isTablet ? 20.0 : 15.0,
        ),
      ),
      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
    );
  }

  // Widget _buildLoginButton(bool isTablet) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       SizedBox(
  //         width: double.infinity,
  //         height: isTablet ? 60.0 : 50.0,
  //         child: Obx(() => ElevatedButton(
  //               onPressed: () async {
  //                 controller.isLoading.value = true;
  //                 await controller.login();
  //                 controller.isLoading.value = false;
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: ElegantTheme.primaryColor,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
  //                 ),
  //                 padding: EdgeInsets.symmetric(
  //                   vertical: isTablet ? 15.0 : 10.0,
  //                 ),
  //               ),
  //               child: controller.isLoading.value
  //                   ? SizedBox(
  //                       height: isTablet ? 32.0 : 28.0,
  //                       width: isTablet ? 32.0 : 28.0,
  //                       child: const CircularProgressIndicator(
  //                         color: ElegantTheme.backgroundColor,
  //                         strokeWidth: 3,
  //                       ),
  //                     )
  //                   : Text(
  //                       "Login",
  //                       style: ElegantTheme.textTheme.labelLarge?.copyWith(
  //                         fontSize: isTablet ? 18.0 : 14.0,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //             )),
  //       ),
  //       TextButton(
  //         onPressed: () => Get.toNamed(FPScreen.routeName),
  //         child: Text(
  //           "Did you forget your password?",
  //           style: ElegantTheme.textTheme.labelLarge?.copyWith(
  //             fontSize: isTablet ? 20.0 : 16.0,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSignUpLink(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: ElegantTheme.textTheme.bodyMedium?.copyWith(
            fontSize: isTablet ? 16.0 : 14.0,
          ),
        ),
        SizedBox(width: isTablet ? 15.0 : 10.0),
        TextButton(
          onPressed: () => Get.toNamed(RegistrationScreen.routeName),
          child: Text(
            "Create Here",
            style: ElegantTheme.textTheme.labelLarge?.copyWith(
              color: ElegantTheme.primaryColor,
              decoration: TextDecoration.underline,
              fontSize: isTablet ? 16.0 : 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFPLink(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Did you forget your password?",
          style: ElegantTheme.textTheme.bodyMedium?.copyWith(
            fontSize: isTablet ? 14.0 : 12.0,
          ),
        ),
        SizedBox(width: isTablet ? 13.0 : 8.0),
        TextButton(
          onPressed: () => Get.toNamed(FPScreen.routeName),
          child: Text(
            "Forget Password_",
            style: ElegantTheme.textTheme.labelLarge?.copyWith(
              color: ElegantTheme.primaryColor,
              decoration: TextDecoration.underline,
              fontSize: isTablet ? 16.0 : 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildTermsAndConditions(bool isTablet) {
  //   return GetBuilder<AuthController>(
  //     builder: (controller) {
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Ana Checkbox ve EULA linki
  //           CheckboxListTile(
  //             title: Text.rich(
  //               TextSpan(
  //                 children: [
  //                   TextSpan(
  //                     text: 'I accept the ',
  //                     style: TextStyle(
  //                       fontSize: isTablet ? 18.0 : 16.0,
  //                       color: Colors.black,
  //                     ),
  //                   ),
  //                   TextSpan(
  //                     text: 'Terms and Conditions',
  //                     style: TextStyle(
  //                       fontSize: isTablet ? 18.0 : 16.0,
  //                       color: ElegantTheme.primaryColor,
  //                       decoration: TextDecoration.underline,
  //                     ),
  //                     recognizer: TapGestureRecognizer()
  //                       ..onTap = () => _showTermsAndConditions(),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             value: controller.termsAccepted.value,
  //             onChanged: (value) {
  //               if (value == true) {
  //                 _showTermsAndConditions();
  //               } else {
  //                 controller.updateTermsAcceptance(false);
  //               }
  //             },
  //             controlAffinity: ListTileControlAffinity.leading,
  //             contentPadding: EdgeInsets.symmetric(
  //               horizontal: isTablet ? 20.0 : 16.0,
  //               vertical: isTablet ? 12.0 : 8.0,
  //             ),
  //           ),
  //           // Kullanıcı İçeriği Politikası Bildirimi
  //           Container(
  //             padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
  //             margin: EdgeInsets.symmetric(
  //               vertical: isTablet ? 16.0 : 12.0,
  //               horizontal: isTablet ? 20.0 : 16.0,
  //             ),
  //             decoration: BoxDecoration(
  //               color: Colors.red.shade50,
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: Colors.red.shade200),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Content Guidelines',
  //                   style: TextStyle(
  //                     fontSize: isTablet ? 18.0 : 16.0,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.red.shade900,
  //                   ),
  //                 ),
  //                 SizedBox(height: 8),
  //                 Text(
  //                   '• No offensive or inappropriate content\n'
  //                   '• No harassment or hate speech\n'
  //                   '• No sharing of personal information\n'
  //                   '• Reports are reviewed within 24 hours\n'
  //                   '• Violations result in account termination',
  //                   style: TextStyle(
  //                     fontSize: isTablet ? 16.0 : 14.0,
  //                     color: Colors.red.shade900,
  //                     height: 1.5,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           // Moderasyon Bildirimi
  //           Container(
  //             padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
  //             margin: EdgeInsets.symmetric(
  //               horizontal: isTablet ? 20.0 : 16.0,
  //             ),
  //             decoration: BoxDecoration(
  //               color: Colors.blue.shade50,
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: Colors.blue.shade200),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Content Moderation',
  //                   style: TextStyle(
  //                     fontSize: isTablet ? 18.0 : 16.0,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.blue.shade900,
  //                   ),
  //                 ),
  //                 SizedBox(height: 8),
  //                 Text(
  //                   '• All content is subject to moderation\n'
  //                   '• Report inappropriate content using 🚩\n'
  //                   '• Block abusive users using ⛔\n'
  //                   '• 24-hour moderation response time',
  //                   style: TextStyle(
  //                     fontSize: isTablet ? 16.0 : 14.0,
  //                     color: Colors.blue.shade900,
  //                     height: 1.5,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

// Widget tarafındaki dialog kodları
  void _showTermsAndConditions() {
    final isTablet = Get.width >= 600;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: isTablet ? Get.width * 0.7 : Get.width * 0.9,
          padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'End User License Agreement',
                style: TextStyle(
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: Get.height * (isTablet ? 0.7 : 0.6),
                child: SingleChildScrollView(
                  child: Text(
                    controller.eula,
                    style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 24.0 : 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.updateTermsAcceptance(false);
                      Get.back();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                    ),
                  ),
                  SizedBox(width: isTablet ? 24.0 : 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _showPrivacyPolicy();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32.0 : 24.0,
                        vertical: isTablet ? 16.0 : 12.0,
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                    ),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: isTablet ? Get.width * 0.7 : Get.width * 0.9,
          padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: Get.height * (isTablet ? 0.7 : 0.6),
                child: SingleChildScrollView(
                  child: Text(
                    controller.privacyPolicy,
                    style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 24.0 : 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.updateTermsAcceptance(false);
                      Get.back();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                    ),
                  ),
                  SizedBox(width: isTablet ? 24.0 : 16.0),
                  ElevatedButton(
                    onPressed: () {
                      controller.updateTermsAcceptance(true);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32.0 : 24.0,
                        vertical: isTablet ? 16.0 : 12.0,
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
                    ),
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
