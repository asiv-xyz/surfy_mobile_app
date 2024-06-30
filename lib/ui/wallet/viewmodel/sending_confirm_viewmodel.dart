import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/ui/wallet/sending_confirm_view.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:vibration/vibration.dart';

class SendingConfirmViewModel {
  late SendingConfirmPageInterface view;

  final SendP2pToken _sendP2pTokenUseCase = Get.find();
  final Rx<BigInt> observableGas = BigInt.zero.obs;
  final Rx<Token> observableGasToken = Rx(Token.ETHEREUM);
  final sessionTime = DateTime.now().millisecondsSinceEpoch;

  void setView(SendingConfirmPageInterface view) {
    this.view = view;
  }

  Future<void> init(Token token, Blockchain blockchain, String receiver, BigInt amount) async {
    view.onLoading();
    try {
      final gas = await _sendP2pTokenUseCase.estimateGas(token, blockchain, receiver, amount);
      observableGas.value = gas;
      final feeCoin = blockchains[blockchain]?.feeCoin;
      if (feeCoin == null) {
        throw Exception();
      }
      observableGasToken.value = feeCoin;
    } catch (e) {
      observableGas.value = BigInt.zero;
    }
    view.offLoading();
  }

  Future<String> processTransfer(Token token, Blockchain blockchain, String sender, String receiver, BigInt amount) async {
    view.onSending();
    Vibration.vibrate(duration: 100);
    final response = await _sendP2pTokenUseCase.send(token, blockchain, sender, receiver, amount);
    view.offSending();
    return response.transactionHash;
  }
}