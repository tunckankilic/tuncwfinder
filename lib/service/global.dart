import 'package:firebase_auth/firebase_auth.dart';

String currentUserId = FirebaseAuth.instance.currentUser!.uid;
String fcmServerToken =
    "AAAA6QfKtmY:APA91bGh0qngvjT1gBgaWwtC6PVrufex3ShEIxbLib2i5_5xFM3GSnDasXhXWq3ilCnuhdnE785C_rozHYLa8JqPJ3bvZX7VuF0SuaIxhvomnyDkkpS2ZsPUMDNDVQ53owD_yy9fEZuX";
String? chosenAge;
String? chosenCountry;
String? chosenGender;
