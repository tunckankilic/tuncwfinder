import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelper {
  static Future<void> setupFirebaseAuth() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Firebase Core için mock
    const channel = MethodChannel('plugins.flutter.io/firebase_core');
    channel.setMockMethodCallHandler((MethodCall call) async {
      if (call.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project-id',
            },
            'pluginConstants': {},
          }
        ];
      }
      if (call.method == 'Firebase#initializeApp') {
        return {
          'name': call.arguments['appName'],
          'options': call.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    });

    // Firebase Auth için mock
    const authChannel = MethodChannel('plugins.flutter.io/firebase_auth');
    authChannel.setMockMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'Auth#signInAnonymously':
          return {
            'user': {
              'uid': 'test-uid',
              'isAnonymous': true,
              'email': null,
              'displayName': null,
            }
          };
        default:
          return null;
      }
    });

    await Firebase.initializeApp();
  }
}
