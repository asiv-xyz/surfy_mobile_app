import 'package:get/get.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class EventBus {
  static void notifyChangeCurrencyType(CurrencyType newCurrencyType) {
    TokenPriceRepository repository = Get.find();
    repository.forceUpdateAndGetTokenPrice(Token.values, newCurrencyType.name);
  }
}