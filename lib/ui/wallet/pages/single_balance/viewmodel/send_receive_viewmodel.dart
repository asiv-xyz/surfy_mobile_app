import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/single_balance/send_receive_view.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class SingleBalanceViewModel {
  late SingleBalanceView view;

  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetWalletAddress _getWalletAddress = Get.find();
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();

  final RxString observableAddress = "".obs;
  final Rx<BigInt> observableCryptoBalance = BigInt.zero.obs;
  final RxDouble observableTokenPrice = 0.0.obs;

  void setView(SingleBalanceView view) {
    this.view = view;
  }

  Future<void> init(Token token, Blockchain blockchain, CurrencyType currency) async {
    view.startLoading();
    final address = await _getWalletAddress.getAddress(blockchain);
    final cryptoBalance = await _getWalletBalancesUseCase.getBalance(token, blockchain, address);
    final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(token, currency);

    observableAddress.value = address;
    observableCryptoBalance.value = cryptoBalance;
    observableTokenPrice.value = tokenPrice?.price ?? 0;
    view.finishLoading();
  }
}