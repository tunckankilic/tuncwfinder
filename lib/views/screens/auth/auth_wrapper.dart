import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/views/screens/auth/auth_service.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: AuthService().checkUserBanStatus(snapshot.data!.uid),
            builder: (context, banSnapshot) {
              if (banSnapshot.hasData && banSnapshot.data == true) {
                return BannedUserScreen();
              }

              if (banSnapshot.hasData && banSnapshot.data == false) {
                return HomeScreen();
              }

              return LoadingScreen();
            },
          );
        }
        return LoginScreen();
      },
    );
  }
}

class BannedUserScreen extends StatelessWidget {
  const BannedUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.gavel,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                'Account Suspended',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Your account has been suspended due to multiple community guidelines violations.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Please check your email for more information about this decision.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Add your brand colors here
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(isTablet),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
}
