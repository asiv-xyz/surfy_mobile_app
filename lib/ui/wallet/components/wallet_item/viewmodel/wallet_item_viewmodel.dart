import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';

class WalletItemViewModel {

  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final Calculator _calculator = Get.find();

  Future<void> init() async {

  }
}