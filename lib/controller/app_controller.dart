import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppController extends GetxController {
  RxBool isFirstScreen = false.obs;


  @override
  void onInit() {
    checkFirstScreen();
    super.onInit();
    print("AppController initialized");

  }

  Future<void> checkFirstScreen() async {
    print("Checking first screen...");
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool seen = pref.getBool('seen') ?? false;
    isFirstScreen.value = seen;
    update();
    print("isFirstScreen value: ${isFirstScreen.value}"); //true
  }
}