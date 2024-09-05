import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/service/global.dart';

class FsfrController extends GetxController {
  RxBool isFavoriteSentClicked = true.obs;
  RxList<String> favoriteSentList = <String>[].obs;
  RxList<String> favoriteReceivedList = <String>[].obs;
  RxList favoritesList = [].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getFavoriteListKeys();
  }

  Future<void> getFavoriteListKeys() async {
    try {
      isLoading.value = true;
      if (isFavoriteSentClicked.value) {
        await _getFavoriteSent();
      } else {
        await _getFavoriteReceived();
      }
      await getKeysDataFromUsersCollection(isFavoriteSentClicked.value
          ? favoriteSentList
          : favoriteReceivedList);
    } catch (e) {
      print("Error in getFavoriteListKeys: $e");
      // Handle error (e.g., show a snackbar to the user)
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getFavoriteSent() async {
    var favoriteSentDocument = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId.toString())
        .collection("favoriteSent")
        .get();

    favoriteSentList.value =
        favoriteSentDocument.docs.map((doc) => doc.id).toList();
  }

  Future<void> _getFavoriteReceived() async {
    var favoriteReceivedDocument = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId.toString())
        .collection("favoriteReceived")
        .get();

    favoriteReceivedList.value =
        favoriteReceivedDocument.docs.map((doc) => doc.id).toList();
  }

  Future<void> getKeysDataFromUsersCollection(RxList<String> keysList) async {
    try {
      var allUsersDocument =
          await FirebaseFirestore.instance.collection("users").get();

      favoritesList.value = allUsersDocument.docs
          .where((doc) => keysList.contains(doc.data()["uid"]))
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print("Error in getKeysDataFromUsersCollection: $e");
      // Handle error
    }
  }

  void toggleFavoriteList(bool isSent) {
    if (isFavoriteSentClicked.value != isSent) {
      isFavoriteSentClicked.value = isSent;
      favoriteSentList.clear();
      favoriteReceivedList.clear();
      favoritesList.clear();
      getFavoriteListKeys();
    }
  }
}
