import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/save_transaction.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/confirm/sending_confirm_view.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:vibration/vibration.dart';

class SendingConfirmViewModel {
  late SendingConfirmView view;

  final SendP2pToken _sendP2pTokenUseCase = Get.find();
  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final SaveTransaction _saveTransactionUseCase = Get.find();
  final KeyService _keyService = Get.find();

  final Rx<BigInt> observableGas = BigInt.zero.obs;
  final Rx<Token> observableGasToken = Rx(Token.ETHEREUM);
  final RxDouble observableTokenPrice = 0.0.obs;
  final RxDouble observableGasTokenPrice = 0.0.obs;
  final RxDouble observableFiat = 0.0.obs;
  final Rx<CurrencyType> observableCurrencyType = Rx(CurrencyType.usd);

  final sessionTime = DateTime.now().millisecondsSinceEpoch;

  void setView(SendingConfirmView view) {
    this.view = view;
  }

  Future<void> init(Token token,
      Blockchain blockchain,
      String receiver,
      BigInt amount,
      double fiat,
      CurrencyType currencyType) async {
    view.startLoading();
    try {
      observableFiat.value = fiat;
      observableCurrencyType.value = currencyType;

      final gas = await _sendP2pTokenUseCase.estimateGas(token, blockchain, receiver, amount);
      observableGas.value = gas;

      final gasToken = blockchains[blockchain]?.feeCoin ?? Token.ETHEREUM;
      observableGasToken.value = gasToken;

      final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(token, currencyType);
      observableTokenPrice.value = tokenPrice?.price ?? 0;

      final gasTokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(observableGasToken.value, currencyType);
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

  Future<String> processTransfer(Token token,
      Blockchain blockchain,
      String sender,
      String receiver,
      BigInt amount,
    {
      double? fiat,
      CurrencyType? currencyType,
    }
  ) async {
    view.onSending();
    Vibration.vibrate(duration: 100);
    final response = await _sendP2pTokenUseCase.send(token, blockchain, sender, receiver, amount);
    await _saveTransactionUseCase.run(
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
    view.finishSending();
    return response.transactionHash;
  }
}