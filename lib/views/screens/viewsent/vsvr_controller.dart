import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncwfinder/service/service.dart';

class VsvrController extends GetxController {
  RxBool isViewSentClicked = true.obs;
  RxList<String> viewSentList = <String>[].obs;
  RxList<String> viewReceivedList = <String>[].obs;
  RxList viewsList = [].obs;

  getViewsListKeys() async {
    if (isViewSentClicked.value) {
      var viewSentDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId.toString())
          .collection("viewSent")
          .get();

      viewSentList.value = viewSentDocument.docs.map((doc) => doc.id).toList();
      getKeysDataFromUsersCollection(viewSentList);
    } else {
      var viewReceivedDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId.toString())
          .collection("viewReceived")
          .get();

      viewReceivedList.value =
          viewReceivedDocument.docs.map((doc) => doc.id).toList();
      getKeysDataFromUsersCollection(viewReceivedList);
    }
  }

  getKeysDataFromUsersCollection(List<String> keysList) async {
    var allUsersDocument =
        await FirebaseFirestore.instance.collection("users").get();

    viewsList.value = allUsersDocument.docs
        .where((doc) => keysList.contains(doc.data()["uid"]))
        .map((doc) => doc.data())
        .toList();
  }
}
