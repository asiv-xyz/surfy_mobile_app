import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/pos/pages/select/select_payment_token_view.dart';
import 'package:surfy_mobile_app/ui/type/balance.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class SelectPaymentTokenViewModel {
  late SelectPaymentTokenView view;

  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetTokenPrice _getTokenPriceUseCase = Get.find();

  final Rx<List<FiatBalance>> observableBalanceList = Rx([]);
  final Rx<Map<Token, Map<CurrencyType, TokenPrice>>> observableTokenPrices = Rx({});

  void setView(SelectPaymentTokenView view) {
    this.view = view;
  }

  Future<void> init(CurrencyType currency) async {
    try {
      view.onLoading();
      List<Token> tokenList = Token.values;
      final tokenPriceList = await _getTokenPriceUseCase.getTokenPrice(tokenList, currency);
      observableTokenPrices.value = tokenPriceList;

      final supportedResources = getSupportedTokenAndNetworkList();
      final balances = await _getWalletBalancesUseCase.getBalancesByDesc(supportedResources, currency);
      observableBalanceList.value = balances;
    } catch (e) {
      view.onError("$e");
    } finally {
      view.offLoading();
    }
  }
}