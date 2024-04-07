import 'package:connectivity_plus/connectivity_plus.dart';

class Utility {
  static Future<bool> isNetworkConnected() async {
    Connectivity connectivity = Connectivity();
    List<ConnectivityResult> result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
