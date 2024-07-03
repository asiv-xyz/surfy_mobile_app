import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/payment/payment_view.dart';
import 'package:surfy_mobile_app/ui/type/balance.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class PaymentViewModel {

  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetMerchants _getMerchantsUseCase = Get.find();
  final SettingsPreference _preference = Get.find();
  final Calculator _calculator = Get.find();

  final Rx<Token?> observableSelectedToken = Rx(null);
  final Rx<Blockchain?> observableSelectedBlockchain = Rx(null);
  final Rx<TokenPrice?> observableTokenPrice = Rx(null);
  final Rx<TokenPrice?> observableTokenPriceByMerchantCurrency = Rx(null);
  final RxString observableInputAmount = "0".obs;
  final Rx<List<FiatBalance>> observableUserBalanceList = Rx([]);

  final RxBool observableIsFiatInputMode = true.obs;
  final Rx<Merchant?> observableMerchant = Rx(null);

  late PaymentView _view;

  void setView(PaymentView view) {
    _view = view;
  }

  Future<void> init(String merchantId) async {
    try {
      _view.startLoading();

      final userBalances = await _getWalletBalancesUseCase.getBalancesByDesc(getSupportedTokenAndNetworkList(), _preference.userCurrencyType.value);
      observableUserBalanceList.value = userBalances;

      observableSelectedToken.value = userBalances[0].token;
      observableSelectedBlockchain.value = userBalances[0].blockchain;

      final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(userBalances[0].token, _preference.userCurrencyType.value);
      observableTokenPrice.value = tokenPrice;

      final merchant = await _getMerchantsUseCase.getSingle(merchantId);
      observableMerchant.value = merchant;

      final tokenPriceByMerchant = await _getTokenPriceUseCase.getSingleTokenPrice(userBalances[0].token, findCurrencyTypeByName(merchant?.currency ?? ""));
      observableTokenPriceByMerchantCurrency.value = tokenPriceByMerchant;
    } catch (e) {
      _view.onError("$e");
    } finally {
      _view.finishLoading();
    }
  }

  Future<void> changePaymentMethod(Token token, Blockchain blockchain) async {
    try {
      _view.startLoading();
      observableSelectedToken.value = token;
      observableSelectedBlockchain.value = blockchain;
      observableTokenPrice.value = await _getTokenPriceUseCase.getSingleTokenPrice(token, _preference.userCurrencyType.value);

      final tokenPriceByMerchant = await _getTokenPriceUseCase.getSingleTokenPrice(token, findCurrencyTypeByName(observableMerchant.value?.currency ?? ""));
      observableTokenPriceByMerchantCurrency.value = tokenPriceByMerchant;
    } catch (e) {
      _view.onError("$e");
    } finally {
      _view.finishLoading();
    }
  }

  Future<void> processPayment(Token token, Blockchain blockchain) async {

  }

  double getFiat() {
    if (observableIsFiatInputMode.isTrue) {
      return observableInputAmount.value.toDouble();
    } else {
      return _calculator.cryptoAmountToFiatV2(
          observableInputAmount.value.toDouble(),
          observableTokenPrice.value?.price ?? 0);
    }
  }

  FiatBalance getSelectedTokenBalance() {
    return observableUserBalanceList.value.where((balance) =>
      balance.token == observableSelectedToken.value && balance.blockchain == observableSelectedBlockchain.value).first;
  }

  double getMayPaidAmount() {
    if (observableIsFiatInputMode.isTrue) {
      return fiatToCrypto(observableInputAmount.value.toDouble(), observableTokenPriceByMerchantCurrency.value?.price ?? 0);
    } else {
      return observableInputAmount.value.toDouble();
    }
  }
}