import 'package:firebase_auth/firebase_auth.dart';

String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
String fcmServerToken = "AIzaSyC7FQUiD1_JUJbKmGl3vU-kIL-ju52uD7A";
String? chosenAge;
String? chosenCountry;
String? chosenGender;
