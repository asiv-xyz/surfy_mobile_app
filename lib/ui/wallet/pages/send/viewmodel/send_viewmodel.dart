import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/send/send_view.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';

class SendViewModel {
  late SendView view;

  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetWalletAddress _getWalletAddressUseCase = Get.find();

  final Rx<TokenData?> observableTokenData = Rx(null);
  final RxString observableAddress = "".obs;
  final RxDouble observableTokenPrice = 0.0.obs;
  final Rx<BigInt> observableCryptoBalance = BigInt.zero.obs;

  RxString observableReceiverAddress = "".obs;
  RxString observableInputData = "0".obs;
  RxBool observableIsFiatInputMode = false.obs;

  void setView(SendView view) {
    this.view = view;
  }

  Future<void> init(Token token,
      Blockchain blockchain,
      CurrencyType currency,
  {
    String? defaultReceiverAddress,
    double? defaultReceiveAmount,
  }
  ) async {
    view.onLoading();
    if (tokens[token] == null) {
      throw Exception('Unsupported token: ${token.name}');
    }

    observableTokenData.value = tokens[token];

    final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(token, currency);
    final address = await _getWalletAddressUseCase.getAddress(blockchain);
    final balance = await _getWalletBalancesUseCase.getBalance(token, blockchain, address);

    if (defaultReceiverAddress != null) {
      observableReceiverAddress.value = defaultReceiverAddress;
    }

    if (defaultReceiveAmount != null) {
      observableInputData.value = defaultReceiveAmount.toString();
    }

    observableAddress.value = address;
    observableTokenPrice.value = tokenPrice?.price ?? 0;
    observableCryptoBalance.value = balance;

    view.offLoading();
  }

  bool canPay(Token token) {
    if (tokens[token] == null) {
      throw Exception('Unsupported token: ${token.name}');
    }

    if (observableIsFiatInputMode.isTrue) {
      final needToPayTokenAmount = fiatToCryptoBigInt(observableInputData.value.toDouble(), tokens[token]!, observableTokenPrice.value);
      return needToPayTokenAmount <= observableCryptoBalance.value;
    } else {
      final needToPayTokenAmount = cryptoDecimalToBigInt(tokens[token]!, observableInputData.value.toDouble());
      return needToPayTokenAmount <= observableCryptoBalance.value;
    }
  }
}