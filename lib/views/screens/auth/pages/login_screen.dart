import 'package:flutter/material.dart';
import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncwfinder/views/screens/screens.dart';

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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                _buildHeader(),
                _buildLogo(),
                _buildSubheader(),
                const SizedBox(height: 30),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 30),
                _buildLoginButton(),
                const SizedBox(height: 20),
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
      "Welcome to TuncWFinder",
      style: ElegantTheme.textTheme.headlineMedium?.copyWith(
        color: ElegantTheme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Image.asset(
        'assets/logo.png',
        width: 200,
        height: 200,
      ),
    );
  }

  Widget _buildSubheader() {
    return Text(
      "Login now\nTo find your best match",
      textAlign: TextAlign.center,
      style: ElegantTheme.textTheme.titleLarge?.copyWith(
        color: ElegantTheme.secondaryColor,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: controller.emailController,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: const Icon(Icons.email, color: ElegantTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ElegantTheme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: ElegantTheme.primaryColor, width: 2),
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
        prefixIcon: const Icon(Icons.lock, color: ElegantTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ElegantTheme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: ElegantTheme.primaryColor, width: 2),
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
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(
                    color: ElegantTheme.backgroundColor)
                : Text("Login", style: ElegantTheme.textTheme.labelLarge),
          )),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: ElegantTheme.textTheme.bodyMedium,
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () => Get.toNamed(RegistrationScreen.routeName),
          child: Text(
            "Create Here",
            style: ElegantTheme.textTheme.labelLarge?.copyWith(
              color: ElegantTheme.primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
