import 'package:flutter/material.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncforwork/views/screens/auth/pages/forgot_password.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class LoginScreen extends GetView<AuthController> {
  static const routeName = "/login";
  const LoginScreen({Key? key}) : super(key: key);

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

  Widget _buildLoginButton(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          height: isTablet ? 60.0 : 50.0,
          child: Obx(() => ElevatedButton(
                onPressed: () async {
                  controller.isLoading.value = true;
                  await controller.login();
                  controller.isLoading.value = false;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElegantTheme.primaryColor,
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
                          color: ElegantTheme.backgroundColor,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        "Login",
                        style: ElegantTheme.textTheme.labelLarge?.copyWith(
                          fontSize: isTablet ? 18.0 : 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )),
        ),
        TextButton(
          onPressed: () => Get.toNamed(FPScreen.routeName),
          child: Text(
            "Did you forget your password?",
            style: ElegantTheme.textTheme.labelLarge?.copyWith(
              fontSize: isTablet ? 20.0 : 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

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
            fontSize: isTablet ? 16.0 : 14.0,
          ),
        ),
        SizedBox(width: isTablet ? 15.0 : 10.0),
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
}
