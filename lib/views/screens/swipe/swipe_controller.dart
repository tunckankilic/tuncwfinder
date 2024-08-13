// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuncwfinder/service/global.dart';
import 'package:url_launcher/url_launcher.dart';

class SwipeController extends GetxController {
  RxList<dynamic> allUsersProfileList = [].obs;
  RxString senderName = "".obs;
  Rx<PageController> pageController =
      PageController(initialPage: 0, viewportFraction: 1).obs;
  RxList<String> ageRangeList = <String>[].obs;
  RxString chosenGender = "".obs;
  RxString chosenCountry = "".obs;
  RxString chosenAge = "".obs;

  @override
  void onInit() {
    super.onInit();
    readCurrentUserData();
    ageRange();
    getResults();
  }

  void readCurrentUserData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .get()
        .then((dataSnapshot) {
      senderName.value = dataSnapshot.data()!["name"].toString();
    });
  }

  void ageRange() {
    for (int i = 18; i < 65; i++) {
      ageRangeList.add(i.toString());
    }
  }

  void applyFilter() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: <Widget>[
            _buildDropdownListTile(
              icon: Icons.person,
              title: 'Gender',
              value: chosenGender,
              items: ['Male', 'Female', 'Other'],
            ),
            _buildDropdownListTile(
              icon: Icons.location_city,
              title: 'Country',
              value: chosenCountry,
              items: ['USA', 'UK', 'Canada', 'Australia'],
            ),
            _buildDropdownListTile(
              icon: Icons.cake,
              title: 'Minimum Age',
              value: chosenAge,
              items: ageRangeList,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                child: const Text('Apply Filter'),
                onPressed: () {
                  Get.back();
                  getResults();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownListTile({
    required IconData icon,
    required String title,
    required RxString value,
    required List<String> items,
  }) {
    return Obx(() => ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: DropdownButton<String>(
            value: value.value.isEmpty ? null : value.value,
            hint: Text('Select $title'),
            onChanged: (String? newValue) {
              if (newValue != null) {
                value.value = newValue;
              }
            },
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ));
  }

  startChattingInWhatsApp(
      {required String receiverPhoneNumber,
      required BuildContext context}) async {
    var androidUrl =
        "whatsapp://send?phone=$receiverPhoneNumber&text=Hi, I found your profile on dating app.";
    var iosUrl =
        "https://wa.me/$receiverPhoneNumber?text=${Uri.parse('Hi, I found your profile on dating app.')}";

    try {
      if (Platform.isIOS) {
        await launchUrl((Uri.parse(iosUrl)));
      } else {
        await launchUrl((Uri.parse(androidUrl)));
      }
    } on Exception {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Whatsapp Not Found"),
              content: const Text("WhatsApp is not installed."),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          });
    }
  }

  void openLinkedInProfile(
      {required String linkedInUsername, required BuildContext context}) async {
    var url = "https://www.linkedin.com/in/$linkedInUsername";

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("LinkedIn Error"),
              content: const Text("Could not open LinkedIn profile."),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          });
    }
  }

  void openInstagramProfile(
      {required String instagramUsername,
      required BuildContext context}) async {
    var instagramUrl = "instagram://user?username=$instagramUsername";
    var webUrl = "https://www.instagram.com/$instagramUsername";

    try {
      if (await canLaunchUrl(Uri.parse(instagramUrl))) {
        await launchUrl(Uri.parse(instagramUrl),
            mode: LaunchMode.externalApplication);
      } else {
        // Eğer Instagram uygulaması yüklü değilse, web sayfasını aç
        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(Uri.parse(webUrl),
              mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $webUrl';
        }
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Instagram Error"),
              content: const Text("Could not open Instagram profile."),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          });
    }
  }

  void getResults() async {
    try {
      Query query = FirebaseFirestore.instance.collection("users");

      // Eşitlik filtreleri önce uygulanır
      if (chosenGender.value.isNotEmpty) {
        query = query.where("gender", isEqualTo: chosenGender.value);
      }
      if (chosenCountry.value.isNotEmpty) {
        query = query.where("country", isEqualTo: chosenCountry.value);
      }

      // Aralık filtresi en son uygulanır
      if (chosenAge.value.isNotEmpty) {
        int minAge = int.tryParse(chosenAge.value) ?? 0;
        query = query.where("age", isGreaterThanOrEqualTo: minAge);
      }

      // Sorgu sonuçlarını sınırla
      query = query.limit(50); // Örnek olarak 50 sonuç ile sınırlandırıldı

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        // Eğer sonuçlar boşsa, snackbar göster ve fonksiyondan çık
        Get.snackbar(
          'No Results',
          'No matches found for your search criteria.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      allUsersProfileList.value = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      Get.snackbar(
        'Error',
        'Failed to fetch results. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void viewSentAndViewReceived(
      {required String toUserId, required String senderName}) async {
    // View sent
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("viewSent")
        .doc(toUserId)
        .set({});

    // View received
    await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserId)
        .collection("viewReceived")
        .doc(currentUserId)
        .set({
      "name": senderName,
    });
  }

  void favoriteSentAndFavoriteReceived(
      {required String toUserID, required String senderName}) async {
    // Favorite sent
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("favoriteSent")
        .doc(toUserID)
        .set({});

    // Favorite received
    await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection("favoriteReceived")
        .doc(currentUserId)
        .set({
      "name": senderName,
    });
  }

  void likeSentAndLikeReceived(
      {required String toUserId, required String senderName}) async {
    // Like sent
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("likeSent")
        .doc(toUserId)
        .set({});

    // Like received
    await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserId)
        .collection("likeReceived")
        .doc(currentUserId)
        .set({
      "name": senderName,
    });
  }
}
