
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AppConfigController extends GetxController{

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxBool changes = true.obs;
  bool chatPage = false;
  bool biblePage = false;
  bool bookPage = false;
  bool dailyBreadPage = false;
  bool donatePage = false;
  bool newsPage = false;

  getConfig(){
    CollectionReference addFunctionality = FirebaseFirestore.instance.collection('app-functionality');
    addFunctionality.snapshots().listen((event) {
      print(":::: event -- ${event.toString()}");
      print(":::: event -- ${event.docs.length}");
      print(":::: event -- ${event.docs.first.data()}");
      Map appConfig = event.docs.first.data() as Map;
      chatPage = appConfig['Chat'];
      biblePage = appConfig['Bible'];
      bookPage = appConfig['Books'];
      dailyBreadPage = appConfig['DailyBread'];
      donatePage = appConfig['Donate'];
      newsPage = appConfig['News'];
      changes.toggle();
    });
    addFunctionality.doc().snapshots().listen((event) async {
      print(":::: event ${event.toString()}");
      print(":::: event ${event.data()}");
    });
  }
}