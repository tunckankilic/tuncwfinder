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
  Future<void> onInit() async {
    super.onInit();
    await getFavoriteListKeys();
    ever(isFavoriteSentClicked, (_) => getFavoriteListKeys());
  }

  Future<void> getFavoriteListKeys() async {
    try {
      isLoading.value = true;
      favoritesList.clear(); // Listeyi temizle

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
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFavoriteList(bool isSent) {
    if (isFavoriteSentClicked.value != isSent) {
      isFavoriteSentClicked.value = isSent;
      getFavoriteListKeys(); // Direkt olarak veriyi yenile
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

  // void toggleFavoriteList(bool isSent) {
  //   if (isFavoriteSentClicked.value != isSent) {
  //     isFavoriteSentClicked.value = isSent;
  //     favoriteSentList.clear();
  //     favoriteReceivedList.clear();
  //     favoritesList.clear();
  //     getFavoriteListKeys();
  //   }
  // }
}
