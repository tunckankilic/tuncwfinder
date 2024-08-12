import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncdating/service/global.dart';

class FsfrController extends GetxController {
  RxBool isFavoriteSentClicked = true.obs;
  RxList<String> favoriteSentList = <String>[].obs;
  RxList<String> favoriteReceivedList = <String>[].obs;
  RxList favoritesList = [].obs;

  @override
  void onInit() {
    super.onInit();
    getFavoriteListKeys();
  }

  getFavoriteListKeys() async {
    if (isFavoriteSentClicked.value) {
      var favoriteSentDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId.toString())
          .collection("favoriteSent")
          .get();

      favoriteSentList.value =
          favoriteSentDocument.docs.map((doc) => doc.id).toList();
      getKeysDataFromUsersCollection(favoriteSentList);
    } else {
      var favoriteReceivedDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId.toString())
          .collection("favoriteReceived")
          .get();

      favoriteReceivedList.value =
          favoriteReceivedDocument.docs.map((doc) => doc.id).toList();
      getKeysDataFromUsersCollection(favoriteReceivedList);
    }
  }

  getKeysDataFromUsersCollection(RxList<String> keysList) async {
    var allUsersDocument =
        await FirebaseFirestore.instance.collection("users").get();

    favoritesList.value = allUsersDocument.docs
        .where((doc) => keysList.contains(doc.data()["uid"]))
        .map((doc) => doc.data())
        .toList();
  }

  void toggleFavoriteList(bool isSent) {
    isFavoriteSentClicked.value = isSent;
    favoriteSentList.clear();
    favoriteReceivedList.clear();
    favoritesList.clear();
    getFavoriteListKeys();
  }
}
