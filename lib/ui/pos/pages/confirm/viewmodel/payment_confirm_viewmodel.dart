import 'dart:math';

import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/save_transaction.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/pos/pages/confirm/payment_confirm_view.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:vibration/vibration.dart';

class PaymentConfirmViewModel {
  late PaymentConfirmView view;

  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetMerchants _getMerchantsUseCase = Get.find();
  final SendP2pToken _sendP2pTokenUseCase = Get.find();
  final GetWalletAddress _getWalletAddressUseCase = Get.find();
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final SettingsPreference _settingsPreference = Get.find();
  final SaveTransaction _saveTransactionUseCase = Get.find();
  final KeyService _keyService = Get.find();

  final Rx<Token> observableSelectedToken = Rx(Token.ETHEREUM);
  final Rx<Blockchain> observableSelectedBlockchain = Rx(Blockchain.ethereum);

  final Rx<BigInt> observableGas = BigInt.zero.obs;
  final Rx<BigInt> observablePayCrypto = BigInt.zero.obs;
  final Rx<BigInt> observableUserBalance = BigInt.zero.obs;

  final Rx<Map<CurrencyType, double>> observableTokenPrice = Rx({});

  final Rx<Merchant?> observableMerchant = Rx(null);
  final Rx<CurrencyType?> observableUserCurrencyType = Rx(null);

  final RxString observableSenderWallet = "".obs;
  final RxString observableReceiverWallet = "".obs;
  final RxString observableTransactionHash = "".obs;

  final RxBool observableCanPay = false.obs;

  void setView(PaymentConfirmView view) {
    this.view = view;
  }

  Future<void> init(String storeId, double fiatAmount, CurrencyType currencyType) async {
    try {
      view.onLoading();

      observableUserCurrencyType.value = _settingsPreference.userCurrencyType.value;

      final merchant = await _getMerchantsUseCase.getSingle(storeId);
      observableMerchant.value = merchant;

      final arg = getSupportedTokenAndNetworkList();
      final userBalances = await _getWalletBalancesUseCase.getBalancesByDesc(arg.toList(), _settingsPreference.userCurrencyType.value);
      await changePaymentMethod(userBalances[0].token, userBalances[0].blockchain, fiatAmount, currencyType);
    } catch (e) {
      view.onError("$e");
    } finally {
      view.offLoading();
    }
  }

  Future<void> changePaymentMethod(Token token, Blockchain blockchain, double fiatAmount, CurrencyType currencyType) async {
    try {
      view.onChangePaymentMethod();
      final tokenData = tokens[token];
      if (tokenData == null) {
        throw Exception();
      }

      observableSelectedToken.value = token;
      observableSelectedBlockchain.value = blockchain;

      final address = await _getWalletAddressUseCase.getAddress(blockchain);
      final balance = await _getWalletBalancesUseCase.getBalance(token, blockchain, address);

      var tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(token, currencyType);
      observableTokenPrice.value[currencyType] = tokenPrice?.price ?? 0;
      observablePayCrypto.value = BigInt.from(pow(10, tokenData.decimal) * fiatAmount / (tokenPrice?.price ?? 1.0));
      if (currencyType != _settingsPreference.userCurrencyType.value) {
        tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(token, _settingsPreference.userCurrencyType.value);
        observableTokenPrice.value[_settingsPreference.userCurrencyType.value] = tokenPrice?.price ?? 0;
      }

      observableSenderWallet.value = address;
      observableUserBalance.value = balance;

      final networkCategory = blockchains[blockchain]?.category;
      final receivedWallet = observableMerchant.value?.wallets?.where((wallet) => wallet.walletCategory == networkCategory).first;
      final estimatedGas = await _sendP2pTokenUseCase.estimateGas(token, blockchain, receivedWallet?.walletAddress ?? "", observablePayCrypto.value);
      observableGas.value = estimatedGas;
      observableReceiverWallet.value = receivedWallet?.walletAddress ?? "";

      await canPay(fiatAmount, currencyType);
    } catch (e) {
      view.onError("$e");
    } finally {
      view.offChangePaymentMethod();
    }
  }

  Future<void> canPay(double targetFiat, CurrencyType merchantCurrencyType) async {
    final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(observableSelectedToken.value, merchantCurrencyType);
    final userBalance = await _getWalletBalancesUseCase.getBalance(observableSelectedToken.value, observableSelectedBlockchain.value, observableSenderWallet.value);
    final fiat = cryptoToFiat(observableSelectedToken.value,
        userBalance, tokenPrice?.price ?? 0, merchantCurrencyType);
    observableCanPay.value = fiat > targetFiat;
  }

  Future<void> processPayment(
      String storeId,
      double fiat,
      CurrencyType paymentCurrencyType,
      Token token,
      Blockchain blockchain,
      String sender,
      String receiver,
      BigInt cryptoAmount) async {
    try {
      Vibration.vibrate(duration: 100);
      view.onStartPayment();
      final response = await _sendP2pTokenUseCase.send(token, blockchain, sender, receiver, cryptoAmount);
      await _saveTransactionUseCase.run(
          type: TransactionType.payment,
          transactionHash: response.transactionHash,
          senderUserId: await _keyService.getKeyHash(),
          senderAddress: sender,
          receiverAddress: receiver,
          amount: cryptoAmount,
          token: token,
          blockchain: blockchain,
          storeId: storeId,
          fiat: fiat,
          currencyType: paymentCurrencyType,
          tokenPrice: observableTokenPrice.value[_settingsPreference.userCurrencyType.value],
          tokenPriceCurrencyType: _settingsPreference.userCurrencyType.value,
      );
      observableTransactionHash.value = response.transactionHash;
    } catch (e) {
      rethrow;
    } finally {
      view.onFinishPayment();
    }
  }
}