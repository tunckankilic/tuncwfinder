import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/service/service.dart';

class VsvrController extends GetxController {
  RxBool isViewSentClicked = true.obs;
  RxList<String> viewSentList = <String>[].obs;
  RxList<String> viewReceivedList = <String>[].obs;
  RxList viewsList = [].obs;

  void switchTab(bool isViewSent) {
    isViewSentClicked.value = isViewSent;
    viewSentList.clear();
    viewReceivedList.clear();
    viewsList.clear();
    getViewsListKeys();
  }

  Future<void> getViewsListKeys() async {
    if (isViewSentClicked.value) {
      var viewSentDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId.toString())
          .collection("viewSent")
          .get();

      viewSentList.value = viewSentDocument.docs.map((doc) => doc.id).toList();
      await getKeysDataFromUsersCollection(viewSentList);
    } else {
      var viewReceivedDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId.toString())
          .collection("viewReceived")
          .get();

      viewReceivedList.value =
          viewReceivedDocument.docs.map((doc) => doc.id).toList();
      await getKeysDataFromUsersCollection(viewReceivedList);
    }
  }

  Future<void> getKeysDataFromUsersCollection(List<String> keysList) async {
    var allUsersDocument =
        await FirebaseFirestore.instance.collection("users").get();

    viewsList.value = allUsersDocument.docs
        .where((doc) => keysList.contains(doc.data()["uid"]))
        .map((doc) => doc.data())
        .toList();
  }

  @override
  Future<void> onInit() async {
    await getViewsListKeys();
    super.onInit();
  }
}
