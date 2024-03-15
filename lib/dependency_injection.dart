import 'package:get/get.dart';
import 'package:elzsi/Network/network.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
