import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:surfy_mobile_app/domain/contact/recent_sent_contacts.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/save_transaction.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/service/blockchain/handlers/send_token_handler.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/confirm/sending_confirm_view.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:vibration/vibration.dart';

class SendingConfirmViewModel {
  late SendingConfirmView view;

  final SendP2pToken _sendP2pTokenUseCase = Get.find();
  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetWalletAddress _getWalletAddress = Get.find();
  final SaveTransaction _saveTransactionUseCase = Get.find();
  final KeyService _keyService = Get.find();
  final SettingsPreference _preference = Get.find();
  final RecentSentContacts _recentSentContactsUseCase = Get.find();

  final Rx<BigInt> observableGas = BigInt.zero.obs;
  final Rx<Token> observableGasToken = Rx(Token.ETHEREUM);
  final RxDouble observableTokenPrice = 0.0.obs;
  final RxDouble observableGasTokenPrice = 0.0.obs;
  final RxDouble observableFiat = 0.0.obs;
  final Rx<CurrencyType> observableCurrencyType = Rx(CurrencyType.usd);
  final RxString observableSenderAddress = "".obs;

  final sessionTime = DateTime.now().millisecondsSinceEpoch;

  void setView(SendingConfirmView view) {
    this.view = view;
  }

  Future<void> init(Token token,
      Blockchain blockchain,
      String receiver,
      BigInt amount
  ) async {
    view.startLoading();
    try {
      observableCurrencyType.value = _preference.userCurrencyType.value;

      final senderAddress = await _getWalletAddress.getAddress(blockchain);
      observableSenderAddress.value = senderAddress;

      final gas = await _sendP2pTokenUseCase.estimateGas(token, blockchain, receiver, amount);
      observableGas.value = gas;

      final gasToken = blockchains[blockchain]?.feeCoin ?? Token.ETHEREUM;
      observableGasToken.value = gasToken;

      final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(token, _preference.userCurrencyType.value);
      observableTokenPrice.value = tokenPrice?.price ?? 0;

      observableFiat.value = cryptoToFiat(token, amount, tokenPrice?.price ?? 0.0, _preference.userCurrencyType.value);

      final gasTokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(observableGasToken.value, _preference.userCurrencyType.value);
      observableGasTokenPrice.value = gasTokenPrice?.price ?? 0;

      final feeCoin = blockchains[blockchain]?.feeCoin;
      if (feeCoin == null) {
        throw Exception();
      }
      observableGasToken.value = feeCoin;
    } catch (e) {
      // observableGas.value = BigInt.zero;
      view.onError("$e");
    }
    view.finishLoading();
  }

  Future<String> generateTransferJob(Token token,
      Blockchain blockchain,
      String sender,
      String receiver,
      BigInt amount, {
        double? fiat,
        CurrencyType? currencyType,
        String? memo,
      }) {
    return _sendP2pTokenUseCase.send(token, blockchain, sender, receiver, amount, memo).then((response) async {
      _saveTransactionUseCase.run(
        type: TransactionType.transfer,
        transactionHash: response.transactionHash,
        senderUserId: await _keyService.getKeyHash(),
        senderAddress: sender,
        receiverAddress: receiver,
        amount: amount,
        token: token,
        blockchain: blockchain,
        fiat: fiat,
        currencyType: currencyType,
        tokenPrice: observableTokenPrice.value,
        tokenPriceCurrencyType: observableCurrencyType.value,
      );

      _recentSentContactsUseCase.put(blockchain, receiver, memo);

      return response.transactionHash;
    });
  }
}