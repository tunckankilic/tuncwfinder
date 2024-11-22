import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/service/service.dart';

class LslrController extends GetxController {
  RxBool isLikeSentClicked = true.obs;
  RxList<String> likeSentList = <String>[].obs;
  RxList<String> likeReceivedList = <String>[].obs;
  RxList likedList = [].obs;
  RxBool isLoading = true.obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    await getLikedListKeys();
    ever(isLikeSentClicked, (_) => getLikedListKeys());
  }

  Future<void> getLikedListKeys() async {
    try {
      isLoading.value = true;
      likedList.clear(); // Listeyi temizle

      if (isLikeSentClicked.value) {
        var likeSentDocument = await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserId.toString())
            .collection("likeSent")
            .get();

        likeSentList.value =
            likeSentDocument.docs.map((doc) => doc.id).toList();
        await getKeysDataFromUsersCollection(likeSentList);
      } else {
        var likeReceivedDocument = await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserId.toString())
            .collection("likeReceived")
            .get();

        likeReceivedList.value =
            likeReceivedDocument.docs.map((doc) => doc.id).toList();
        await getKeysDataFromUsersCollection(likeReceivedList);
      }
    } catch (e) {
      print("Error in getLikedListKeys: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleLikeList(bool isSent) {
    isLikeSentClicked.value = isSent;
    getLikedListKeys(); // Direkt olarak veriyi yenile
  }

  getKeysDataFromUsersCollection(RxList<String> keysList) async {
    var allUsersDocument =
        await FirebaseFirestore.instance.collection("users").get();

    likedList.value = allUsersDocument.docs
        .where((doc) => keysList.contains(doc.data()["uid"]))
        .map((doc) => doc.data())
        .toList();
  }

  // void toggleLikeList(bool isSent) {
  //   isLikeSentClicked.value = isSent;
  //   likeSentList.clear();
  //   likeReceivedList.clear();
  //   likedList.clear();
  //   getLikedListKeys();
  // }
}
