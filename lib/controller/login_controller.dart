import 'package:get/get.dart';

class LoginController extends GetxController {
  RxBool validatedUsername = true.obs;
  RxBool validatedPassword = true.obs;
  RxBool isLoading = false.obs;

  void setValidatedUsername(bool value) {
    validatedUsername(value);
  }

  void setValidatedPassword(bool value) {
    validatedPassword(value);
  }

  void setLoading(bool value) {
    isLoading(value);
  }
}
