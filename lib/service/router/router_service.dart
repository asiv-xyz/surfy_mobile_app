import 'package:go_router/go_router.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class RouterService {
  RouterService({required this.router});
  final GoRouter router;

  Future<void> checkLoginAndGo(String path, List<String> pathParameters) async {
    try {
      await Web3AuthFlutter.getUserInfo();
      switch (path) {
        case "payment":
          router.go("/payment/${pathParameters[1]}");
        default:
          router.go("/$path");
      }
    } catch (e) {
      if (e.toString().contains('No user found')) {
        logger.i('Not logged in, route to login page');
        router.go("/login");
      }
    }

  }

  Future<void> checkLoginAndPush(String path, List<String> pathParameters) async {
    try {
      await Web3AuthFlutter.getUserInfo();
      switch (path) {
        case "payment":
          router.push("/payment/${pathParameters[0]}");
        default:
          router.push("/$path");
      }
    } catch (e) {
      if (e.toString().contains('No user found')) {
        logger.i('Not logged in, route to login page');
        router.go("/login");
      }
    }
  }

}