import 'package:flutter/material.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';

class FPScreen extends GetView<AuthController> {
  static const routeName = "/forgotpass";
  const FPScreen({Key? key}) : super(key: key);

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
                  _buildFPSendButton(isTablet),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildHeader(bool isTablet) {
  //   return Text(
  //     "Welcome to TuncForWork",
  //     style: ElegantTheme.textTheme.headlineMedium?.copyWith(
  //       color: ElegantTheme.primaryColor,
  //       fontWeight: FontWeight.bold,
  //       fontSize: isTablet ? 32.0 : 24.0,
  //     ),
  //     textAlign: TextAlign.center,
  //   );
  // }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      decoration: BoxDecoration(
        color: ElegantTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios),
                iconSize: isTablet ? 28.0 : 24.0,
                padding: EdgeInsets.all(isTablet ? 12.0 : 8.0),
              ),
              Text(
                "Forget Password?",
                style: ElegantTheme.textTheme.headlineMedium?.copyWith(
                  color: ElegantTheme.primaryColor,
                  fontSize: isTablet ? 32.0 : 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 15.0 : 10.0),
        ],
      ),
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
      "Enter mail and send link for recovering the access",
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

  Widget _buildFPSendButton(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 80.0 : 70.0,
      child: Obx(() => ElevatedButton(
            onPressed: () async {
              controller.isLoading.value = true;
              await controller.fpSend();
              controller.isLoading.value = false;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ElegantTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12.0 : 10.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 20.0 : 15.0,
              ),
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    height: isTablet ? 28.0 : 24.0,
                    width: isTablet ? 28.0 : 24.0,
                    child: const CircularProgressIndicator(
                      color: ElegantTheme.backgroundColor,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    "Send Recovery Email",
                    style: ElegantTheme.textTheme.labelLarge?.copyWith(
                      fontSize: isTablet ? 20.0 : 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          )),
    );
  }
}
