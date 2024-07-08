import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:surfy_mobile_app/domain/qr/get_qr_controller.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/pos/pages/confirm/payment_confirm_view.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class RouterService {
  RouterService({required this.router});
  final GoRouter router;

  Future<void> checkLoginAndGoByUrl(BuildContext context, String uri) async {
    logger.i('checkLoginAndGoByUrl: $uri');
    Uri parsedUri = Uri.parse(uri);
    // print('path: ${parsedUri.path}');
    // final token = parsedUri.pathSegments[1];
    // final blockchain = parsedUri.pathSegments[2];
    // final address = parsedUri.pathSegments[3];
    // final amount = parsedUri.pathSegments[4].toDouble();
    checkAuthAndGo(context, parsedUri.path);
  }

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
    logger.i('checkLoginAndPush, path=$path, params=$pathParameters');
    final GetQRController _getQrController = Get.find();
    _getQrController.qrViewController.value?.pauseCamera();
    try {
      await Web3AuthFlutter.getUserInfo();
      switch (path) {
        case "payment":
          router.push("/payment/${pathParameters[1]}");
          break;
        case "send":
          // TODO : fix it!!!
          router.push("/wallet/${pathParameters[1]}/${pathParameters[2]}/send/${pathParameters[3]}/${pathParameters[4]}");
          break;
        case "pos":
          // surfy://com.riverbank.surfy_mobile_app/pos/payment/testStore/8/usd
          final storeId = pathParameters[2];
          final wantToReceiveAmount = pathParameters[3].toDouble();
          final receiveCurrency = findCurrencyTypeByName(pathParameters[4]);
          router.push("/pos/payment", extra: PaymentConfirmPageProps(storeId: storeId, receiveCurrency: receiveCurrency, wantToReceiveAmount: wantToReceiveAmount));
          break;
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