import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncwfinder/service/service.dart';

class LslrController extends GetxController {
  RxBool isLikeSentClicked = true.obs;
  RxList<String> likeSentList = <String>[].obs;
  RxList<String> likeReceivedList = <String>[].obs;
  RxList likedList = [].obs;

  @override
  void onInit() {
    super.onInit();
    getLikedListKeys();
  }

  getLikedListKeys() async {
    if (isLikeSentClicked.value) {
      var likeSentDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId.toString())
          .collection("likeSent")
          .get();

      likeSentList.value = likeSentDocument.docs.map((doc) => doc.id).toList();
      getKeysDataFromUsersCollection(likeSentList);
    } else {
      var likeReceivedDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId.toString())
          .collection("likeReceived")
          .get();

      likeReceivedList.value =
          likeReceivedDocument.docs.map((doc) => doc.id).toList();
      getKeysDataFromUsersCollection(likeReceivedList);
    }
  }

  getKeysDataFromUsersCollection(RxList<String> keysList) async {
    var allUsersDocument =
        await FirebaseFirestore.instance.collection("users").get();

    likedList.value = allUsersDocument.docs
        .where((doc) => keysList.contains(doc.data()["uid"]))
        .map((doc) => doc.data())
        .toList();
  }

  void toggleLikeList(bool isSent) {
    isLikeSentClicked.value = isSent;
    likeSentList.clear();
    likeReceivedList.clear();
    likedList.clear();
    getLikedListKeys();
  }
}
