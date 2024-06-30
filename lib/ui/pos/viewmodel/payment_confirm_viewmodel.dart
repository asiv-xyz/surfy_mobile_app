import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/pos/payment_confirm_view.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:vibration/vibration.dart';

class PaymentConfirmViewModel {
  late PaymentConfirmView view;

  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetMerchants _getMerchantsUseCase = Get.find();
  final SendP2pToken _sendP2pTokenUseCase = Get.find();
  final GetWalletAddress _getWalletAddressUseCase = Get.find();
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final SettingsPreference _settingsPreference = Get.find();

  final Rx<Token> observableSelectedToken = Rx(Token.ETHEREUM);
  final Rx<Blockchain> observableSelectedBlockchain = Rx(Blockchain.ETHEREUM);
  final Rx<BigInt> observableGas = BigInt.zero.obs;
  final Rx<BigInt> observablePayCrypto = BigInt.zero.obs;
  final Rx<BigInt> observableUserBalance = BigInt.zero.obs;
  final RxDouble observableTokenPrice = 0.0.obs;
  final Rx<Merchant?> observableMerchant = Rx(null);

  final RxString observableSenderWallet = "".obs;
  final RxString observableReceiverWallet = "".obs;
  final RxString observableTransactionHash = "".obs;

  void setView(PaymentConfirmView view) {
    this.view = view;
  }

  Future<void> init(String storeId, double fiatAmount, CurrencyType currencyType) async {
    view.onLoading();

    final merchant = await _getMerchantsUseCase.getSingle(storeId);
    observableMerchant.value = merchant;

    final arg = getSupportedTokenAndNetworkList();
    final userBalances = await _getWalletBalancesUseCase.getBalancesByDesc(arg.toList(), _settingsPreference.userCurrencyType.value);
    await changePaymentMethod(userBalances[0].token, userBalances[0].blockchain, fiatAmount, currencyType);

    view.offLoading();
  }

  Future<void> changePaymentMethod(Token token, Blockchain blockchain, double fiatAmount, CurrencyType currencyType) async {
    view.onChangePaymentMethod();
    final tokenData = tokens[token];
    if (tokenData == null) {
      throw Exception();
    }

    observableSelectedToken.value = token;
    observableSelectedBlockchain.value = blockchain;

    final address = await _getWalletAddressUseCase.getAddress(blockchain);
    final balance = await _getWalletBalancesUseCase.getBalance(token, blockchain, address);
    final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(token, _settingsPreference.userCurrencyType.value);

    observableSenderWallet.value = address;
    observableTokenPrice.value = tokenPrice?.price ?? 0;
    observableUserBalance.value = balance;
    observablePayCrypto.value = BigInt.from(pow(10, tokenData.decimal) * fiatAmount / (tokenPrice?.price ?? 1.0));

    final networkCategory = blockchains[blockchain]?.category;
    final receivedWallet = observableMerchant.value?.wallets?.where((wallet) => wallet.walletCategory == networkCategory).first;
    final estimatedGas = await _sendP2pTokenUseCase.estimateGas(token, blockchain, receivedWallet?.walletAddress ?? "", observablePayCrypto.value);
    observableGas.value = estimatedGas;
    observableReceiverWallet.value = receivedWallet?.walletAddress ?? "";

    view.offChangePaymentMethod();
  }

  Future<void> processPayment(Token token, Blockchain blockchain, String sender, String receiver, BigInt cryptoAmount) async {
    try {
      Vibration.vibrate(duration: 100);
      view.onStartPayment();
      final response = await _sendP2pTokenUseCase.send(token, blockchain, sender, receiver, cryptoAmount);
      observableTransactionHash.value = response.transactionHash;
    } catch (e) {
      view.onError("$e");
    }

    view.onFinishPayment();
  }
}