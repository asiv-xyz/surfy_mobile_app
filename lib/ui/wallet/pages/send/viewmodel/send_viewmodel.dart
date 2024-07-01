import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/send/send_view.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class SendViewModel {
  late SendView view;

  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetWalletAddress _getWalletAddressUseCase = Get.find();
  final SendP2pToken _sendP2pTokenUseCase = Get.find();

  final RxString observableAddress = "".obs;
  final RxDouble observableTokenPrice = 0.0.obs;
  final Rx<BigInt> observableCryptoBalance = BigInt.zero.obs;

  RxString observableReceiverAddress = "".obs;
  RxString observableInputData = "0".obs;
  RxBool observableIsFiatInputMode = false.obs;

  void setView(SendView view) {
    this.view = view;
  }

  Future<void> init(Token token, Blockchain blockchain, CurrencyType currency) async {
    view.onLoading();

    final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(token, currency);
    final address = await _getWalletAddressUseCase.getAddress(blockchain);
    final balance = await _getWalletBalancesUseCase.getBalance(token, blockchain, address);

    observableAddress.value = address;
    observableTokenPrice.value = tokenPrice?.price ?? 0;
    observableCryptoBalance.value = balance;

    view.offLoading();
  }
}